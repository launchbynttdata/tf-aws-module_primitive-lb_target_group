// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package testimpl

import (
	"context"
	"os"
	"strconv"
	"strings"
	"testing"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	elbv2 "github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2"
	"github.com/aws/aws-sdk-go-v2/service/elasticloadbalancingv2/types"
	"github.com/gruntwork-io/terratest/modules/terraform"
	terratesttypes "github.com/launchbynttdata/lcaf-component-terratest/types"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func newELBv2Client(t *testing.T) *elbv2.Client {
	t.Helper()

	region := os.Getenv("AWS_DEFAULT_REGION")
	if region == "" {
		region = os.Getenv("AWS_REGION")
	}
	if region == "" {
		region = "us-east-2"
	}

	cfg, err := config.LoadDefaultConfig(context.Background(), config.WithRegion(region))
	require.NoError(t, err, "loading AWS SDK config")
	return elbv2.NewFromConfig(cfg)
}

func describeTargetGroup(t *testing.T, client *elbv2.Client, arn string) types.TargetGroup {
	t.Helper()

	out, err := client.DescribeTargetGroups(context.Background(), &elbv2.DescribeTargetGroupsInput{
		TargetGroupArns: []string{arn},
	})
	require.NoError(t, err, "DescribeTargetGroups")
	require.Len(t, out.TargetGroups, 1, "expected exactly one target group")
	return out.TargetGroups[0]
}

func attributeValue(attrs []types.TargetGroupAttribute, key string) (string, bool) {
	for _, a := range attrs {
		if aws.ToString(a.Key) == key {
			return aws.ToString(a.Value), true
		}
	}
	return "", false
}

// assertCommonTargetGroupState performs the read-only assertions shared by both the
// functional and readonly test variants.
func assertCommonTargetGroupState(t *testing.T, ctx terratesttypes.TestContext) {
	tfOpts := ctx.TerratestTerraformOptions()

	id := terraform.Output(t, tfOpts, "id")
	assert.NotEmpty(t, id, "id should be set")
	assert.True(t, strings.HasPrefix(id, "arn:aws:elasticloadbalancing:"), "id should be an ELBv2 ARN")

	arn := terraform.Output(t, tfOpts, "arn")
	assert.Equal(t, id, arn, "id and arn should be identical for aws_lb_target_group")

	arnSuffix := terraform.Output(t, tfOpts, "arn_suffix")
	assert.True(t, strings.HasPrefix(arnSuffix, "targetgroup/"), "arn_suffix should start with targetgroup/")

	tgName := terraform.Output(t, tfOpts, "name")
	assert.NotEmpty(t, tgName, "name should be set")
	assert.LessOrEqual(t, len(tgName), 32, "target group name must not exceed 32 characters")

	vpcID := terraform.Output(t, tfOpts, "vpc_id")
	assert.NotEmpty(t, vpcID, "vpc_id should be set")

	client := newELBv2Client(t)
	tg := describeTargetGroup(t, client, arn)

	assert.Equal(t, tgName, aws.ToString(tg.TargetGroupName), "target group name should match")
	assert.Equal(t, vpcID, aws.ToString(tg.VpcId), "target group should be in the example VPC")
	assert.Equal(t, types.TargetTypeEnumIp, tg.TargetType, "target_type should be ip")
	assert.Equal(t, types.ProtocolEnumHttps, tg.Protocol, "protocol should be HTTPS")
	assert.Equal(t, int32(443), aws.ToInt32(tg.Port), "port should be 443")
	assert.Equal(t, "HTTP1", aws.ToString(tg.ProtocolVersion), "protocol_version should be HTTP1")
	assert.Equal(t, types.TargetGroupIpAddressTypeEnumIpv4, tg.IpAddressType, "ip_address_type should be ipv4")

	require.NotNil(t, tg.HealthCheckEnabled, "health check enabled flag must be present")
	assert.True(t, aws.ToBool(tg.HealthCheckEnabled), "health checks should be enabled")
	assert.Equal(t, types.ProtocolEnumHttps, tg.HealthCheckProtocol, "health check protocol should be HTTPS")
	assert.Equal(t, "traffic-port", aws.ToString(tg.HealthCheckPort), "health check port should be traffic-port")
	assert.Equal(t, "/", aws.ToString(tg.HealthCheckPath), "health check path should be /")
	assert.Equal(t, int32(30), aws.ToInt32(tg.HealthCheckIntervalSeconds), "health check interval should be 30s")
	assert.Equal(t, int32(10), aws.ToInt32(tg.HealthCheckTimeoutSeconds), "health check timeout should be 10s")
	assert.Equal(t, int32(3), aws.ToInt32(tg.HealthyThresholdCount), "healthy_threshold should be 3")
	assert.Equal(t, int32(3), aws.ToInt32(tg.UnhealthyThresholdCount), "unhealthy_threshold should be 3")
	require.NotNil(t, tg.Matcher, "matcher should be set on HTTP health checks")
	assert.Equal(t, "200-299", aws.ToString(tg.Matcher.HttpCode), "matcher should be 200-299")

	attrsOut, err := client.DescribeTargetGroupAttributes(context.Background(), &elbv2.DescribeTargetGroupAttributesInput{
		TargetGroupArn: aws.String(arn),
	})
	require.NoError(t, err, "DescribeTargetGroupAttributes")

	dereg, ok := attributeValue(attrsOut.Attributes, "deregistration_delay.timeout_seconds")
	require.True(t, ok, "deregistration_delay.timeout_seconds attribute must be present")
	assert.Equal(t, "60", dereg, "deregistration_delay should match the configured value")

	stickinessEnabled, ok := attributeValue(attrsOut.Attributes, "stickiness.enabled")
	require.True(t, ok, "stickiness.enabled attribute must be present")
	assert.Equal(t, "true", stickinessEnabled, "stickiness should be enabled")

	stickinessType, ok := attributeValue(attrsOut.Attributes, "stickiness.type")
	require.True(t, ok, "stickiness.type attribute must be present")
	assert.Equal(t, "lb_cookie", stickinessType, "stickiness type should be lb_cookie")

	stickinessDuration, ok := attributeValue(attrsOut.Attributes, "stickiness.lb_cookie.duration_seconds")
	require.True(t, ok, "stickiness.lb_cookie.duration_seconds attribute must be present")
	assert.Equal(t, "3600", stickinessDuration, "stickiness duration should be 3600s")

	algo, ok := attributeValue(attrsOut.Attributes, "load_balancing.algorithm.type")
	require.True(t, ok, "load_balancing.algorithm.type attribute must be present")
	assert.Equal(t, "round_robin", algo, "load_balancing.algorithm.type should be round_robin")

	dnsCount, ok := attributeValue(attrsOut.Attributes, "target_group_health.dns_failover.minimum_healthy_targets.count")
	require.True(t, ok, "target_group_health.dns_failover.minimum_healthy_targets.count attribute must be present")
	assert.Equal(t, "1", dnsCount, "dns_failover minimum_healthy_targets_count should be 1")

	routingCount, ok := attributeValue(attrsOut.Attributes, "target_group_health.unhealthy_state_routing.minimum_healthy_targets.count")
	require.True(t, ok, "target_group_health.unhealthy_state_routing.minimum_healthy_targets.count attribute must be present")
	assert.Equal(t, "1", routingCount, "unhealthy_state_routing minimum_healthy_targets_count should be 1")
}

// TestComposableComplete is the functional test entry point. It performs the
// shared read-only assertions and additionally exercises the target group via a
// write operation (ModifyTargetGroupAttributes), which it then reverts.
func TestComposableComplete(t *testing.T, ctx terratesttypes.TestContext) {
	t.Run("StaticConfigurationMatchesModuleInputs", func(t *testing.T) {
		assertCommonTargetGroupState(t, ctx)
	})

	t.Run("ModifyTargetGroupAttributesIsAccepted", func(t *testing.T) {
		tfOpts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, tfOpts, "arn")
		require.NotEmpty(t, arn, "arn output is required for the functional write test")

		client := newELBv2Client(t)

		const updatedDelay = "120"

		_, err := client.ModifyTargetGroupAttributes(context.Background(), &elbv2.ModifyTargetGroupAttributesInput{
			TargetGroupArn: aws.String(arn),
			Attributes: []types.TargetGroupAttribute{
				{
					Key:   aws.String("deregistration_delay.timeout_seconds"),
					Value: aws.String(updatedDelay),
				},
			},
		})
		require.NoError(t, err, "ModifyTargetGroupAttributes should succeed against the deployed target group")

		out, err := client.DescribeTargetGroupAttributes(context.Background(), &elbv2.DescribeTargetGroupAttributesInput{
			TargetGroupArn: aws.String(arn),
		})
		require.NoError(t, err, "DescribeTargetGroupAttributes after modification")
		actual, ok := attributeValue(out.Attributes, "deregistration_delay.timeout_seconds")
		require.True(t, ok, "deregistration_delay.timeout_seconds must be present after ModifyTargetGroupAttributes")
		assert.Equal(t, updatedDelay, actual, "deregistration_delay should reflect the modification")

		// Revert so a subsequent terraform plan/apply does not see drift.
		original := strconv.Itoa(60)
		_, err = client.ModifyTargetGroupAttributes(context.Background(), &elbv2.ModifyTargetGroupAttributesInput{
			TargetGroupArn: aws.String(arn),
			Attributes: []types.TargetGroupAttribute{
				{
					Key:   aws.String("deregistration_delay.timeout_seconds"),
					Value: aws.String(original),
				},
			},
		})
		require.NoError(t, err, "reverting deregistration_delay should succeed")
	})
}

// TestComposableCompleteReadonly is the read-only test entry point. It only
// performs read assertions against the deployed target group and never mutates
// remote state.
func TestComposableCompleteReadonly(t *testing.T, ctx terratesttypes.TestContext) {
	t.Run("DeployedTargetGroupMatchesExpectedConfiguration", func(t *testing.T) {
		assertCommonTargetGroupState(t, ctx)
	})

	t.Run("DescribeTargetHealthIsAvailable", func(t *testing.T) {
		tfOpts := ctx.TerratestTerraformOptions()
		arn := terraform.Output(t, tfOpts, "arn")
		require.NotEmpty(t, arn, "arn output is required for the readonly health check")

		client := newELBv2Client(t)
		out, err := client.DescribeTargetHealth(context.Background(), &elbv2.DescribeTargetHealthInput{
			TargetGroupArn: aws.String(arn),
		})
		require.NoError(t, err, "DescribeTargetHealth should succeed for the deployed target group")
		assert.NotNil(t, out, "DescribeTargetHealth output must not be nil")
	})
}
