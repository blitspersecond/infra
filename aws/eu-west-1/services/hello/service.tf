data "aws_ecs_cluster" "ecs_cluster" {
  cluster_name = var.environment
}

resource "aws_ecs_task_definition" "hello_task_definition" {
  family       = "hello-a"
  network_mode = "bridge"
  container_definitions = jsonencode([
    {
      name      = "hello"
      image     = "${aws_ecr_repository.hello.repository_url}:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 5000
        }
      ]
      #   logConfiguration = {
      #     logDriver = "awslogs"
      #     options = {
      #       "awslogs-group"         = "hello-service"
      #       "awslogs-region"        = "eu-west-1"
      #       "awslogs-stream-prefix" = "hello"
      #     }
      #   }
    }
  ])
}

resource "aws_ecs_service" "hello_service" {
  name            = "hello-service"
  cluster         = data.aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.hello_task_definition.arn
  desired_count   = 1
  # iam_role        = aws_iam_role.ecs_service_role.arn # will be needed when load balancer is added
  depends_on = [aws_iam_role.ecs_service_role]

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  # placement_constraints {
  #   type       = "memberOf"
  #   expression = "attribute:ecs.availability-zone in [eu-west-1a, eu-west-1b, eu-west-1c]"
  # }
}
