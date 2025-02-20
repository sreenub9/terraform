#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Update system packages
yum update -y

# Install Java (Jenkins dependency)
yum install -y java-17-amazon-corretto

# Add the Jenkins repository
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key

# Install Jenkins
yum install -y jenkins

# Start and enable Jenkins service
systemctl enable --now jenkins

# Install required utilities
yum install -y git wget

# Open firewall ports (if firewalld is enabled)
if systemctl is-active --quiet firewalld; then
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --reload
fi

# Print initial admin password
echo "Jenkins installation completed. Access it at http://$(curl -s ifconfig.me):8080"
echo "Initial admin password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"

