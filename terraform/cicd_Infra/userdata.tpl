#!/bin/bash
DEVICE=/dev/sdh
MOUNT_POINT=/var/jenkins_home

if [ ! -b $DEVICE ]; then
  echo "$DEVICE not found. Exiting."
  exit 1
fi

# Check if the device is formatted
if ! file -s $DEVICE | grep -q ext4; then
  mkfs -t ext4 $DEVICE
fi

mkdir -p $MOUNT_POINT
mount $DEVICE $MOUNT_POINT
echo "$DEVICE $MOUNT_POINT ext4 defaults,nofail 0 2" >> /etc/fstab

# Install Java for Jenkins
sudo apt-get update
sudo apt install -y wget apt-transport-https
sudo bash -c 'wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null'
sudo bash -c 'echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list'
sudo apt install temurin-17-jdk

# Install Jenkins 2.479.3
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sudo bash -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install -y jenkins=2.479.3

# Configure Jenkins to use the mounted directory
systemctl stop jenkins || true  # Stop Jenkins if it's running
rm -rf /var/lib/jenkins  # Remove default directory if it exists
mv /var/lib/jenkins /var/jenkins_home/  # Move data to mounted directory (if it exists after install)
ln -s $MOUNT_POINT /var/lib/jenkins  # Create symlink
systemctl start jenkins  # Start Jenkins 