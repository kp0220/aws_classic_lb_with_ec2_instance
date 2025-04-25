# Get Default VPC
data "aws_vpc" "default" {
  default = true
}

# Get available AZs that support t2.micro
data "aws_availability_zones" "available" {
  state = "available"
  filter {
    name   = "zone-type"
    values = ["availability-zone"]
  }
}

# Get Default VPC Subnets in supported AZs
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "availability-zone"
    values = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]] # Using first two AZs
  }
}

# Create a new SSH key pair
resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "ec2-key"
  public_key = tls_private_key.my_key.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content         = tls_private_key.my_key.private_key_pem
  filename        = "${path.module}/ec2-key.pem"
  file_permission = "0400"
}

# Security Group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH from anywhere"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-server-sg"
  }
}

# EC2 Instances
resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = var.instance_type
  key_name      = aws_key_pair.generated_key.key_name
  
  subnet_id                   = element(data.aws_subnets.default.ids, count.index % length(data.aws_subnets.default.ids))
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  user_data = file("user_data.sh")

  tags = {
    Name = "web-server-${count.index + 1}"
  }
}

# Latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}