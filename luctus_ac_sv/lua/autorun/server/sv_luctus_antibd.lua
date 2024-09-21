--Luctus Anti Backdoor
--Made by OverlordAkise

--This tries to secure you from backdoors by disabling RunString from net and http messages
--WARNING: This could mess up vcmod or similar addons, please adjust manually

local ENABLED = true

--Please keep the list of good Sources minimal
local goodSource = {
    ["addons/test/lua/autorun/sh_testing.lua:24"] = true,
}

local lprint = print
local lErrorNoHaltWithStack = ErrorNoHaltWithStack
local debugGetinfo = debug.getinfo
local oldRunString = RunString
local oldRunStringEx = RunStringEx
local oldCompileString = CompileString

local badSources = {
    ["lua/includes/modules/http.lua"] = true,
    ["lua/includes/extensions/net.lua"] = true,
}

local function IsBadSourceInCall()
    for i=1,50 do
        local tab = debugGetinfo(i)
        if not tab or not tab.short_src then continue end
        if goodSource[tab.short_src..":"..tab.currentline] then
            return false
        end
        if badSources[tab.short_src] then
            return true
        end
    end
    return false
end

function newRunString(text)
    if IsBadSourceInCall() then
        lprint("[antibd] !!! WARNING !!!")
        lErrorNoHaltWithStack("[antibd] Blocked RunString from a bad source.")
        lprint("[antibd] Please contact your dev")
        return
    end
    oldRunString(text)
end

function newRunStringEx(text)
    if IsBadSourceInCall() then
        lprint("[antibd] !!! WARNING !!!")
        lErrorNoHaltWithStack("[antibd] Blocked RunStringEx from a bad source.")
        lprint("[antibd] Please contact your dev")
        return
    end
    oldRunStringEx(text)
end

function newCompileString(c,i,h)
    if IsBadSourceInCall() then
        lprint("[antibd] !!! WARNING !!!")
        lErrorNoHaltWithStack("[antibd] Blocked CompileString from a bad source.")
        lprint("[antibd] Please contact your dev")
        return ""
    end
    return oldCompileString(c,i,h)
end

if ENABLED then
    RunString = newRunString
    RunStringEx = newRunStringEx
    CompileString = newCompileString
end

lprint("[luctus_antibd] sv loaded")
