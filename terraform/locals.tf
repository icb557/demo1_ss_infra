locals {
  my_sg_keys = ["app_server"]
  my_sgs = {
    app_server = aws_security_group.demo1_app_server_sg.id
  }
  admins_ips = ["181.51.33.104/32", "122.51.33.105/32"]
  sg_ip_pairs = {
    for pair in setproduct(local.my_sg_keys, local.admins_ips) :
    "${pair[0]}_${pair[1]}" => { sg_key = pair[0], ip = pair[1] }
  }
}