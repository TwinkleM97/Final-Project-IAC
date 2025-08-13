########################################
# Root module entrypoint (main.tf)
# Resources are organized in:
#   - provider.tf (provider config)
#   - vpc.tf      (VPC, subnets, routes, AZs data)
#   - ec2.tf      (AMI data, SG, EC2)
#   - rds.tf      (DB subnet group, SG, RDS)
#   - s3.tf       (buckets, PAB, versioning)
#   - variables.tf, outputs.tf, backend.tf
########################################

# Common tags available for reuse (optional)
locals {
  common_tags = {
    Project = "PROG8870"
    Owner   = var.student_alias
    Student = var.student_id
  }
}
