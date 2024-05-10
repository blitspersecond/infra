resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/${var.environment}/hello-service"
  retention_in_days = 14
  tags = merge(
    local.tags,
    {
      Name = "${var.environment}-hello-service"
    }
  )
}
