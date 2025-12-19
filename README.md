# Slack Channel Weekly Scheduler

Automatically schedule weekly Slack messages that introduce different channels in your workspace. Each week, a new channel is highlighted with its name, topic, and description to help community members discover and engage with different discussion spaces.

## Features

- 📅 **Weekly Scheduling**: Automatically schedule messages to introduce one channel per week
- 🔍 **Channel Discovery**: Fetches all public channels from your Slack workspace
- 📝 **Rich Messages**: Creates formatted messages using channel names and topics/descriptions
- ⚡ **Flexible Scheduling**: Post immediately or schedule for future dates
- 🎯 **Customizable**: Choose which channels to highlight and when

## Requirements

- R (>= 4.0.0)
- R packages:
  - `httr` - for HTTP requests to Slack API
  - `jsonlite` - for JSON parsing
  - `lubridate` (optional) - for easier date/time handling

Install required packages:

```r
install.packages(c("httr", "jsonlite", "lubridate"))
```

## Slack App Setup

1. **Create a Slack App**: Go to [https://api.slack.com/apps](https://api.slack.com/apps) and create a new app

2. **Add Required Scopes**: In "OAuth & Permissions", add these Bot Token Scopes:
   - `channels:read` - to list channels
   - `chat:write` - to post messages
   - `chat:write.public` - to post in channels the bot isn't a member of

3. **Install to Workspace**: Install the app to your workspace

4. **Copy Bot Token**: Copy the "Bot User OAuth Token" (starts with `xoxb-`)

## Configuration

1. Copy the example environment file:
   ```bash
   cp .Renviron.example .Renviron
   ```

2. Edit `.Renviron` and add your Slack token:
   ```
   SLACK_BOT_TOKEN=xoxb-your-actual-token-here
   SLACK_ANNOUNCEMENT_CHANNEL=#general
   ```

3. **Important**: Add `.Renviron` to `.gitignore` to keep your token secure:
   ```bash
   echo ".Renviron" >> .gitignore
   ```

## Usage

### Basic Usage

```r
# Load the scheduler
source("slack_channel_scheduler.R")

# Schedule 4 weeks of channel spotlights
run_scheduler(num_weeks = 4)
```

### Schedule Starting from a Specific Date

```r
library(lubridate)

# Start next Monday at 9 AM
next_monday <- ceiling_date(Sys.time(), "week") + hours(9)
run_scheduler(num_weeks = 4, start_date = next_monday)
```

### Post First Message Immediately

```r
# Post the first spotlight now, schedule the rest weekly
run_scheduler(num_weeks = 4, immediate = TRUE)
```

### Preview Channels and Messages

```r
# Get list of channels
channels <- get_slack_channels()
print(channels)

# Preview a message
message <- format_channel_message(
  channels$name[1],
  channels$topic[1],
  channels$purpose[1]
)
cat(message)
```

### Select Specific Channels

```r
# Get all channels
channels <- get_slack_channels()

# Filter for specific channels
selected <- channels[channels$name %in% c("help", "announcements", "random"), ]

# Schedule only these channels
schedule_weekly_spotlights(selected, immediate = TRUE)
```

## Functions

### Main Functions

- `run_scheduler(num_weeks, start_date, immediate)` - Main function to run the scheduler
  - `num_weeks`: Number of weeks to schedule (default: all channels)
  - `start_date`: When to start scheduling (default: now)
  - `immediate`: Post first message immediately (default: FALSE)

### Core Functions

- `get_slack_channels(token)` - Fetch all public channels from Slack
- `format_channel_message(channel_name, channel_topic, channel_purpose)` - Format a channel introduction message
- `post_slack_message(message, channel, token)` - Post a message immediately
- `schedule_slack_message(message, post_at, channel, token)` - Schedule a message for later
- `schedule_weekly_spotlights(channels_df, start_date, num_weeks, ...)` - Schedule multiple weekly messages

## Example Message Format

The scheduler creates messages like this:

```
:wave: *Weekly Channel Spotlight* :wave:

This week, we'd like to introduce you to: *#random*

:sparkles: *About this channel:*
A place for non-work-related fluff and fun

Join us in #random to participate in the conversation!

_Want to learn about more channels? Stay tuned for next week's spotlight!_ :rocket:
```

## Automation Options

### Using Cron (Linux/Mac)

Schedule the script to run weekly:

```bash
# Edit crontab
crontab -e

# Add line to run every Monday at 9 AM
0 9 * * 1 cd /path/to/project && /usr/bin/Rscript -e "source('slack_channel_scheduler.R'); run_scheduler(num_weeks = 1, immediate = TRUE)"
```

### Using Task Scheduler (Windows)

1. Open Task Scheduler
2. Create a new task that runs weekly
3. Set the action to run: `Rscript.exe -e "source('slack_channel_scheduler.R'); run_scheduler(num_weeks = 1, immediate = TRUE)"`

### Using GitHub Actions

Create `.github/workflows/slack-scheduler.yml`:

```yaml
name: Weekly Slack Channel Spotlight

on:
  schedule:
    - cron: '0 9 * * 1'  # Every Monday at 9 AM UTC
  workflow_dispatch:  # Allow manual triggering

jobs:
  post-channel-spotlight:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: '4.3.0'
      
      - name: Install dependencies
        run: |
          install.packages(c("httr", "jsonlite"))
        shell: Rscript {0}
      
      - name: Run scheduler
        env:
          SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
          SLACK_ANNOUNCEMENT_CHANNEL: '#general'
        run: |
          source('slack_channel_scheduler.R')
          run_scheduler(num_weeks = 1, immediate = TRUE)
        shell: Rscript {0}
```

Then add `SLACK_BOT_TOKEN` to your repository secrets.

## Security Notes

- ⚠️ **Never commit your `.Renviron` file** - it contains your Slack token
- ⚠️ Use environment variables or secrets management for tokens
- ⚠️ Limit bot token scopes to only what's needed
- ⚠️ Rotate tokens periodically

## Troubleshooting

**"SLACK_BOT_TOKEN environment variable not set"**
- Make sure `.Renviron` exists and contains your token
- Restart your R session after creating `.Renviron`

**"Slack API error: invalid_auth"**
- Check that your token is correct and starts with `xoxb-`
- Verify the app is installed in your workspace

**"Slack API error: missing_scope"**
- Add the required scopes in your Slack app settings
- Reinstall the app to your workspace

**No channels returned**
- Make sure your bot has the `channels:read` scope
- Check that there are public channels in your workspace

## License

MIT License - feel free to use and modify for your needs.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.