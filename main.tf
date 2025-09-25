# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Local variables block for configuration values
locals {
    aws_key = "YULIS_MAC_KEY_EAST1"   # SSH key pair name for EC2 instance access
}

resource "aws_security_group" "web_sg" {
  name = "allow-web-traffic"

  ingress {
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  backend "s3" {
    bucket = "yuli-github-actions-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "${local.aws_key}"          # Specify the SSH key pair name
   security_groups = [aws_security_group.web_sg.name]
   user_data     = file("wp_install.sh")

   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }
}
