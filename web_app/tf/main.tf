provider "aws" {
  region = "us-east-1"
}

resource "aws_ecr_repository" "my_ecr_repository" {
  name = "flask-web-app"
}

resource "aws_instance" "example" {
 ami = "ami-123456" # Replace with your AMI
 instance_type = "t2.micro"
 iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}





# create role for service
# defines who can assume the role, 
# ie who can adopt the permissions that the role grants
# sts:AssumeRole, enables requesting temporary, limited-privilege credentials 
# Allow Specifies the AWS account, user, role, or service that is allowed to perform the actions
resource "aws_iam_role" "ec2_ecr_role" {
    name = "ec2-ecr-role"

    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
      Service = "ec2.amazonaws.com"
      }
      Sid = ""
      },
    ]
  })
}

# create instance profile, as a container for the iam role
resource "aws_iam_instance_profile" "ec2_profile" {
 name = "ec2-ecr-instance-profile"
 role = aws_iam_role.ec2_ecr_role.name
}

# attach role to policy
resource "aws_iam_role_policy_attachment" "ecr_read_only" {
 role = aws_iam_role.ec2_ecr_role.name
 policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

