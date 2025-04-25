# AWS Classic Load Balancer with EC2 Instances

This Terraform project deploys a highly available web infrastructure on AWS using Classic Load Balancer (ELB) and multiple EC2 instances running Amazon Linux 2.

## Architecture

The infrastructure consists of:
- Multiple EC2 instances running Amazon Linux 2 (configurable count)
- A Classic Load Balancer for distributing traffic
- Security groups for both EC2 instances and the load balancer
- Automatically generated SSH key pair for instance access

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform installed (version 1.5.7 or later)
- Basic understanding of AWS services (EC2, ELB, VPC)

### AWS Configuration

1. Install AWS CLI:
   ```
   # For macOS (using Homebrew)
   brew install awscli

   # For Linux
   curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
   unzip awscliv2.zip
   sudo ./aws/install
   ```

2. Configure AWS credentials using one of these methods:

   a. Using AWS CLI (Recommended for local development):
   ```
   aws configure
   ```
   You will be prompted to enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name (e.g., ap-south-1)
   - Default output format (json)

   b. Using Environment Variables:
   ```
   export AWS_ACCESS_KEY_ID="your_access_key"
   export AWS_SECRET_ACCESS_KEY="your_secret_key"
   export AWS_DEFAULT_REGION="ap-south-1"
   ```

   c. Using AWS credentials file:
   Create or edit ~/.aws/credentials:
   ```
   [default]
   aws_access_key_id = your_access_key
   aws_secret_access_key = your_secret_key
   ```

3. Verify AWS configuration:
   ```
   aws sts get-caller-identity
   ```

## Configuration

### Variables

The following variables can be configured in `variables.tf`:

- `aws_region`: AWS region for deploying resources (default: ap-south-1)
- `instance_type`: EC2 instance type (default: t2.micro)
- `key_name`: Name of the EC2 key pair (default: web-server-key)
- `instance_count`: Number of EC2 instances to create (default: 2)

### Security Groups

1. EC2 Security Group:
   - Inbound: 
     - HTTP (80) from anywhere
     - SSH (22) from anywhere
   - Outbound: All traffic allowed

2. Load Balancer Security Group:
   - Inbound: HTTP (80) from anywhere
   - Outbound: All traffic allowed

### EC2 Instances

- OS: Amazon Linux 2
- Auto-assigns public IP
- Uses user data script to install and configure Apache web server
- Distributed across available AZs in the region

## Outputs

The infrastructure provides the following outputs:

- `instance_public_ips`: Public IP addresses of the EC2 instances
- `ssh_connection_strings`: Ready-to-use SSH connection strings for each instance
- `load_balancer_dns`: DNS name of the Classic Load Balancer

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the execution plan:
   ```
   terraform plan
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

4. After successful deployment, you can access:
   - Web application through the Load Balancer DNS
   - Individual instances via SSH using the generated key pair

5. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Notes

- The EC2 instances run a simple Apache web server (installed via user data)
- Instances are automatically registered with the load balancer
- The infrastructure uses the default VPC in the specified region
- SSH key pair is automatically generated and saved locally

## Best Practices

- Regularly update the Amazon Linux 2 AMI to get the latest security patches
- Consider enabling detailed monitoring for production environments
- Review security group rules periodically
- Backup any important data stored on EC2 instances
- Use proper key pair management in production environments