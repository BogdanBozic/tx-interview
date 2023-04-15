locals {

  dns_record = <<-EOF
{
  "Changes": [
    {
      "Action": "CREATE",
      "ResourceRecordSet": {
        "Name": "goldbach.${data.aws_route53_zone.bastovansurcinski.name}",
        "Type": "CNAME",
        "TTL": 300,
        "ResourceRecords": [
          {
            "Value": "placeholder-value"
          }
        ]
      }
    }
  ]
}

EOF

  cert_manager = <<-EOF

apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.email}
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
    - dns01:
        route53:
          region: ${var.default_region}
          hostedZoneID: ${data.aws_route53_zone.bastovansurcinski.id}
      selector:
        dnsZones:
          - ${data.aws_route53_zone.bastovansurcinski.name}

EOF

  ingress = <<-EOF

apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: goldbach-ingress
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  ingressClassName: nginx
  rules:
    - host: goldbach.${data.aws_route53_zone.bastovansurcinski.name}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: goldbach
                port:
                  number: 80
  tls:
  - hosts:
      - goldbach.${data.aws_route53_zone.bastovansurcinski.name}
    secretName: goldbach-tls
EOF
}
