--Luctus Modelchanger
--Made by OverlordAkise

function LuctusLoadModelchangerEntities()
    for name,modelTable in pairs(LUCTUS_MODELCHANGER_CABINETS) do
        local newClass = "luctus_modelchanger"..string.lower(string.Replace(name," ",""))
        local SENT = table.Copy(scripted_ents.Get("luctus_modelchanger"))
        SENT.Base = "luctus_modelchanger"
        SENT.PrintName = name
        SENT.Category = "Luctus Modelchanger"
        SENT.Spawnable = true
        SENT.ModelConfig = modelTable
        SENT.ClassName = newClass
        scripted_ents.Register(SENT,newClass)
    end
end

hook.Add("PopulatePropMenu", "luctus_load_modelchanger", LuctusLoadModelchangerEntities)
hook.Add("InitPostEntity", "luctus_load_modelchanger",LuctusLoadModelchangerEntities)

hook.Add("PlayerSpawn","luctus_modelchanger_keep",function(ply)
    if not LUCTUS_MODELCHANGER_KEEP_MODEL_AFTER_DEATH then return end
    if not ply.lnewModel then return end
    timer.Simple(0.3,function()
        ply:SetModel(ply.lnewModel)
    end)
end)

print("[luctus_modelchanger] sh loaded")
