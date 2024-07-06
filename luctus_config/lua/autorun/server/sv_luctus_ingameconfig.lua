--Luctus Ingame Config
--Made by OverlordAkise

util.AddNetworkString("luctus_ingame_config")
util.AddNetworkString("luctus_ingame_config_cl")
util.AddNetworkString("luctus_ingame_config_cl_sync")

LUCTUS_IGC_CLIENT_VALUES = LUCTUS_IGC_CLIENT_VALUES or {}

hook.Add("PlayerSay","luctus_ingame_config",function(ply,text,team)
    if not ply:IsSuperAdmin() then return end
    if text ~= LUCTUS_INGAME_CONFIG_CMD_SV then return end
    net.Start("luctus_ingame_config")
        net.WriteTable(LuctusIngameConfigGetAll())
    net.Send(ply)
    return ""
end)

net.Receive("luctus_ingame_config",function(len,ply)
    if not ply:IsSuperAdmin() then return end
    local variable = net.ReadString()
    local value = net.ReadString()
    LuctusIngameConfigChangeServer(variable,value,ply)
end)

net.Receive("luctus_ingame_config_cl",function(len,ply)
    if not ply:IsSuperAdmin() then return end
    local variable = net.ReadString()
    local value = net.ReadString()
    LuctusIngameConfigChangeForClients(variable,value,ply)
end)

--small cache for initially syncing CL configs to joining players
local initCLSyncCache
net.Receive("luctus_ingame_config_cl_sync",function(len,ply)
    if ply.ligc_synced then return end
    ply.ligc_synced = true
    if not initCLSyncCache then
        initCLSyncCache = util.Compress(util.TableToJSON(LUCTUS_IGC_CLIENT_VALUES))
    end
    net.Start("luctus_ingame_config_cl_sync")
        net.WriteUInt(#initCLSyncCache,16)
        net.WriteData(initCLSyncCache,#initCLSyncCache)
    net.Send(ply)
end)

function LuctusIngameConfigNotify(ply,isError,text)
    DarkRP.notify(ply,isError and 1 or 0,5,text)
end

function LuctusIngameConfigSave(var,val,cat,realm)
    local res = sql.Query("INSERT OR REPLACE INTO luctus_config(realm,name,confcategory,value,valuetype) VALUES("..sql.SQLStr(realm)..","..sql.SQLStr(var)..","..sql.SQLStr(cat)..","..sql.SQLStr(val)..","..sql.SQLStr(LuctusGetType(val))..")")
    if res == false then
        error(sql.LastError())
    end
end

function LuctusIngameConfigChangeServer(variable,value,ply)
    local typedValue = LuctusGetValue(value)
    local isInTable = false
    local category = nil
    
    for k,v in pairs(LUCTUS_INGAME_CONFIG_SV) do
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
    LuctusIngameConfigSave(variable,typedValue,category,"server")
    LuctusIngameConfigNotify(ply,false,"[luctus_config] Saved successfully!")
    local message = ply:Nick().."("..ply:SteamID()..") set sv config var '"..variable.."' to '"..tostring(typedValue).."'"
    print("[luctus_config]",message)
    hook.Run("LuctusConfigChanged",ply,variable,typedValue,message)
end

function LuctusIngameConfigChangeForClients(variable,value,ply)
    local typedValue = LuctusGetValue(value)
    local isInTable = false
    local category = nil
    
    for k,v in pairs(LUCTUS_INGAME_CONFIG_CL) do
        if table.HasValue(v,variable) then
            isInTable = true
            category = k
        end
    end
    if not isInTable then
        LuctusIngameConfigNotify(ply,true,"[luctus_config] ERROR: Couldnt find variable in config!")
        return
    end
    
    --Clear cache for joining players because variables changed
    initCLSyncCache = nil
    
    LuctusIngameConfigSave(variable,typedValue,category,"client")
    LuctusIngameConfigSendClientSingle(variable,typedValue,category)
    
    if not LUCTUS_IGC_CLIENT_VALUES[category] then
        LUCTUS_IGC_CLIENT_VALUES[category] = {}
    end
    LUCTUS_IGC_CLIENT_VALUES[category][variable] = typedValue
    
    LuctusIngameConfigNotify(ply,false,"[luctus_config] Saved successfully!")
    local message = ply:Nick().."("..ply:SteamID()..") set cl config var '"..variable.."' to '"..tostring(typedValue).."'"
    print("[luctus_config]",message)
    hook.Run("LuctusConfigChanged",ply,variable,typedValue,message)
end

function LuctusIngameConfigSendClientSingle(var,val,cat)
    net.Start("luctus_ingame_config_cl")
        net.WriteString(cat)
        net.WriteString(var)
        net.WriteType(val)
    net.Broadcast()
end

--Load
hook.Add("InitPostEntity","luctus_ingame_config_load",function()
    sql.Query("CREATE TABLE IF NOT EXISTS luctus_config(realm VARCHAR(7), name VARCHAR(255) UNIQUE,confcategory VARCHAR(255),value VARCHAR(255),valuetype VARCHAR(255))")
    local configs = sql.Query("SELECT * FROM luctus_config")
    if configs == false then
        error(sql.LastError())
    end
    if configs == nil then return end
    LUCTUS_IGC_CLIENT_VALUES = {}
    for k,row in pairs(configs) do
        local typedValue = LuctusGetValue(row.value)
        if row.realm == "client" then
            if not LUCTUS_INGAME_CONFIG_CL[row.confcategory] or not table.HasValue(LUCTUS_INGAME_CONFIG_CL[row.confcategory],row.name) then continue end
            if not LUCTUS_IGC_CLIENT_VALUES[row.confcategory] then
                LUCTUS_IGC_CLIENT_VALUES[row.confcategory] = {}
            end
            LUCTUS_IGC_CLIENT_VALUES[row.confcategory][row.name] = typedValue
        else
            if not LUCTUS_INGAME_CONFIG_SV[row.confcategory] or not table.HasValue(LUCTUS_INGAME_CONFIG_SV[row.confcategory],row.name) then continue end
            LuctusIngameConfigSet(row.name,typedValue,row.confcategory)
        end
    end
    print("[luctus_config] Loaded config successfully!")
end)

print("[luctus_config] sv loaded")
