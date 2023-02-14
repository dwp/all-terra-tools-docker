# All Terra Tools

## Overview
This GitHub repo is used to build the container we are using to build
our Terraform modules and Terragrunt deployments.

The image is based on Ubuntu:20.04_stable.

## Main Tools provided by this image

| Name                 | Version |
| -------------------- |---------|
| Terraform            | 1.0.11 |
| Terraform Compliance | 1.3.40  |
| Terragrunt           | 0.43.2  |
| GO                   | 1.20   |
| Terraform Docs       | 0.16.0  |
| Tflint               | 0.45.0  |
| Tfmask               | 0.70    |

## Local Build image

It is possible to build the image.(Currently broken on DWP Laptops.)

```
# ./run.sh
```
