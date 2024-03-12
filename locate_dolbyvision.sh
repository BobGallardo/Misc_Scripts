#!/bin/bash

# Default values
search_path="./" # Default search path is the current directory
log_file="" # Empty default log file path, to be overridden by user input
progress_bar_enabled=false
progress_bar_width=50 # Width of the progress bar in characters
spinner_chars='-\|/'

# Parse command-line arguments
while getopts "d:l:p" opt; do
  case ${opt} in
    d ) search_path=$(realpath "$OPTARG") ;;
    l ) log_file=$OPTARG ;;
    p ) progress_bar_enabled=true ;;
    \? ) echo "Usage: cmd [-d directory] [-l logfile] [-p]"
         exit 1 ;;
  esac
done

# Set default log file if not specified
if [ -z "$log_file" ]; then
    log_file="${search_path}/dolby_vision_only_files.log"
fi

# Ensure the log file exists
touch "$log_file"

# Find all video files
mapfile -t files < <(find "$search_path" -type f \( -iname "*.mkv" -o -iname "*.mp4" -o -iname "*.avi" -o -iname "*.mov" \))

total_files=${#files[@]}
current_file=0
spinner_index=0

# Iterate through files and check for Dolby Vision as the only HDR format
for file in "${files[@]}"; do
  if $progress_bar_enabled; then
    # Update and display the progress bar and spinner
    current_file=$((current_file + 1))
    percent=$((current_file * 100 / total_files))
    filled=$((percent * progress_bar_width / 100))
    empty=$((progress_bar_width - filled))
    spinner_char=${spinner_chars:spinner_index%${#spinner_chars}:1}
    spinner_index=$((spinner_index + 1))
    printf "\r[%-${progress_bar_width}s] %3d%% %s" "$(printf '%0.s#' $(seq 1 $filled))" "$percent" "$spinner_char"
  fi

  hdr_format=$(mediainfo "--Inform=Video;%HDR_Format%" "$file")
  # Check if Dolby Vision is mentioned and ensure it's the only HDR format
  if [[ $hdr_format == "Dolby Vision" ]]; then
    # Remove the specified search path from the file path before logging
    relative_path=${file#$search_path/}
    # Ensure spinner and progress don't mess up the output
    if $progress_bar_enabled; then echo; fi
    echo "$relative_path, $hdr_format"
    echo "$relative_path, $hdr_format" >> "$log_file"
  fi
done

if $progress_bar_enabled; then
  echo # Ensure we end with a new line after the progress bar
fi

echo "Scan complete. Results saved to $log_file"
