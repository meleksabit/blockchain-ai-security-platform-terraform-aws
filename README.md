# $\color{Goldenrod}{₿lockchain\ AI\ Security\ Platform\}$

[![Lint](https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws/actions/workflows/super-linter.yml/badge.svg)](https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws/actions/workflows/super-linter.yml) [![PR Title Check](https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws/actions/workflows/pr-title-linter.yml/badge.svg)](https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws/actions/workflows/pr-title-linter.yml) [![GitHub Release](https://img.shields.io/github/v/release/meleksabit/blockchain-ai-security-platform-terraform-aws)](https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws/releases)

### An ֎🇦🇮-powered security platform for detecting anomalies in blockchain transactions, built with Terraform <img width="50" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/terraform.png" alt="Terraform" title="Terraform"/> for AWS <img width="50" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/aws.png" alt="AWS" title="AWS"/> infrastructure, Helm <img height="32" width="32" src="https://cdn.simpleicons.org/helm" /> for Kubernetes <img height="32" width="32" src="https://cdn.simpleicons.org/kubernetes" /> deployments, and a CI/CD <img height="32" width="32" src="https://cdn.simpleicons.org/jenkins" /> pipeline. The platform integrates AI agents <img height="32" width="32" src="https://cdn.simpleicons.org/openai" />, Go <img width="50" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/go.png" alt="Go" title="Go"/> microservices, RDS <img height="32" width="32" src="https://cdn.simpleicons.org/amazonrds" />, and containerized deployments for a robust DevSecOps solution.

## Table of Contents
- [Implementation Overview](#implementation-overview)
- [Prerequisites](#prerequisites)
- [Project Structure: Directory Overview](#%EF%B8%8Fproject-structure-directory-overview)
- [Setup](#setup)
  - [Configure Terraform Cloud](#configure-terraform-cloud)
  - [Configure Vault](#configure-vault)
    - [Option 1: Docker Compose (Local)](#option-1-docker-compose-local)
    - [Option 2: Helm (Local or EKS)](#option-2-helm-local-or-eks)
    - [Option 3: AWS Secrets Manager](#option-3-aws-secrets-manager)
  - [IAM Role (TerraformCloudRole)](#iam-role-terraformcloudrole)
  - [Optimize Uploads](#optimize-uploads)
- [Deploy Infrastructure and Application](#%EF%B8%8Fdeploy-infrastructure-and-application)
  - [Local Testing (Kubernetes)](#local-testing-kubernetes)
  - [AWS Deployment (Terraform Cloud)](#%EF%B8%8Faws-deployment-terraform-cloud)
- [Infrastructure Details](#%EF%B8%8Finfrastructure-details)
- [Troubleshooting](#%EF%B8%8Ftroubleshooting)

## 💡🚀Implementation Overview

- **Purpose**: Monitors blockchain transactions (Ethereum testnet) for anomalies using AI-driven microservices, a dashboard, and RDS for data persistence.
- **Testing**:
  - **Local**: Tested on a local Kubernetes cluster via `kubectl` (e.g., Docker Desktop, Kind).
  - **AWS**: Deployed via Terraform Cloud.
- **Components**:
  - <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/python.png" alt="Python" title="Python"/> **AI Agent**: Core anomaly detection service (port 8000).
  - <img height="32" width="32" src="https://cdn.simpleicons.org/go" /> **Go Microservices**:
    - `blockchain-monitor`: Tracks transactions (port 8081).
    - `anomaly-detector`: Analyzes anomalies (port 8082).
    - `dashboard`: Visualizes transaction data (port 8083, LoadBalancer).
  - <img height="32" width="32" src="https://cdn.simpleicons.org/vault" /> **Vault**: HashiCorp Vault for secret management (port 8200).
  - <img height="32" width="32" src="https://cdn.simpleicons.org/postgresql" /> **RDS**: Relational database for storing transaction metadata.
- **Secrets**: Sensitive variables (e.g., Infura API key, RDS credentials) stored in HashiCorp Vault (`vault.vault.svc.cluster.local`).
- <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/ethereum.png" alt="Ethereum" title="Ethereum"/> **Blockchain**: Anomalies implemented using Ethereum testnet (via Infura).
- **Helm Charts**:
  - Located in `helm/` (`ai-agent`, `go-microservices/blockchain-monitor`, `go-microservices/anomaly-detector`, `go-microservices/dashboard`).
  - Configures replicas, image tags, service types, and environment variables.
- **Health Checks** (Kubernetes):
  - **Liveness Probe**: Ensures pods are running (e.g., `/health` for `ai-agent`, `/dashboard` for dashboard).
  - **Readiness Probe**: Confirms pods are ready to serve traffic.
  - **Startup Probe**: Allows initial pod startup (e.g., 30 retries for dashboard).
  - Example (dashboard):
    ```yaml
      probes:
    liveness:
      enabled: true
      path: "/dashboard"
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 2
      failureThreshold: 3
    readiness:
      enabled: true
      path: "/dashboard"
      initialDelaySeconds: 5
      periodSeconds: 10
      timeoutSeconds: 2
      failureThreshold: 3
    startup:
      enabled: true
      path: "/dashboard"
      initialDelaySeconds: 5
      periodSeconds: 5
      timeoutSeconds: 2
      failureThreshold: 30
    ```
- **Database**: AWS RDS (configured in `terraform/modules/rds/`) for persistent storage, with IAM role (`rds-service-role`) for enhanced monitoring and S3 backups.
- <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/jenkins.png" alt="Jenkins" title="Jenkins"/> **CI/CD**: Jenkins pipeline (`Jenkinsfile`) builds/pushes Docker images to ECR and deploys to EKS via Helm.

## 📝✅Prerequisites

1. <img height="32" width="32" src="https://cdn.simpleicons.org/amazonwebservices" /> **AWS Account**:
   - Active account with IAM user access keys (EKS, EC2, ELB, ECR, IAM, S3, RDS permissions).
   - Region: `eu-central-1`.

2. **Tools**:
   - <img height="32" width="32" src="https://cdn.simpleicons.org/terraform" /> **Terraform**: Install version `1.11.4`:
     ```bash
     # Linux (Ubuntu/Debian)
     sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
     wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
     echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
     sudo apt-get update && sudo apt-get install terraform=1.11.4
     ```
     Alternatively, use `tfenv` for version management:
     ```bash
     tfenv install 1.11.4
     tfenv use 1.11.4
     ```
   - <img height="32" width="32" src="https://cdn.simpleicons.org/gnometerminal" /> **AWS CLI**: Configured via `~/.aws/config` and `~/.aws/credentials`:
     ```bash
     # Example ~/.aws/credentials
     [default]
     aws_access_key_id = <your-access-key>
     aws_secret_access_key = <your-secret-key>

     # Example ~/.aws/config
     [default]
     region = eu-central-1
     output = json
     ```
     Alternatively, use:
     ```bash
     aws configure
     ```
   - <img height="32" width="32" src="https://cdn.simpleicons.org/helm" /> **Helm**: For deploying application charts.
   - <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/kubernetes.png" alt="Kubernetes" title="Kubernetes"/> **kubectl**: For Kubernetes interaction.
   - <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/docker.png" alt="Docker" title="Docker"/> **Docker**: For local testing (e.g., Docker Desktop).
   - <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/github.png" alt="GitHub" title="GitHub"/> **Git**: Clone the repository:
     ```bash
     git clone https://github.com/meleksabit/blockchain-ai-security-platform-terraform-aws.git
     cd blockchain-ai-security-platform-terraform-aws
     ```

3. <img width="33" src="https://raw.githubusercontent.com/marwin1991/profile-technology-icons/refs/heads/main/icons/vault.png" alt="Vault" title="Vault"/> **HashiCorp Vault**:
   - Local testing: Run via `docker-compose.yml` or Helm (see below).
   - EKS: Deployed via Helm and terraform/modules/vault.

## 🌲🗀️Project Structure: Directory Overview
This section outlines the repository’s directory structure to help you navigate the project’s key components, including Terraform modules, Helm charts, Go microservices, and CI/CD configuration.

```bash
.
├── ai-agent
│   ├── ai_agent.py
│   ├── Dockerfile
│   └── requirements.txt
├── docker-compose.yml
├── go-services
│   ├── anomaly-detector
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── main.go
│   ├── blockchain-monitor
│   │   ├── Dockerfile
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── main.go
│   └── dashboard
│       ├── Dockerfile
│       ├── go.mod
│       ├── go.sum
│       ├── main.go
│       └── templates
│           └── dashboard.tmpl
├── helm
│   ├── ai-agent
│   │   ├── Chart.yaml
│   │   ├── templates
│   │   │   ├── deployment.yaml
│   │   │   ├── hpa.yaml
│   │   │   ├── rbac.yaml
│   │   │   ├── rolebinding.yaml
│   │   │   ├── serviceaccount.yaml
│   │   │   └── service.yaml
│   │   └── values.yaml
│   ├── go-microservices
│   │   ├── anomaly-detector
│   │   │   ├── Chart.yaml
│   │   │   ├── templates
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── hpa.yaml
│   │   │   │   ├── rolebinding.yaml
│   │   │   │   ├── role.yaml
│   │   │   │   ├── serviceaccount.yaml
│   │   │   │   └── service.yaml
│   │   │   └── values.yaml
│   │   ├── blockchain-monitor
│   │   │   ├── Chart.yaml
│   │   │   ├── templates
│   │   │   │   ├── deployment.yaml
│   │   │   │   ├── hpa.yaml
│   │   │   │   ├── rbac.yaml
│   │   │   │   ├── rolebinding.yaml
│   │   │   │   ├── role.yaml
│   │   │   │   ├── serviceaccount.yaml
│   │   │   │   └── service.yaml
│   │   │   └── values.yaml
│   │   └── dashboard
│   │       ├── Chart.yaml
│   │       ├── templates
│   │       │   ├── deployment.yaml
│   │       │   ├── hpa.yaml
│   │       │   ├── rolebinding.yaml
│   │       │   ├── role.yaml
│   │       │   ├── serviceaccount.yaml
│   │       │   └── service.yaml
│   │       └── values.yaml
│   └── vault
│       ├── Chart.yaml
│       ├── templates
│       │   ├── deployment.yaml
│       │   └── service.yaml
│       └── values.yaml
├── Jenkinsfile
├── LICENSE
├── README.md
└── terraform
    ├── backend.tf
    ├── LICENSE.txt
    ├── main.tf
    ├── modules
    │   ├── alb
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── ecr
    │   │   ├── main.tf
    │   │   └── outputs.tf
    │   ├── eks
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── security_groups.tf
    │   │   └── variables.tf
    │   ├── iam
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   ├── network
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── security_groups.tf
    │   │   ├── variables.tf
    │   │   └── variables.tfvars.disabled
    │   ├── rds
    │   │   ├── data.tf.disabled
    │   │   ├── locals.tf.disabled
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   ├── security_groups.tf
    │   │   └── variables.tf
    │   ├── s3
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── vault
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── outputs.tf
    ├── provider.tf
    ├── terraform.tfvars.disabled
    ├── variables.tf
    └── versions.tf

29 directories, 94 files
```
- **Key Directories**:
  - `terraform/`: Manages AWS infrastructure (EKS, RDS, S3, ALB, IAM, Vault).
  - `helm/`: Contains Helm charts for deploying services to Kubernetes.
  - `ai-agent/`: Source code for the AI agent service, responsible for anomaly detection.
  - `go-services/`: Source code for Go microservices (`blockchain-monitor`, `anomaly-detector`, `dashboard`).
  - `Jenkinsfile`: Defines the CI/CD pipeline for building and deploying to EKS.
  - `.terraformignore`: Optimizes Terraform Cloud uploads by excluding unnecessary files.
  
## 🔧🔩🔛Setup

1. **Configure Terraform Cloud**:
   - Edit `terraform/backend.tf` to enable Terraform Cloud backend (configured via UI or CLI).
   ```hcl
    terraform {
        cloud {
            organization = "your-organization-name"

            workspaces {
                name = "your-workspace-name"
            }
        }
    }
   ```
   - Set variables in Terraform Cloud > Variables:
     - Environment Variables:
       - `AWS_ACCESS_KEY_ID`: Valid access key.
       - `AWS_SECRET_ACCESS_KEY`: Corresponding secret key.
       - `AWS_DEFAULT_REGION`: Your deployment region.
     - Terraform Variables:
       - `aws_role_arn`: `arn:aws:iam::<your-account-id>:role/TerraformCloudRole`.
       - `allowed_ssh_ip`: `["<your-ip>/32"]` (find via `curl ifconfig.me`).

2. **Configure Vault**:
   - **Option 1: Docker Compose (Local)**:
     ```bash
     docker-compose up -d
     vault operator init
     ```
   - **Option 2: Helm (Local or EKS)**:
     - Add HashiCorp Helm repository:
       ```bash
       helm repo add hashicorp https://helm.releases.hashicorp.com
       helm repo update
       ```
     - Install Vault locally (e.g., Docker Desktop):
       ```bash
       helm install vault hashicorp/vault --namespace default --set "server.dev.enabled=true"
       ```
     - For EKS, deploy with production-ready settings (after Terraform applies `terraform/modules/vault`):
       ```bash
       helm install vault hashicorp/vault --namespace default --set "server.ha.enabled=true" --set "server.ha.replicas=3"
       ```
     - Initialize and unseal Vault:
       ```bash
       kubectl exec -it vault-0 -- vault operator init
       kubectl exec -it vault-0 -- vault operator unseal <unseal-key-1>
       kubectl exec -it vault-0 -- vault operator unseal <unseal-key-2>
       kubectl exec -it vault-0 -- vault operator unseal <unseal-key-3>
       ```
   - Store secrets (e.g., Infura API key, RDS credentials):
     ```bash
     vault kv put secret/infura api_key=<your-infura-api-key>
     vault kv put secret/rds username=<rds-username> password=<rds-password>
     ```

  > [!WARNING]
  > This project uses Vault’s `kv-v2` secrets engine, so secrets are stored internally at `secret/data/<path>` (e.g., `secret/data/infura`). Use `vault kv get secret/infura` to retrieve the latest version, as the CLI automatically maps `secret/<path>` to `secret/data/<path>`. To access a specific version, use `vault kv get -version=<version> secret/infura`. If the Infura API key is rotated, update it with `vault kv put secret/infura api_key=<new-key>` and verify with `vault kv get secret/infura`. Ensure services (e.g., Helm charts) are configured to fetch secrets from `secret/data/<path>` when using Vault’s API or secret injection. The shorthand CLI syntax (`secret/<path>`) is correct but may cause confusion since it doesn’t reflect the full internal path (`secret/data/<path>`). For details, see the official Vault CLI tutorial: https://developer.hashicorp.com/vault/tutorials/get-started/learn-cli.

   - **Option 3: AWS Secrets Manager**:
     - Use AWS Secrets Manager to store secrets as an alternative to Vault. Ensure the IAM role (`TerraformCloudRole`) has `secretsmanager:CreateSecret`, `secretsmanager:PutSecretValue`, and `secretsmanager:GetSecretValue` permissions.
     - Store secrets using AWS CLI or Console:
       ```bash
       # Infura API key
       aws secretsmanager create-secret --name infura --secret-string '{"api_key":"<your-infura-api-key>"}' --region eu-central-1
       # RDS credentials
       aws secretsmanager create-secret --name rds --secret-string '{"username":"<rds-username>","password":"<rds-password>"}' --region eu-central-1
       ```
     - Retrieve secrets for verification:
       ```bash
       aws secretsmanager get-secret-value --secret-id infura --region eu-central-1
       aws secretsmanager get-secret-value --secret-id rds --region eu-central-1
       ```
     - Configure services (e.g., Helm charts) to access secrets via AWS SDK or Kubernetes secrets:
       - **Option A: IAM Role**: Assign an IAM role to EKS pods (e.g., via IRSA) with `secretsmanager:GetSecretValue` permissions. Update Helm charts (e.g., `helm/go-microservices/blockchain-monitor/values.yaml`) to use AWS SDK to fetch secrets.
       - **Option B: Kubernetes Secrets**: Use the AWS Secrets Manager CSI Driver to mount secrets as Kubernetes secrets. Install the driver:
         ```bash
         helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
         helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
         ```
         Create a `SecretProviderClass` and update Helm charts to mount secrets. Example (`SecretProviderClass`):
         ```yaml
         apiVersion: secrets-store.csi.x-k8s.io/v1
         kind: SecretProviderClass
         metadata:
           name: aws-secrets
           namespace: default
         spec:
           provider: aws
           parameters:
             objects: |
               - objectName: "infura"
                 objectType: "secretsmanager"
                 objectAlias: "infura.json"
               - objectName: "rds"
                 objectType: "secretsmanager"
                 objectAlias: "rds.json"
         ```
         Update Helm chart (e.g., `values.yaml`):
         ```yaml
         volumes:
           - name: secrets
             csi:
               driver: secrets-store.csi.k8s.io
               readOnly: true
               volumeAttributes:
                 secretProviderClass: "aws-secrets"
         volumeMounts:
           - name: secrets
             mountPath: "/mnt/secrets"
             readOnly: true
         ```
     - For more details, see the AWS Secrets Manager documentation: https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html.

3. **Configure Blockchain Network**:
Set the blockchain network for the `blockchain-monitor` and `ai-agent` services using the `NETWORK` environment variable. Supported networks are:

- **mainnet**: Ethereum mainnet (production, requires Infura API key with mainnet access).
- **sepolia**: Sepolia testnet (default, recommended for testing).
- **holesky**: Holesky testnet (alternative testnet for validator and staking tests).
- **hoodi**: Hoodi testnet (new testnet for Pectra upgrade testing).
- **local**: Local Ethereum node (e.g., Hardhat, Ganache) for development.

<table>
<tr>
<th>⚠️ⓘ❗ <b>NOTE</b></th>
</tr>
<tr>
<td width="33%"">
Obtain an Infura API key by creating an account at <b><i>[infura.io](https://infura.io) (MetaMask wallet login supported)</b></i>. Avoid using MetaMask’s default Infura key due to rate limits, as it is shared and heavily restricted. Using mainnet incurs <b><i>higher Infura API costs</b></i> and interacts with <b><i>real</b></i> Ethereum transactions. Ensure your Infura API key supports mainnet and testnet access and use <b><i>cautiously</b></i> in production environments.
</td>
</tr>
</table>

### To configure the network:

  1. **Set the NETWORK environment variable**:
      - For local testing:
      ```bash
      export NETWORK=<mainnet|sepolia|holesky|hoodi|local>
      ```
      - For EKS deployment, update Helm values:
      ```bash
      helm upgrade --install blockchain-monitor ./helm/go-microservices/blockchain-monitor --set env.NETWORK=<mainnet|sepolia|holesky|hoodi|local>
      helm upgrade --install ai-agent ./helm/ai-agent --set env.NETWORK=<mainnet|sepolia|holesky|hoodi|local>
      ```
  2. **Verify network configuration**:
      - Check the `/health` endpoint for each service:
      ```bash
      curl http://<blockchain-monitor-load-balancer>:8081/health
      curl http://<ai-agent-load-balancer>:8000/health
      ```
      - Ensure the `network` field matches the configured value.

4. **IAM Role (`TerraformCloudRole`)**:
   - Ensure trust policy allows Terraform Cloud user:
     ```json
     {
       "Version": "2012-10-17",
       "Statement": [
         {
           "Effect": "Allow",
           "Principal": { "AWS": "<terraform-cloud-user-arn>" },
           "Action": "sts:AssumeRole"
         }
       ]
     }
     ```
   - Permissions: EKS, EC2, ELB, ECR, IAM, S3, RDS.

5. **Optimize Uploads**:
   - To optimize uploads in Terraform Cloud, it’s recommended to create a `.terraformignore` file in the project root to exclude unnecessary files, reducing upload size and speeding up Terraform runs. Create the file with the following content:
     ```hcl
      # .terraformignore
      # Terraform state and backup files
      *.tfstate
      *.tfstate.backup
      *.tfplan

      # Terraform internal directories
      .terraform/

      # Logs and debug artifacts
      *.log
      crash.log
      *.out
      *.err

      # AWS credentials and sensitive files
      .aws/
      *.pem
      *.key
      *.crt
      *.env
      .env.*
      credentials.json
      secrets/
      **/credentials.tfvars

      # Python artifacts
      __pycache__/
      *.pyc
      *.pyo
      *.pyd
      *.egg-info/
      *.dist-info/
      *.ipynb_checkpoints/
      *.sqlite3
      *.db
      .venv/
      venv/
      env/

      # Docker build cache and local overrides
      Dockerfile.*
      docker-compose.override.yml
      *.tar
      *.img

      # Node-related (if present)
      node_modules/
      npm-debug.log
      yarn-error.log

      # Editor/OS/CI-related
      .idea/
      .vscode/
      *.swp
      *.swo
      *.bak
      *.tmp
      .DS_Store
      Thumbs.db

      # Git
      .git/
      .gitignore
      .gitattributes

      # Tests & coverage (optional)
      coverage/
      tests/__pycache__/
      test-results/

      # Model cache (if using Hugging Face Transformers)
      model_cache/
      transformers_cache/
      huggingface/
     ```
   - This excludes Terraform state, logs, credentials, Python artifacts, Docker files, editor files, Git, and non-essential Helm files while including critical Helm templates and configurations.

## 💻➡️🟢Deploy Infrastructure and Application

### 🐳☸Local Testing (Kubernetes)
1. Start a local Kubernetes cluster (e.g., Docker Desktop):
   ```bash
   kubectl cluster-info
   ```
2. Deploy Vault (via Helm or Docker Compose, see [Setup](#setup)).
3. Install Helm Charts:
   ```bash
   helm install ai-agent ./helm/ai-agent --set image.repository=<local-ai-agent-image>
   helm install blockchain-monitor ./helm/go-microservices/blockchain-monitor --set image.repository=<local-blockchain-monitor-image>
   helm install anomaly-detector ./helm/go-microservices/anomaly-detector --set image.repository=<local-anomaly-detector-image>
   helm install dashboard ./helm/go-microservices/dashboard --set image.repository=<local-dashboard-image>
   ```
   - Replace `<local-*-image>` with the locally built Docker image tags for each service (e.g., `ai-agent:latest`, `blockchain-monitor:latest`, etc.).
4. Verify pods and health checks:
   ```bash
   kubectl get pods
   kubectl describe pod <dashboard-pod>
   ```

### ☁️📄🚀AWS Deployment (Terraform Cloud)
1. Initialize Terraform:
   ```bash
   cd terraform
   terraform init
   ```
2. Format and Validate:
   ```bash
   terraform fmt
   terraform validate
   ```
   - Ensure no errors in the configuration files. 

3. Plan and Apply:
   ```bash
   terraform plan
   terraform apply
   ```
   - Deploys EKS (`blockchain_eks`), ALB, S3 (`blockchain-ai-models-prod`, `blockchain-logs-prod`), RDS, IAM roles, ECR, VPC.

4. Configure EKS:
   ```bash
   aws eks update-kubeconfig --region eu-central-1 --name blockchain_eks
   ```

5. Deploy Vault (via Helm, see [Setup](#setup)).

6. Deploy Application via Helm:
   ```bash
   helm upgrade --install ai-agent ./helm/ai-agent --namespace default --set image.repository=<ecr-repo>/ai-agent
   helm upgrade --install blockchain-monitor ./helm/go-microservices/blockchain-monitor --namespace default --set image.repository=<ecr-repo>/blockchain-monitor
   helm upgrade --install anomaly-detector ./helm/go-microservices/anomaly-detector --namespace default --set image.repository=<ecr-repo>/anomaly-detector
   helm upgrade --install dashboard ./helm/go-microservices/dashboard --namespace default --set image.repository=<ecr-repo>/dashboard
   ```
   - Replace `<ecr-repo>` with your ECR registry URI (from `Jenkinsfile`).
   - Alternatively, use the provided `Jenkinsfile` to automate building, pushing Docker images to ECR, and deploying these Helm charts to EKS. Run the Jenkins pipeline after configuring Jenkins with `aws-credentials` and `ecr-registry-uri` credentials.

7. Access Dashboard:
   ```bash
   kubectl get svc dashboard --namespace default
   ```
   - Use the LoadBalancer URL (port 8083).

## 🏗️🧱📐Infrastructure Details
Infrastructure is managed in the `terraform/` folder:
- **Modules**: `eks`, `alb`, `s3`, `iam`, `network`, `vault`, `rds`, `vault`.
- **Resources**:
  - EKS cluster (`blockchain_eks`) with Spot instances.
  - ALB with target groups (`blockchain-monitor:8081`, `anomaly-detector:8082`, `dashboard:8083`, `ai-agent:8000`, `vault:8200`).
  - S3 buckets with lifecycle policies (180 days for models, 90 days for logs).
  - RDS instance for transaction metadata, with IAM role for monitoring.
  - Vault service for secret management, with infrastructure provisioned by Terraform and deployed via Helm.
  - VPC with public/private subnets.
- Deploy via Terraform Cloud (see [AWS Deployment (Terraform Cloud)](#%EF%B8%8Faws-deployment-terraform-cloud)).

## ⚠️🩺🔧Troubleshooting
- **Credentials Error**:
  - Verify `~/.aws/credentials`:
    ```bash
    aws sts get-caller-identity
    ```
- **Vault Secrets**:
  - Check connectivity:
    ```bash
    vault kv get secret/infura
    ```
- **Helm Deployment**:
  - Inspect pod logs:
    ```bash
    kubectl logs <pod-name>
    ```
- **RDS Issues**:
  - Verify RDS endpoint and credentials in Vault:
    ```bash
    vault kv get secret/rds
    ```
  - Check security group allows EKS access (port 3306 for MySQL, 5432 for PostgreSQL).

> [!IMPORTANT]
> - **Ethereum Networks**: Supports `mainnet`, `Sepolia` (default), `Holesky`, `Hoodi`, and `local` networks. Set `NETWORK` environment variable to configure (see **Setup > Configure Blockchain Network**).
> - **CI/CD**: Jenkins pipeline builds/pushes images to ECR and deploys to EKS.
> - **Health Checks**: Ensure probes are configured per service.
> - **Region**: `eu-central-1` (Frankfurt) is the default region for all AWS resources (EKS, RDS, S3, Secrets Manager). To use a different region, update AWS_DEFAULT_REGION in Terraform Cloud variables or terraform/backend.tf. Ensure consistency across resources to avoid cross-region latency or costs.
> - **Secret Rotation**: Regularly rotate sensitive secrets (e.g., Infura API key, RDS credentials) in Vault or AWS Secrets Manager to maintain security, and update dependent services accordingly.
> - **Monitoring**: Configure monitoring tools (e.g., AWS CloudWatch, Prometheus) to track EKS cluster metrics and application health, leveraging logs in S3 (blockchain-logs-prod).
> - **Cost Management**: Monitor AWS resource usage (e.g., EKS Spot instances, RDS, S3) to optimize costs, especially when using Terraform Cloud and Jenkins pipelines

For issues, check Terraform Cloud logs or review `kubectl` outputs.

[:arrow_up:](#top)
