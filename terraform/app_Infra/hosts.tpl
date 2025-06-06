cat << EOF > /var/jenkins_home/shared/hosts.ini

[webservers]
webserver ansible_host=${hostname} ansible_user=${user}