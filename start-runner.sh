#!/bin/bash
set -e

# Required environment variables:
# - GITHUB_URL: The GitHub organization or repository URL (e.g., https://github.com/myorg or https://github.com/myorg/myrepo)
# - GITHUB_TOKEN: A GitHub Personal Access Token with appropriate permissions
# Optional environment variables:
# - RUNNER_NAME: Name for the runner (default: hostname)
# - RUNNER_WORKDIR: Working directory for the runner (default: _work)
# - RUNNER_LABELS: Comma-separated list of labels (default: self-hosted,Linux,X64)
# - RUNNER_GROUP: Runner group to add the runner to (default: Default)

# Validate required environment variables
if [ -z "$GITHUB_URL" ]; then
  echo "ERROR: GITHUB_URL environment variable is required"
  echo "Example: GITHUB_URL=https://github.com/myorg"
  exit 1
fi

if [ -z "$GITHUB_TOKEN" ]; then
  echo "ERROR: GITHUB_TOKEN environment variable is required"
  echo "You need a GitHub Personal Access Token with 'repo' and 'admin:org' scopes"
  exit 1
fi

# Set defaults for optional variables
RUNNER_NAME=${RUNNER_NAME:-$(hostname)}
RUNNER_WORKDIR=${RUNNER_WORKDIR:-_work}
RUNNER_LABELS=${RUNNER_LABELS:-self-hosted,Linux,X64}
RUNNER_GROUP=${RUNNER_GROUP:-Default}

echo "Configuring GitHub Actions runner..."
echo "  URL: ${GITHUB_URL}"
echo "  Runner Name: ${RUNNER_NAME}"
echo "  Labels: ${RUNNER_LABELS}"
echo "  Working Directory: ${RUNNER_WORKDIR}"

# Get registration token
echo "Obtaining registration token..."

# Determine if URL is for an organization or repository
if [[ "$GITHUB_URL" =~ ^https://github\.com/([^/]+)$ ]]; then
  # Organization URL
  ORG="${BASH_REMATCH[1]}"
  TOKEN_URL="https://api.github.com/orgs/${ORG}/actions/runners/registration-token"
elif [[ "$GITHUB_URL" =~ ^https://github\.com/([^/]+)/([^/]+)$ ]]; then
  # Repository URL
  OWNER="${BASH_REMATCH[1]}"
  REPO="${BASH_REMATCH[2]}"
  TOKEN_URL="https://api.github.com/repos/${OWNER}/${REPO}/actions/runners/registration-token"
else
  echo "ERROR: Invalid GITHUB_URL format"
  echo "Expected: https://github.com/myorg OR https://github.com/myorg/myrepo"
  exit 1
fi

REGISTRATION_TOKEN=$(curl -sS -X POST -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer ${GITHUB_TOKEN}" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  "${TOKEN_URL}" | jq -r '.token')

if [ -z "$REGISTRATION_TOKEN" ] || [ "$REGISTRATION_TOKEN" == "null" ]; then
  echo "ERROR: Failed to obtain registration token"
  echo "Please check your GITHUB_TOKEN permissions and GITHUB_URL"
  exit 1
fi

# Cleanup function to remove runner on exit
cleanup() {
  echo "Removing runner from GitHub..."
  ./config.sh remove --token "${REGISTRATION_TOKEN}" || true
}

trap cleanup EXIT INT TERM

# Configure the runner
./config.sh \
  --url "${GITHUB_URL}" \
  --token "${REGISTRATION_TOKEN}" \
  --name "${RUNNER_NAME}" \
  --labels "${RUNNER_LABELS}" \
  --runnergroup "${RUNNER_GROUP}" \
  --work "${RUNNER_WORKDIR}" \
  --unattended \
  --replace

echo "Starting GitHub Actions runner..."
./run.sh
