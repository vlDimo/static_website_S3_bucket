output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.website_distribution.domain_name}"
  description = "The URL of the CloudFront Distribution"
}
output "nameservers" {
  value = aws_route53_zone.my_domain_routing.name_servers
  description = "List of Nameservers for the Route53 hosted zone"
}