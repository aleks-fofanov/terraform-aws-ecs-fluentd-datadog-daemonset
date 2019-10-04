#############################################################
# Providers
#############################################################

provider "aws" {
  version = "~> 2.12"
}

#############################################################
# Task Defenition
#############################################################

module "container_definition" {
  source                       = "git::https://github.com/cloudposse/terraform-aws-ecs-container-definition?ref=tags/0.15.0"
  container_name               = "${var.container_name}"
  container_image              = "${var.container_image}"
  container_cpu                = "${var.task_cpu}"
  container_memory             = "${var.task_memory}"
  container_memory_reservation = "${var.task_memory_reservation}"

  entrypoint        = "${var.entrypoint}"
  command           = "${var.command}"
  working_directory = "${var.working_directory}"
  healthcheck       = "${var.healthcheck}"

  environment = "${var.environment}"
  secrets     = "${var.secrets}"

  port_mappings = [
    {
      containerPort = "${var.log_collector_port}"
      hostPort      = "${var.log_collector_port}"
      protocol      = "udp"
    },
    {
      containerPort = "${var.log_collector_port}"
      hostPort      = "${var.log_collector_port}"
      protocol      = "tcp"
    },
    {
      containerPort = "${var.healthcheck_port}"
      hostPort      = "${var.healthcheck_port}"
      protocol      = "tcp"
    },
  ]

  log_driver  = "${var.log_driver}"
  log_options = "${var.log_options}"

  mount_points           = "${var.mount_points}"
  ulimits                = "${var.ulimits}"
  repository_credentials = "${var.repository_credentials}"
  stop_timeout           = "${var.stop_timeout}"
}

#############################################################
# Service
#############################################################

module "fluentd_daemonset" {
  source     = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-service-task-daemonset?ref=tags/0.3.0"
  attributes = ["${compact(concat(var.attributes, list("fluentd")))}"]
  delimiter  = "${var.delimiter}"
  name       = "${var.name}"
  namespace  = "${var.namespace}"
  stage      = "${var.stage}"
  tags       = "${var.tags}"

  ecs_cluster_arn = "${var.ecs_cluster_arn}"

  container_definition_json = "${module.container_definition.json}"
  container_name            = "${var.container_name}"
  task_cpu                  = "${var.task_cpu}"
  task_memory               = "${var.task_memory}"
  volumes                   = "${var.volumes}"

  ignore_changes_task_definition = "${var.ignore_changes_task_definition}"
}
