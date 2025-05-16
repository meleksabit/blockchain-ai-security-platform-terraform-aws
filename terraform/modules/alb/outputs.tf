output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "alb_target_groups" {
  value = {
    blockchain_monitor = aws_lb_target_group.blockchain_monitor.arn
    anomaly_detector   = aws_lb_target_group.anomaly_detector.arn
    dashboard          = aws_lb_target_group.dashboard.arn
    ai_agent           = aws_lb_target_group.ai_agent.arn
    vault              = aws_lb_target_group.vault.arn
  }
}
