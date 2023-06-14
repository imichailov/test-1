###########################################
# IAM role creation
###########################################

resource "aws_iam_role" "ssm_system_manager" {
  name = "ssm_management_test"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = {
    Name = "role for simple system management"
  }
}

###########################################
# Policy attachment
###########################################

resource "aws_iam_role_policy_attachment" "ssm_mgmt_attachment" {
  role       = aws_iam_role.ssm_system_manager.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_core_attachment" {
  role       = aws_iam_role.ssm_system_manager.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

############################################
# Profile for simple system management
############################################

resource "aws_iam_instance_profile" "iam_instance_profile" {
  name = "instance-profile-test"
  role = aws_iam_role.ssm_system_manager.name
  tags = {
    Name = "my_profile"
  }
}


# Lambda Role
##########################################
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({

    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
}

##########################################
# Cloudwatch EC2 Policy
##########################################

resource "aws_iam_role_policy" "cloudwatch_ec2_policy" {
  name = "cloudwatch-ec2-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "forEC2",
        "Effect": "Allow",
        "Resource": "*",
        "Action": [
          "ec2:DescribeInstances",
          "ec2:StopInstances",
          "ec2:TerminateInstances"
        ]
      },
      {
        "Sid": "forASG",
        "Effect": "Allow",
        "Action": [
          "autoscaling:UpdateAutoScalingGroup",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:SuspendProcesses"
        ],
        "Resource": "*"
      }
    ]
  })
}