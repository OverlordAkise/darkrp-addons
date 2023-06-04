--Luctus Warn
--Made by OverlordAkise

--What groups have access to the warn admin system
LUCTUS_WARN_ADMINGROUPS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    ["supporter"] = true,
}
--How many active warns until you get kicked for new warns
LUCTUS_WARNS_TILL_KICK = 3
--How many days till warns become inactive
LUCTUS_WARN_DAYS_TILL_EXPIRE = 14
--If warns get echoed in chat
LUCTUS_WARN_SHOULD_ECHO_IN_CHAT = true
--What command opens the warn menu
LUCTUS_WARN_CHAT_COMMAND = "!warn"


LUCTUS_WARN_BAN_CONFIG = {
  --[warnsNeeded] = bantime in minutes,
    [5] = 1440, --after 5 active warns 24h ban
    [10] = 44640, --10 warns = 1 month ban
}

print("[luctus_warn] Loaded SH file!")
