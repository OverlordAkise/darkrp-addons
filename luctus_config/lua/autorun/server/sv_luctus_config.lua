--Luctus Ingame Config
--Made by OverlordAkise

util.AddNetworkString("luctus_ingame_config")

LuctusLog = LuctusLog or function()end

hook.Add("PlayerSay","luctus_ingame_config",function(ply,text,team)
    if ply:IsAdmin() and text == "!luctusconfig" then
        net.Start("luctus_ingame_config")
            net.WriteTable(LUCTUS_INGAME_CONFIG)
        net.Send(ply)
    end
end)

net.Receive("luctus_ingame_config",function(len,ply)
    if not ply:IsAdmin() then return end
    local variable = net.ReadString()
    local value = net.ReadString()
    local typedValue = LuctusGetValue(value)
    local isInTable = false
    local category = nil
    for k,v in pairs(LUCTUS_INGAME_CONFIG) do
        if v[variable] then
            isInTable = true
            category = k
        end
    end
    if not isInTable then
        ply:PrintMessage(HUD_PRINTTALK, "[luctus_config] ERROR: Couldnt find variable in config!")
        return
    end
    LuctusIngameConfigSet(variable,typedValue,category)
    _G[variable] = typedValue
    ply:PrintMessage(HUD_PRINTTALK, "[luctus_config] Set successfully!")
    LuctusIngameConfigSave(variable,typedValue,category)
    ply:PrintMessage(HUD_PRINTTALK, "[luctus_config] Saved successfully!")
    LuctusLog("Config",ply:Nick().."("..ply:SteamID()..") set config var '"..variable.."' to '"..typedValue.."'")
end)

function LuctusIngameConfigSet(var,val,cat)
    --also set table:
    LUCTUS_INGAME_CONFIG[cat][var] = val
    
    local tables = string.Split(var,".")
    if #tables == 1 then
        print("[quickset:]",var,val)
        _G[var] = val
        return
    end
    local G = _G
    for i=1,#tables-1 do
        G = G[tables[i]]
        print("[loop_set]",i,tables[i])
    end
    print("[setting:]",tables[#tables],val)
    G[tables[#tables]] = val
end

function LuctusIngameConfigSave(var,val,cat)
    local res = sql.Query("INSERT OR REPLACE INTO luctus_config(name,confcategory,value,valuetype) VALUES("..sql.SQLStr(var)..","..sql.SQLStr(cat)..","..sql.SQLStr(val)..","..sql.SQLStr(LuctusGetType(val))..")")
    if res == false then
        error(sql.LastError())
    end
end

function LuctusGetValue(val)
    if val == "true" or val == "false" then
        return tobool(val)
    end
    if tonumber(val) then
        return tonumber(val)
    end
    return val
end

function LuctusGetType(val)
    if val == "true" or val == "false" then
        return "bool"
    end
    if tonumber(val) then
        return "number"
    end
    return "string"

end

--Load
hook.Add("InitPostEntity","luctus_ingame_config_load",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_config(name VARCHAR(255) UNIQUE,confcategory VARCHAR(255),value VARCHAR(255),valuetype VARCHAR(255))")
    local configs = sql.Query("SELECT * FROM luctus_config")
    if configs == false then
        error(sql.LastError())
    end
    if configs == nil then return end
    for k,row in pairs(configs) do
        local typedValue = LuctusGetValue(row.value)
        LUCTUS_INGAME_CONFIG[row.confcategory][row.name] = typedValue
        LuctusIngameConfigSet(row.name,typedValue,row.confcategory)
    end
    print("[luctus_config] Loaded config successfully!")
end)

print("[luctus_config] SV loaded!")
