resource "aws_iam_policy" "todo_api_pod_policy" {
  name = "todo_api_pod_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["secretsmanager:GetSecretValue"]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.mapquest_api_key.arn
      },
    ]
  })
}