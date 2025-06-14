cat << EOF > /var/jenkins_home/shared/hosts.ini

[webservers]
webserver ansible_host=${hostname} ansible_user=${user} ansible_ssh_private_key_file=${identity_file}
