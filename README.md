# AWS Infrastructure Automation with Terraform & CloudFormation

## Overview
This project provisions AWS infrastructure using **Terraform** and **AWS CloudFormation**.  
It deploys:
- **S3 buckets** (private, versioned)
- **EC2 instance** in a custom VPC
- **MySQL RDS database** with public access (demo purpose only)

The setup follows Infrastructure-as-Code (IaC) best practices with modular code, dynamic variables, and reusable configurations.

---

## Prerequisites
- AWS CLI installed and configured  
- Terraform installed  
- Access key & secret key with sufficient AWS permissions  
- `jq` and `curl` installed locally  
- `.pem` key file for EC2 SSH access  

---

## Setup Steps

### 1. Configure AWS CLI
```bash
aws configure
aws sts get-caller-identity
```

### 2. Get Your Public IP
```bash
MYIP=$(curl -s https://checkip.amazonaws.com)
```

---

## Terraform Deployment

### Navigate to Terraform Directory
```bash
cd terraform
```

### Format, Validate, and Initialize
```bash
terraform fmt -recursive
terraform validate
terraform init
```

### Plan and Apply
```bash
terraform plan
terraform apply -auto-approve
```

### Get Outputs
```bash
terraform output
```

---

## SSH into EC2
```bash
KEY="$(realpath ../key.pem)"
chmod 400 "$KEY"
EC2_IP="$(terraform output -raw ec2_public_ip)"
ssh -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -i "$KEY" ec2-user@"$EC2_IP"
```

---

## RDS Connection from EC2
```bash
sudo dnf install -y mariadb105
mysql -h <RDS_ENDPOINT> -P 3306 -u adminuser -p
```

Example SQL:
```sql
USE proj8870db;
CREATE TABLE demo_table (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50)
);
INSERT INTO demo_table (name) VALUES ('Hello from EC2');
SELECT * FROM demo_table;
```

---

## Check S3 Buckets & Versioning
```bash
aws s3 ls
aws s3api get-bucket-versioning --bucket <BUCKET_NAME>
```

---

## CloudFormation Deployment

### EC2 Stack
```bash
REGION=us-east-1
KEYNAME=yourkeyname

aws cloudformation create-stack   --region "$REGION"   --stack-name ec2-stack-8894858   --template-body file://cloudformation/ec2.yaml   --parameters       ParameterKey=KeyName,ParameterValue="$KEYNAME"       ParameterKey=SSHCidr,ParameterValue="${MYIP}/32"       ParameterKey=PreferredAZ,ParameterValue=us-east-1a       ParameterKey=VpcCidr,ParameterValue=10.60.0.0/16       ParameterKey=PublicSubnetCidr,ParameterValue=10.60.1.0/24
```

### S3 Stack
```bash
SUFFIX=$(date +%y%m%d%H%M)

aws cloudformation create-stack   --region "$REGION"   --stack-name s3-stack-8894858   --template-body file://cloudformation/s3.yaml   --parameters       ParameterKey=BucketPrefix,ParameterValue="twinkle-8894858"       ParameterKey=Suffix,ParameterValue="$SUFFIX"       ParameterKey=EnableVersioning,ParameterValue=true
```

### RDS Stack
```bash
aws cloudformation create-stack   --region "$REGION"   --stack-name rds-stack-8894858   --template-body file://cloudformation/rds.yaml   --parameters       ParameterKey=DBName,ParameterValue=proj8870db       ParameterKey=MasterUsername,ParameterValue=adminuser       ParameterKey=MasterPassword,ParameterValue=YourStrongPassword!       ParameterKey=DBInstanceClass,ParameterValue=db.t3.micro       ParameterKey=AllocatedStorage,ParameterValue=20
```

---

## Cleanup

### Terraform
```bash
terraform destroy -auto-approve
```

### CloudFormation
```bash
aws cloudformation delete-stack --region "$REGION" --stack-name ec2-stack-8894858
aws cloudformation delete-stack --region "$REGION" --stack-name s3-stack-8894858
aws cloudformation delete-stack --region "$REGION" --stack-name rds-stack-8894858
```

---
