
# Check if on main branch
current_branch=$(git branch --show-current)
default_tag="v0.0.1"

# ANSI color codes
RED='\033[0;31m'
NC='\033[0m' # No Color

# First checks if we are on the main branch
if [ "$current_branch" != "main" ]; then
    echo -e "${RED}Error: You are not on the main branch.${NC}"
    exit 1
fi

# Makes sure user has a clean main branch without pending changes
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${RED}Error: There are pending changes in the working directory.${NC}"
    exit 1
fi

 Fetch from remote and reset to main/branch, with that we make sure we have the latest main changes.
git fetch
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to fetch from origin.${NC}"
    exit 1
fi

git reset --hard origin/main
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to reset to origin/main.${NC}"
    exit 1
fi

echo "Successfully reset to the main branch"

latest_tag=$(git tag -l)
new_tag=$default_tag

echo "test -${latest_tag}"

#increment minor version
if [ -n "$latest_tag" ]; then
    new_tag=$(echo "$latest_tag" | sed -E 's/v([0-9]+)\.([0-9]+)\.([0-9]+)/printf "v\1.\2.$((\3 + 1))"/ge')
    echo "The latest tag is ${new_tag}"
fi

echo "Do you want to publish tag ${new_tag}? (yes/no)"
read response

if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "User confirmed. Proceeding..."
else
    echo "Operation canceled"
fi

