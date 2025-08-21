# 📡 Transmission Trackers 

This Bash script simplifies adding trackers to torrents managed with **Transmission**.  
It validates credentials, checks if the torrent ID exists, fetches an updated tracker list from a public source, and adds them automatically.

✨ Features  
- Secure credential input, username and password.  
- Validates Transmission connection before continuing.  
- Lists all torrents with IDs for easy selection.  
- Validates the torrent ID exists.  
- Downloads a public “best” tracker list.  
- Skips invalid tracker URLs.  
- Displays success and failure statistics.

⚙️ Requirements  
- **Transmission** with `transmission-remote` available.  
- **curl** installed.  
- Core utilities **(awk, sed, grep)** typically pre-installed on most systems
- Internet connection to fetch the tracker list.

🚀 Usage  
1. **Make the script executable:**  
   ```bash
   chmod +x addtrackers.sh
   ```

2. **Run the script:**  
   ```bash
   ./addtrackers.sh
   ```

3. **Enter your Transmission username and password when prompted**
4. **Pick the torrent ID from the displayed list.**
5. **The script adds trackers and shows a summary**

