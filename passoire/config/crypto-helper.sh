#!/bin/bash

# Configuration
NODE_SERVER_FILE="/passoire/crypto-helper/server.js"
LOG_DIR="/var/log/passport-api"
LOG_FILE="$LOG_DIR/crypto-helper.log"
PID_FILE="$LOG_DIR/crypto-helper.pid"

# Ensure the log directory exists
mkdir -p "$LOG_DIR"
chmod 755 "$LOG_DIR"

# Functions
start_server() {
  if [ -f "$PID_FILE" ]; then
    if ps -p $(cat "$PID_FILE") > /dev/null 2>&1; then
      echo "Server is already running with PID $(cat $PID_FILE). Use 'stop' to restart."
      exit 1
    else
      echo "Found stale PID file. Cleaning up."
      rm -f "$PID_FILE"
    fi
  fi

  echo "Starting the Node.js server..."
  if ! command -v node > /dev/null 2>&1; then
    echo "Error: 'node' command not found. Please install Node.js."
    exit 1
  fi

  nohup node "$NODE_SERVER_FILE" > "$LOG_FILE" 2>&1 &
  echo $! > "$PID_FILE"
  echo "Server started with PID $(cat $PID_FILE). Logs: $LOG_FILE"
}

stop_server() {
  if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p $PID > /dev/null 2>&1; then
      echo "Stopping the Node.js server with PID $PID..."
      kill "$PID"
      rm -f "$PID_FILE"
      echo "Server stopped."
    else
      echo "Server process not found. Cleaning up stale PID file."
      rm -f "$PID_FILE"
    fi
  else
    echo "No server is running."
  fi
}

# Main script logic
case "$1" in
  start)
    start_server
    ;;
  stop)
    stop_server
    ;;
  *)
    echo "Usage: $0 {start|stop}"
    exit 1
    ;;
esac
