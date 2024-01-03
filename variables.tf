variable "name" {}

variable "root_records" {
  type    = map(list(string))
  default = {}
}

variable "records" {
  type = map(object({
    type    = optional(string)
    records = set(string)
  }))
  default = {}
}