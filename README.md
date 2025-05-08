# CI/CD Pipeline for Containerized Web Application

A production-ready CI/CD pipeline implementation for containerized web applications using GitHub Actions, Docker, and Kubernetes.

## Features

- 🔄 Automated CI/CD workflows
- 🐳 Docker containerization
- ☸️ Kubernetes deployment
- 🔒 Security scanning
- 📊 Health monitoring
- 🔄 Automatic rollbacks
- 📝 Comprehensive logging

## Prerequisites

- GitHub account with repository access
- Docker installed locally
- Kubernetes cluster (EKS)
- AWS CLI configured
- Node.js 18 or higher

## Quick Start

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/your-repo.git
   cd your-repo
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Configure environment variables in GitHub repository settings:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`
   - `EKS_CLUSTER_NAME`
   - `SNYK_TOKEN`

4. Push to develop branch to trigger staging deployment:
   ```bash
   git checkout -b develop
   git push origin develop
   ```

## Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature
   ```

2. Make changes and commit:
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

3. Push changes and create PR:
   ```bash
   git push origin feature/your-feature
   ```

4. Merge to develop for staging deployment
5. Create PR to main for production deployment

## Pipeline Stages

### CI Pipeline
- Linting
- Unit & Integration Testing
- Container Building
- Security Scanning

### CD Pipeline (Staging)
- Automatic deployment on develop branch
- Smoke Tests
- Health Monitoring

### CD Pipeline (Production)
- Manual approval required
- Canary Deployment
- Automatic Rollback
- Extended Health Monitoring

## Directory Structure

```
.
├── .github/
│   ├── workflows/          # GitHub Actions workflows
│   └── dependabot.yml      # Dependency updates
├── k8s/                    # Kubernetes manifests
│   ├── staging/
│   └── production/
├── nginx/                  # Nginx configuration
├── scripts/               # Utility scripts
├── src/                   # Application source
└── docs/                  # Documentation
```

## Monitoring & Troubleshooting

- View GitHub Actions dashboard for pipeline status
- Check deployment logs in Kubernetes
- Monitor application health endpoints
- Review security scan reports

## Security

- Automated vulnerability scanning
- Secret management
- Container security best practices
- Regular dependency updates

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

MIT License - see [LICENSE](LICENSE) for details