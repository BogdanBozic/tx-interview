data "aws_route53_zone" "bastovansurcinski" {
  name = "bastovansurcinski.click"
}

#resource "aws_route53_record" "goldbach" {
#  zone_id = data.aws_route53_zone.bastovansurcinski.id
#  name    = "goldbach."
#  type    = "CNAME"
#  ttl     = "300"
#  records = [
#    "10.0.0.2",
#  ]
#}

resource "aws_iam_policy" "cert_manager" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : "route53:GetChange",
        "Resource" : "arn:aws:route53:::${data.aws_route53_zone.bastovansurcinski.id}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        "Resource" : "arn:aws:route53:::hostedzone/"
      }
    ]
  })
}