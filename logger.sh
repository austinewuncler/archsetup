#!/usr/bin/env bash

RESET=$(tput sgr0)
BOLD=$(tput bold)
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)

log_step() {
  printf '%s===>%s %s%s%s\n' "$CYAN$BOLD" "$RESET" "$BOLD" "$*" "$RESET"
}

log_info() {
  printf '%s%s%s\n' "$BLUE$BOLD" "$*" "$RESET"
}

log_ok() {
  printf '%s%s%s\n' "$GREEN" "$*" "$RESET"
}

log_warning() {
  printf '%s%s%s\n' "$YELLOW" "$*" "$RESET"
}

log_error() {
  printf '%s%s%s\n' "$RED" "$*" "$RESET"
}

confirm() {
  local reply
  read -rp "$(printf '%s%s%s ' "$YELLOW$BOLD" "$1" "$RESET")" reply
  [[ "$reply" == "yes" ]]
}
