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

pnpm version patch

new_tag=$(cat package.json | grep '"version"' | awk -F'"' '{print $4}')

echo "Do you want to publish tag ${new_tag}? (y/n)"
read response

if [[ "$response" =~ ^[Yy]$ ]]; then
    # Lets make it as a transaction and break the flow if some of the commands fail to execute
    pnpm build
    # Remove if we already have the build in our tmp folder
    rm -rf /tmp/build 
    # We should force it, since we always want to override the build folder on releases
    mv build /tmp/build
    git checkout -f release
    rm -rf build
    mkdir build
    mv /tmp/build .
    # We need force for both tag/push because a tag doesn't get updated by running git commit. 
    git add .
    git commit -m "Release ${new_tag}"
    git tag -f $new_tag
    git push origin --force $new_tag
    git push origin release
    git checkout main

    echo -e "\n${GREEN}Release completed successfully${NC} - ${releases_remote_url}${new_tag}"
else
    git checkout .
    echo "Operation canceled"
fi