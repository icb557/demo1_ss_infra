variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "public_key" {
  type = string
}

variable "network_interface_id" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "host_os" {
  type = string
}

variable "ssh_user" {
  type = string
  default = "ubuntu"
}

variable "identity_file" {
  type = string
  default = "~/.ssh/demo1Ec2Key"
} 