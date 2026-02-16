#!/bin/bash
# manage_story.sh
# Adds or removes a story page for Fanshawe FWB Church

echo "==============================="
echo "Fanshawe FWB Church Story Manager"
echo "==============================="
echo "Choose an action:"
echo "1) Add a new story"
echo "2) Remove an existing story"
read -p "Enter 1 or 2: " ACTION

# Ensure directories exist
mkdir -p images/stories
mkdir -p docs/stories
mkdir -p stories

STORIES_LIST="stories.html"

# Function to capitalize nicely
function title_case() {
    echo "$1" | sed -E 's/(^|-)([a-z])/\U\2/g' | sed 's/-/ /g'
}

# ----------------------
# ADD STORY
# ----------------------
if [ "$ACTION" == "1" ]; then
    read -p "Enter the story/family name (use lowercase, hyphen for spaces): " STORY
    IMG="images/stories/$STORY.jpg"
    BIO="docs/stories/$STORY.txt"
    HTML="stories/$STORY.html"
    DISPLAY_NAME=$(title_case "$STORY")

    # Create bio template if missing
    if [ ! -f "$BIO" ]; then
        echo "Creating bio template: $BIO"
        echo "Write your bio here for $DISPLAY_NAME." > "$BIO"
    fi

    # Check for image
    if [ ! -f "$IMG" ]; then
        echo "⚠️ Image $IMG not found! Place your image in images/stories/ and rerun."
        exit 1
    fi

    # Convert bio to HTML paragraphs
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

# Add link to stories.html
LINK="<li><a href=\"stories/$STORY.html\">$DISPLAY_NAME</a></li>"
if ! grep -qxF "$LINK" "$STORIES_LIST"; then
    sed -i "/<\/ul>/i $LINK" "$STORIES_LIST"
    echo "✅ Updated stories.html with link to $DISPLAY_NAME"
fi

# Git add, commit, push
git add .
if git diff --cached --quiet; then
    echo "ℹ️ No changes to commit."
else
    git commit -m "Add $DISPLAY_NAME story"
    git push origin master
    echo "✅ Changes pushed to GitHub."
fi

echo "🎉 Done! $DISPLAY_NAME story added."

# ----------------------
# REMOVE STORY
# ----------------------
elif [ "$ACTION" == "2" ]; then
    read -p "Enter the story/family name to remove (use lowercase, hyphen for spaces): " STORY
    IMG="images/stories/$STORY.jpg"
    BIO="docs/stories/$STORY.txt"
    HTML="stories/$STORY.html"
    DISPLAY_NAME=$(title_case "$STORY")

    # Remove HTML page
    if [ -f "$HTML" ]; then
        rm "$HTML"
        echo "✅ Removed HTML page: $HTML"
    else
        echo "⚠️ HTML page not found: $HTML"
    fi

    # Remove bio
    if [ -f "$BIO" ]; then
        rm "$BIO"
        echo "✅ Removed bio file: $BIO"
    else
        echo "⚠️ Bio file not found: $BIO"
    fi

    # Reminder for image
    if [ -f "$IMG" ]; then
        echo "⚠️ Image still exists: $IMG. Delete manually if desired."
    fi

    # Remove link from stories.html
    LINK="<li><a href=\"stories/$STORY.html\">$DISPLAY_NAME</a></li>"
    if grep -qxF "$LINK" "$STORIES_LIST"; then
        sed -i "\|$LINK|d" "$STORIES_LIST"
        echo "✅ Removed link from stories.html"
    else
        echo "ℹ️ Link not found in stories.html"
    fi

    # Git add, commit, push
    git add .
    if git diff --cached --quiet; then
        echo "ℹ️ No changes to commit."
    else
        git commit -m "Remove $DISPLAY_NAME story"
        git push origin master
        echo "✅ Changes pushed to GitHub."
    fi

    echo "🎉 Done! $DISPLAY_NAME story removed."

else
    echo "❌ Invalid option. Please run the script again and choose 1 or 2."
    exit 1
fi

