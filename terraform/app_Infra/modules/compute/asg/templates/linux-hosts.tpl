cat << EOF > /var/jenkins_home/shared/hosts.ini

[webservers]
%{ for instance in instances ~}
webserver-${instance.hostname} ansible_host=${instance.hostname} ansible_user=${instance.user}
%{ endfor ~}
EOF