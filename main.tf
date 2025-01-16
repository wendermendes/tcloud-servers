data "aws_vpc" "vpc-servers" {
  filter {
    name   = "tag:Name"
    values = ["tcloud-vpc-servers"]
  }
}

data "aws_ami" "ami-servers" {
  most_recent = true
  owners      = ["136693071363"]
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "sgp-dockerhost" {
  source              = "terraform-aws-modules/security-group/aws"
  name                = "tcloud-sgp-dockerhost"
  description         = "Security Group para o servidor Docker Host"
  vpc_id              = data.aws_vpc.vpc-servers.id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "ssh-tcp"]
  egress_rules        = ["all-all"]
}


module "ec2-dockerhost" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 3.0"
  name                   = "tcloud-ec2-dockerhost"
  ami                    = data.aws_ami.ami-servers.id
  instance_type          = "t3.micro"
  key_name               = "vockey"
  monitoring             = true
  vpc_security_group_ids = [module.sgp-dockerhost.security_group_id]
  subnet_id              = "subnet-062e7f91018671821"
  user_data              = file("dependencias.sh")
  tags = {
    Terraform = "true"
  }
}

resource "aws_eip" "eip-dockerhost" {
  instance = module.ec2-dockerhost.id
  vpc      = true
}
