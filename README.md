

## Getting Started

⭐ Download the node_controller.sh script to your server.

    sudo wget https://raw.githubusercontent.com/lukemax47/node_controller/main/node_controller.sh

⭐ Edit the node_keys list with all of your Public Validator Keys

    sudo nano node_controller.sh

⭐ Adjust the epoch triggers (optional) - Currently set to turn on <5 epochs

    if [ "$epoch" -gt 6 ] - epochs over # to shut off container
    
    elif [ "$epoch" -lt 5 ] - epochs under # to turn on container

⭐ Make the script executable

    sudo chmod +x node_controller.sh

⭐ Add this script to your crontab to automatically run (Example: `0 */2 * * * /home/server/node_controller.sh)
  
    sudo crontab -e

---

That's it! Congratulations, you have just automatated your docker containers to automatically start or stop! 🚀
