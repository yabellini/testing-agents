# Example Usage of Slack Channel Weekly Scheduler

# Load the scheduler functions
source("slack_channel_scheduler.R")

# --- Example 1: Schedule messages for the next 4 weeks ---
# This will schedule 4 weekly messages, starting from now
# run_scheduler(num_weeks = 4)

# --- Example 2: Schedule messages starting next Monday ---
# Calculate next Monday at 9 AM
# Requires lubridate package: install.packages("lubridate")
# library(lubridate)
# next_monday <- ceiling_date(Sys.time(), "week") + hours(9)
# run_scheduler(num_weeks = 4, start_date = next_monday)

# --- Example 3: Post first message immediately, then schedule rest ---
# This posts the first channel spotlight right away, then schedules the rest weekly
# run_scheduler(num_weeks = 4, immediate = TRUE)

# --- Example 4: Get channels and preview messages (without posting) ---
# Fetch channels
channels <- get_slack_channels()
print(head(channels))

# Preview what a message would look like for the first channel
if (nrow(channels) > 0) {
  sample_message <- format_channel_message(
    channels$name[1],
    channels$topic[1],
    channels$purpose[1]
  )
  cat("\nSample Message:\n")
  cat(sample_message)
  cat("\n")
}

# --- Example 5: Post a single test message ---
# test_message <- format_channel_message("testing", "This is a test channel", "For testing purposes")
# post_slack_message(test_message, "#test-channel")

# --- Example 6: Schedule specific channels ---
# Filter for specific channels you want to highlight
# selected_channels <- channels[channels$name %in% c("random", "general", "help"), ]
# schedule_weekly_spotlights(selected_channels, immediate = TRUE)
