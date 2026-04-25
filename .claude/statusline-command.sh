#!/bin/sh
input=$(cat)

# Model display name
model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

# Context window usage
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

input_tokens=$(echo "$input" | jq -r '
  (.context_window.current_usage.input_tokens // 0) +
  (.context_window.current_usage.cache_read_input_tokens // 0) +
  (.context_window.current_usage.cache_creation_input_tokens // 0)
')

# Format token counts as human-readable (k or M)
format_tokens() {
  val=$1
  if [ "$val" -ge 1000000 ]; then
    printf "%sM" "$(echo "$val" | awk '{v=$1/1000000; if(v==int(v)) printf "%d",v; else printf "%.1f",v}')"
  elif [ "$val" -ge 1000 ]; then
    printf "%dk" "$(echo "$val" | awk '{printf "%d", $1/1000}')"
  else
    printf "%d" "$val"
  fi
}

tok_used=$(format_tokens "$input_tokens")
tok_total=$(format_tokens "$ctx_size")

# Colors
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"
DIM="\033[2m"
RESET="\033[0m"
SEP=$(printf "${DIM} │ ${RESET}")

# Pick color based on percentage: green <70, yellow 70-84, red 85+
pct_color() {
  val=$(printf "%.0f" "$1")
  if [ "$val" -ge 85 ]; then
    printf "%s" "$RED"
  elif [ "$val" -ge 70 ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$GREEN"
  fi
}

# Pick color for context window based on absolute token count and window size.
# Thresholds (yellow/red) scale with the context window size:
#   200k window → yellow at 170k, red at 190k
#   1M window   → yellow at 200k, red at 850k
# For other sizes we interpolate proportionally between these two reference points.
ctx_token_color() {
  tokens=$1
  window=$2
  # Reference points
  ref_small=200000; ref_small_yellow=170000; ref_small_red=190000
  ref_large=1000000; ref_large_yellow=200000; ref_large_red=850000
  if [ "$window" -le "$ref_small" ]; then
    yellow=$ref_small_yellow
    red=$ref_small_red
  elif [ "$window" -ge "$ref_large" ]; then
    yellow=$ref_large_yellow
    red=$ref_large_red
  else
    # Linear interpolation between the two reference points
    span=$((ref_large - ref_small))
    delta=$((window - ref_small))
    yellow=$(( ref_small_yellow + (ref_large_yellow - ref_small_yellow) * delta / span ))
    red=$(( ref_small_red + (ref_large_red - ref_small_red) * delta / span ))
  fi
  if [ "$tokens" -ge "$red" ]; then
    printf "%s" "$RED"
  elif [ "$tokens" -ge "$yellow" ]; then
    printf "%s" "$YELLOW"
  else
    printf "%s" "$GREEN"
  fi
}

# Render a mini bar: filled portion colored, unfilled dimmed
# Usage: mini_bar <percentage> <width> <color>
mini_bar() {
  pct=$(printf "%.0f" "$1")
  width=$2
  color=$3
  filled=$(( pct * width / 100 ))
  [ "$filled" -lt 0 ] && filled=0
  [ "$filled" -gt "$width" ] && filled="$width"
  unfilled=$((width - filled))

  bar=""
  if [ "$filled" -gt 0 ]; then
    i=0; while [ "$i" -lt "$filled" ]; do bar="${bar}━"; i=$((i+1)); done
  fi
  # Cap character at the boundary
  if [ "$filled" -gt 0 ] && [ "$unfilled" -gt 0 ]; then
    bar="${bar}╸"
    unfilled=$((unfilled - 1))
  fi
  rest=""
  if [ "$unfilled" -gt 0 ]; then
    i=0; while [ "$i" -lt "$unfilled" ]; do rest="${rest}━"; i=$((i+1)); done
  fi

  printf "${color}${bar}${RESET}${DIM}${rest}${RESET}"
}

if [ -n "$used_pct" ]; then
  ctx_color=$(ctx_token_color "$input_tokens" "$ctx_size")
else
  ctx_color="$GREEN"
fi

# Rate limits
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

# Build output
output="$model"

if [ -n "$used_pct" ]; then
  ctx_bar=$(mini_bar "$used_pct" 15 "$ctx_color")
  output="$output  $(printf "%s/%s %b " "$tok_used" "$tok_total" "$ctx_bar")"
fi

if [ -n "$five_pct" ]; then
  five_color=$(pct_color "$five_pct")
  five_bar=$(mini_bar "$five_pct" 15 "$five_color")
  if [ -n "$five_resets" ]; then
    if date -r "$five_resets" >/dev/null 2>&1; then
      five_label=$(date -r "$five_resets" +"%-I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/:00//')
    else
      five_label=$(date -d "@$five_resets" +"%I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/^0//;s/:00//')
    fi
  else
    five_label="5h"
  fi
  output="$output$SEP $(printf "%s %b " "$five_label" "$five_bar")"
fi

if [ -n "$seven_pct" ]; then
  seven_color=$(pct_color "$seven_pct")
  seven_bar=$(mini_bar "$seven_pct" 15 "$seven_color")
  if [ -n "$seven_resets" ]; then
    if date -r "$seven_resets" >/dev/null 2>&1; then
      seven_day=$(date -r "$seven_resets" +"%a")
      seven_time=$(date -r "$seven_resets" +"%-I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/:00//')
    else
      seven_day=$(date -d "@$seven_resets" +"%a")
      seven_time=$(date -d "@$seven_resets" +"%I:%M%p" | tr '[:upper:]' '[:lower:]' | sed 's/^0//;s/:00//')
    fi
    seven_label="${seven_day} ${seven_time}"
  else
    seven_label="7d"
  fi
  output="$output$SEP $(printf "%s %b " "$seven_label" "$seven_bar")"
fi

printf "%b" "$output"
