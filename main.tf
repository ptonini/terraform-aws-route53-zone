resource "aws_route53_zone" "this" {
  name = var.domain
}

module "root_record" {
  source = "github.com/ptonini/terraform-aws-route53-record?ref=v1"
  for_each = var.root_records
  name = var.domain
  route53_zone = aws_route53_zone.this
  type = each.key
  records = each.value
  providers = {
    aws = aws
  }
}

module "record" {
  source = "github.com/ptonini/terraform-aws-route53-record?ref=v1"
  for_each = {for r in var.records : "${r["name"]}_${r["type"]}" => r}
  name = each.value["name"]
  route53_zone = aws_route53_zone.this
  type = each.value["type"]
  records = each.value["records"]
  providers = {
    aws = aws
  }
}