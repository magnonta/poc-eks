# Terraform PoC

This Terraform configuration sets up cloud resources using a reusable module. The module is designed to be flexible and customizable, allowing you to specify different configurations based on the environment (e.g., `dev`, `prod`) and region (e.g., `us-east-1`).

## Overview

The provided Terraform code is structured to deploy an EKS cluster using a pre-defined module located at `../../modules/eks`. The module is configured with several parameters that dictate how the cluster and its associated resources are deployed. The configuration uses local variables and YAML files to manage environment-specific settings.

## How It Works

### 1. Module Configuration
- The main configuration block is a Terraform module that is sourced from `../../modules/eks`.
- The module is provided with various inputs such as the cluster name, instance types, node group names, scaling configuration, and IAM roles/policies.
- The inputs for the module are dynamically constructed using local variables and data from environment-specific YAML files.

### 2. Local Variables
- **`env`**: This local variable extracts environment-specific data (e.g., `dev`, `prod`) from the `environments` map based on the selected `var.environment` and `var.region`.
- **`testing_us_east_1_yaml`**: This local variable reads a YAML file containing configurations specific to the `testing` environment in the `us-east-1` region.
- **`environments`**: This map contains the environment and region-specific data decoded from YAML files. It is used to pass environment-specific configurations to the module.

### 3. Environment and Region Configuration
- The `environments` map is populated by decoding YAML files that hold the configuration for each environment and region.
- For example, the `dev` environment's configuration for the `us-east-1` region is stored in `test-us-east-1.yaml`. The contents of this YAML file are decoded and used as inputs to the EKS module.

