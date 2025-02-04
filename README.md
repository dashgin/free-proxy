# SSH SOCKS Proxy Tunnel

This repository contains a simple Bash script to start and stop an SSH-based SOCKS proxy tunnel on your machine. You can use this tunnel to route your web traffic (for example, from Python scripts) through a remote server.

## What It Does

- **Start the Tunnel:**  
  The script opens an SSH connection that creates a SOCKS proxy on your local machine (default port: `1080`).

- **Stop the Tunnel:**  
  The script stops the SSH connection (and therefore the proxy) by killing the associated process.

## Requirements

- **Operating System:** Linux, macOS, or any Unix-like OS.
- **Software:**  
  - An SSH client  
  - The `ss` command (usually part of the `iproute2` package on Linux)
  - Bash
- **For Python Usage (Optional):**  
  - Python 3  
  - The `requests` library with SOCKS support. Install it with:
    ```bash
    pip install requests[socks]
    ```

## How to Set Up

1. **Edit the Script**  
   Open the `tunnel.sh` file and update these lines with your own details:
   ```bash
   SSH_USER="user"                # Your SSH username
   SSH_SERVER="YOUR.PROXY.SERVER.IP"  # Your proxy server's IP address
   LOCAL_PORT=1080                # Port for the SOCKS proxy (default is 1080)
   PID_FILE="/tmp/ssh_tunnel.pid" # File where the process ID will be stored
   ```

2. **Make the Script Executable**  
   Run:
   ```bash
   chmod +x tunnel.sh
   ```

## How to Use the Script

### Starting the Tunnel

To start the proxy tunnel, run:
```bash
./tunnel.sh start
```
- This will create the SSH tunnel.
- The script saves the tunnel's process ID (PID) to a file so it can be stopped later.
- It also checks that your local port (`1080`) is open.

### Stopping the Tunnel

To stop the proxy tunnel, run:
```bash
./tunnel.sh stop
```
- The script reads the PID from the file and stops the SSH process.
- It then removes the PID file.

## Using the Proxy with Python

If you want to send your Python web requests through the proxy, you can do so with the `requests` library.

### Install the Required Package
```bash
pip install 'requests[socks]'
```

### Example Python Code
```python
import requests

proxies = {
    "http": "socks5://localhost:1080",
    "https": "socks5://localhost:1080"
}

response = requests.get("http://httpbin.org/ip", verify=False, proxies=proxies)
print("Response:", response.text)
```
This code directs your web requests through the SOCKS proxy tunnel running on your local machine at port `1080`.

## License
MIT
Feel free to use, modify, and share this script as needed.
