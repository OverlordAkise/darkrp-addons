--Luctus Radio
--Made by OverlordAkise

util.AddNetworkString("luctus_radio_frequency")
resource.AddWorkshop("635535045")

lradioHear = {}

hook.Add("InitPostEntity","luctus_radio_init",function()

    timer.Create("luctus_radio_main", DarkRP.voiceCheckTimeDelay, 0, function()
        local players = player.GetHumans()
        for _, ply in ipairs(players) do
            lradioHear[ply] = {}
            for kk,ply2 in pairs(player.GetAll()) do
                if not ply.lradioOn or not ply2.lradioOn or ply.lradioFrequency != ply2.lradioFrequency then continue end
                if IsValid(ply2:GetActiveWeapon()) and ply2:GetActiveWeapon():GetClass() == "luctus_radio" then
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


function LuctusRadioToggle(ply,turnOn)
    if not ply:IsPlayer() then return end
    if ply.lradioCooldown > CurTime() then return end
    ply.lradioCooldown = CurTime() + 0.5
    ply.lradioOn = turnOn
    if turnOn then
        DarkRP.notify(ply,0,5,"You logged into radio channel "..ply.lradioFrequency.."!")
        DarkRP.notify(ply,0,5,"People only hear you if you got the device in your hand!")
    else
        DarkRP.notify(ply,1,5,"You logged out of the radio channel!")
    end
end

function LucidResetRadio(ply)
    ply.lradioOn = false
end
hook.Add("PostPlayerDeath","lucid_radio_reset",LucidResetRadio)
hook.Add("PlayerSpawn","lucid_radio_reset",LucidResetRadio)

net.Receive("luctus_radio_frequency", function(len,ply)
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
    hook.Run("LuctusRadioFreqChanged",ply,ply.lradioFrequency)
end)

print("[lucid_radio] sv loaded!")
