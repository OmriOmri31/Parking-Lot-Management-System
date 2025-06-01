terraform {
  required_version = ">= 1.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ---------- VPC ----------
data "aws_vpc" "default" {
  default = true
}

# ---------- Security groups ----------
resource "aws_security_group" "ec2_sg" {
  name   = "parkinglot-ec2-sg"
  vpc_id = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Flask HTTP"
    from_port   = 5000
    to_port     = 5000
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

# ---------- Use existing RDS instance ----------
data "aws_db_instance" "mysql" {
  db_instance_identifier = "parkinglot-db"
}

# ---------- EC2 ----------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_instance" "app" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t3.micro"
  key_name                    = var.key_pair_name
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  user_data                   = file("${path.module}/user_data.sh")
  associate_public_ip_address = true

  tags = { Name = "ParkingLotApp" }
}

# ---------- Pass DB info via SSM ----------
resource "aws_ssm_parameter" "env_file" {
  name  = "/parkinglot/.env"
  type  = "SecureString"
  value = <<EOF
DB_HOST=${data.aws_db_instance.mysql.address}
DB_PORT=3306
DB_USER=${var.db_user}
DB_PASS=${var.db_password}
EOF
}

# ---------- Outputs ----------
output "app_public_ip" {
  value = aws_instance.app.public_ip
}

output "flask_url" {
  value = "http://${aws_instance.app.public_ip}:5000/"
}
