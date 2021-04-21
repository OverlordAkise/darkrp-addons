--LucidWarn
--by OverlordAkise

lwconfig = {}

lwconfig.allowedGroups = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["moderator"] = true,
  ["supporter"] = true,
}

lwconfig.warnsToKick = 3
lwconfig.daysToExpire = 14
lwconfig.chatWarns = true
lwconfig.chatCommand = "!lwarn"


lwconfig.warnsToBan = {
--[warns] = time in minutes,
  [5] = 5,
  [10] = 10080,
}