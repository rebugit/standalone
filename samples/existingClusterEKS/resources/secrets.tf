resource "aws_secretsmanager_secret" "mapquest_api_key" {
  name = "example/mapQuestApikey"
  tags = {
    env: "dev"
    app: "example/rebugit"
    description: "Mapquest API key for rebugit test"
    type = "security"
  }
}