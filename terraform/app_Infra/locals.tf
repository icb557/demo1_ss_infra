locals {
  my_sg_keys = ["app_server"]
  my_sgs = {
    app_server = module.security_groups.app_server_sg_id
  }
  admins_ips = ["181.71.139.122/32", "3.89.142.113/32", "38.156.230.172/32"]
  sg_ip_pairs = {
    for pair in setproduct(local.my_sg_keys, local.admins_ips) :
    "${pair[0]}_${pair[1]}" => { sg_key = pair[0], ip = pair[1] }
  }
}