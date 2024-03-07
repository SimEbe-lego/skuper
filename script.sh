#!/bin/bash
set -e

# Bash script for setting up a repository with GitHub and Databricks configuration

# Define variables
REPO="LEGO/dab-skuper"

# Function to display help
display_help() {
  echo -e "\nAvailable targets:\n"
  echo "  help            - Display help"
  echo "  setup           - Set up Databricks profile (requires: ENV)"
  echo "  auth            - Authenticate with Databricks (requires: PROFILE)"
  echo "  deploy          - Deploy Databricks bundle (requires: ENV, PROFILE)"
  echo "  destroy         - Destroy Databricks bundle (requires: ENV, PROFILE)"
  echo -e "  repo            - Initialize Git repository, create GitHub repo, and set up environments\n"
}

# Function to set up Databricks development profile
auth_setup() {
  local env=$1

  if [ -z "$env" ]; then
    echo "Usage: $0 setup <ENV>"
    exit 1
  fi
  if [ "$env" = "dev" ] || [ "$env" = "qa" ] || [ "$env" = "prod" ]; then
    echo "Setting up Databricks profile '$env'"
    databricks auth login --host "https://lego-ssc-$env.cloud.databricks.com/" -p $env
    databricks auth profiles
  else
    echo "Invalid ENV. Please provide 'dev', 'qa', or 'prod'."
  fi
}

# Function to authenticate with a Databricks profile
auth_login() {
  local profile=$1
  if [ -z "$profile" ]; then
    echo "Usage: $0 auth <PROFILE>"
    exit 1
  fi
  databricks auth login -p $profile
}

# Function to deploy Databricks bundle
deploy() {
  local env=$1
  local profile=$2

  if [ -z "$env" ] || [ -z "$profile" ]; then
    echo "Usage: $0 deploy <ENV> <PROFILE>"
    exit 1
  fi
  if [ "$env" = "dev" ] || [ "$env" = "qa" ]; then
    databricks bundle deploy -t $env -p $profile
  else
    echo "Invalid ENV. Please provide 'dev' or 'qa'."
  fi
}

# Function to destroy Databricks bundle
destroy() {
  local env=$1
  local profile=$2

  if [ -z "$env" ] || [ -z "$profile" ]; then
    echo "Usage: $0 destroy <ENV> <PROFILE>"
    exit 1
  fi
  if [ "$env" = "dev" ] || [ "$env" = "qa" ]; then
    databricks bundle destroy -t $env -p $profile
  else
    echo "Invalid ENV. Please provide 'dev' or 'qa'."
  fi
}

# Function to initialize Git repository
init_git() {
  echo "Step 1: Initializing a Git repository"
  git init
  echo "Step 2: Adding changes"
  git add .
  echo "Step 3: Committing changes"
  git commit -m "Initial commit"
  echo "Step 4: Renaming the branch to 'main'"
  git branch -M main
}

# Function to check if GitHub CLI is installed
check_install_gh() {
  if command -v gh &>/dev/null; then
    echo "GitHub CLI (gh) is already installed."
  else
    echo "GitHub CLI (gh) is not installed."

    # Check if Homebrew is installed
    if command -v brew &>/dev/null; then
      echo "Installing GitHub CLI (gh) using Homebrew..."
      brew install gh
    else
      echo "Installing GitHub CLI (gh) using apt-get..."
      sudo apt-get update
      sudo apt-get install gh
    fi
  fi
}

# Function to create GitHub repository
create_gh_repo() {
  check_install_gh
  echo "Step 5: Adding the remote 'origin'"
  gh repo create $REPO --internal --source=. --remote=origin
  echo "Step 6: Pushing to 'main' branch"
  git push -u origin main
}

# Function to create GitHub repository environments and secrets
create_gh_environments() {
  check_install_gh
  echo "Step 7: Creating GitHub environments and secrets"
  gh api -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO/environments/dev"
  gh secret set -f env/.env.dev --env dev -R $REPO
  gh api -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO/environments/qa"
  gh secret set -f env/.env.qa --env qa -R $REPO
  gh api -X PUT \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "/repos/$REPO/environments/prod"
  gh secret set -f env/.env.prod --env prod -R $REPO
}

# Main script logic
case "$1" in
help)
  display_help
  ;;
setup)
  shift
  auth_setup "$@"
  ;;
login)
  shift
  auth_login "$@"
  ;;
deploy)
  shift
  deploy "$@"
  ;;
destroy)
  shift
  destroy "$@"
  ;;
repo)
  init_git
  create_gh_repo
  create_gh_environments
  ;;
*)
  echo "Invalid argument. Use 'help' for a list of available targets."
  exit 1
  ;;
esac
