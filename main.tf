terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "backup_bucket" {
  bucket = "harsh-project19-backup-${random_id.suffix.hex}"
}

resource "aws_iam_role" "ec2_role" {
  name = "project19-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "s3_policy" {
  name = "project19-s3-policy"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.backup_bucket.arn,
        "${aws_s3_bucket.backup_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "project19-profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_instance" "backup_server" {

  ami           = "ami-03f4878755434977f"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.instance_profile.name

  user_data = templatefile("${path.module}/userdata.sh", {
    bucket_name = aws_s3_bucket.backup_bucket.bucket
  })

  tags = {
    Name = "project19-backup-server"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.backup_bucket.bucket
}

output "instance_id" {
  value = aws_instance.backup_server.id
}