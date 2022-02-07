terraform {
  required_version = ">= 1.1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.1.0"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = var.aws_region
}

locals {
  tags = {
    Owner       = "${var.app_name}-app"
    Environment = "dev"
  }
}

################################################################################
# Supporting Resources
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = "${var.app_name}-stack-vpc"
  cidr = "10.99.0.0/18"

  azs              = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets   = ["10.99.0.0/24", "10.99.1.0/24", "10.99.2.0/24"]
  private_subnets  = ["10.99.3.0/24", "10.99.4.0/24", "10.99.5.0/24"]
  database_subnets = ["10.99.7.0/24", "10.99.8.0/24", "10.99.9.0/24"]

  tags = local.tags
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["*ubuntu-*20.04*-amd64-server*"]
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "${var.app_name}-stack-sg"
  description = "Security group for EBI gallery app EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "all-icmp", "ssh-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

resource "tls_private_key" "ebi_gallery_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.ebi_gallery_key.private_key_pem
  filename        = "${var.generated_key_name}.pem"
  file_permission = "0600"
}

resource "aws_key_pair" "ssh_keypair" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.ebi_gallery_key.public_key_openssh
  tags       = local.tags
}

################################################################################
# EC2 Module
################################################################################

module "ec2" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name                        = "${var.app_name}-stack-ec2"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = var.ec2_instance_size
  key_name                    = aws_key_pair.ssh_keypair.key_name
  availability_zone           = element(module.vpc.azs, 0)
  subnet_id                   = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids      = [module.security_group.security_group_id]
  associate_public_ip_address = true
  tags                        = local.tags
  volume_tags                 = local.tags
  depends_on                  = [module.vpc]
}

resource "aws_volume_attachment" "ebi-volume_attachment" {
  device_name = "/dev/xvde"
  volume_id   = aws_ebs_volume.ebi-volume.id
  instance_id = module.ec2.id
}

resource "aws_ebs_volume" "ebi-volume" {
  availability_zone = element(module.vpc.azs, 0)
  size              = 10
  tags              = local.tags
}

resource "aws_eip" "ebi-gallery-ip" {
  vpc       = true
  instance  = "${module.ec2.id}"
  tags      = local.tags
}