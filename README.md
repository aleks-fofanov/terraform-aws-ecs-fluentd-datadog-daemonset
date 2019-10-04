<!-- This file was automatically generated by the `build-harness`. Make all changes to `README.yaml` and run `make readme` to rebuild this file. -->

# terraform-aws-ecs-fluentd-datadog-daemonset

 [![Build Status](https://travis-ci.org/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset.svg?branch=master)](https://travis-ci.org/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset) [![Latest Release](https://img.shields.io/github/release/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset.svg)](https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset/releases/latest)


Terraform module to provision ECS service configured to collect logs from containers scheduled on EC2 container
instances and ship them to Datadog.


---


It's 100% Open Source and licensed under the [APACHE2](LICENSE).









## Introduction

This module helps to provision Fluentd ECS service scheduled on every ECS container instances (EC2) as a daemon and
configured to ship logs to Datadog.

**Why this project**:
Installing Datadog agent on each node in your ECS cluster may not be an option for some users
as this can be expensive depending on the number of nodes in the cluster.

**Implementation notes and Warnings**:
- Don't forget to pass `Datadog API key` via env variables or secrets (recommended)
- Pefix your containers log tags with `docker.`, otherwise logs won't be processed, for example:
  ```json
  "logConfiguration": {
      "logDriver": "fluentd",
      "options": {
          "fluentd-address": "127.0.0.1:24224",
          "tag": "docker.backend-app"
      }
  }
  ```

This module is backed by best of breed terraform modules maintained by [Cloudposse](https://github.com/cloudposse).

## Usage


**IMPORTANT:** The `master` branch is used in `source` just as an example. In your code, do not pin to `master` because there may be breaking changes between releases.
Instead pin to the release tag (e.g. `?ref=tags/x.y.z`) of one of our [latest releases](https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset/releases).


This is a simple example of how to create an ECS cluster service scheduled with daemon scheduling strategy:

```hcl
module "fluentd_datadog_logs_aggregator" {
  source    = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset?ref=master"
  name      = "fluentd"
  namespace = "cp"
  stage     = "prod"

  ecs_cluster_arn = "XXXXXXXXXXX"
}
```




## Examples

### Full example
This example provisions:
- Fluentd ECS cluster log aggregator
- Cloudwatch log group for storing fluentd containers' logs
- Encrypted SSM Parameter for storing Datadog API key
- Additional policy that allows ECS agent access encrypted SSM parameter when creating fluentd containers
  and attaches it to fluentd service execution role
```hcl
module "fluentd_datadog_logs_aggregator" {
  source    = "git::https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset?ref=master"
  name      = "fluentd"
  namespace = "cp"
  stage     = "prod"

  ecs_cluster_arn         = "XXXXXXXXXXX"
  task_cpu                = "256"
  task_memory             = "512"
  task_memory_reservation = "512"

  log_driver  = "awslogs"
  log_options = {
    "awslogs-region"        = "us-west-2"
    "awslogs-group"         = "${aws_cloudwatch_log_group.fluentd.name}"
    "awslogs-stream-prefix" = "fluentd"
  }

  secrets = [
    {
      name      = "DD_API_KEY",
      valueFrom = "${aws_ssm_parameter.datadog_api_key.arn}"
    }
  ]
}

data "aws_iam_policy_document" "fluentd" {
  statement {
    sid    = "SSMParameterStoreAccess"
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
      "kms:Decrypt"
    ]
    resources = [
      "${data.aws_kms_key.aws_ssm.arn}",
      "${aws_ssm_parameter.datadog_api_key.arn}"
    ]
  }
}

resource "aws_iam_policy" "fluentd_ecs_exec_role_additions" {
  name   = "fluentd"
  policy = "${data.aws_iam_policy_document.fluentd.json}"
}

resource "aws_iam_role_policy_attachment" "fluentd_ecs_exec_role_additions" {
  role       = "${module.fluentd_datadog_logs_aggregator.task_exec_role_name}"
  policy_arn = "${aws_iam_policy.fluentd_ecs_exec_role_additions.arn}"
}

resource "aws_cloudwatch_log_group" "fluentd" {
  name = "ECS/fluentd-daemonset"
}

resource "aws_ssm_parameter" "datadog_api_key" {
  name        = "/some/path/DD_API_KEY"
  type        = "SecureString"
  value       = "XXXXXXXXXXX"
  overwrite   = "true"
  description = "Datadog API key"

  key_id = "XXXXXXXXXXX"
}
```



## Makefile Targets
```
Available targets:

  help                                Help screen
  help/all                            Display help for all targets
  help/short                          This help short screen
  lint                                Lint terraform code

```
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




## Related Projects

Check out these related projects.

- [terraform-aws-ecs-service-task-daemonset](https://github.com/aleks-fofanov/terraform-aws-ecs-service-task-daemonset) - Terraform module to provision ECS service with daemon scheduling strategy
- [terraform-aws-ecs-cluster-traefik](https://github.com/aleks-fofanov/terraform-aws-ecs-cluster-traefik) - Terraform module to provision ECS cluster with Traefik as an edge router
- [ecs-datadog-logs-aggregator](https://github.com/aleks-fofanov/ecs-datadog-logs-aggregator) - Customized Fluentd image configured to be deployed AWS ECS cluster and ship containers logs to Datadog



## Help

**Got a question?**

File a GitHub [issue](https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset/issues).


## Contributing

### Bug Reports & Feature Requests

Please use the [issue tracker](https://github.com/aleks-fofanov/terraform-aws-ecs-fluentd-datadog-daemonset/issues) to report any bugs or file feature requests.

### Developing

In general, PRs are welcome. We follow the typical "fork-and-pull" Git workflow.

 1. **Fork** the repo on GitHub
 2. **Clone** the project to your own machine
 3. **Commit** changes to your own branch
 4. **Push** your work back up to your fork
 5. Submit a **Pull Request** so that we can review your changes

**NOTE:** Be sure to merge the latest changes from "upstream" before making a pull request!


## Copyright

Copyright © 2017-2019 Aleksandr Fofanov



## License 

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0) 

See [LICENSE](LICENSE) for full details.

    Licensed to the Apache Software Foundation (ASF) under one
    or more contributor license agreements.  See the NOTICE file
    distributed with this work for additional information
    regarding copyright ownership.  The ASF licenses this file
    to you under the Apache License, Version 2.0 (the
    "License"); you may not use this file except in compliance
    with the License.  You may obtain a copy of the License at

      https://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing,
    software distributed under the License is distributed on an
    "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
    KIND, either express or implied.  See the License for the
    specific language governing permissions and limitations
    under the License.








## Trademarks

All other trademarks referenced herein are the property of their respective owners.


### Contributors

|  [![Aleksandr Fofanov][aleks-fofanov_avatar]][aleks-fofanov_homepage]<br/>[Aleksandr Fofanov][aleks-fofanov_homepage] |
|---|

  [aleks-fofanov_homepage]: https://github.com/aleks-fofanov
  [aleks-fofanov_avatar]: https://github.com/aleks-fofanov.png?size=150



