#!/bin/bash

main() {
  echo "Lua lint started..."

  if ! luacheck .; then
    echo "Lua lint failed!"
    exit 1
  fi

  echo "Lua lint finished!"

  echo "Secret lint started..."

  if ! git ls-files | xargs ./node_modules/.bin/secretlint; then
    echo "Secret lint failed!"
    exit 1
  fi

  echo "Secret lint finished!"
}

main

