--Luctus Charsystem
--Made by OverlordAkise

LuctusChar = LuctusChar or {}
LuctusChar.Config = LuctusChar.Config or {}

--Welcome message in the middle of the char menu
LuctusChar.Config.WelcomeMessage = "Welcome to "..GetHostName()

--Buttons that should be displayed at the top, left = name, right = url link
LuctusChar.Config.CustomButtons = {
  {"Forum", "https://google.com"},
  {"Workshop", "https://google.com"},
  {"Discord", "https://google.com"}
}


--can kick out of job, change name, open admin menu
LuctusChar.Config.AdminGroups = {
  ["superadmin"] = true,
  ["admin"] = true,
  ["operator"] = true,
  ["moderator"] = true,
  ["supporter"] = true,
}

--Error message, used often
LuctusChar.Config.NoPermissions = "You do not have permissions, to execute this command!"

--Default Job config has to load after darkrpmodification
hook.Add("postLoadCustomDarkRPItems","luctus_charsys_jobconfig",function()

  --Default team for new characters
  LuctusChar.Config.DefaultTeam = TEAM_CITIZEN
  
  --Default money for new characters, currently uses the DarkRP setting
  LuctusChar.Config.DefaultMoney = (GM and GM.Config.startingmoney) or (GAMEMODE and GAMEMODE.Config.startingmoney)
  
  -- On the left the group that can invite, on the right the job the guy will get after accepting the invite
  -- Example: Gangster Boss invites someone, they will get job gangster after accepting
  LuctusChar.Config.AllowedInvite = {
    [TEAM_MOB] = TEAM_GANG,
  }
  
  --Don't Change this
  DarkRP.removeChatCommand("nick")
  DarkRP.removeChatCommand("name")
  DarkRP.removeChatCommand("rpname")
  
end)
