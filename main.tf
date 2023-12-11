resource "aws_route53_zone" "this" {
  name = var.name

  lifecycle {
    ignore_changes = [
      tags["business_unit"],
      tags["product"],
      tags["env"],
      tags_all
    ]
  }
}

module "policy" {
  source  = "ptonini/iam-policy/aws"
  version = "~> 2.0.0"
  name    = "${var.name}-zone-access-policy"
  statement = [
    {
      Effect = "Allow"
      Action = [
        "route53:ListHostedZones",
        "route53:GetChange"
      ],
      Resource = ["*"]
    },
    {
      Effect = "Allow",
      Action = [
        "route53:ListResourceRecordSets",
        "route53:ChangeResourceRecordSets"
      ],
      Resource = [
        "arn:aws:route53:::hostedzone/${aws_route53_zone.this.id}",
      ]
    }
  ]
}

module "root_record" {
  source   = "ptonini/route53-record/aws"
  version  = "~> 1.1.0"
  for_each = var.root_records
  name     = var.name
  zone_id  = aws_route53_zone.this.id
  type     = each.key
  records  = each.value
}

module "record" {
  source   = "ptonini/route53-record/aws"
  version  = "~> 1.1.0"
  for_each = var.records
  name     = each.key
  zone_id  = aws_route53_zone.this.id
  type     = each.value.type
  records  = each.value.records
}