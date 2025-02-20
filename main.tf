provider "aws" {
  region = "us-east-1" # Change to your preferred region
}

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the private key to a local file
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/jenkins_key.pem"
  file_permission = "0400" # Restrict permissions to read-only for the owner
}

# Upload the public key to AWS
resource "aws_key_pair" "jenkins_key_pair" {
  key_name   = "jenkins-key-pair"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Find the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Create a security group for Jenkins
resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH and Jenkins web interface"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP in production
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this to your IP in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "jenkins_server" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.medium" # Adjust instance type as needed
  key_name      = aws_key_pair.jenkins_key_pair.key_name # Use the generated key pair

  security_groups = [aws_security_group.jenkins_sg.name]

  tags = {
    Name = "Jenkins-Server"
  }

  # Use the file function to read the user_data script
  user_data = file("${path.module}/user_data.sh")
}

# Output the public IP of the Jenkins server
output "jenkins_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

# Output the private key (for reference)
output "private_key" {
  value     = tls_private_key.ssh_key.private_key_pem
  sensitive = true # Mark as sensitive to avoid displaying in logs
}
