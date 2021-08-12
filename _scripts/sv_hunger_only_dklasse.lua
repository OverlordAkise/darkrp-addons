--Luctus Hunger-Only-For-DKlasse-Fix
--Made by OverlordAkise

--Hungerspeed config is at addons/darkrpmodification/lua/darkrp_config/settings.lua at the bottom

hook.Add("PlayerInitialSpawn", "luctus_fix_hunger_dklasse_only", function(ply)
  if timer.Exists("HMThink") then
    timer.Remove("HMThink")
    --https://wiki.facepunch.com/gmod/timer.Remove
    timer.Simple(0.1, function()
      timer.Create("HMThink", 10, 0, function()
        local a = nil
        for k,v in pairs(player.GetAll()) do
          if (v:getJobTable().name == "Koch") then
            a = true
            break
          end
        end
        if !a then return end 
        
        for _, v in ipairs(player.GetAll()) do 
          if not v:Alive() then continue end 
          if not string.find(v:getJobTable().name,"D-Klasse") then continue end 
          v:hungerUpdate() 
        end 
      end)
    end)
  end
  hook.Remove("PlayerInitialSpawn", "luctus_fix_hunger_dklasse_only")
end)
