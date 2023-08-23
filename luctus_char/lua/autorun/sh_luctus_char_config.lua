--Luctus Charsystem
--Made by OverlordAkise

--Message shown in the middle of the job menu
LUCTUS_CHAR_WELCOMEMSG = "Welcome to MyServer!" --GetHostName()

--Buttons that should be displayed at the top, left = name, right = url link or lua function
--The disconnect button is added automatically on the right
LUCTUS_CHAR_UI_BUTTONS = {
    {"Forum", "https://google.com"},
    {"Workshop", "https://google.com"},
    {"Discord", "https://google.com"},
}

--Usergroups who may edit characters, kick from jobs, etc.
LUCTUS_CHAR_ADMINS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["operator"] = true,
    ["moderator"] = true,
    ["supporter"] = true,
}

--Default Job config has to load after darkrpmodification
hook.Add("postLoadCustomDarkRPItems","luctus_charsys_jobconfig",function()

    --Default team for new characters
    LUCTUS_CHAR_DEFAULT_TEAM = TEAM_CITIZEN

    --Default money for new characters, currently uses the DarkRP setting
    LUCTUS_CHAR_DEFAULT_MONEY = (GM and GM.Config.startingmoney) or (GAMEMODE and GAMEMODE.Config.startingmoney)
    
    
    --Enable jobs like Police Chief to invite other players to e.g. Police jobs
    LUCTUS_CHAR_INVITE_ENABLED = true
    -- On the left the group that can invite, on the right the job the guy will get after accepting the invite
    -- Example: Gangster Boss invites someone, they will get job gangster after accepting
    LUCTUS_CHAR_INVITE_JOBS = {
        [TEAM_MOB] = TEAM_GANG,
    }
    
    
    --Remove easy renaming
    DarkRP.removeChatCommand("nick")
    DarkRP.removeChatCommand("name")
    DarkRP.removeChatCommand("rpname")
    --Remove everyone can join any team
    GM.Config.restrictallteams = true
    
    print("[luctus_char] config loaded")
end)

print("[luctus_char] sh loaded")
