output "repository_urls" {
  value = {
    blockchain_monitor = aws_ecr_repository.blockchain_monitor.repository_url
    anomaly_detector   = aws_ecr_repository.anomaly_detector.repository_url
    dashboard          = aws_ecr_repository.dashboard.repository_url
    ai_agent           = aws_ecr_repository.ai_agent.repository_url
  }
}
