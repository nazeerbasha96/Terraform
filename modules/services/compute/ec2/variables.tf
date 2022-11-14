variable "vpc_id" {
  type = string
}
variable "sg_cidr_block" {
  type = list(string)
}
variable "subnet_id" {
  type = string
}
variable "ami" {
  type = string
}
variable "instance_type" {
  type = string
}
variable "key_name" {
  type = string
}
variable "instance_name" {
  type = string
}
variable "associate_public_ip_address" {
  type = bool
}
