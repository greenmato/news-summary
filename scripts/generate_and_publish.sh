#!/bin/bash
set -e  # Exit on any error

# Run the summarizer and save output
echo "Running news summarizer..."
SUMMARY_OUTPUT=$(docker run -e ANTHROPIC_API_KEY="${ANTHROPIC_API_KEY}" ghcr.io/greenmato/news-summarizer:latest app --month $(date +%m) --year $(date +%Y))

# Get today's date for the filename
DATE=$(date +%Y-%m)
TITLE="${DATE}.md"

# Create new Hugo content
echo "Creating Hugo content..."
hugo new "content/posts/${TITLE}.md"

# Insert the summary into the new file
# Assuming the Hugo archetype creates frontmatter that ends with ---
echo "Updating content..."
cat > "content/posts/${TITLE}.md" << EOL
---
title: "$(date +%B %Y)"
weight: -$(date +%Y%m)
---

${SUMMARY_OUTPUT}
EOL

# Git operations
echo "Committing changes..."
git config --global user.name "GitHub Actions Bot"
git config --global user.email "actions@github.com"
git add "content/posts/${TITLE}.md"
git commit -m "Add news summary for ${DATE}"
git push
