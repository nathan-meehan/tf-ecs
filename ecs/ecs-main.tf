resource "aws_lb" "ecs_lb" {
  name            = "ecs-lb-tf"
  subnets         = var.subnet_ids
  security_groups = [var.sg_ids]
}

resource "aws_lb_target_group" "lighttpd_tg" {
  name        = "lighttpd-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

   health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    unhealthy_threshold = "2"
  }

}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.ecs_lb.id
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.lighttpd_tg.id
    type             = "forward"
  }
}


resource "aws_ecs_task_definition" "app_def_tf" {
  family                   = "lighttpd-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  execution_role_arn       = "arn:aws:iam::535566415663:role/LabRole"

  container_definitions = <<DEFINITION
[
  {
    "image": "535566415663.dkr.ecr.us-east-1.amazonaws.com/tf-cloud:latest",
    "cpu": 1024,
    "memory": 2048,
    "name": "lighttpd-service",
    "networkMode": "awsvpc",
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ]
  }
]
DEFINITION
}

resource "aws_ecs_cluster" "ecs_tf" {
  name = "tf-cluster"
}

resource "aws_ecs_service" "lighttpd_app_tf" {
  name            = "lighttpd-app-tf"
  cluster         = aws_ecs_cluster.ecs_tf.id
  task_definition = aws_ecs_task_definition.app_def_tf.arn
  desired_count   = 3
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [var.sg_ids]
    subnets         = var.subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lighttpd_tg.id
    container_name   = "lighttpd-service"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.ecs_listener]
}

resource "aws_appautoscaling_target" "ecs_target_scaling" {
  max_capacity       = 3
  min_capacity       = 2
  resource_id        = "service/${aws_ecs_cluster.ecs_tf.name}/${aws_ecs_service.lighttpd_app_tf.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"


  depends_on = [aws_ecs_cluster.ecs_tf, aws_ecs_service.lighttpd_app_tf]
}