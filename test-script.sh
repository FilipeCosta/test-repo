
# Check if on main branch
current_branch=$(git branch --show-current)

if [ "$current_branch" != "main" ]; then
    echo "Error: You are not on the main branch."
    exit 1
fi

if [ -n "$(git status --porcelain)" ]; then
    echo "Error: There are pending changes in the working directory."
    exit 1
fi

echo "You are on the main branch."