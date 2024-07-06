--Luctus Ingame Config
--Made by OverlordAkise

--This is not a config file

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
    -- print("[DEBUG]",CLIENT and "CL" or "SV",var,"=",val)
    local tables = string.Split(var,".")
    if #tables == 1 then
        _G[var] = val
        return
    end
    local G = _G
    for i=1,#tables-1 do
        G = G[tables[i]]
    end
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

print("[luctus_config] sh loaded")
