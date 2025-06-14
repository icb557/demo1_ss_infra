set-content -path "./hosts.ini" -value @'

[webservers]
webserver ansible_host=${hostname} ansible_user=${user} ansible_ssh_private_key_file=${identity_file}
'@