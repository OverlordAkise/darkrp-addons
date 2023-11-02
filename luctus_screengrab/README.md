# Luctus Screengrab

**WARNING** : This is no easy addon to install! You either ask me, OverlordAkise, if you can use my instance or you have to host your own screengrab server.

This took, on average, 0.4s from starting the screengrab via ulx to receiving the link. The actual time on the client from request to response was only 0.25s.


## Install addon

Simply drag the `luctus_screengrab` folder in the addons folder into your server's addons folder.  

## Install webserver

If you want to host your own screengrab server:

```bash
# On your linux server go into the _go_webserver folder
cd _go_webserver
# Use the example config
mv config.example.yaml config.yaml
# Edit the config to set your database credentials
# nano config.yaml
# Get the go dependencies
go get .
# Build the go server
go build .
# Run it
./scene &
```
