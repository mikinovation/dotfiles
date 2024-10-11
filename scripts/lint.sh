#!/bin/bash

main() {
  echo "Lua lint started..."
  
  if ! luacheck .; then
    echo "Lua lint failed!"
    exit 1
  fi

  echo "Lua lint finished!"
}

main

