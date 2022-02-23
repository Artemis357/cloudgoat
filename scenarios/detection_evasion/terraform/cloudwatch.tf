resource "aws_cloudwatch_log_group" "honeytoken_logs" {
  name = "honeytoken_logs"
}

// Resources for detecting/alerting on honeytokens
resource "aws_cloudwatch_log_metric_filter" "honeytoken_is_used" {
  name           = "honeytoken_is_used"
  pattern        = "{ $.userIdentity.arn = \"${aws_iam_user.spacesiren_user.arn}\" || $.userIdentity.arn = \"${aws_iam_user.canarytoken_user.arn}\" || $.userIdentity.arn = \"${aws_iam_user.spacecrab_user.arn}\" }"
  log_group_name = "${aws_cloudwatch_log_group.honeytoken_logs.name}"

  metric_transformation {
    name      = "honeytoken_is_used"
    namespace = "cloudgoat_detection_evasion"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "honeytoken_alarm" {
  alarm_name                = "honeytoken_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "honeytoken_is_used"
  namespace                 = "cloudgoat_detection_evasion"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Alerts on the usage of honeytokens"
  insufficient_data_actions = []
  actions_enabled = "true"
  alarm_actions = ["arn:aws:sns:us-east-1:${data.aws_caller_identity.aws-account-id.account_id}:phase1"]
}

// resources for detecting/alerting on abnormal instance_profile usage
resource "aws_cloudwatch_log_metric_filter" "instance_profile_abnormal_usage" {
  name           = "instance_profile_abnormal_usage"
  pattern        = "{ ($.sourceIPAddress != \"${aws_instance.instance_1.public_ip}\") && ($.userIdentity.arn = \"arn:aws:sts::${data.aws_caller_identity.aws-account-id.account_id}:assumed-role/aws:ec2-instance/${aws_instance.instance_1.id}\") }"
  log_group_name = "${aws_cloudwatch_log_group.honeytoken_logs.name}"

  metric_transformation {
    name      = "instance_profile_abnormal_usage"
    namespace = "cloudgoat_detection_evasion"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "instance_profile_alarm" {
  alarm_name                = "instance_profile_alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "instance_profile_abnormal_usage"
  namespace                 = "cloudgoat_detection_evasion"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Alarms on the usage of instance_profile credentials from an IP other than that of the ec2 instance associated with the profile."
  insufficient_data_actions = []
  actions_enabled = "true"
  alarm_actions = ["arn:aws:sns:us-east-1:${data.aws_caller_identity.aws-account-id.account_id}:phase2"]
}