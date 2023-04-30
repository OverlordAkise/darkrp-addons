--Lucid's Radio 2
--Made by OverlordAkise
--Difference to v1: A custom radio model

util.AddNetworkString("lucid_radio_frequency")
resource.AddWorkshop("635535045")

lucid_radio_teams = {}

LuctusLog = LuctusLog or function()end

lradioHear = {}

for _, ply in pairs(player.GetAll()) do
    lradioHear[ply] = {}
end

timer.Simple(1,function()

    timer.Create("lucid_radio_main", DarkRP.voiceCheckTimeDelay, 0, function()
        local players = player.GetHumans()
        for _, ply in ipairs(players) do
            lradioHear[ply] = {}
            for kk,ply2 in pairs(player.GetAll()) do
                if not ply.lradioOn or not ply2.lradioOn or ply.lradioFrequency != ply2.lradioFrequency then continue end
                if IsValid(ply2:GetActiveWeapon()) and ply2:GetActiveWeapon():GetClass() == "lucid_radio" then
                    lradioHear[ply][ply2] = true
                end
            end
        end
    end)

end)

hook.Add("PlayerCanHearPlayersVoice","lucid_radio",function(listener, talker)
    if lradioHear[listener] and lradioHear[listener][talker] then
        return true, false
    end
end)

hook.Add("PlayerInitialSpawn", "lucid_radio_spawnset", function(ply)
  ply.lradioOn = false
  ply.lradioCooldown = CurTime() + 0.5
  ply.lradioFrequency = 99
end)


function lucidAddRadioReceiver(ply,bol)
  if ply:IsPlayer() then
    if ply.lradioCooldown > CurTime() then return end
    ply.lradioCooldown = CurTime() + 0.5
    ply.lradioOn = bol
    if(bol)then
      DarkRP.notify(ply,0,5,"You logged into radio channel "..ply.lradioFrequency.."!")
      DarkRP.notify(ply,0,5,"People only hear you if you got the device in your hand!")
    else
      DarkRP.notify(ply,1,5,"You logged out of the radio channel!")
    end
  end
end

function LucidResetRadio(ply)
  ply.lradioOn = false
end
hook.Add("PostPlayerDeath","lucid_radio_reset",LucidResetRadio)
hook.Add("PlayerSpawn","lucid_radio_reset",LucidResetRadio)

function LucidAddRadioTeam(name, ...)
  lucid_radio_teams[name] = {}
  for k,v in pairs({...}) do
    lucid_radio_teams[name][v] = true
  end
end

net.Receive("lucid_radio_frequency", function(len,ply)
  local freq = net.ReadString()
  if not tonumber(freq) then 
    DarkRP.notify(ply,1,5,"Frequency wasn't a number!")
    return 
  end
  local fr = tonumber(freq)
  if fr > 99999 or fr < 0 then 
    DarkRP.notify(ply,1,5,"You have to enter a frequency between 0 and 99999!")
    return 
  end
  if fr % 1 ~= 0 then
    DarkRP.notify(ply,1,5,"Only whole numbers are allowed!")
    return
  end
  ply.lradioFrequency = tonumber(freq)
  DarkRP.notify(ply,0,5,"Frequency updated to "..freq)
  LuctusLog("Radio",ply:Nick().."("..ply:SteamID()..") set his radio freq to "..ply.lradioFrequency)
end)

print("[lucid_radio] sv loaded!")
