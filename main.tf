resource "aws_route53_zone" "this" {
  name = var.domain
  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}

module "policy" {
  source  = "ptonini/iam-policy/aws"
  version = "~> 1.0.0"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
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
  })
}

module "root_record" {
  source       = "ptonini/route53-record/aws"
  version      = "~> 1.0.0"
  for_each     = var.root_records
  name         = var.domain
  route53_zone = aws_route53_zone.this
  type         = each.key
  records      = each.value
  providers = {
    aws = aws
  }
}

module "record" {
  source       = "ptonini/route53-record/aws"
  version      = "~> 1.0.0"
  for_each     = { for r in var.records : "${r["name"]}_${r["type"]}" => r }
  name         = each.value["name"]
  route53_zone = aws_route53_zone.this
  type         = each.value["type"]
  records      = each.value["records"]
  providers = {
    aws = aws
  }
}