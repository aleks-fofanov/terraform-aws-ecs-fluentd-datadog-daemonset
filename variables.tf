variable "namespace" {
  type        = "string"
  description = "Namespace, which could be your organization name, e.g. 'eg' or 'cp'"
}

variable "stage" {
  type        = "string"
  description = "Stage, e.g. 'prod', 'staging', 'dev', or 'test'"
}

variable "name" {
  type        = "string"
  description = "Solution name, e.g. 'app' or 'cluster'"
}

variable "delimiter" {
  type        = "string"
  default     = "-"
  description = "Delimiter to be used between `name`, `namespace`, `stage`, etc."
}

variable "attributes" {
  type        = "list"
  default     = []
  description = "Additional attributes (e.g. `1`)"
}

variable "tags" {
  type        = "map"
  default     = {}
  description = "Additional tags (e.g. `map('BusinessUnit`,`XYZ`)"
}

variable "ecs_cluster_arn" {
  type        = "string"
  description = "The ARN of the ECS cluster where service will be provisioned"
}

variable "log_collector_port" {
  type        = "string"
  description = "Log-forwarding port number to be binded to on all hosts to Fluentd container"
  default     = "24224"
}

variable "healthcheck_port" {
  type        = "string"
  description = "Log-forwarding port number to be binded to on all hosts to Fluentd container"
  default     = "9880"
}

variable "container_name" {
  type        = "string"
  description = "The name of the container in task definition"
  default     = "fluentd"
}

variable "container_image" {
  type        = "string"
  description = "fluentd docker image to be used with deployment"
  default     = "aleksfofanov/ecs-datadog-logs-aggregator:0.1.0"
}

variable "task_cpu" {
  description = "The number of CPU units used by the fluentd task."
  default     = 256
}

variable "task_memory" {
  description = "The amount of memory (in MiB) used by the fluentd task."
  default     = 512
}

variable "task_memory_reservation" {
  type        = "string"
  description = "The amount of RAM (Soft Limit) to allow fluentd container to use in MB. This value must be less than container_memory if set"
  default     = "128"
}

variable "entrypoint" {
  type        = "list"
  description = "The entry point that is passed to the container"
  default     = [""]
}

variable "command" {
  type        = "list"
  description = "The command that is passed to the container"
  default     = [""]
}

variable "working_directory" {
  type        = "string"
  description = "The working directory to run commands inside the container"
  default     = ""
}

variable "environment" {
  type        = "list"
  description = "The environment variables to pass to the container. This is a list of maps"
  default     = []
}

variable "secrets" {
  type        = "list"
  description = "The secrets to pass to the container. This is a list of maps"
  default     = []
}

variable "log_driver" {
  type        = "string"
  description = "The log driver to use for the container."
  default     = "awslogs"
}

variable "log_options" {
  type        = "map"
  description = "The configuration options to send to the `log_driver`"

  default = {
    "awslogs-region"        = "us-west-2"
    "awslogs-group"         = "default"
    "awslogs-stream-prefix" = "fluentd"
  }
}

variable "volumes" {
  type        = "list"
  description = "Task volume definitions as list of maps"
  default     = []
}

variable "mount_points" {
  type        = "list"
  description = "Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume`"
  default     = []

  #default     = [
  #  {
  #    containerPath  = "/tmp"
  #    sourceVolume = "test-volume"
  #  }
  #]
}

variable "healthcheck" {
  type        = "map"
  description = "A map containing command (string), interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy, and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries)"

  default = {
    command = [
      "CMD-SHELL",
      "curl http://0.0.0.0:9880/fluentd.healthcheck?json=%7B%22log%22%3A+%22health+check%22%7D || exit 1",
    ]

    startPeriod = "20"
    retries     = "3"
  }
}

variable "dns_servers" {
  type        = "list"
  description = "Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers."
  default     = []
}

variable "ulimits" {
  type        = "list"
  description = "Container ulimit settings. This is a list of maps, where each map should contain \"name\", \"hardLimit\" and \"softLimit\""
  default     = []
}

variable "repository_credentials" {
  type        = "map"
  description = "Container repository credentials; required when using a private repo.  This map currently supports a single key; \"credentialsParameter\", which should be the ARN of a Secrets Manager's secret holding the credentials"
  default     = {}
}

variable "stop_timeout" {
  description = "Timeout in seconds between sending SIGTERM and SIGKILL to container"
  default     = 30
}

variable "ignore_changes_task_definition" {
  type        = "string"
  description = "Whether to ignore changes in container definition and task definition in the ECS service"
  default     = "true"
}
