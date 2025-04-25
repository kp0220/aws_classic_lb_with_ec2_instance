variable "aws_region" {
  description = "AWS region for creating resources"
  type        = string
  default     = "ap-south-1"  # Mumbai region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Name of the EC2 key pair"
  type        = string
  default     = "web-server-key"
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 2
}