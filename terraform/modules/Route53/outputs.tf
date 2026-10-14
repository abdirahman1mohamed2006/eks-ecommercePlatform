output "zone_id" {
  description = "ID of the hosted zone."
  value       = data.aws_route53_zone.this.zone_id
}

output "zone_arn" {
  description = "ARN of the hosted zone."
  value       = data.aws_route53_zone.this.arn
}

output "zone_arns" {
  description = "Hosted zone ARNs as a list, for the IAM module's route53_hosted_zone_arns input."
  value       = [data.aws_route53_zone.this.arn]
}

output "zone_name" {
  description = "Name of the hosted zone."
  value       = data.aws_route53_zone.this.name
}

output "name_servers" {
  description = "Name servers of the hosted zone."
  value       = data.aws_route53_zone.this.name_servers
}
