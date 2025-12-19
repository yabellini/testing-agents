# Quick Start Guide

This guide will help you get started with the Slack Channel Weekly Scheduler in just a few minutes.

## Prerequisites

- R installed (version 4.0.0 or higher)
- A Slack workspace where you have admin permissions
- 5-10 minutes to set up

## Step-by-Step Setup

### 1. Install R Packages

Open R or RStudio and run:

```r
install.packages(c("httr", "jsonlite", "lubridate"))
```

### 2. Create a Slack App

1. Go to https://api.slack.com/apps
2. Click "Create New App" → "From scratch"
3. Give it a name (e.g., "Channel Spotlight Bot")
4. Select your workspace
5. Click "Create App"

### 3. Add Permissions

1. In your app settings, go to "OAuth & Permissions" (left sidebar)
2. Scroll to "Scopes" → "Bot Token Scopes"
3. Add these scopes:
   - `channels:read` - to list channels
   - `chat:write` - to post messages
   - `chat:write.public` - to post in any channel

### 4. Install to Workspace

1. Scroll to top of "OAuth & Permissions" page
2. Click "Install to Workspace"
3. Review permissions and click "Allow"
4. **Copy the "Bot User OAuth Token"** (starts with `xoxb-`)

### 5. Configure Your Environment

1. In your project directory, copy the example file:
   ```bash
   cp .Renviron.example .Renviron
   ```

2. Edit `.Renviron` and paste your token:
   ```
   SLACK_BOT_TOKEN=xoxb-your-actual-token-here
   SLACK_ANNOUNCEMENT_CHANNEL=#general
   ```

3. **Important**: Make sure `.Renviron` is in `.gitignore`

### 6. Test It Out

Open R and run:

```r
# Load the scheduler
source("slack_channel_scheduler.R")

# Fetch channels (test connection)
channels <- get_slack_channels()
print(channels)

# Preview a message
if (nrow(channels) > 0) {
  message <- format_channel_message(
    channels$name[1],
    channels$topic[1],
    channels$purpose[1]
  )
  cat(message)
}
```

If this works, you're ready to go! 🎉

### 7. Schedule Your First Messages

#### Option A: Post immediately and schedule weekly

```r
# Post first spotlight now, schedule next 3 for following weeks
run_scheduler(num_weeks = 4, immediate = TRUE)
```

#### Option B: Schedule all for future dates

```r
library(lubridate)

# Start next Monday at 9 AM
next_monday <- ceiling_date(Sys.time(), "week") + hours(9)
run_scheduler(num_weeks = 4, start_date = next_monday)
```

## Common Commands

### View all channels
```r
source("slack_channel_scheduler.R")
channels <- get_slack_channels()
View(channels)
```

### Schedule for specific channels only
```r
source("slack_channel_scheduler.R")
channels <- get_slack_channels()

# Pick specific channels
selected <- channels[channels$name %in% c("help", "random", "announcements"), ]

# Schedule them
schedule_weekly_spotlights(selected, immediate = TRUE)
```

### Change the posting channel
```r
# Set in .Renviron:
SLACK_ANNOUNCEMENT_CHANNEL=#announcements

# Or specify in code:
run_scheduler(num_weeks = 4, post_channel = "#team-updates")
```

## Automation

### Option 1: GitHub Actions (Recommended)

If your repository is on GitHub:

1. Add `SLACK_BOT_TOKEN` to repository secrets:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `SLACK_BOT_TOKEN`
   - Value: your token

2. The workflow in `.github/workflows/slack-scheduler.yml` will run every Monday at 9 AM UTC

3. You can also trigger it manually from the Actions tab

### Option 2: Cron Job (Linux/Mac)

```bash
# Edit crontab
crontab -e

# Add this line (runs every Monday at 9 AM)
0 9 * * 1 cd /path/to/project && /usr/bin/Rscript -e "source('slack_channel_scheduler.R'); run_scheduler(num_weeks = 1, immediate = TRUE)"
```

### Option 3: Task Scheduler (Windows)

1. Open Task Scheduler
2. Create Basic Task
3. Trigger: Weekly, Monday, 9:00 AM
4. Action: Start a program
5. Program: `C:\Program Files\R\R-4.3.0\bin\Rscript.exe`
6. Arguments: `-e "source('C:/path/to/slack_channel_scheduler.R'); run_scheduler(num_weeks = 1, immediate = TRUE)"`

## Troubleshooting

**Error: "SLACK_BOT_TOKEN environment variable not set"**
- Make sure `.Renviron` exists in your project directory
- Restart R/RStudio after creating `.Renviron`
- Check that the file contains `SLACK_BOT_TOKEN=xoxb-...`

**Error: "invalid_auth"**
- Verify your token is correct (starts with `xoxb-`)
- Make sure the app is installed in your workspace
- Try reinstalling the app

**Error: "missing_scope"**
- Go to your Slack app settings
- Add the missing scopes in "OAuth & Permissions"
- Reinstall the app to your workspace

**No channels returned**
- Verify the `channels:read` scope is added
- Make sure you have public channels in your workspace

**Message not posting**
- Check that the bot has the `chat:write` scope
- Verify the channel exists
- Try adding the bot to the channel manually: `/invite @YourBotName`

## Tips

1. **Test with a private channel first**: Create a test channel to verify everything works

2. **Review channels before scheduling**: Check which channels have good descriptions
   ```r
   channels <- get_slack_channels()
   channels_with_topics <- channels[channels$topic != "", ]
   ```

3. **Customize the message format**: Edit the `format_channel_message()` function in `slack_channel_scheduler.R`

4. **Set a regular schedule**: Use the GitHub Actions workflow or cron to automate weekly posts

5. **Monitor scheduled messages**: In Slack, check the scheduled messages from your bot

## Next Steps

- Customize the message format in `format_channel_message()`
- Set up automation using GitHub Actions or cron
- Add more channels to your workspace
- Encourage team members to add good descriptions to channels

## Need Help?

Check the main [README.md](README.md) for detailed documentation.
