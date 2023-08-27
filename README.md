
![141617d7c996e466c8d2b5201950df8fbc208ddc](https://github.com/lukemax47/node_controller/assets/90896055/79d12412-7807-4c44-8c4b-5c048fd03e0a)


## Welcome to the Node Controller 👨🏼‍💻

Run multiple nodes on one server? Having issues with RAM or CPU usage? Use this script to automatically start and stop your nodes based on 
how close to COMMITTEE they are. The following script will check each node via the Node Monitor API (monitor.incognito.org) and handle
starting and stopping for you.


## Getting Started

⭐ Download the node_controller.sh script to your server.

    sudo wget https://raw.githubusercontent.com/lukemax47/node_controller/main/node_controller.sh

⭐ Edit the node_keys list with all of your Public Validator Keys (same keys used on monitor.incognito.org)

    sudo nano node_controller.sh

⭐ Adjust the epoch triggers (optional) - Currently set to turn on <5 epochs

    if [ "$epoch" -gt 6 ] - epochs over # to shut off container
    
    elif [ "$epoch" -lt 5 ] - epochs under # to turn on container

⭐ Make the script executable

    sudo chmod +x node_controller.sh

⭐ Add this script to your crontab to automatically run (Example: 0 */2 * * * /home/server/node_controller.sh)
  
    sudo crontab -e

----

### That's it!

Congratulations, you have just automatated your docker containers to automatically start or stop! 🚀
