#!/bin/bash
# Adds a new message page and pushes to GitHub

read -p "Enter message title (use lowercase, hyphen for spaces): " MSG
read -p "Enter speaker name: " SPEAKER
read -p "Enter type (Sermon / Devotional): " TYPE
read -p "Enter scripture reference: " SCRIPTURE
read -p "Enter a short summary: " SUMMARY
read -p "Optional: paste video embed code or leave blank: " VIDEO_EMBED
read -p "Optional: notes PDF file path (relative to mysite folder) or leave blank: " NOTES_PDF
read -p "Key takeaways (1-3 sentences): " KEY_POINTS
read -p "Reflection questions (optional): " REFLECTION

DATE=$(date +%Y-%m-%d)
FOLDER="messages/$DATE-$MSG"
mkdir -p "$FOLDER"

HTML_FILE="$FOLDER/index.html"

# Copy template
cat messages/template.html \
| sed "s|{{TITLE}}|$MSG|g" \
| sed "s|{{DATE}}|$DATE|g" \
| sed "s|{{SPEAKER}}|$SPEAKER|g" \
| sed "s|{{TYPE}}|$TYPE|g" \
| sed "s|{{SCRIPTURE}}|$SCRIPTURE|g" \
| sed "s|{{SUMMARY}}|$SUMMARY|g" \
| sed "s|{{VIDEO_EMBED}}|$VIDEO_EMBED|g" \
| sed "s|{{NOTES_PDF}}|$NOTES_PDF|g" \
| sed "s|{{KEY_POINTS}}|$KEY_POINTS|g" \
| sed "s|{{REFLECTION}}|$REFLECTION|g" \
> "$HTML_FILE"

echo "✅ Created message page: $HTML_FILE"

# Add a link to main messages/index.html
LINK="<li><a href=\"$DATE-$MSG/index.html\">$MSG</a></li>"
MAIN_INDEX="messages/index.html"
if [ ! -f "$MAIN_INDEX" ]; then
    echo "<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset='UTF-8'>
<meta name='viewport' content='width=device-width, initial-scale=1.0'>
<title>Messages - Fanshawe FWB</title>
<link rel='stylesheet' href='../css/style.css'>
</head>
<body>
<h1>Messages</h1>
<ul>
$LINK
</ul>
</body>
</html>" > "$MAIN_INDEX"
else
    grep -qxF "$LINK" "$MAIN_INDEX" || sed -i "/<\/ul>/i $LINK" "$MAIN_INDEX"
fi

# Git add, commit, push
git add .
git commit -m "Add message: $MSG"
git push origin master

echo "🎉 Done! Message '$MSG' added and pushed."
