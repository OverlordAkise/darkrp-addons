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

## Install webserver as service behind NGINX

You could use the following NGINX config to setup scene behind it (this uses scene running with default port 5456):

```
#scene
location /sg/ {
        proxy_pass http://localhost:5456/;
}
location = /sg/getkey {
        allow 193.154.217.37;
        # ^your gmod server IP or localhost
        deny all;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://localhost:5456/getkey;
}
```

This enables you to use `http://website.com/sg/` as the root url of your deployment instead of `http://websice.com:5456/`. It also enables you to easily add HTTPS support via nginx.  
This also secures your webserver against people who want to abuse it, because only the IP configured can request keys to upload images.

Use the following systemd .service file to secure your application further and run it as a background app:

```
[Unit]
Description=scene
After=network.target iptables.service mariadb.service

[Service]
Type=simple
User=myuser
Group=myuser
ExecStart=/scene
Restart=always
RestartSec=1m
IPAddressDeny=any
IPAddressAllow=localhost

IPAccounting=yes
CapabilityBoundingSet=
RestrictAddressFamilies=AF_INET
RestrictNamespaces=true
ProtectClock=true
ProtectControlGroups=true
ProtectHome=true
ProtectKernelLogs=true
ProtectKernelModules=true
ProtectKernelTunables=true
ProtectProc=noaccess
ProtectSystem=full
SystemCallFilter=~@clock @debug @module @mount @reboot @privileged @swap @cpu-emulation @obsolete
LockPersonality=true
RemoveIPC=true
UMask=0027
RestrictRealtime=true
NoNewPrivileges=true
PrivateTmp=true
PrivateMounts=true
PrivateDevices=true
ProtectHostname=true
ProcSubset=pid
RestrictSUIDSGID=true
PrivateUsers=true

RootDirectory=/opt/scene
BindReadOnlyPaths=/etc/resolv.conf
InaccessiblePaths=/bin /boot /lib /lib64 /media /mnt /root /sbin /usr /var
StandardOutput=append:/opt/scene/stdout.log
StandardError=inherit

[Install]
WantedBy=multi-user.target
```

