variable "region" {
  type    = string
  default = "ap-south-1"

}

variable "pub_key" {
 description    = "Public key to access Jump"
 default = "~/.ssh/id_rsa.pub"
 type           = string
}

variable "private_key" {
 description    = "Public key to access Jump"
 default = "~/.ssh/id_rsa"
 type           = string
}

variable "image_name" {
 description    = "image_name"
 default = "pankaj2212/bookkeeper"
 type           = string
}

variable "image_tag" {
 description    = "image_tag"
 default = "latest"
 type           = string
}