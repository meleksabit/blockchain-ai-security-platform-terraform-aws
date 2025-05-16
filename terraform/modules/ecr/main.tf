resource "aws_ecr_repository" "blockchain_monitor" {
  name = "blockchain-monitor-repo"
}

resource "aws_ecr_repository" "anomaly_detector" {
  name = "anomaly-detector-repo"
}

resource "aws_ecr_repository" "dashboard" {
  name = "dashboard-repo"
}

resource "aws_ecr_repository" "ai_agent" {
  name = "ai-agent-repo"
}
