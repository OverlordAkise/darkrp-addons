--Luctus NLR
--Made by OverlordAkise

util.AddNetworkString("luctus_nlr_greyscreen")
util.AddNetworkString("luctus_nlr_showzone")

function LuctusNlrHandleDeath(ply)
  if ply.nlrzone and IsValid(ply.nlrzone) then
    ply.nlrzone:Remove()
  end
  local ent = ents.Create("nlr_zone")
  ent.player = ply
  ply.nlrzone = ent
  ply.insideNLR = false
  ent:SetPos(ply:GetPos())
  ent:Spawn()
  luctusStartNLRTimer(ply)
  timer.Simple(0.5,function()
    net.Start("luctus_nlr_showzone")
      net.WriteEntity(ent)
    net.Send(ply)
  end)
end

hook.Add("MedicSys_PlayerDeath","luctus_nlr_set_gd",LuctusNlrHandleDeath)
hook.Add("PostPlayerDeath","luctus_nlr_set",LuctusNlrHandleDeath)


function luctusStartNLRTimer(ply)
  timer.Create(ply:SteamID().."_nlrzone",300,1,function()
    if IsValid(ply) and IsValid(ply.nlrzone) then
      ply.nlrzone:Remove()
      if ply.nlrweapons and #ply.nlrweapons > 0 then
        for k,v in pairs(ply.nlrweapons) do
          ply:Give(v)
        end
      end
    end
  end)
end

function luctusGiveWeaponsBack(ply)
  net.Start("luctus_nlr_greyscreen")
    net.WriteBool(false)
  net.Send(ply)
  if not ply.nlrweapons or #ply.nlrweapons == 0 then return end
  for k,v in pairs(ply.nlrweapons) do
    ply:Give(v)
  end
  ply.nlrweapons = {}
end

function luctusTakeWeapons(ply)
  net.Start("luctus_nlr_greyscreen")
    net.WriteBool(true)
  net.Send(ply)
  ply.nlrweapons = {}
  for k,v in pairs(ply:GetWeapons()) do
    table.insert(ply.nlrweapons,v:GetClass())
  end
  ply:StripWeapons()
end

print("[luctus_nlr] SV loaded")
