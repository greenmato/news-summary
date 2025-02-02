#!/bin/bash
set -e  # Exit on any error

echo "${GITHUB_TOKEN}" | docker login ghcr.io -u greenmato --password-stdin

# Pull the image first
echo "Pulling news summarizer image..."
docker pull ghcr.io/greenmato/news-summarizer:latest

# Run the summarizer and save output
echo "Running news summarizer..."
SUMMARY_OUTPUT=$(docker run -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" ghcr.io/greenmato/news-summarizer:latest app --month $(date -d "$(date +%Y-%m-01) -1 month" +%m) --year $(date -d "$(date +%Y-%m-01) -1 month" +%Y))

# Get today's date for the filename
DATE=$(date -d "$(date +%Y-%m-01) -1 month" +%Y-%m)
TITLE="${DATE}.md"

# Create new Hugo content
echo "Creating Hugo content..."
hugo new "content/docs/${TITLE}"

# Insert the summary into the new file
# Assuming the Hugo archetype creates frontmatter that ends with ---
echo "Updating content..."
cat > "content/docs/${TITLE}" << EOL
---
title: "$(date -d "$(date +%Y-%m-01) -1 month" "+%B %Y")"
weight: -$(date -d "$(date +%Y-%m-01) -1 month" +%Y%m)
---

${SUMMARY_OUTPUT}
EOL

# Git operations
echo "Committing changes..."
git config --global user.name "GitHub Actions Bot"
git config --global user.email "actions@github.com"
git add "content/docs/${TITLE}"
git commit -m "Add news summary for ${DATE}"
git push
sleep 30
