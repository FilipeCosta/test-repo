tag="v1.2.20"
new_tag=$(echo "$tag" | sed -E 's/v([0-9]+)\.([0-9]+)\.([0-9]+)/printf "v\1.\2.$((\3 + 1))"/ge')
echo "$new_tag"