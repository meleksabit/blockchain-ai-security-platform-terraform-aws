resource "aws_security_group" "alb" {
  name   = "blockchain-ai-alb-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "blockchain-ai-alb-sg" }
}

resource "aws_lb" "main" {
  name               = "blockchain-ai-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids
  tags               = { Name = "blockchain-ai-lb" }
}

resource "aws_lb_target_group" "blockchain_monitor" {
  name        = "tg-blockchain-monitor-8081"
  port        = 8081
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/health" }
}

resource "aws_lb_target_group" "anomaly_detector" {
  name        = "tg-anomaly-detector-8082"
  port        = 8082
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/health" }
}

resource "aws_lb_target_group" "dashboard" {
  name        = "tg-dashboard-8083"
  port        = 8083
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/dashboard" }
}

resource "aws_lb_target_group" "ai_agent" {
  name        = "tg-ai-agent-8000"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/health" }
}

resource "aws_lb_target_group" "vault" {
  name        = "tg-vault-8200"
  port        = 8200
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check { path = "/v1/sys/health" }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Welcome to Blockchain AI Security Platform"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "blockchain_monitor" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 100
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blockchain_monitor.arn
  }
  condition {
    path_pattern { values = ["/block/*", "/health"] }
  }
}

resource "aws_lb_listener_rule" "anomaly_detector" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 90
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.anomaly_detector.arn
  }
  condition {
    path_pattern { values = ["/anomaly/*", "/health"] }
  }
}

resource "aws_lb_listener_rule" "dashboard" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 80
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.dashboard.arn
  }
  condition {
    path_pattern { values = ["/dashboard"] }
  }
}

resource "aws_lb_listener_rule" "ai_agent" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 70
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ai_agent.arn
  }
  condition {
    path_pattern { values = ["/analyze", "/health"] }
  }
}

resource "aws_lb_listener_rule" "vault" {
  listener_arn = aws_lb_listener.main.arn
  priority     = 60
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.vault.arn
  }
  condition {
    path_pattern { values = ["/v1/*"] }
  }
}
