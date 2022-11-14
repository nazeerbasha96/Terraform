variable "region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "vpc_name" {
  type = string
}
variable "subnet_cidr" {
  type = list(any)
}
variable "availability_zone" {
  type = list(string)
}
variable "ig_cofig" {
  type = object({
    ig_name    = string
    ig_rt_name = string
  })
}
variable "keypair_config" {
  type = object({
    public_key = string
    key_name   = string
  })
}
variable "ec2_config" {
  type = object({
    ami           = string
    instance_type = string
    instance_name = string
  })
}
variable "application_db" {
  type = object({
    allocated_storage    = number
    db_name              = string
    engine               = string
    engine_version       = number
    instance_class       = string
    username             = string
    password             = string
    parameter_group_name = string
    skip_final_snapshot  = bool
    db_subnet_group_name = string

  })
}
variable "lbr_config" {
  type = object({
    tg_name = string
    lbr_name = string
    lbr_sg_name =string
  })
}
