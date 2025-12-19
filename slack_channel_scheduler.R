# Slack Channel Weekly Scheduler
# This script schedules weekly messages introducing different channels in a Slack workspace

library(httr)
library(jsonlite)

# Configuration
SLACK_TOKEN <- Sys.getenv("SLACK_BOT_TOKEN")
SLACK_CHANNEL_ID <- Sys.getenv("SLACK_ANNOUNCEMENT_CHANNEL", "#general")

#' Get list of channels from Slack workspace
#'
#' @param token Slack API token
#' @return data.frame with channel information
get_slack_channels <- function(token = SLACK_TOKEN) {
  if (token == "") {
    stop("SLACK_BOT_TOKEN environment variable not set")
  }
  
  url <- "https://slack.com/api/conversations.list"
  
  response <- GET(
    url,
    add_headers(Authorization = paste("Bearer", token)),
    query = list(
      types = "public_channel",
      exclude_archived = "true",
      limit = 1000
    )
  )
  
  if (status_code(response) != 200) {
    stop("Failed to fetch channels: HTTP ", status_code(response))
  }
  
  content <- content(response, as = "parsed")
  
  if (!content$ok) {
    stop("Slack API error: ", content$error)
  }
  
  channels <- content$channels
  
  if (length(channels) == 0) {
    return(data.frame(
      id = character(),
      name = character(),
      topic = character(),
      purpose = character(),
      stringsAsFactors = FALSE
    ))
  }
  
  # Extract channel information
  channel_df <- data.frame(
    id = sapply(channels, function(x) x$id),
    name = sapply(channels, function(x) x$name),
    topic = sapply(channels, function(x) {
      if (!is.null(x$topic$value) && x$topic$value != "") {
        x$topic$value
      } else {
        ""
      }
    }),
    purpose = sapply(channels, function(x) {
      if (!is.null(x$purpose$value) && x$purpose$value != "") {
        x$purpose$value
      } else {
        ""
      }
    }),
    stringsAsFactors = FALSE
  )
  
  return(channel_df)
}

#' Format a message introducing a channel
#'
#' @param channel_name Name of the channel
#' @param channel_topic Topic/description of the channel
#' @param channel_purpose Purpose of the channel
#' @return Formatted message string
format_channel_message <- function(channel_name, channel_topic, channel_purpose = "") {
  message <- paste0(
    ":wave: *Weekly Channel Spotlight* :wave:\n\n",
    "This week, we'd like to introduce you to: *#", channel_name, "*\n\n"
  )
  
  # Use topic if available, otherwise use purpose
  description <- if (channel_topic != "" && !is.na(channel_topic)) {
    channel_topic
  } else if (channel_purpose != "" && !is.na(channel_purpose)) {
    channel_purpose
  } else {
    "A place for discussion and collaboration"
  }
  
  message <- paste0(
    message,
    ":sparkles: *About this channel:*\n",
    description, "\n\n",
    "Join us in #", channel_name, " to participate in the conversation!\n\n",
    "_Want to learn about more channels? Stay tuned for next week's spotlight!_ :rocket:"
  )
  
  return(message)
}

#' Post a message to Slack
#'
#' @param message Message text to post
#' @param channel Channel ID or name to post to
#' @param token Slack API token
#' @return Response from Slack API
post_slack_message <- function(message, channel = SLACK_CHANNEL_ID, token = SLACK_TOKEN) {
  if (token == "") {
    stop("SLACK_BOT_TOKEN environment variable not set")
  }
  
  url <- "https://slack.com/api/chat.postMessage"
  
  response <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", token),
      "Content-Type" = "application/json"
    ),
    body = list(
      channel = channel,
      text = message,
      unfurl_links = FALSE,
      unfurl_media = FALSE
    ),
    encode = "json"
  )
  
  if (status_code(response) != 200) {
    stop("Failed to post message: HTTP ", status_code(response))
  }
  
  content <- content(response, as = "parsed")
  
  if (!content$ok) {
    stop("Slack API error: ", content$error)
  }
  
  message("Message posted successfully to ", channel)
  return(content)
}

#' Schedule a message to Slack
#'
#' @param message Message text to post
#' @param post_at Unix timestamp when to post the message
#' @param channel Channel ID or name to post to
#' @param token Slack API token
#' @return Response from Slack API
schedule_slack_message <- function(message, post_at, channel = SLACK_CHANNEL_ID, token = SLACK_TOKEN) {
  if (token == "") {
    stop("SLACK_BOT_TOKEN environment variable not set")
  }
  
  url <- "https://slack.com/api/chat.scheduleMessage"
  
  response <- POST(
    url,
    add_headers(
      Authorization = paste("Bearer", token),
      "Content-Type" = "application/json"
    ),
    body = list(
      channel = channel,
      text = message,
      post_at = as.character(post_at),
      unfurl_links = FALSE,
      unfurl_media = FALSE
    ),
    encode = "json"
  )
  
  if (status_code(response) != 200) {
    stop("Failed to schedule message: HTTP ", status_code(response))
  }
  
  content <- content(response, as = "parsed")
  
  if (!content$ok) {
    stop("Slack API error: ", content$error)
  }
  
  message("Message scheduled successfully for ", as.POSIXct(post_at, origin = "1970-01-01"))
  return(content)
}

#' Schedule weekly channel spotlight messages
#'
#' @param channels_df Data frame with channel information
#' @param start_date Starting date for scheduling (POSIXct)
#' @param num_weeks Number of weeks to schedule
#' @param post_channel Channel to post messages to
#' @param token Slack API token
#' @param immediate If TRUE, post first message immediately instead of scheduling
#' @return List of scheduled message responses
schedule_weekly_spotlights <- function(channels_df, 
                                       start_date = Sys.time(),
                                       num_weeks = nrow(channels_df),
                                       post_channel = SLACK_CHANNEL_ID,
                                       token = SLACK_TOKEN,
                                       immediate = FALSE) {
  
  if (nrow(channels_df) == 0) {
    stop("No channels to schedule")
  }
  
  # Limit to available channels
  num_weeks <- min(num_weeks, nrow(channels_df))
  
  results <- list()
  
  for (i in 1:num_weeks) {
    channel_info <- channels_df[i, ]
    
    # Format the message
    message <- format_channel_message(
      channel_info$name,
      channel_info$topic,
      channel_info$purpose
    )
    
    # Calculate post time (add weeks to start date)
    post_time <- start_date + (i - 1) * 7 * 24 * 60 * 60
    post_timestamp <- as.numeric(post_time)
    
    # Post immediately if first message and immediate flag is set
    if (i == 1 && immediate) {
      result <- post_slack_message(message, post_channel, token)
    } else {
      result <- schedule_slack_message(message, post_timestamp, post_channel, token)
    }
    
    results[[i]] <- result
  }
  
  message("\nSuccessfully scheduled ", num_weeks, " weekly channel spotlight messages!")
  return(results)
}

#' Main function to run the weekly channel scheduler
#'
#' @param num_weeks Number of weeks to schedule (default: all channels)
#' @param start_date Starting date (default: current time)
#' @param immediate Post first message immediately (default: FALSE)
run_scheduler <- function(num_weeks = NULL, start_date = Sys.time(), immediate = FALSE) {
  message("Fetching Slack channels...")
  channels <- get_slack_channels()
  
  message("Found ", nrow(channels), " channels")
  
  if (nrow(channels) == 0) {
    message("No channels found to schedule")
    return(invisible(NULL))
  }
  

  
  if (is.null(num_weeks)) {
    num_weeks <- nrow(channels)
  }
  
  message("\nScheduling ", num_weeks, " weekly messages...")
  message("Starting from: ", format(start_date))
  
  results <- schedule_weekly_spotlights(
    channels,
    start_date = start_date,
    num_weeks = num_weeks,
    immediate = immediate
  )
  
  return(invisible(results))
}

# Example usage (uncomment to run):
# run_scheduler(num_weeks = 4, immediate = TRUE)
