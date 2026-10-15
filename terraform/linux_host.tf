# 1. Automatically generate a clean, secure cryptographic SSH Private Key
resource "tls_private_key" "orchestrator_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# 2. Register the generated Public Key signature natively into your AWS region console profile
resource "aws_key_pair" "generated_key" {
  key_name   = "devsecops-prod-key"
  public_key = tls_private_key.orchestrator_key.public_key_openssh
}

# 3. Export the secure Private Key file (.pem) straight into your local directory space
resource "local_file" "ssh_key_file" {
  content         = tls_private_key.orchestrator_key.private_key_pem
  filename        = "${path.module}/devsecops-prod-key.pem"
  file_permission = "0600"
}

# 4. DYNAMIC AMI LOOKUP: Automatically fetches the verified, active Ubuntu 24.04 LTS image for your region
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Official Canonical Owner ID
}

# 5. Provision the Main Security Ingress Group gateways
resource "aws_security_group" "node_sg" {
  name        = "devsecops-prod-sg"
  description = "Orchestration host secure network routing parameters"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
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

# 6. Spin up the Core Orchestration host instance mapping the dynamic AMI ID
resource "aws_instance" "devsecops_host" {
  instance_type          = "m7i-flex.large"
  # Maps the dynamic lookup directly to bypass hardcoded string failures
  ami                    = data.aws_ami.ubuntu.id 
  
  key_name               = aws_key_pair.generated_key.key_name
  vpc_security_group_ids = [aws_security_group.node_sg.id]

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  tags = {
    Name    = "devsecops-prod-orchestration-host"
    Project = "devsecops-eks-project"
  }
}

# 7. Output variables to easily read your connection endpoints
output "production_host_public_ip" {
  value = aws_instance.devsecops_host.public_ip
}

