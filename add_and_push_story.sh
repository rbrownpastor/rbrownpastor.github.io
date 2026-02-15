#!/bin/bash
# add_and_push_story.sh
# Prompts for a story name, generates HTML, and pushes to Git

read -p "Enter the story/family name (use lowercase, hyphen for spaces): " STORY

IMG="images/stories/$STORY.jpg"
BIO="docs/stories/$STORY.txt"
HTML="stories/$STORY.html"
STORIES_LIST="stories.html"

# Check if image exists
if [ ! -f "$IMG" ]; then
    echo "Image $IMG not found! Place your image in images/stories/ first."
    exit 1
fi

# Check if bio exists
if [ ! -f "$BIO" ]; then
    echo "Bio file $BIO not found! Place your bio in docs/stories/ first."
    exit 1
fi

# Read bio content
BIO_CONTENT=$(cat "$BIO")

# Generate HTML page
cat > "$HTML" <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${STORY//-/ } - Fanshawe FWB Church</title>
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
  <img src="../$IMG" alt="${STORY//-/ }" class="story-photo">
  <h2>${STORY//-/ }</h2>
  <p>$BIO_CONTENT</p>
</section>

</body>
</html>
EOL

# Add to stories.html list if not already present
LINK="<li><a href=\"stories/$STORY.html\">${STORY//-/ }</a></li>"
grep -qxF "$LINK" "$STORIES_LIST" || sed -i "/<\/ul>/i $LINK" "$STORIES_LIST"

# Git add, commit, push
git add .
git commit -m "Add $STORY story"
git push

echo "Done! $STORY page generated, linked, and pushed."
