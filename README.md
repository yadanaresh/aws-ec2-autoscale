# aws-ec2-autoscale
# Terraform AWS Infrastructure Setup with EC2 Auto Scaling

This Terraform script automates the setup of AWS infrastructure, including the creation of a VPC, subnets, internet gateway, route table, security groups, load balancers, launch templates, and an auto-scaling group for EC2 instances.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Features](#features)
- [Usage](#usage)
- [Structure](#structure)
- [Why Auto Scaling?](#why-auto-scaling)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

To utilize this Terraform script, ensure you have the following:

- **AWS Account**: Obtain your AWS access key and secret key.
- **Terraform Installed**: [Download and install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) on your local machine.

## Features

This script provisions the following infrastructure on AWS:
- **VPC**: Virtual Private Cloud.
- **Subnets**: Two subnets distributed across different availability zones.
- **Internet Gateway**: To enable internet access for resources within the VPC.
- **Route Table and Routes**: Configured to direct traffic in and out of the VPC.
- **Security Groups**: For controlling inbound and outbound traffic.
- **Load Balancers**: An Application Load Balancer (ALB) to distribute traffic to backend instances.
- **Launch Templates**: A template to launch EC2 instances with specified configurations.
- **Auto-Scaling Group**: Allows the automatic adjustment of EC2 instance capacity based on defined conditions.

## Usage

1. **AWS Credentials**:
   - Ensure you have AWS credentials set up with appropriate permissions.

2. **Terraform Configuration**:
   - Clone this repository.
   - Update the `variables.tf` file with necessary variables or use a `terraform.tfvars` file to set values.

3. **Execution**:
   - Run `terraform init` to initialize the working directory.
   - Execute `terraform plan` to view the proposed changes.
   - Run `terraform apply` to create the infrastructure.

## Structure

The main files and directories in this repository include:
- `main.tf`: Contains the main Terraform configuration for infrastructure setup.
- `variables.tf`: Defines input variables for the Terraform script.
- `user_data_script.sh`: Script used for EC2 instances launched from the template.
- `README.md`: Documentation for the repository.

## Why Auto Scaling?

The Auto Scaling feature in AWS helps maintain application availability and allows for cost optimization by automatically adjusting the number of EC2 instances based on demand. With Auto Scaling, this infrastructure setup ensures that your application can dynamically handle varying loads without manual intervention. The auto-scaling group within this Terraform script enables the scaling of instances up or down based on predefined conditions, ensuring performance and cost-efficiency.

## Contributing

Contributions are welcome! If you find issues or improvements, feel free to open an issue or create a pull request.

## License

This Terraform script is licensed under the [MIT License](LICENSE).

