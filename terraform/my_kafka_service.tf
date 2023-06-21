terraform {
  required_providers {
    aiven = {
      source = "aiven/aiven"
      version = ">= 4.0.0, < 5.0.0"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_api_token
}

################### kafka service, topic and user ###################

resource "aiven_kafka" "kafka1" {
  project                 = var.aiven_project
  cloud_name              = var.aiven_region
  plan                    = "startup-2"
  service_name            = "my-kafka-service"
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"

  kafka_user_config {
    kafka_rest      = true
    kafka_connect   = false
    schema_registry = true
    kafka_version   = "3.4"

    kafka {
      group_max_session_timeout_ms = 70000
      log_retention_bytes          = 1000000000
    }

    public_access {
      kafka_rest    = true
      kafka_connect = true
    }
  }
}

resource "aiven_kafka_topic" "mytesttopic" {
  project                = var.aiven_project
  service_name           = aiven_kafka.kafka1.service_name
  topic_name             = "mytopic"
  partitions             = 5
  replication            = 3
  termination_protection = true

  config {
    flush_ms                       = 10
    cleanup_policy                 = "compact,delete"
  }

  timeouts {
    create = "1m"
    read   = "5m"
  }
}

resource "aiven_kafka_user" "demo" {
  service_name = aiven_kafka.kafka1.service_name
  project      = var.aiven_project
  username     = "demoapp"
  password     = "demo1234"
}

resource "aiven_kafka_acl" "demoacl" {
  project      = var.aiven_project
  service_name = aiven_kafka.kafka1.service_name
  topic        = aiven_kafka_topic.mytesttopic.topic_name
  permission   = "admin"
  username     = aiven_kafka_user.demo.username
}

################### observability and monitoring ###################


resource "aiven_influxdb" "inf1" {
  project                 = var.aiven_project
  cloud_name              = var.aiven_region
  plan                    = "startup-4"
  service_name            = "my-influxdb"
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"

  influxdb_user_config {
    public_access {
      influxdb = true
    }
  }
}

resource "aiven_service_integration" "my_integration_metrics" {
  project                  = var.aiven_project
  integration_type         = "metrics"
  source_service_name      = aiven_kafka.kafka1.service_name
  destination_service_name = aiven_influxdb.inf1.service_name
}

resource "aiven_grafana" "gr1" {
  project                 = var.aiven_project
  cloud_name              = var.aiven_region
  plan                    = "startup-1"
  service_name            = "my-grafana"
  maintenance_window_dow  = "sunday"
  maintenance_window_time = "10:00:00"

  grafana_user_config {
    alerting_enabled = true

    public_access {
      grafana = true
    }
  }
}

resource "aiven_service_integration" "my_integration_dashboard" {
  project                  = var.aiven_project
  integration_type         = "dashboard"
  source_service_name      = aiven_grafana.gr1.service_name
  destination_service_name = aiven_influxdb.inf1.service_name
}