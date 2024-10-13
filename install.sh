#!/bin/sh

set -e

echo Running installer..

BIN_DIR="/Library/Application Support/Magnolia/bin"
mkdir -p "$HOME$BIN_DIR"

# Function to install Ollama on Linux
function install_ollama_linux {
    FILE_NAME="/ollama-linux-amd64"
    echo download to $HOME$BIN_DIR$FILE_NAME..
    curl -L https://github.com/ollama/ollama/releases/download/v0.3.12/ollama-linux-amd64 -o "$HOME$BIN_DIR$FILE_NAME" 
    chmod +x "$HOME$BIN_DIR$FILE_NAME"
}

# Function to install Ollama on macOS
function install_ollama_macos {
    FILE_NAME="/ollama-darwin"
    echo download to $HOME$BIN_DIR$FILE_NAME..
    curl -L https://github.com/ollama/ollama/releases/download/v0.3.12/ollama-darwin -o "$HOME$BIN_DIR$FILE_NAME"
    chmod +x "$HOME$BIN_DIR$FILE_NAME"
}

# Function to install Host on Linux
function install_host_linux {
    FILE_NAME="/magnolia-linux"
    echo download to $HOME$BIN_DIR$FILE_NAME..
    curl -L https://github.com/extrataylor/magnolia/releases/download/v.0.0.1/magnolia-linux -o "$HOME$BIN_DIR$FILE_NAME" 
    chmod +x "$HOME$BIN_DIR$FILE_NAME"
}

# Function to install Host on macOS
function install_host_macos {
    FILE_NAME="/magnolia-darwin"
    echo download to $HOME$BIN_DIR$FILE_NAME..
    curl -L https://github.com/extrataylor/magnolia/releases/download/v.0.0.1/magnolia-darwin -o "$HOME$BIN_DIR$FILE_NAME"
    chmod +x "$HOME$BIN_DIR$FILE_NAME"
}

# Detect the operating system and install Ollama if necessary
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # install_ollama_linux
    # install_host_linux
    echo Linux is not supported yet.
elif [[ "$OSTYPE" == "darwin"* ]]; then
    install_ollama_macos
    install_host_macos
else
    exit 1
fi

DIR="$( cd "$( dirname "$0" )" && pwd )"
if [ $(uname -s) == 'Darwin' ]; then
  HOST_PATH="$HOME/Library/Application Support/Magnolia/bin/magnolia-darwin"
  if [ "$(whoami)" == "root" ]; then
    TARGET_DIR="/Library/Google/Chrome/NativeMessagingHosts"
  else
    TARGET_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
  fi
else
  HOST_PATH="$HOME/Library/Application Support/Magnolia/bin/magnolia-linux"
  if [ "$(whoami)" == "root" ]; then
    TARGET_DIR="/etc/opt/chrome/native-messaging-hosts"
  else
    TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
  fi
fi

HOST_NAME=local.labs.magnolia

# Create directory to store native messaging host.
mkdir -p "$TARGET_DIR"

JSON_DATA=$(printf '{
  "name": "local.labs.magnolia",
  "description": "Magnolia Native Messaging Host",
  "path": "%s",
  "type": "stdio",
  "allowed_origins": ["chrome-extension://hchaaemmeephmfcgfjbhcdlhagfgbjbl/"]
}' "$HOST_PATH")

echo "$JSON_DATA" > "$TARGET_DIR/$HOST_NAME.json"

# Set permissions for the manifest so that all users can read it.
chmod o+r "$TARGET_DIR/$HOST_NAME.json"

echo Native messaging host $HOST_NAME has been installed.