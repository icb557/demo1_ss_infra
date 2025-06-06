cat << EOF > /var/jenkins_home/workspace/Infrastructure_pipeline_PR-43/demo1_ss_infra/terraform/app_Infra/ansible/inventories/hosts.ini

[webservers] 
webserver ansible_host=${hostname} ansible_user=${user}