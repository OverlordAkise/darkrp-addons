--Luctus Charsystem
--Made by OverlordAkise

hook.Add("PlayerSay", "CharacterSystemPlayerSay", function(ply, text, teamchat)

  local args = string.Split(text, " ")
  args[1] = string.lower(args[1])

  if(args[1] == "!charname") then
    if not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
      ply:ChatAddText(Color(198, 0, 0), LuctusChar.Config.NoPermissions)
      return
    end
    local Target = LuctusGetPlayerFromName(args[2])
    if(!Target) then
      ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
    else
      local NewName = ""
      for i, v in ipairs(args) do
        if(i > 2) then
          NewName = NewName.." "..v  -- Make a the new name complete
        end
      end
      NewName = string.sub(NewName, 2)
      if(!NewName or NewName == "") then -- is there even a name?
      else
        sql.Query("UPDATE luctus_char SET name = "..sql.SQLStr(NewName).." WHERE steamid = "..sql.SQLStr(Target:SteamID()).." AND slot = "..Target.charCurSlot)
        Target:setDarkRPVar("rpname", NewName)  -- Change Name ingame
        ply:ChatAddText(color_white, "Name successfully changed!")
      end
    end
  end
  
  if(args[1] == "!setjob") then
    if not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
      ply:ChatAddText(Color(198, 0, 0), LuctusChar.Config.NoPermissions)
      return
    end
    local Target = LuctusGetPlayerFromName(args[2])
    if(!Target) then
      ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
    else
      local jobnameCH = ""
      for s,l in ipairs(args) do
        if(s > 2) then
          jobnameCH = jobnameCH.." "..l  -- get the jobname
        end
      end
      local NewJob
      jobnameCH = string.sub(jobnameCH, 2)  -- get jobname
      for k, v in pairs(RPExtraTeams) do
        if(string.lower(jobnameCH) == string.lower(v.name)) then   -- if the job name we need to find is equal to v.name k is the jobid
          NewJob = k
        end
      end
      if(!NewJob) then
        ply:ChatAddText(Color(198, 0, 0), "Team not found!")
        return
      end
      Target:changeTeam(NewJob, true, true)
      ply:ChatAddText(color_white, "Successfully changed the job of "..Target:Nick().."!")
    end
  end
  
  if(args[1] == "!chars")then
    if not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
      ply:ChatAddText(Color(198, 0, 0), LuctusChar.Config.NoPermissions)
      return
    end
    local CharInfoTable
    local PlayerName = ""
    PlayerName = args[2]
    local Target = LuctusGetPlayerFromName(PlayerName)
    if(!Target) then
      ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
    else
      CharInfoTable = LuctusGetCharTable(Target)
      if(CharInfoTable) then
        net.Start("LuctusCharAdminMenuOpen")  -- send it to the client
        net.WriteTable(CharInfoTable)
        net.WriteString(Target:SteamID())
        net.Send(ply)
      else
        ply:ChatAddText(Color(198, 0, 0), "No characters found!")
      end
    end
  end
  
  if(args[1] == "!invite") then
    if not LuctusChar.Config.AllowedInvite[ply:Team()] then
      ply:ChatAddText(Color(198, 0, 0), "You can't invite others!")
      return
    end

    local Target = LuctusGetPlayerFromName(text.Split(text,"!invite ")[2])
    if(!Target) then
      ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
      return
    end
    Target.InviteTeam = LuctusChar.Config.AllowedInvite[ply:Team()]
    ply:ChatAddText("You invited "..Target:Nick().."!")
    Target:ChatAddText("You got invited to the job "..team.GetName(ply:Team()).."! Type !accept to accept the invitation!")
    timer.Remove("Invitation"..Target:SteamID())
    timer.Create("Invitation"..Target:SteamID(), 60, 1, function()
      Target.InviteTeam = nil
      Target:ChatAddText(Color(198, 0, 0), "Invitation expired!")
    end)
  end
  
  if(args[1] == "!accept") then
    if(ply.InviteTeam) then
      ply:changeTeam(ply.InviteTeam,true)
      ply.InviteTeam = nil
      timer.Remove("Invitation"..ply:SteamID())
      ply:ChatAddText("You successfully joined as "..team.GetName(ply:Team()).."!")
    else
      ply:ChatAddText("You don't have a pending invitation!")
    end
  end
  
  if(args[1] == "!jkick") then
    if not LuctusChar.Config.AllowedInvite[ply:Team()] and not LuctusChar.Config.AdminGroups[ply:GetUserGroup()] then
      ply:ChatAddText(Color(198, 0, 0), LuctusChar.Config.NoPermissions)
      return
    end
    local Target = LuctusGetPlayerFromName(text.Split(text,"!jkick ")[2])
    if not Target then
      ply:ChatAddText(Color(198, 0, 0), "No player with that name found!")
      return
    end
    if LuctusChar.Config.AllowedInvite[ply:Team()] ~= Target:Team() then
      ply:ChatAddText(Color(198, 0, 0), "You can't kick your target from a job which you do not reign over!")
      return
    end
    Target:changeTeam(LuctusChar.Config.DefaultTeam,true)
    ply:ChatAddText("You kicked "..Target:Nick().." out!")
    Target:ChatAddText("You got kicked out of your job by "..ply:Nick().."!")
  end
end)
