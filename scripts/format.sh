#!/bin/bash

main() {
  echo "Lua format started..."
  
  if ! stylua .; then
    echo "Lua format failed!"
    exit 1
  fi

  echo "Lua format finished!"
}

main

