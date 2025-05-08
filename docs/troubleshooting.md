# CI/CD Pipeline Troubleshooting Guide

This guide provides detailed troubleshooting steps for common issues that may occur in our CI/CD pipeline.

## Table of Contents

1. [GitHub Actions Workflow Issues](#github-actions-workflow-issues)
2. [Docker Build Issues](#docker-build-issues)
3. [Kubernetes Deployment Issues](#kubernetes-deployment-issues)
4. [Testing Issues](#testing-issues)
5. [Security Scan Issues](#security-scan-issues)
6. [Performance and Scaling Issues](#performance-and-scaling-issues)

## GitHub Actions Workflow Issues

### Workflow doesn't start

**Symptoms:**
- Pushes or PRs don't trigger workflow runs
- No workflow runs appear in the Actions tab

**Troubleshooting steps:**
1. Check if the workflow file is in the correct location (`.github/workflows/`)
2. Verify the `on` section matches your event (branch, PR, etc.)
3. Check if the repository has Actions enabled in Settings
4. Look for syntax errors in the workflow YAML file

**Resolution:**
```bash
# Validate the workflow file syntax
yamllint .github/workflows/ci.yml

# Check GitHub API for workflow run status
curl -H "Authorization: token $GITHUB_TOKEN" \
  https://api.github.com/repos/owner/repo/actions/runs
```

### Workflow fails with permission errors

**Symptoms:**
- Error messages about insufficient permissions
- "Resource not accessible by integration" errors

**Troubleshooting steps:**
1. Check the repository's Actions permissions in Settings
2. Verify the `GITHUB_TOKEN` permissions
3. Ensure that required secrets are available to the workflow

**Resolution:**
- Update repository settings: Settings → Actions → General → Workflow permissions
- Add specific permissions to the workflow:
  ```yaml
  permissions:
    contents: read
    packages: write
  ```

## Docker Build Issues

### Docker build fails

**Symptoms:**
- Error in the build step of the workflow
- "failed to build" messages in logs

**Troubleshooting steps:**
1. Check the Dockerfile for syntax errors
2. Verify all required files are included in the build context
3. Check if base images are accessible
4. Look for resource limitations

**Resolution:**
```bash
# Test the Docker build locally
docker build -t test-image .

# Check for file permissions issues
find . -type f -name "*.sh" -exec chmod +x {} \;

# Validate Dockerfile
docker run --rm -v $(pwd):/project hadolint/hadolint:latest hadolint /project/Dockerfile
```

### Container registry authentication issues

**Symptoms:**
- "unauthorized: authentication required" errors
- Docker push fails but build succeeds

**Troubleshooting steps:**
1. Check registry credentials and secrets
2. Verify the `docker/login-action` step
3. Check image naming and tagging format

**Resolution:**
- Update the login credentials in GitHub Secrets
- Verify the registry URL is correct
- Test locally:
  ```bash
  echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
  ```

## Kubernetes Deployment Issues

### Deployment fails to apply

**Symptoms:**
- Error in the deployment step
- "unable to recognize" or "no matches for kind" errors

**Troubleshooting steps:**
1. Validate Kubernetes manifests
2. Check cluster connectivity and authentication
3. Verify namespace exists
4. Check for CRD dependencies

**Resolution:**
```bash
# Validate Kubernetes manifests
kubectl apply --dry-run=client -f k8s/staging/deployment.yaml

# Check for missing resources
kubectl get namespace staging || kubectl create namespace staging

# Verify connection to cluster
kubectl cluster-info
```

### Pods not starting or crashing

**Symptoms:**
- Deployment succeeds but pods show CrashLoopBackOff or ImagePullBackOff
- Health checks fail

**Troubleshooting steps:**
1. Check pod logs
2. Verify image exists and is accessible to the cluster
3. Check resource constraints
4. Verify container entrypoint and health check endpoints

**Resolution:**
```bash
# Check pod status
kubectl get pods -n staging

# View detailed pod description
kubectl describe pod <pod-name> -n staging

# Check logs
kubectl logs <pod-name> -n staging

# Verify image pull access
kubectl create secret docker-registry github-container-registry \
  --docker-server=ghcr.io \
  --docker-username=<username> \
  --docker-password=<token> \
  --docker-email=<email> \
  -n staging
```

## Testing Issues

### Tests failing inconsistently

**Symptoms:**
- Tests pass locally but fail in CI
- Tests fail intermittently

**Troubleshooting steps:**
1. Check for race conditions or timing issues
2. Verify environment-specific configurations
3. Look for external dependencies or services
4. Check for resource limitations in CI

**Resolution:**
```bash
# Run tests with increased verbosity
npm run test:unit -- --verbose

# Run tests with extended timeout
npm run test:integration -- --timeout 30000

# Check for flaky tests by running multiple times
for i in {1..5}; do npm test; done
```

### Integration tests failing

**Symptoms:**
- Unit tests pass but integration tests fail
- Environment-specific errors

**Troubleshooting steps:**
1. Check if required services are running and accessible
2. Verify database or API connections
3. Check for correct environment variables
4. Verify mocks or test doubles are properly configured

**Resolution:**
```bash
# Create or use a dedicated test environment
kubectl apply -f k8s/test/

# Check service connectivity
curl -v http://service-name:port/health

# Verify environment variables
echo "Environment variables:"
kubectl exec <pod-name> -n staging -- env | sort
```

## Security Scan Issues

### Vulnerability scans failing

**Symptoms:**
- Security scan step fails
- High severity vulnerabilities reported

**Troubleshooting steps:**
1. Check detailed scan results
2. Identify the affected packages or components
3. Determine if vulnerabilities are in direct or transitive dependencies
4. Check for available updates or patches

**Resolution:**
```bash
# Update dependencies
npm audit fix

# Force update of a specific package
npm install package-name@latest

# Run local security scan
npx snyk test

# Check Docker image for vulnerabilities
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image your-image:tag
```

### False positives in security scans

**Symptoms:**
- Security scan reports issues that don't apply
- Vulnerabilities in test or development dependencies

**Troubleshooting steps:**
1. Review the vulnerability details
2. Determine if the vulnerability is exploitable in your context
3. Check if the affected code is actually used

**Resolution:**
- Update the security scan configuration to exclude false positives
- Add exceptions for specific vulnerabilities with justification
- Separate dev dependencies from production dependencies

## Performance and Scaling Issues

### Slow pipeline execution

**Symptoms:**
- CI/CD pipeline takes too long to complete
- Build or test steps are particularly slow

**Troubleshooting steps:**
1. Identify the slowest steps in the pipeline
2. Check for unnecessary or redundant operations
3. Look for opportunities to parallelize steps
4. Check for resource constraints

**Resolution:**
```bash
# Use build caching
uses: docker/build-push-action@v5
with:
  cache-from: type=gha
  cache-to: type=gha,mode=max

# Optimize test execution
npm run test -- --maxWorkers=4

# Improve dependency caching
uses: actions/cache@v3
with:
  path: node_modules
  key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
```

### Resource constraints

**Symptoms:**
- Jobs failing with out-of-memory errors
- Very slow execution or timeouts

**Troubleshooting steps:**
1. Check resource usage during pipeline execution
2. Review container resource limits
3. Optimize build and test processes
4. Consider upgrading runner machine types

**Resolution:**
- Increase container resource limits in Kubernetes manifests
- Split large jobs into smaller ones
- Use more powerful GitHub-hosted runners or self-hosted runners
- Optimize Docker build with multi-stage builds and .dockerignore