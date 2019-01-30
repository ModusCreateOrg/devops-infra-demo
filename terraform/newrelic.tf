# Configure the New Relic provider

# Adapted from https://www.terraform.io/docs/providers/newrelic/index.html

provider "newrelic" {
  api_key = "${var.newrelic_api_key}"
  version = "~> 1.2"
}

# Create an alert policy
resource "newrelic_alert_policy" "alert" {
  name = "Alert"
}

# Add a condition
resource "newrelic_alert_condition" "spin-appdex" {
  policy_id = "${newrelic_alert_policy.alert.id}"

  name        = "spin-appdex"
  type        = "apm_app_metric"
  entities    = "${var.newrelic_apm_entities}"
  metric      = "apdex"
  runbook_url = "${var.newrelic_runbook_url}"

  term {
    duration      = 5
    operator      = "below"
    priority      = "critical"
    threshold     = "0.75"
    time_function = "all"
  }

  condition_scope = "application"

  count = "${length(var.newrelic_apm_entities) > 0 ? 1 : 0}"
}

# Add a notification channel
resource "newrelic_alert_channel" "email" {
  name = "email"
  type = "email"

  configuration = {
    recipients              = "richard+devops.infra.demo@moduscreate.com"
    include_json_attachment = "1"
  }

  count = "${length(var.newrelic_alert_email) > 0 ? 1 : 0}"
}

# Link the channel to the policy
resource "newrelic_alert_policy_channel" "alert_email" {
  policy_id  = "${newrelic_alert_policy.alert.id}"
  channel_id = "${newrelic_alert_channel.email.id}"

  count = "${length(var.newrelic_alert_email) > 0 ? 1 : 0}"
}

# Add a dashboard
resource "newrelic_dashboard" "spindash" {
  title = "Spin Dashboard"

  widget {
    title         = "Average Transaction Duration"
    row           = 1
    column        = 1
    width         = 2
    visualization = "faceted_line_chart"
    nrql          = "SELECT AVERAGE(duration) from Transaction FACET appName TIMESERIES auto"
  }

  widget {
    title         = "Average Apdex 1"
    row           = 2
    column        = 1
    width         = 2
    visualization = "faceted_line_chart"
    nrql          = "SELECT apdex(duration, 0.5) FROM Transaction SINCE 3 HOURS AGO COMPARE WITH 6 HOURS AGO TIMESERIES"
  }

  widget {
    title         = "Average Apdex 2"
    row           = 3
    column        = 1
    width         = 2
    visualization = "faceted_line_chart"
    nrql          = "SELECT apdex(duration, t: 0.4) from Transaction FACET appName TIMESERIES auto"
  }

  widget {
    title         = "Average CPU Percent"
    row           = 4
    column        = 1
    width         = 2
    visualization = "faceted_line_chart"
    nrql          = "SELECT average(cpuPercent) FROM SystemSample SINCE 1 HOUR AGO COMPARE WITH 3 HOUR AGO TIMESERIES"
  }

#  widget {
#    title         = "Page Views"
#    row           = 1
#    column        = 3
#    visualization = "billboard"
#    nrql          = "SELECT count(*) FROM PageView SINCE 1 week ago"
#  }
}
