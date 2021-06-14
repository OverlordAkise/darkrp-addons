--Luctus Technician
--Made by OverlordAkise


LUCTUS_TECHNICIAN_BREAK_DELAY = 120 -- Every 2 minutes a thing breaks for repair
LUCTUS_TECHNICIAN_MIN_REWARD = 1000 --Reward = random between min and max
LUCTUS_TECHNICIAN_MAX_REWARD = 2000


hook.Add("loadCustomDarkRPItems", "luctus_technician_drp", function()
  TEAM_TECHNICIAN = DarkRP.createJob("Technician", {
    color = Color(214, 214, 214, 255),
    model = "models/player/odessa.mdl",
    description = [[Repair broken equipment and earn money!]],
    weapons = {},
    command = "technician",
    max = 2,
    salary = 300,
    admin = 0,
    vote = false,
    hasLicense = false,
    candemote = true,
    category = "Citizens"
  })
end)

if SERVER then
  util.AddNetworkString("luctus_technician_repair")
  util.AddNetworkString("luctus_technician_togglehud")
  
  hook.Add("OnPlayerChangedTeam", "luctus_technician_timer", function(ply, beforeNum, afterNum)
    --switch to technician
    if RPExtraTeams[afterNum].name == "Technician" then
      net.Start("luctus_technician_togglehud")
        net.WriteBool(true)
      net.Send(ply)
    end
    --switch from technician
    if RPExtraTeams[beforeNum].name == "Technician" then
      net.Start("luctus_technician_togglehud")
        net.WriteBool(false)
      net.Send(ply)
    end
  end)
  
  hook.Add("InitPostEntity", "luctus_technician_breaker", function()
    timer.Create("luctus_technician_breaker",LUCTUS_TECHNICIAN_BREAK_DELAY,0,function()
      local ents = ents.FindByClass( "luctus_tec_*" )
      local randomEnt = ents[math.random(#ents)]
      if randomEnt and IsValid(randomEnt) and not randomEnt:GetBroken() then
        randomEnt:SetBroken(true)
        print("[luctus_technician] Sabotaged a random object!")
      end
    end)
    print("[luctus_technician] Timer created!")
  end)
end

print("[luctus_technician] Loaded SH Config!")
