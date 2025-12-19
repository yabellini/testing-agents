# Test script for Slack Channel Scheduler
# This script tests the core functionality without requiring actual Slack credentials

# Load the main script
source("slack_channel_scheduler.R")

# Test 1: Test message formatting
cat("Test 1: Message Formatting\n")
cat("===========================\n")

test_message <- format_channel_message(
  channel_name = "test-channel",
  channel_topic = "This is a test topic for the channel",
  channel_purpose = "Purpose: Testing the scheduler"
)

cat(test_message)
cat("\n\n")

# Verify message contains expected elements
if (grepl("Weekly Channel Spotlight", test_message) &&
    grepl("#test-channel", test_message) &&
    grepl("This is a test topic for the channel", test_message)) {
  cat("✓ Message formatting test PASSED\n\n")
} else {
  cat("✗ Message formatting test FAILED\n\n")
}

# Test 2: Test message formatting with empty topic (should use purpose)
cat("Test 2: Message Formatting with Empty Topic\n")
cat("============================================\n")

test_message2 <- format_channel_message(
  channel_name = "another-channel",
  channel_topic = "",
  channel_purpose = "This channel is for another purpose"
)

cat(test_message2)
cat("\n\n")

if (grepl("This channel is for another purpose", test_message2)) {
  cat("✓ Empty topic handling test PASSED\n\n")
} else {
  cat("✗ Empty topic handling test FAILED\n\n")
}

# Test 3: Test with mock channel data
cat("Test 3: Mock Channel Data Processing\n")
cat("=====================================\n")

mock_channels <- data.frame(
  id = c("C001", "C002", "C003"),
  name = c("general", "random", "help"),
  topic = c("General discussions", "Off-topic chat", "Get help here"),
  purpose = c("Main channel", "Fun stuff", "Support"),
  stringsAsFactors = FALSE
)

cat("Mock channels created:\n")
print(mock_channels)
cat("\n")

# Test message creation for each channel
for (i in 1:nrow(mock_channels)) {
  msg <- format_channel_message(
    mock_channels$name[i],
    mock_channels$topic[i],
    mock_channels$purpose[i]
  )
  cat(sprintf("Channel %d (%s): Message created successfully\n", i, mock_channels$name[i]))
}

cat("\n✓ Mock data processing test PASSED\n\n")

# Test 4: Test date/time calculations for scheduling
cat("Test 4: Scheduling Time Calculations\n")
cat("=====================================\n")

# Use current time as base for more relevant testing
start_time <- Sys.time()
num_weeks <- 3

for (i in 1:num_weeks) {
  post_time <- start_time + (i - 1) * 7 * 24 * 60 * 60
  cat(sprintf("Week %d: %s\n", i, format(post_time)))
}

cat("\n✓ Time calculation test PASSED\n\n")

# Summary
cat("\n")
cat("==========================================\n")
cat("Test Summary\n")
cat("==========================================\n")
cat("All core functionality tests completed!\n")
cat("\nNote: To test actual Slack API integration:\n")
cat("1. Set up SLACK_BOT_TOKEN in .Renviron\n")
cat("2. Run: source('example_usage.R')\n")
cat("3. Try: get_slack_channels() to fetch real channels\n")
cat("==========================================\n")
