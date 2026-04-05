#!/bin/bash

main() {
  echo "Secret lint started..."

  if ! npx secretlint "**/*"; then
    echo "Secret lint failed!"
    exit 1
  fi

  echo "Secret lint finished!"
}

main
