
default_tag="v0.0.1"

releases_remote_url="https://github.com/FilipeCosta/test-repo/releases/tag/"

# ANSI color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

latest_tag=$(git tag -l)
new_tag=$default_tag

[ -n "$latest_tag" ] && echo "latest tag is: $latest_tag" || echo "No remote tags found"

# Increment minor version
if [ -n "$latest_tag" ]; then
    new_tag=$(echo "$latest_tag" | sed -E 's/v([0-9]+)\.([0-9]+)\.([0-9]+)/printf "v\1.\2.$((\3 + 1))"/ge')
fi

echo "Do you want to publish tag ${new_tag}? (yes/no)"
read response

if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    # Lets make it as a transaction and break the flow if some of the commands fail to execute
    set -e

    pnpm build
    git checkout release
    git add .
    git commit -m "Release ${new_tag}"
    git tag $new_tag
    git push origin $new_tag
    git checkout main

    echo -e "\n${GREEN}Release completed successfully${NC} - ${releases_remote_url}${new_tag}"

    set +e
else
    echo "Operation canceled"
fi

