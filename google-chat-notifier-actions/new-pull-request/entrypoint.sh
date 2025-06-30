#!/bin/bash
set -e

WEBHOOK_URL="$1"
PR_JSON="$2"

# Parse fields from PR JSON
PR_TITLE=$(echo "$PR_JSON" | jq -r '.title')
PR_URL=$(echo "$PR_JSON" | jq -r '.html_url')
PR_AUTHOR=$(echo "$PR_JSON" | jq -r '.user.login')
PR_AUTHOR_AVATAR=$(echo "$PR_JSON" | jq -r '.user.avatar_url')
REPOSITORY=$(echo "$PR_JSON" | jq -r '.base.repo.full_name')
PR_ID=$(echo "$PR_JSON" | jq -r '.id')

# Build payload
payload=$(cat <<EOF
{
  "cardsV2": [
    {
      "cardId": "new-pr-card-${PR_ID}",
      "card": {
        "header": {
          "title": "New Pull Request Opened",
          "subtitle": "Repository: ${REPOSITORY}",
          "imageUrl": "https://cdn-icons-png.flaticon.com/512/25/25231.png",
          "imageType": "CIRCLE"
        },
        "sections": [
          {
            "widgets": [
              {
                "decoratedText": {
                  "topLabel": "Title",
                  "text": "${PR_TITLE}"
                }
              },
              {
                "decoratedText": {
                  "topLabel": "Author",
                  "text": "${PR_AUTHOR}",
                  "startIcon": {
                    "iconUrl": "${PR_AUTHOR_AVATAR}"
                  }
                }
              },
              {
                "buttonList": {
                  "buttons": [
                    {
                      "text": "View Pull Request",
                      "onClick": {
                        "openLink": {
                          "url": "${PR_URL}"
                        }
                      }
                    }
                  ]
                }
              }
            ]
          }
        ]
      }
    }
  ]
}
EOF
)

# Send notification
response=$(curl -s -w "%{http_code}" -X POST -H 'Content-Type: application/json' -d "$payload" "$WEBHOOK_URL")
http_code="${response: -3}"

if [ "$http_code" -lt 200 ] || [ "$http_code" -gt 299 ]; then
  echo "Error: Failed to send notification to Google Chat, HTTP code: $http_code"
  exit 1
else
  echo "Notification sent successfully to Google Chat!"
fi
