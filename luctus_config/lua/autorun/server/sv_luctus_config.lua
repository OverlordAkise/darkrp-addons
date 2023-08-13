--Luctus Ingame Config
--Made by OverlordAkise

util.AddNetworkString("luctus_ingame_config")

hook.Add("PlayerSay","luctus_ingame_config",function(ply,text,team)
    if ply:IsAdmin() and text == "!luctusconfig" then
        net.Start("luctus_ingame_config")
            net.WriteTable(LuctusIngameConfigGetAll())
        net.Send(ply)
    end
end)

function LuctusIngameConfigGetAll()
    local tab = {}
    for cat,values in pairs(LUCTUS_INGAME_CONFIG) do
        if not tab[cat] then tab[cat] = {} end
        for k,var in pairs(values) do
            tab[cat][var] = LuctusIngameConfigGet(var)
        end
    end
    return tab
end

net.Receive("luctus_ingame_config",function(len,ply)
    if not ply:IsAdmin() then return end
    local variable = net.ReadString()
    local value = net.ReadString()
    local typedValue = LuctusGetValue(value)
    local isInTable = false
    local category = nil
    
    for k,v in pairs(LUCTUS_INGAME_CONFIG) do
        if table.HasValue(v,variable) then
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
    LuctusIngameConfigSave(variable,typedValue,category)
    ply:PrintMessage(HUD_PRINTTALK, "[luctus_config] Saved successfully!")
    local message = ply:Nick().."("..ply:SteamID()..") set config var '"..variable.."' to '"..tostring(typedValue).."'"
    print("[config]",message)
    hook.Run("LuctusConfigChanged",ply,variable,typedValue,message)
end)

--non-existing var will be nil
function LuctusIngameConfigGet(var)
    local tables = string.Split(var,".")
    if #tables == 1 then
        return _G[var]
    end
    local G = _G
    for i=1,#tables-1 do
        G = G[tables[i]]
    end
    return G[tables[#tables]]
end

function LuctusIngameConfigSet(var,val,cat)
    local tables = string.Split(var,".")
    if #tables == 1 then
        print("[luctus_config] QSet",var,"to",val)
        _G[var] = val
        return
    end
    local G = _G
    for i=1,#tables-1 do
        G = G[tables[i]]
    end
    print("[luctus_config] Set",tables[#tables],"to",val)
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
    if val=="true" or val=="false" or val==true or val==false then
        return "bool"
    end
    if tonumber(val) then
        return "number"
    end
    return "string"

end

--Load
hook.Add("InitPostEntity","luctus_ingame_config_load",function()
    print("[luctus_config] Loading config from database")
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_config(name VARCHAR(255) UNIQUE,confcategory VARCHAR(255),value VARCHAR(255),valuetype VARCHAR(255))")
    local configs = sql.Query("SELECT * FROM luctus_config")
    if configs == false then
        error(sql.LastError())
    end
    if configs == nil then return end
    for k,row in pairs(configs) do
        local typedValue = LuctusGetValue(row.value)
        if not LUCTUS_INGAME_CONFIG[row.confcategory] or not table.HasValue(LUCTUS_INGAME_CONFIG[row.confcategory],row.name) then continue end
        LuctusIngameConfigSet(row.name,typedValue,row.confcategory)
    end
    print("[luctus_config] Loaded config successfully!")
end)

print("[luctus_config] sv loaded!")
