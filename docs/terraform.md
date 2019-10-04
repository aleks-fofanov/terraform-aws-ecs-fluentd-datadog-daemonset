## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| attributes | Additional attributes (e.g. `1`) | list | `<list>` | no |
| command | The command that is passed to the container | list | `<list>` | no |
| container_image | fluentd docker image to be used with deployment | string | `aleksfofanov/ecs-datadog-logs-aggregator:0.1.0` | no |
| container_name | The name of the container in task definition | string | `fluentd` | no |
| delimiter | Delimiter to be used between `name`, `namespace`, `stage`, etc. | string | `-` | no |
| dns_servers | Container DNS servers. This is a list of strings specifying the IP addresses of the DNS servers. | list | `<list>` | no |
| ecs_cluster_arn | The ARN of the ECS cluster where service will be provisioned | string | - | yes |
| entrypoint | The entry point that is passed to the container | list | `<list>` | no |
| environment | The environment variables to pass to the container. This is a list of maps | list | `<list>` | no |
| healthcheck | A map containing command (string), interval (duration in seconds), retries (1-10, number of times to retry before marking container unhealthy, and startPeriod (0-300, optional grace period to wait, in seconds, before failed healthchecks count toward retries) | map | `<map>` | no |
| healthcheck_port | Log-forwarding port number to be binded to on all hosts to Fluentd container | string | `9880` | no |
| ignore_changes_task_definition | Whether to ignore changes in container definition and task definition in the ECS service | string | `true` | no |
| log_collector_port | Log-forwarding port number to be binded to on all hosts to Fluentd container | string | `24224` | no |
| log_driver | The log driver to use for the container. | string | `awslogs` | no |
| log_options | The configuration options to send to the `log_driver` | map | `<map>` | no |
| mount_points | Container mount points. This is a list of maps, where each map should contain a `containerPath` and `sourceVolume` | list | `<list>` | no |
| name | Solution name, e.g. 'app' or 'cluster' | string | - | yes |
| namespace | Namespace, which could be your organization name, e.g. 'eg' or 'cp' | string | - | yes |
| repository_credentials | Container repository credentials; required when using a private repo.  This map currently supports a single key; "credentialsParameter", which should be the ARN of a Secrets Manager's secret holding the credentials | map | `<map>` | no |
| secrets | The secrets to pass to the container. This is a list of maps | list | `<list>` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | - | yes |
| stop_timeout | Timeout in seconds between sending SIGTERM and SIGKILL to container | string | `30` | no |
| tags | Additional tags (e.g. `map('BusinessUnit`,`XYZ`) | map | `<map>` | no |
| task_cpu | The number of CPU units used by the fluentd task. | string | `256` | no |
| task_memory | The amount of memory (in MiB) used by the fluentd task. | string | `512` | no |
| task_memory_reservation | The amount of RAM (Soft Limit) to allow fluentd container to use in MB. This value must be less than container_memory if set | string | `128` | no |
| ulimits | Container ulimit settings. This is a list of maps, where each map should contain "name", "hardLimit" and "softLimit" | list | `<list>` | no |
| volumes | Task volume definitions as list of maps | list | `<list>` | no |
| working_directory | The working directory to run commands inside the container | string | `` | no |

## Outputs

| Name | Description |
|------|-------------|
| ecs_exec_role_policy_id | The ECS service role policy ID, in the form of role_name:role_policy_name |
| ecs_exec_role_policy_name | ECS service role name |
| service_name | ECS Service name |
| service_role_arn | ECS Service role ARN |
| task_definition_family | ECS task definition family |
| task_definition_revision | ECS task definition revision |
| task_exec_role_arn | ECS Task exec role ARN |
| task_exec_role_name | ECS Task role name |
| task_role_arn | ECS Task role ARN |
| task_role_id | ECS Task role id |
| task_role_name | ECS Task role name |

