# Google Chat Notifier Actions

This repository contains modular GitHub Actions for sending notifications to Google Chat in different scenarios, organized by event type.

## Available Actions

- [**New Pull Request Notifier**](new-pull-request)  
  Sends notifications to Google Chat when a pull request is opened.  
  See details and usage in [`new-pull-request/new-pull-request-notifier.md`](new-pull-request/new-pull-request-notifier.md).

---

Each action is self-contained within its own folder, making it easy to maintain and extend for new notification types.

## How to Create a Google Chat Webhook and Add It to GitHub Secrets

### 1. Create a Google Chat Webhook

1. **Open Google Chat** and go to the space/channel where you want to receive notifications.
2. Click on the space name at the top, then select **Manage webhooks** (or “Apps & integrations”).
3. Click **Add webhook**.
4. Give your webhook a name (e.g., “GitHub Actions Notifier”).
5. (Optional) Upload an avatar image for the bot.
6. Click **Save**.  
   You’ll be given a **Webhook URL**. **Copy this URL** — you’ll need it for the next step.

### 2. Add the Webhook URL to GitHub Secrets

1. In your GitHub repository, click on **Settings**.
2. In the sidebar, select **Secrets and variables** > **Actions**.
3. Click **New repository secret**.
4. Name the secret (for example):  
   `GOOGLE_CHAT_WEBHOOK_URL`
5. Paste the Google Chat webhook URL you copied earlier into the **Secret** field.
6. Click **Add secret**.

Your GitHub Actions workflow can now reference this secret as `${{ secrets.GOOGLE_CHAT_WEBHOOK_URL }}`.

