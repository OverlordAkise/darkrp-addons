# Luctus MultiServerChat

**WARNING** : This is no easy addon to install or use! This addon requires a linux server because you need to run a websocket echo-server.

I also recommend to use this for local-servers only (as in 2 gmod servers on the same host) because the echo server doesn't have any security built in by default.

## Install

First take the addon `luctus_multiserverchat` from the addons folder and upload it to your server's addon folder.  
Change the URL to your local echoserver URL. (It has to begin with `ws://` !)

Then take the lua/bin/gmsv_gwsockets_linux.dll file and upload it to your server to `garrysmod/lua/bin/gmsv_gwsockets_linux.dll`.  
This file is built for linux 32bit. If you need any other version (e.g. 64bit or windows) then please download them from [https://github.com/FredyH/GWSockets/releases/tag/1.2.0](https://github.com/FredyH/GWSockets/releases/tag/1.2.0)

Lastly you are going to need a websocket echo server. This folder has one built in Golang as an example, but you can run your own aswell. It only needs an endpoint which, if connected to via a websocket connection, echoes messages sent to it back to everyone connected.

To run the example echoserver code install Go and run the following inside the folder:

    go install
    go build .
    ./gmodwss

To run it in the background:

    screen -A -m -d -S gmodwss ./gmodwss

The server should never crash as any panic in HTTP routes is recovered from automatically.
