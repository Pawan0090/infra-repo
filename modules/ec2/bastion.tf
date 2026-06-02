############################################
# Security Group
############################################

resource "aws_security_group" "bastion_sg" {

  name = "eks-bastion-sg"

  description = "Security group for bastion host"

  vpc_id = var.vpc_id

  ingress {

    description = "SSH Access"

    from_port = 22

    to_port = 22

    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  egress {

    from_port = 0

    to_port = 0

    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {

    Name = "eks-bastion-sg"
  }
}

############################################
# IAM Role
############################################

resource "aws_iam_role" "bastion_role" {

  name = "eks-bastion-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

############################################
# IAM Policies
############################################

resource "aws_iam_role_policy_attachment" "admin_access" {

  role = aws_iam_role.bastion_role.name

  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_core" {

  role = aws_iam_role.bastion_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################
# Instance Profile
############################################

resource "aws_iam_instance_profile" "bastion_profile" {

  name = "eks-bastion-profile"

  role = aws_iam_role.bastion_role.name
}

############################################
# Latest Amazon Linux AMI
############################################

data "aws_ami" "amazon_linux" {

  most_recent = true

  owners = ["amazon"]

  filter {

    name = "name"

    values = [
      "al2023-ami-*-x86_64"
    ]
  }

  filter {

    name = "virtualization-type"

    values = [
      "hvm"
    ]
  }
}

############################################
# Bastion EC2
############################################

resource "aws_instance" "bastion" {

  ami = data.aws_ami.amazon_linux.id

  instance_type = "t3.micro"

  subnet_id = var.public_subnet_id

  associate_public_ip_address = true

  key_name = var.key_name

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name

  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]

  user_data = file("userdata/bastion.sh")

  root_block_device {

    volume_size = 20

    volume_type = "gp3"

    encrypted = true
  }

  tags = {

    Name = "eks-bastion-host"
  }
}