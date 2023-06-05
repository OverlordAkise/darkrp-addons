# Luctus Discord

This is a small "discord bot" that can send messages to a discord channel via discord webhooks.  
The current code (in sv_luctus_discord.lua) mainly monitors your server and sends alerts on important events.  
Example events included: ULX bans, kicks, lag, jobranks, warns, whitelist changed.

To create a webhook URL you have to click on the settings of a channel and head to "integrations".

The problem: Discord blocks api calls from GMod user-agent "Valve/Steam HTTP Client 1.0 (4000)".  
Source: https://github.com/discord/discord-api-docs/issues/849#issuecomment-622654079

This means we have to send the message via a relay, a simple web application that takes our webhook request and sends it to discord from there.  
The current implementation, included with my other project "istina", takes a POST request with a json body of: url,msg,tag. All of those 3 are strings. Msg is the message text, url is the discord webhook url and tag is the word inside of the square brackets at the beginning of the discord message.

You can also implement your own relay, or you can ask me to use my one.
