# GitLab Runner All Terra Tools

## Overview
This GitLab repo is used to build the GitLab runner we are using to build
our Terraform modules and Terragrunt deployments.

The image is based on Ubuntu:20.04_stable.

## Requirements for using this repo

* [signed-commits](https://docs.gitlab.com/ee/user/project/repository/gpg_signed_commits/)
* [commitlint](https://commitlint.js.org/#/guides-local-setup)
  * [config](commitlint.config.js)
* [pre-commit](https://pre-commit.com)
  * [config](.pre-commit-config.yaml)

## Adding runner to your pipeline

The following should be added to the top of the pipeline

```yaml
image:
  name: registry.gitlab.com/dwp/data-as-a-service/platform/shared-services/infrastructure/modules/aws/all-terra-tools-docker/main:latest
```
## Code templates from upstream

```yaml
 #.pre
  - project: 'dwp/engineering/pipeline-fragments/fragment-version-check'
    ref: 2-0-0
    file: 'ci-include-fragment-version-check.yml'
  #code-quality
  - project: 'dwp/engineering/pipeline-fragments/gitleaks'
    ref: 2-0-0
    file: 'ci-include-gitleaks.yml'
  - project: 'dwp/engineering/pipeline-fragments/shell-check'
    ref: 3-0-0
    file: 'ci-include-shell-check.yml'
  - project: 'dwp/engineering/pipeline-fragments/todo-checker'
    ref: 2-0-0
    file: 'ci-include-todo-checker.yml'
  - project: 'dwp/engineering/pipeline-fragments/docker-lint'
    ref: 2-1-0
    file: 'ci-include-docker-lint.yml'
```

## Security Templates

The pipeline uses the following GitLab templates.

* Security/License-Scanning.gitlab-ci.yml
* Security/Secret-Detection.gitlab-ci.yml
* Security/Container-Scanning.gitlab-ci.yml

If there are any high or critical vulnerabilities the build will fail and no
images will be pushed into the repo.

## Main Tools provided by this image

| Name                 | Version |
| -------------------- |---------|
| Terraform            | 0.14.11 |
| Terraform Compliance | 1.3.13  |
| Terragrunt           | 0.31.0  |
| GO                   | 1.17.6   |
| Terraform Docs       | 0.14.1  |
| Tflint               | 0.30.0  |
| Tfmask               | 0.70    |

## Scheduled build

This image is built every week on Sunday with the main branch building
an up to date image for consumption by the pipelines.

## Pull image from gitlab registry

```shell
docker login registry.example.com -u <username> -p <token>
docker pull registry.gitlab.com/dwp/data-as-a-service/platform/shared-services/infrastructure/modules/aws/all-terra-tools-docker/<branch>:<tag>
```

## Local Build image

It is possible to build the image.(Currently broken on DWP Laptops.)

```
# ./run.sh
```
