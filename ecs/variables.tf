variable "vpc_id" {}
variable "sg_ids" {}
variable "subnet_ids" {
    type = list(string)
}
variable "image_uri" {}
variable "exec_role_arn" {}



