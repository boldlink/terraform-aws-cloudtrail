output "arn" {
  value       = aws_cloudtrail.main.arn
  description = "ARN of the trail."
}

output "home_region" {
  value       = aws_cloudtrail.main.home_region
  description = "Region in which the trail was created."
}

output "id" {
  value       = aws_cloudtrail.main.id
  description = "Name of the trail."
}

output "tags_all" {
  value       = aws_cloudtrail.main.tags_all
  description = "Map of tags assigned to the resource"
}
