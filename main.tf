terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"             # Provider source
      version = "~> 4.16"                   # <--- Update this version
    }
  }

  required_version = ">= 1.2.0"             # Terraform version
}

provider "aws" {
  profile = "default"                       # AWS profile
  region  = "us-west-2"                     # Change to your region
}

resource "aws_instance" "app_server" {
  ami           = "ami-0c09c7eb16d3e8e70"   # Ubuntu Server 20.04 LTS AMI (HVM), SSD Volume Type
  instance_type = "t2.micro"                # Free tier eligible
  key_name = "Infra-oregon"                 # Change to your key name
  # user_data = <<-EOF
  #             #!/bin/bash
  #             cd /home/ubuntu
  #             rm -rf index.html
  #             touch index.html
  #             echo "<h1>Feito com terraform</h1>" >> index.html
  #             nohup busybox httpd -f -p 8080 &
  #             EOF
  tags = {
    Name = "terraform ansible python"                   # Name tag
  }
}