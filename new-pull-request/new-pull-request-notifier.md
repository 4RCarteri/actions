# New Pull Request Google Chat Notifier GitHub Action

Send notifications to Google Chat when a pull request is opened.

## Usage

```yaml
on:
  pull_request:
    types: [opened]

jobs:
  notify-chat:
    runs-on: ubuntu-latest
    steps:
      - name: New Pull Request Notification
        uses: wexinc/google-chat-notifier/new-pull-request@v1
        with:
          webhook-url: ${{ secrets.GOOGLE_CHAT_WEBHOOK_URL }}
          pr-data: ${{ toJson(github.event.pull_request) }}
```
