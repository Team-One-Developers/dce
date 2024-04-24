# Creates SES email entry
resource "aws_ses_email_identity" "from_email_address" {
  email = var.budget_notification_from_email
}

# Allow budget notifications to be send to our BCC email addresses from the DCE account
resource "aws_ses_email_identity" "bcc_email_address" {
  for_each = var.budget_notification_bcc_emails
  
  email = each.value
}

# Send delivery failures and bounces to SNS topic
resource "aws_ses_configuration_set" "ses" {
  name = "dce_ses_${var.namespace}"
}

resource "aws_ses_event_destination" "ses_to_cloudwatch" {
  name                   = "event-destination-cloudwatch-${var.namespace}"
  configuration_set_name = aws_ses_configuration_set.ses.name
  enabled                = true

  matching_types = [
    "bounce",
    "reject",
    "complaint",
    "renderingFailure",
  ]

  cloudwatch_destination {
    default_value  = "Failed_Send"
    dimension_name = "RB_SES_FAILURE"
    value_source   = "emailHeader"
  }
}
