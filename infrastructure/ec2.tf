# ==========================================================
# EC2 Instance - runs the Dockerized GroceryMate app
# ==========================================================

resource "aws_instance" "app_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name

  vpc_security_group_ids = [aws_security_group.ec2.id]

  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = 8
    encrypted   = true
  }

  # Install Docker + docker-compose on first boot, clone the repo,
  # and start the application automatically.
  user_data = <<-BOOTSTRAP
    #!/bin/bash
    set -e
    dnf update -y
    dnf install -y docker git
    systemctl enable --now docker
    usermod -aG docker ec2-user
    curl -L "https://github.com/docker/compose/releases/download/v2.29.7/docker-compose-linux-x86_64" \
      -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

    cd /home/ec2-user
    sudo -u ec2-user git clone --branch version2 \
      https://github.com/sakhiaryan/AWS_grocery.git
    cd AWS_grocery
    /usr/local/bin/docker-compose up -d --build
  BOOTSTRAP

  tags = {
    Name = "${var.project_name}-app-server"
    Role = "application"
  }
}
