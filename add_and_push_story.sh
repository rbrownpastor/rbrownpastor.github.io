#!/bin/bash
# add_and_push_story.sh
# Prompts for a story/family name, generates HTML, and pushes to Git

# Prompt for the story/family name
read -p "Enter the story/family name (use lowercase, hyphen for spaces): " STORY

# Paths
IMG="images/stories/$STORY.jpg"
BIO="docs/stories/$STORY.txt"
HTML="stories/$STORY.html"
STORIES_LIST="stories.html"

# Function to capitalize words for display
function title_case() {
    echo "$1" | sed -E 's/(^|-)([a-z])/\U\2/g' | sed 's/-/ /g'
}

DISPLAY_NAME=$(title_case "$STORY")

# Check if image exists
if [ ! -f "$IMG" ]; then
    echo "❌ Image $IMG not found! Place your image in images/stories/ first."
    exit 1
fi

# Check if bio exists
if [ ! -f "$BIO" ]; then
    echo "❌ Bio file $BIO not found! Place your bio in docs/stories/ first."
    exit 1
fi

# Convert text bio into HTML paragraphs
BIO_CONTENT=$(awk 'BEGIN{ORS="</p><p>"} {print $0}' "$BIO")
BIO_CONTENT="<p>$BIO_CONTENT</p>"

# Generate HTML page
cat > "$HTML" <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$DISPLAY_NAME - Fanshawe FWB Church</title>
  <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<header>
  <h1>Fanshawe Free Will Baptist Church</h1>
  <nav>
    <a href="../index.html">Home</a> |
    <a href="../stories.html">Stories</a>
  </nav>
</header>

<section class="story-page">
  <img src="../$IMG" alt="$DISPLAY_NAME" class="story-photo">
  <h2>$DISPLAY_NAME</h2>
  $BIO_CONTENT
</section>

</body>
</html>
EOL

echo "✅ HTML page generated: $HTML"

# Add to stories.html list if not already present
LINK="<li><a href=\"stories/$STORY.html\">$DISPLAY_NAME</a></li>"
if ! grep -qxF "$LINK" "$STORIES_LIST"; then
    sed -i "/<\/ul>/i $LINK" "$STORIES_LIST"
    echo "✅ stories.html updated with link to $DISPLAY_NAME"
fi

# Git add, commit, push (only if changes exist)
git add .
if git diff --cached --quiet; then
    echo "ℹ️ No changes to commit."
else
    git commit -m "Add $DISPLAY_NAME story"
    git push origin master
    echo "✅ Changes pushed to GitHub."
fi

echo "🎉 Done! $DISPLAY_NAME page generated, linked, and pushed."

