#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Update system packages
apt update -y && apt upgrade -y

# Install Java (Jenkins dependency)
apt install -y openjdk-17-jdk

# Add the Jenkins repository
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package lists
apt update -y

# Install Jenkins
apt install -y jenkins

# Start and enable Jenkins service
systemctl enable --now jenkins

# Install required utilities
apt install -y git wget

# Open firewall ports (if UFW is enabled)
if systemctl is-active --quiet ufw; then
    ufw allow 8080/tcp
    ufw reload
fi

# Print initial admin password
echo "Jenkins installation completed. Access it at http://$(curl -s ifconfig.me):8080"
echo "Initial admin password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)"

