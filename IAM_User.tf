#create iam user
resource "aws_iam_user" "nav_terra_user" {
  name = "nav_terra_user"
  tags = {
    Name = "nav_terra_user"
  }
}

#attach ec2 read only access policy to the user
resource "aws_iam_user_policy_attachment" "nav_terra_user_attach" {
  user       = aws_iam_user.nav_terra_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

#attach s3 admin access policy to the user
resource "aws_iam_user_policy_attachment" "nav_terra_s3_attach" {
  user       = aws_iam_user.nav_terra_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}