set-content -path "./hosts.ini" -value @'

[webservers]
%{ for instance in instances ~}
webserver-${instance.hostname} ansible_host=${instance.hostname} ansible_user=${instance.user}
%{ endfor ~}
'@