data "aws_ami" "dns" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_network_interface" "dns" {
  subnet_id   = var.dns_subnet.id
  private_ips = [var.dns_ip_address]

  tags = {
    Name = "${var.prefix}-dns-service"
  }
}

resource "aws_instance" "dns" {
  ami           = data.aws_ami.dns.id
  instance_type = "t2.micro"
  key_name      = var.ec2_key_pair.key_name
  user_data     = templatefile("${path.module}/dns-service.yaml", {
    dns_ip_address  = var.dns_ip_address
    dns_domain_name = var.dns_domain_name
    rds_ip_address  = var.rds_ip_address
  })

  network_interface {
    network_interface_id = aws_network_interface.dns.id
    device_index         = 0
  }

  tags = {
    Name = "${var.prefix}-dns-service"
  }
}
