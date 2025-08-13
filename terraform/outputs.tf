output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.mysql.address
}

output "rds_port" {
  description = "RDS port"
  value       = aws_db_instance.mysql.port
}

output "s3_bucket_names" {
  description = "All S3 bucket names"
  value       = [for b in aws_s3_bucket.b : b.bucket]
}
