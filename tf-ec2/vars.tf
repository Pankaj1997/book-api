variable "region" {
  type    = string
  default = "ap-south-1"

}

variable "pub_key" {
 description    = "Public key to access Jump"
 default = "~/.ssh/id_rsa.pub"
 type           = string
}

