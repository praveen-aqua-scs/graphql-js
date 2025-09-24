provider "aws" {
  region = "us-east-1"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD..."  # Replace with your actual SSH public key
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "example" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type = "t2.micro"
  admin_username = "azureuser"
  # 🔐 Intentionally hardcoded for testing secret detection
  admin_password = "AdminPassw0rd!ShouldBeDetected"
  key_name      = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.allow_ssh.name]

  # ✅ Aqua will scan this user_data for secrets
  user_data = <<-EOF
    #!/bin/bash
    # Write secrets to /etc/environment (environment file)
    echo "DB_USER=admin" >> /etc/environment
    echo "DB_PASSWORD=HardCodedPassword123!" >> /etc/environment
    echo "API_KEY=sk_live_fakeapikeyvalue" >> /etc/environment

    # Export secrets as shell environment variables
    export SECRET_KEY=AnotherSuperSecret456#
    export PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAsimulatedPrivateKeyData...
-----END RSA PRIVATE KEY-----"
  EOF

  tags = {
    Name = "aqua-detectable-ec2-instance"
  }
}
