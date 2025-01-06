## Inside Server

### System Information:

- **View system info:**
  ```bash
  uname -a
  ```
- **Check memory usage:**
  ```bash
  free -h
  ```
- **Check disk usage:**
  ```bash
  df -h
  ```
- **Check CPU usage:**
  ```bash
  top
  ```
  or
  ```bash
  htop
  ```
- **Check system uptime:**
  ```bash
  uptime
  ```

### User and Permissions:

- **List all users:**
  ```bash
  cut -d: -f1 /etc/passwd
  ```
- **Switch user:**
  ```bash
  su - username
  ```
- **Change user password:**
  ```bash
  sudo passwd username
  ```
- **Add a user:**
  ```bash
  sudo adduser username
  ```

### File Operations:

- **List files in directory:**
  ```bash
  ls -l
  ```
- **Change directory:**
  ```bash
  cd /path/to/directory
  ```
- **Copy files:**
  ```bash
  cp source destination
  ```
- **Move/rename files:**
  ```bash
  mv source destination
  ```
- **Remove files:**
  ```bash
  rm filename
  ```
- **Edit a file (with nano editor):**
  ```bash
  nano filename
  ```

### Networking:

- **Check IP address:**
  ```bash
  ip a
  ```
- **Check open ports:**
  ```bash
  sudo netstat -tuln
  ```
- **Test connectivity to a host:**
  ```bash
  ping hostname_or_ip
  ```
- **Check active network connections:**
  ```bash
  ss -tuln
  ```

### Package Management (Debian-based systems):

- **Update packages:**
  ```bash
  sudo apt update
  ```
- **Upgrade packages:**
  ```bash
  sudo apt upgrade
  ```
- **Install a package:**
  ```bash
  sudo apt install package_name
  ```
- **Remove a package:**
  ```bash
  sudo apt remove package_name
  ```

### Services Management:

- **Check service status:**
  ```bash
  sudo systemctl status service_name
  ```
- **Start a service:**
  ```bash
  sudo systemctl start service_name
  ```
- **Stop a service:**
  ```bash
  sudo systemctl stop service_name
  ```
- **Enable a service to start at boot:**
  ```bash
  sudo systemctl enable service_name
  ```
- **Restart a service:**
  ```bash
  sudo systemctl restart service_name
  ```

### Logs:

- **View system logs (most recent logs):**
  ```bash
  sudo journalctl -xe
  ```
- **View specific service logs:**
  ```bash
  sudo journalctl -u service_name
  ```

### Firewall (UFW):

- **Check UFW status:**
  ```bash
  sudo ufw status
  ```
- **Allow port (e.g., port 80 for HTTP):**
  ```bash
  sudo ufw allow 80/tcp
  ```
- **Enable UFW:**
  ```bash
  sudo ufw enable
  ```
- **Disable UFW:**
  ```bash
  sudo ufw disable
  ```
- **Check firewall rules:** ```bash
  sudo ufw status verbose

````

### Processes:
- **Show running processes:**
  ```bash
  ps aux
````

- **Kill a process:**
  ```bash
  kill process_id
  ```
- **Kill a process by name:**
  ```bash
  pkill process_name
  ```

### SSH:

- **SSH into server:**
  ```bash
  ssh username@hostname_or_ip
  ```
- **SSH with a specific port:**
  ```bash
  ssh -p port_number username@hostname_or_ip
  ```

### Disk Usage & Cleanup:

- **Check disk usage:**
  ```bash
  sudo du -sh /path/to/folder
  ```
- **Clean up apt cache:**
  ```bash
  sudo apt clean
  ```

### Backup and Restore:

- **Create a tar backup:**
  ```bash
  tar -czvf backup.tar.gz /path/to/directory
  ```
- **Extract a tar backup:**
  ```bash
  tar -xzvf backup.tar.gz
  ```
