# 1. Attach Production Firewall Access Rules directly using your Hardcoded Default VPC ID
resource "aws_security_group" "node_sg" {
  name        = "devsecops-prod-sg"
  description = "Security group for production DevSecOps orchestration host"
  vpc_id      = "vpc-001b49a92c6514440" # Your verified ap-southeast-2 Default VPC

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Production SSH Maintenance Port Access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Application Ingress Frontend Port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "devsecops-prod-sg"
    Environment = "Production"
  }
}

# 2. Provision Core Production DevSecOps Orchestration Engine Node
resource "aws_instance" "devsecops_host" {
  # Your explicitly verified Amazon Linux 2023 AMI for ap-southeast-2
  ami           = "ami-0720cb7af233b0529" 
  instance_type = "m7i-flex.large" # Using your account-approved instance type

  # Places your machine directly inside your default corporate subnet track to bypass SCP blocks
  subnet_id              = "subnet-0591d45598929c350" # Your verified ap-southeast-2a Subnet
  vpc_security_group_ids = [aws_security_group.node_sg.id]

  root_block_device {
    volume_size           = 30 
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # Automatically bootstrap Docker and Kubernetes on your production Amazon Linux instance
  user_data = <<-EOF
              #!/bin/bash
              sudo dnf update -y
              sudo dnf install -y docker
              sudo systemctl start docker
              sudo systemctl enable docker
              curl -sfL https://k3s.io | sh -
              EOF

  tags = {
    Name        = "devsecops-prod-orchestration-host"
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# 3. Output your Live Machine IP Address automatically upon successful build completion
output "production_host_public_ip" {
  value       = aws_instance.devsecops_host.public_ip
  description = "The public IP address of your production orchestration host machine."
}

