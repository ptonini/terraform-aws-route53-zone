variable "domain" {}

variable "root_records" {
  default = {}
}

variable "records" {
  type = list(object({
    name = string
    type = string
    records = list(string)
  }))
  default = []
}