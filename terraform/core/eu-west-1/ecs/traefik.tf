resource "aws_ecs_task_definition" "traefik_task_definition" {
  family       = "traefik-service"
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      name      = "traefik"
      image     = "${aws_ecr_repository.traefik.repository_url}:latest"
      cpu       = 256
      memory    = 128
      essential = true
      portMappings = [
        {
          containerPort = 5000
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"        = "/aws/${var.environment}/traefik-service",
          "awslogs-region"       = "eu-west-1",
          "awslogs-create-group" = "true",
        }
      }
    }
  ])
}
