# Luctus Text-To-Speech (project olga)

This is a text-to-speech addon for garrysmod.  
You can use lua functions or chat commands to turn text into a voice everyone can hear.

**WARNING: THIS ADDON DOES NOT WORK OUT OF THE BOX!**  
You need access to the voice-generation webserver (either self hosted or from someone else) and configure the URLs in the gmod addon correctly.

If you do not have the capabilities to host the webserver yourself you can contact me and I will let you use mine.

# Limitations

There currently is only one voice available (jenny, female) and the only language is english. This means you have to write your messages in english for them to sound well.

The apiserver golang binary can NOT be run multiple times at once because of the limitations of the wrapper module.

It uses quite a lot of CPU to generate the audio files. The application caches generated audio files, but many different messages at once could exhaust your available CPU.  
I recommend limiting the CPU available to the `ttss` binary by using `CPUQuota=100%` in a systemd service file.

# Install

First install the alsa library:

On debian/ubuntu:

```
apt install libasound2-dev
```

or on redhat based systems:

```
dnf install alsa-lib-devel
```

Now go into the `go_webserver` directory. With go installed run the following command to build the binary:

```
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags '-w -s' -o ttss .
```

This should create a file named `ttss` in the current directory, this is the voice api server.  
You can start it simply by using `./ttss`, logging will be (by default) send to stdout.  
You can also use `./ttss --help` to see available flags.

# Using in gmod

To use tts in gmod you can either use the chat command (`!tts` by default) or the following 2 lua functions:

```
--play for everyone:
LuctusSpeechPlaySound("test message")
--play sound only for one player:
LuctusSpeechPlaySoundPly(ply,"test message only for ply")
```
