
#################
# Create RSA Key Pair
#################
resource "tls_private_key" "ssh_server" {
  # This resource is not recommended for production environements
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "server_key" {
  key_name_prefix   = var.cluster_name
  public_key = tls_private_key.ssh_server.public_key_openssh
}

#################
# Grab latest Ubuntu AMI ID
#################
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic*"]
  }

}
#################
# Security Groups allowing SSH
#################
module "ssh_server_sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = var.cluster_name
  description = "Security group to allow SSH from all"
  vpc_id      = var.vpc_id

  egress_cidr_blocks       = ["0.0.0.0/0"]
  egress_rules             = ["all-all"]
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_rules            = ["ssh-tcp"]

  create = var.ssh_server_count > 0 ? true:false
}
#################
# Create EC2 instance
#################
resource "aws_instance" "ubuntu" {
  count         = var.ssh_server_count > 0 ? 1:0
  instance_type = "t3.small"
  key_name      = aws_key_pair.server_key.key_name
  ami           = data.aws_ami.ubuntu.image_id
  vpc_security_group_ids = [module.ssh_server_sg.this_security_group_id]
  subnet_id              = var.subnet_id
  tags = var.tags
}

#################
# Add server to strongDM
#################
resource "sdm_resource" "ssh_server" {
  count = var.ssh_server_count
  ssh {
    name     = "${var.cluster_name}-server${count.index}"
    username = "ubuntu"
    hostname = aws_instance.ubuntu[0].private_ip
    port     = 22
  }
  # Provisioner to add strongDM public key to server.
  provisioner "remote-exec" {
    inline = [
      "echo '${self.ssh.0.public_key}' >> ~/.ssh/authorized_keys",
    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = tls_private_key.ssh_server.private_key_pem
      host        = aws_instance.ubuntu[0].public_ip
    }
  }
}