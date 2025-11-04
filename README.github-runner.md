# GitHub Self-Hosted Runner Docker Container

This Dockerfile creates a Docker container that runs as a GitHub Actions self-hosted runner. It can be used to run GitHub Actions workflows on your own infrastructure.

## Prerequisites

1. A GitHub Personal Access Token (PAT) with the following scopes:
   - For organization runners: `admin:org` scope
   - For repository runners: `repo` scope
   
   Create a token at: https://github.com/settings/tokens

2. Docker installed on your host system

## Building the Image

```bash
docker build -f Dockerfile.github-runner -t github-runner:latest .
```

You can also specify a different runner version:

```bash
docker build -f Dockerfile.github-runner --build-arg RUNNER_VERSION=2.321.0 -t github-runner:latest .
```

## Running the Container

### For an Organization

```bash
docker run -d \
  --name github-runner \
  -e GITHUB_URL=https://github.com/your-org \
  -e GITHUB_TOKEN=your_github_token \
  -e RUNNER_NAME=my-docker-runner \
  -e RUNNER_LABELS=self-hosted,Linux,X64,docker \
  github-runner:latest
```

### For a Repository

```bash
docker run -d \
  --name github-runner \
  -e GITHUB_URL=https://github.com/your-org/your-repo \
  -e GITHUB_TOKEN=your_github_token \
  -e RUNNER_NAME=my-docker-runner \
  -e RUNNER_LABELS=self-hosted,Linux,X64,docker \
  github-runner:latest
```

## Environment Variables

### Required

- `GITHUB_URL`: The GitHub organization or repository URL
  - Organization: `https://github.com/myorg`
  - Repository: `https://github.com/myorg/myrepo`

- `GITHUB_TOKEN`: GitHub Personal Access Token with appropriate permissions

### Optional

- `RUNNER_NAME`: Name for the runner (default: container hostname)
- `RUNNER_WORKDIR`: Working directory for the runner (default: `_work`)
- `RUNNER_LABELS`: Comma-separated list of labels (default: `self-hosted,Linux,X64`)
- `RUNNER_GROUP`: Runner group to add the runner to (default: `Default`)

## Using Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'

services:
  github-runner:
    build:
      context: .
      dockerfile: Dockerfile.github-runner
    environment:
      - GITHUB_URL=https://github.com/your-org
      - GITHUB_TOKEN=${GITHUB_TOKEN}
      - RUNNER_NAME=docker-runner-1
      - RUNNER_LABELS=self-hosted,Linux,X64,docker
    restart: unless-stopped
```

Then run:

```bash
export GITHUB_TOKEN=your_github_token
docker-compose up -d
```

## Running Multiple Runners

You can scale up multiple runners using Docker Compose:

```bash
docker-compose up -d --scale github-runner=3
```

Or run multiple separate containers with different names:

```bash
for i in {1..3}; do
  docker run -d \
    --name github-runner-$i \
    -e GITHUB_URL=https://github.com/your-org \
    -e GITHUB_TOKEN=your_github_token \
    -e RUNNER_NAME=docker-runner-$i \
    github-runner:latest
done
```

## Security Considerations

1. **Token Security**: Store your GitHub token securely. Consider using Docker secrets or environment variable files with restricted permissions.

2. **Container Isolation**: This runner runs with sudo capabilities inside the container. Be aware of the security implications when running untrusted workflows.

3. **Network Access**: The container needs internet access to communicate with GitHub and download dependencies.

4. **Token Permissions**: Use tokens with minimal required permissions:
   - For organization runners: Only grant access to specific repositories if possible
   - For repository runners: Use repository-scoped tokens

## Monitoring and Logs

View runner logs:

```bash
docker logs -f github-runner
```

Check runner status:

```bash
docker ps | grep github-runner
```

## Stopping and Removing

Stop the runner gracefully:

```bash
docker stop github-runner
```

The runner will automatically unregister itself from GitHub when stopped.

Remove the container:

```bash
docker rm github-runner
```

## Customization

### Adding Additional Tools

You can customize the Dockerfile to include additional tools needed for your workflows:

```dockerfile
# Add to Dockerfile.github-runner before the USER runner line
RUN apt-get update && apt-get install -y \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

### Using with Azure Container Apps

This runner can be deployed to Azure Container Apps or other container orchestration platforms. Ensure that:

1. Environment variables are properly configured
2. The container has internet access to reach GitHub
3. Persistent storage is configured if needed for the working directory

## Troubleshooting

### Runner not appearing in GitHub

1. Check the container logs: `docker logs github-runner`
2. Verify the GITHUB_URL is correct
3. Ensure the GITHUB_TOKEN has the correct permissions
4. Check network connectivity from the container

### Runner fails to start

1. Ensure all required environment variables are set
2. Check if the runner name is already in use
3. Verify Docker has enough resources (CPU, memory)

### Permission errors

If you encounter permission errors, ensure the runner user has proper permissions and the container is not trying to access restricted host resources.

## Links

- [GitHub Actions Self-Hosted Runners Documentation](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GitHub Actions Runner Releases](https://github.com/actions/runner/releases)
