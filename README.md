# ContainerApp-Agent

This repository contains Docker containers for running CI/CD agents as self-hosted runners in containerized environments.

## Available Agents

### 1. GitHub Actions Self-Hosted Runner

A Docker container that runs as a GitHub Actions self-hosted runner, allowing you to run GitHub Actions workflows on your own infrastructure.

**Files:**
- `Dockerfile.github-runner` - Dockerfile for GitHub Actions runner
- `start-runner.sh` - Startup script for GitHub runner configuration
- `docker-compose.github-runner.yml` - Docker Compose configuration
- `README.github-runner.md` - Detailed documentation

**Quick Start:**

```bash
# Build the image
docker build -f Dockerfile.github-runner -t github-runner:latest .

# Run the container
docker run -d \
  -e GITHUB_URL=https://github.com/your-org \
  -e GITHUB_TOKEN=your_github_token \
  -e RUNNER_NAME=my-docker-runner \
  github-runner:latest
```

**Documentation:** See [README.github-runner.md](README.github-runner.md) for complete documentation.

### 2. Azure Pipelines Agent

A Docker container that runs as an Azure DevOps Pipeline agent with Azure CLI and Terraform pre-installed.

**Files:**
- `Dockerfile` - Dockerfile for Azure Pipelines agent
- `start.sh` - Startup script for Azure DevOps agent configuration

**Quick Start:**

```bash
# Build the image
docker build -t azure-pipelines-agent:latest .

# Run the container
docker run -d \
  -e AZP_URL=https://dev.azure.com/your-org \
  -e AZP_TOKEN=your_azure_token \
  -e AZP_POOL=your_pool_name \
  azure-pipelines-agent:latest
```

## Use Cases

- **CI/CD in Containerized Environments**: Run self-hosted agents in container orchestration platforms like Azure Container Apps, Kubernetes, or Docker Swarm
- **Isolated Build Environments**: Each container provides a clean, isolated environment for running builds and deployments
- **Scalable Infrastructure**: Easily scale up or down the number of agents based on workload
- **Custom Tooling**: Pre-install specific tools and dependencies needed for your workflows

## Security Considerations

1. **Secrets Management**: Never commit tokens or secrets to the repository. Use environment variables, Docker secrets, or secret management services.
2. **Network Isolation**: Consider network policies and firewall rules to restrict container access.
3. **Image Security**: Regularly update base images and dependencies to patch security vulnerabilities.
4. **Token Permissions**: Use tokens with minimal required permissions.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

This project is provided as-is for use in containerized CI/CD environments.
