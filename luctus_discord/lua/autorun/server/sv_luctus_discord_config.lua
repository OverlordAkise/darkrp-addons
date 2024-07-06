--Luctus Discord Notifications
--Made by OverlordAkise

--Is the discord echo enabled?
LUCTUS_DISCORD_ENABLED = true
--Endpoint for discord relay
LUCTUS_DISCORD_ENDPOINT = "http://localhost:8080/discordrelay"
--Discord webhook URL
LUCTUS_DISCORD_WEBHOOK = "https://discord.com/api/webhooks/12345/abc123-_456"
--Name/Tag to prepend with every message
LUCTUS_DISCORD_TAG = "[gmod] "
--If ulx/sam is installed, which commands should be logged to discord
--SAM commands only need the command itself, ULX needs to have "ulx " infront of it
LUCTUS_DISCORD_ADMIN_CMDS = {
    ["ulx noclip"] = true, --ulx example
    ["slap"] = true, --sam example
}

--Function on how to send the data to the endpoint
--(Includes an anti-spam check)
function LuctusDiscordSend(message)
    print("[luctus_discord]",message)
    if not LUCTUS_DISCORD_ENABLED then return end
    HTTP({
        failed = function(failMessage)
            print("[luctus_discord] FAILED TO SEND MESSAGE!")
            print("[luctus_discord]",os.date("%H:%M:%S - %d/%m/%Y",os.time()))
            -- ErrorNoHaltWithStack(failMessage)
        end,
        success = function(httpcode,body,headers)
            --nothing yet
        end, 
        method = "POST",
        url = LUCTUS_DISCORD_ENDPOINT,
        body = util.TableToJSON({url=LUCTUS_DISCORD_WEBHOOK,tag=LUCTUS_DISCORD_TAG,msg=message}),
        type = "application/json; charset=utf-8",
        timeout = 10
    })
end

print("[luctus_discord] config loaded!")
