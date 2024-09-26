--Luctus a n t i c h e a t
--Made by OverlordAkise

local netstart = net.Start
local writestring = net.WriteString
local netsendserver = net.SendToServer
local getcvarstring = GetConVarString
local loop = pairs
local oldvguiCreate = vgui.Create
local hookadd = hook.Add
local concommandadd = concommand.Add
local ltype = type
local stringlower = string.lower
local stringfind = string.find
local timerSimple = timer.Simple
local function punish(text)
    netstart("luctusac_caught")
        writestring(text)
    netsendserver()
end
local function checkThat(name,src)
    if ltype(name) != "string" then return end
    name = stringlower(name)
    if stringfind(name,"aimbot") then
        punish(src.." / "..name)
    end
    if stringfind(name,"wallhack") then
        punish(src.." / "..name)
    end
    if src ~= "hookAdd" and string.find(name,"exploit") then
        punish(src.." / "..name)
    end
    if stringfind(name,"loki") then
        punish(src.." / "..name)
    end
    if stringfind(name,"bhop") then
        punish(src.." / "..name)
    end
    if stringfind(name,"spiritwalk") then
        punish(src.." / "..name)
    end
    if stringfind(name,"lowkey") then
        punish(src.." / "..name)
    end
    if src == "concommandAdd" and name == "book" then
        punish(src.." / "..name)
    end
end

--Makes some not load B-)
_G.CAC = true
_G.GAC = true
_G.QAC = true
_G.SAC = true
_G.DAC = true
_G.TAC = true
_G.simplicity = true
_G.SMAC = true
_G.MAC = true
_G.CardinalLib = true

vgui.Create = function(...)
    local cPanel = oldvguiCreate(...)
    if not IsValid(cPanel) then return end
    timerSimple(0,function()
        if not cPanel or not IsValid(cPanel) or not cPanel.GetTitle or not IsValid(cPanel.lblTitle) then return end
        local o=isfunction(cPanel.GetTitle) and cPanel:GetTitle() or ""
        checkThat(o,"vguiCreate")
        if cPanel.ExploitCount then 
            checkThat("ExploitCount","vguiCreate")
        end 
    end)
    return cPanel
end

function hook.Add(event,name,func)
    checkThat(name,"hookAdd")
    hookadd(event,name,func)
end

function concommand.Add(name,callback,autoComplete,helpText,flags)
    checkThat(name,"concommandAdd")
    concommandadd(name,callback,autoComplete,helpText,flags)
end


local function ConvarTell(name,val)
    netstart("luctusac_change")
        writestring(name)
        writestring(val)
    netsendserver()
end

local defaultValue = {}
local convars = {
    ["sv_cheats"] = function(cname,old,newVal) ConvarTell(cname,newVal) end,
    ["sv_allowcslua"] = function(cname,old,newVal) ConvarTell(cname,newVal) end,
    ["vcollide_wireframe"] = function(cname,old,newVal) ConvarTell(cname,newVal) end,
}

local function DetectConVarChange()
    for cv,cb in loop(convars) do
        local curVal = getcvarstring(cv)
        if not defaultValue[cv] then
            defaultValue[cv] = curVal
            continue
        else
            local origVal = defaultValue[cv]
            if origVal ~= curVal then
                cb(cv, origVal, curVal)
                defaultValue[cv] = curVal
            end
        end
    end
    timerSimple(0.2,DetectConVarChange)
end

DetectConVarChange()
