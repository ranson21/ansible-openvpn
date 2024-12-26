
variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "zone" {
  type = string
}

variable "network" {
  type    = string
  default = "global/networks/default"
}

variable "user" {
  type    = string
  default = "root"
}

variable "home_path" {
  type    = string
  default = "/home"
}

variable "home" {
  type    = string
  default = env("HOME")
}

variable "base" {
  type    = string
  default = "ansible"
}
