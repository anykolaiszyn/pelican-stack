#!/bin/bash
# init.sh
# Creates a .env file from .env.example if .env does not exist.

if [ ! -f .env ]; then
  if [ -f .env.example ]; then
    cp .env.example .env
    echo ".env file created from .env.example. Please review and update as necessary."
  else
    echo "Error: .env.example not found. Cannot create .env file."
    exit 1
  fi
else
  echo ".env file already exists. No action taken."
fi

exit 0
