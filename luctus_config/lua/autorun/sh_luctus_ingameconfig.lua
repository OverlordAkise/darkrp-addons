--Luctus Ingame Config
--Made by OverlordAkise


--This is not a config file

function LuctusIngameConfigNotify(ply,isError,text)
    if SERVER then
        DarkRP.notify(ply,isError and 1 or 0,5,text)
    else
        notification.AddLegacy(text, isError and 1 or 0, 5)
        surface.PlaySound("buttons/lightswitch2.wav")
    end
end

function LuctusGetValue(val)
    if val == "true" or val == "false" or isbool(val) then
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

function LuctusIngameConfigGetAll()
    local tab = {}
    for cat,values in pairs(SERVER and LUCTUS_INGAME_CONFIG_SV or LUCTUS_INGAME_CONFIG_CL) do
        if not tab[cat] then tab[cat] = {} end
        for k,var in pairs(values) do
            tab[cat][var] = LuctusIngameConfigGet(var)
        end
    end
    return tab
end

function LuctusIngameConfigSave(var,val,cat)
    local res = sql.Query("INSERT OR REPLACE INTO luctus_config(name,confcategory,value,valuetype) VALUES("..sql.SQLStr(var)..","..sql.SQLStr(cat)..","..sql.SQLStr(val)..","..sql.SQLStr(LuctusGetType(val))..")")
    if res == false then
        error(sql.LastError())
    end
end

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

function LuctusIngameConfigChange(variable,value,ply)
    local typedValue = LuctusGetValue(value)
    local isInTable = false
    local category = nil
    
    for k,v in pairs(SERVER and LUCTUS_INGAME_CONFIG_SV or LUCTUS_INGAME_CONFIG_CL) do
        if table.HasValue(v,variable) then
            isInTable = true
            category = k
        end
    end
    if not isInTable then
        LuctusIngameConfigNotify(ply,true,"[luctus_config] ERROR: Couldnt find variable in config!")
        return
    end
    LuctusIngameConfigSet(variable,typedValue,category)
    _G[variable] = typedValue
    LuctusIngameConfigSave(variable,typedValue,category)
    LuctusIngameConfigNotify(ply,false,"[luctus_config] Saved successfully!")
    local message = ply:Nick().."("..ply:SteamID()..") set config var '"..variable.."' to '"..tostring(typedValue).."'"
    print("[config]",message)
    hook.Run("LuctusConfigChanged",ply,variable,typedValue,message)
end

--Load
hook.Add("InitPostEntity","luctus_ingame_config_load",function()
    local tab = SERVER and LUCTUS_INGAME_CONFIG_SV or LUCTUS_INGAME_CONFIG_CL
    print("[luctus_config] Loading config from database")
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_config(name VARCHAR(255) UNIQUE,confcategory VARCHAR(255),value VARCHAR(255),valuetype VARCHAR(255))")
    local configs = sql.Query("SELECT * FROM luctus_config")
    if configs == false then
        error(sql.LastError())
    end
    if configs == nil then return end
    for k,row in pairs(configs) do
        local typedValue = LuctusGetValue(row.value)
        if not tab[row.confcategory] or not table.HasValue(tab[row.confcategory],row.name) then continue end
        LuctusIngameConfigSet(row.name,typedValue,row.confcategory)
    end
    print("[luctus_config] Loaded config successfully!")
end)

print("[luctus_config] sh loaded")
