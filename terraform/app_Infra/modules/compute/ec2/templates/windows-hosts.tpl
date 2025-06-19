set-content -path "./hosts.ini" -value @'

[webservers]
webserver ansible_host=${hostname} ansible_user=${user}
'@