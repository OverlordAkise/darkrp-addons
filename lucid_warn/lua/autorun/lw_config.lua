--LucidWarn
--Made by OverlordAkise

lwconfig = {}

--What groups have access to the warn admin system
lwconfig.allowedGroups = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["moderator"] = true,
  ["supporter"] = true,
}
--How many active warns until you get kicked for new warns
lwconfig.warnsToKick = 3
--How many days till warns become inactive
lwconfig.daysToExpire = 14
--If warns get echoed in chat
lwconfig.chatWarns = true
--What command opens the warn menu
lwconfig.chatCommand = "!warn"


lwconfig.warnsToBan = {
--[warns] = time in minutes,
  [5] = 1440, --after 5 active warns 24h ban
  [10] = 44640, --10 warns = 1 month ban
}

print("[lucid_warn] Loaded SH file!")
