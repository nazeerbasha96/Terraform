# variable "keypair_config" {
#   type = object({
#    public_key = string
#    key_name = string 
#   })
# }
variable "key_name" {
    type = string
}
variable "public_key" {
    type = string
  
}