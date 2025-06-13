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
apt-get update
apt install -y wget apt-transport-https
wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | gpg --dearmor | tee /etc/apt/trusted.gpg.d/adoptium.gpg > /dev/null
echo "deb https://packages.adoptium.net/artifactory/deb $(awk -F= '/^VERSION_CODENAME/{print$2}' /etc/os-release) main" | tee /etc/apt/sources.list.d/adoptium.list
apt install temurin-17-jdk

# Install Jenkins 2.479.3
apt-get install -y wget apt-transport-https
wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
sh -c 'echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
apt-get update
apt-get install -y jenkins=2.479.3

# Configure Jenkins to use the mounted directory
systemctl stop jenkins || true  # Stop Jenkins if it's running
rm -rf /var/lib/jenkins  # Remove default directory if it exists
mv /var/lib/jenkins /var/jenkins_home/  # Move data to mounted directory (if it exists after install)
ln -s $MOUNT_POINT /var/lib/jenkins  # Create symlink
systemctl start jenkins  # Start Jenkins 