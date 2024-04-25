
# Check if on main branch
current_branch=$(git branch --show-current)
default_tag="v0.1"

# First checks if we are on the main branch
if [ "$current_branch" != "main" ]; then
    echo "Error: You are not on the main branch."
    exit 1
fi

# Makes sure user has a clean main branch without pending changes
if [ -n "$(git status --porcelain)" ]; then
    echo "Error: There are pending changes in the working directory."
    exit 1
fi

# Fetch from remote and reset to main/branch, with that we make sure we have the latest main changes.
git fetch
if [ $? -ne 0 ]; then
    echo "Error: Failed to fetch from origin."
    exit 1
fi

git reset --hard origin/main
if [ $? -ne 0 ]; then
    echo "Error: Failed to reset to origin/main."
    exit 1
fi

echo "Successfully reset to the main branch"

latest_tag=$(git tag -l)

if [ -z "$latest_tag" ]; then
    new_tag="$default_tag"
    echo "The latest tag is ${defualt_tag}"
else
    new_tag=$(echo "$tag" | sed -E 's/v([0-9]+)\.([0-9]+)\.([0-9]+)/printf "v\1.\2.$((\3 + 1))"/ge')
    echo "The latest tag is ${latest_tag}"
fi

echo "Do you want to publish tag ${new_tag}? (yes/no)"
read response

if [[ "$response" =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "User confirmed. Proceeding..."
else
    echo "Operation canceled"
fi

