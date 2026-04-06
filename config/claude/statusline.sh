#!/bin/sh
input=$(cat)

# Workspace directory name
workspace_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
if [ -n "$workspace_dir" ]; then
  dir_name=$(basename "$workspace_dir")
else
  dir_name=""
fi

# Git branch name (skip optional locks)
if [ -n "$workspace_dir" ] && [ -d "$workspace_dir/.git" ]; then
  branch=$(git -C "$workspace_dir" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git -C "$workspace_dir" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
elif [ -d ".git" ]; then
  branch=$(git --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  fi
fi

# Rate limit info
five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Build output
parts=""

if [ -n "$dir_name" ]; then
  parts="${dir_name}"
fi

if [ -n "$branch" ]; then
  if [ -n "$parts" ]; then
    parts="${parts}(${branch})"
  else
    parts="(${branch})"
  fi
fi

rate_info=""
if [ -n "$five_pct" ]; then
  rate_info="Rate Limit 5h:$(printf '%.0f' "$five_pct")%"
fi
if [ -n "$week_pct" ]; then
  if [ -n "$rate_info" ]; then
    rate_info="${rate_info} 7d:$(printf '%.0f' "$week_pct")%"
  else
    rate_info="7d:$(printf '%.0f' "$week_pct")%"
  fi
fi

if [ -n "$rate_info" ]; then
  if [ -n "$parts" ]; then
    parts="${parts} | ${rate_info}"
  else
    parts="${rate_info}"
  fi
fi

printf '%s' "$parts"
