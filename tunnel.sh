#!/bin/bash
# tunnel.sh - Script to start and stop an SSH SOCKS proxy tunnel

# Customize these variables
SSH_USER="user"                # Your SSH username
SSH_SERVER="YOUR.PROXY.SERVER.IP"  # Your proxy server's IP address

LOCAL_PORT=1080                # Port for the SOCKS proxy (default is 1080)
PID_FILE="/tmp/ssh_tunnel.pid" # File where the process ID will be stored

start_tunnel() {
    # Check if a PID file already exists.
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            echo "Tunnel is already running with PID $PID."
            exit 0
        else
            # Remove stale PID file if process not found.
            rm -f "$PID_FILE"
        fi
    fi

    echo "Starting SSH tunnel..."
    # Start the SSH tunnel in the background.
    ssh -D 0.0.0.0:$LOCAL_PORT -f -C -q -N $SSH_USER@$SSH_SERVER

    # Give SSH a moment to establish the connection.
    sleep 1

    # Find the PID of the SSH process. This uses pgrep with the full command string.
    PID=$(pgrep -f "ssh -D 0.0.0.0:$LOCAL_PORT -f -C -q -N $SSH_USER@$SSH_SERVER" | head -n 1)
    if [ -z "$PID" ]; then
        echo "Failed to start SSH tunnel."
        exit 1
    fi

    # Save the PID to a file for later use.
    echo "$PID" > "$PID_FILE"
    echo "SSH tunnel started with PID $PID."

    # Display that the port is listening.
    echo "Verifying that port $LOCAL_PORT is open:"
    ss -tulpn | grep ":$LOCAL_PORT" || echo "Port $LOCAL_PORT not found. Check if the tunnel started correctly."
}

stop_tunnel() {
    if [ ! -f "$PID_FILE" ]; then
        echo "No PID file found. The tunnel might not be running."
        exit 1
    fi

    PID=$(cat "$PID_FILE")
    echo "Stopping SSH tunnel with PID $PID..."
    kill -9 $PID

    if [ $? -eq 0 ]; then
        rm -f "$PID_FILE"
        echo "SSH tunnel stopped."
    else
        echo "Failed to stop the SSH tunnel. You may need to check manually."
    fi
}

case "$1" in
    start)
        start_tunnel
        ;;
    stop)
        stop_tunnel
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
