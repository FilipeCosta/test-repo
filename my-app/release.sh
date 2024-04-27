#!/usr/bin/env bash
default_tag="v0.0.1"

releases_remote_url="https://github.com/FilipeCosta/test-repo/releases/tag/"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

set -eu

# First checks if we are on the main branch
current_branch=$(git branch --show-current)
if [ "$current_branch" != "main" ]; then
    echo -e "${RED}Error: You are not on the main branch.${NC}"
    exit 1
fi

# Makes sure user has a clean main branch without pending changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: There are pending changes in the working directory.${NC}"
    exit 1
fi

# Delete all local tags
git tag -l | xargs git tag -d

# Delete local release branch that might have commited changes and sync bellow.
if git show-ref --verify --quiet "refs/heads/release"; then
    git branch -D release
fi

# Fetch branches/tags from remote.
git fetch --all
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to fetch from origin.${NC}"
    exit 1
fi

# Reset to main/branch, with that we make sure we have the latest main changes
git reset --hard origin/main
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to reset to origin/main.${NC}"
    exit 1
fi

echo "Successfully reset to the main branch"

latest_tag=$(git ls-remote --tags origin | cut -d '/' -f 3 | sort -V | tail -n 1)
new_tag=$default_tag

# Increment minor version
if [ -n "$latest_tag" ]; then
    echo "latest tag is: $latest_tag"
    new_tag=$(echo "$latest_tag" | awk -F'[.]' '{print $1 "." $2 "." $3 + 1}')
else
    echo "No remote tags found"
fi

echo "Do you want to publish tag ${new_tag}? (y/n)"
read response

if [[ "$response" =~ ^[Yy]$ ]]; then
    # Lets make it as a transaction and break the flow if some of the commands fail to execute
    pnpm build
    # Remove if we already have the build in our tmp folder
    rm -rf /tmp/dist 
    # We should force it, since we always want to override the dist folder on releases
    mv dist /tmp/dist
    git checkout -f release
    rm -rf dist
    mkdir dist
    mv /tmp/dist .
    # We need force for both tag/push because a tag doesn't get updated by running git commit. 
    git tag -f $new_tag
    git add .
    git commit -m "Release ${new_tag}"
    git push origin --force $new_tag
    git checkout main

    echo -e "\n${GREEN}Release completed successfully${NC} - ${releases_remote_url}${new_tag}"
else
    echo "Operation canceled"
fi