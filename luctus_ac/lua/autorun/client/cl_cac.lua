--Luctus a n t i c h e a t
--Made by OverlordAkise

local netstart = netstart or net.Start
local writestring = writestring or net.WriteString
local netsendserver = netsendserver or net.SendToServer
local cvarstring = cvarstring or GetConVarString
local loop = loop or pairs
local oldMsgC = oldMsgC or MsgC
local oldMsg = oldMsg or Msg
local oldvguiCreate = oldvguiCreate or vgui.Create
local hookadd = hookadd or hook.Add
local concommandadd = concommandadd or concommand.Add

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
    timer.Simple(0,function()
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

function checkThat(name,src)
    if type(name) != "string" then return end
    name = string.lower(name)
    if string.find(name,"aimbot") then
        bestrafe(src.." / "..name)
    end
    if string.find(name,"wallhack") then
        bestrafe(src.." / "..name)
    end
    if src ~= "hookAdd" and string.find(name,"exploit") then
        bestrafe(src.." / "..name)
    end
    if string.find(name,"loki") then
        bestrafe(src.." / "..name)
    end
    if string.find(name,"bhop") then
        bestrafe(src.." / "..name)
    end
    if string.find(name,"spiritwalk") then
        bestrafe(src.." / "..name)
    end
    if string.find(name,"lowkey") then
        bestrafe(src.." / "..name)
    end
    if src == "concommandAdd" and name == "book" then
        bestrafe(src.." / "..name)
    end
end

function bestrafe(text)
    net.Start("luctusac_caught")
    net.WriteString(text)
    net.SendToServer()
end

local callbacks = {}
local callbackv = {}
local function ConVarCallback( name, func )
    callbacks[name] = func
end

local function DetectConVarChange()
    for k, v in loop(callbacks) do
        local s = cvarstring(k)
        if not callbackv[k] then
            callbackv[k] = s
            continue
        else
            local ov = callbackv[k]
            if ov != s then
                v( k, ov, s )
                callbackv[k] = s
            end
        end
    end
end
timer.Create(""..math.random().."",0.1,0,DetectConVarChange)

local function VerifyInfo(name, val)
    if not name or not val then return end
    netstart("luctusac_change")
    writestring(name)
    writestring(val)
    netsendserver()
end
  
ConVarCallback("sv_cheats", function(convar_name, value_old, value_new) VerifyInfo(convar_name,value_new) end)
ConVarCallback("sv_allowcslua", function(convar_name, value_old, value_new) VerifyInfo(convar_name,value_new) end)
ConVarCallback("vcollide_wireframe", function(convar_name, value_old, value_new) VerifyInfo(convar_name,value_new) end)
