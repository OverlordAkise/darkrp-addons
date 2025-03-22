--Luctus Buttons
--Made by OverlordAkise

util.AddNetworkString("luctus_buttons")
util.AddNetworkString("luctus_buttons_notif")

local lbsc = {} --LuctusButtonStateCache
for k,v in pairs(LUCTUS_BUTTONS_TOGGLEBUTTONS) do
    lbsc[k] = false
    if not istable(v) or #v < 2 then
        error("config LUCTUS_BUTTONS_TOGGLEBUTTONS is wrong!")
    end
end
function DebugLuctusButtonGetStateCache() return lbsc end

function LuctusButtonAllowed(ply)
    if not IsValid(ply) then return false end
    if LUCTUS_BUTTONS_ADMINS[ply:GetUserGroup()] then return true end
    if LUCTUS_BUTTONS_CHECK_RANKS and not LUCTUS_BUTTONS_RANKS[ply:GetUserGroup()] then return false end
    if LUCTUS_BUTTONS_CHECK_JOB and not LUCTUS_BUTTONS_JOBS[team.GetName(ply:Team())] then return false end
    return true
end

local function LuctusNotify(ply,text,typ,duration)
    ply:PrintMessage(HUD_PRINTTALK, text)
    net.Start("luctus_buttons_notif")
        net.WriteString(text)
    net.Send(ply)
end

net.Receive("luctus_buttons",function(len,ply)
    if not LuctusButtonAllowed(ply) then return end
    local cmd = net.ReadString()
    local entsToPress = nil
    if LUCTUS_BUTTONS_BUTTONS[cmd] then
        entsToPress = LUCTUS_BUTTONS_BUTTONS[cmd]
    end
    if LUCTUS_BUTTONS_TOGGLEBUTTONS[cmd] then
        if lbsc[cmd] then
            entsToPress = {LUCTUS_BUTTONS_TOGGLEBUTTONS[cmd][2]}
            lbsc[cmd] = false
        else
            entsToPress = {LUCTUS_BUTTONS_TOGGLEBUTTONS[cmd][1]}
            lbsc[cmd] = true
        end
    end
    if not entsToPress then return end
    local pressingEnt = Entity(0)
    if LUCTUS_BUTTONS_PLAYERPRESS then
        pressingEnt = ply
    end
    for k,v in pairs(entsToPress) do
        LuctusButtonPush(v,pressingEnt)
    end
    LuctusNotify(ply,string.format(LUCTUS_BUTTONS_CHATTEXT,cmd),0,5)
end)

function LuctusButtonPush(name,ply)
    print("[DEBUG]",ply,"pressed",name)
    local ent = ply
    if not ply or not IsValid(ply) then
        ent = Entity(0)
    end
    if type(name) == "string" then
        if ents.FindByName(name)[1] and IsValid(ents.FindByName(name)[1]) then
            ents.FindByName(name)[1]:Use(ent)
        end
    else
        if IsValid(ents.GetMapCreatedEntity(name)) then
            ents.GetMapCreatedEntity(name):Use(ent)
        end
    end
end


hook.Add("PlayerSay","luctus_buttons",function(ply,text)
    if text == LUCTUS_BUTTONS_COMMAND then
        if not LuctusButtonAllowed(ply) then return end
        net.Start("luctus_buttons")
            net.WriteTable(lbsc)
        net.Send(ply)
    end
end)

concommand.Add("get_button",function(ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end
    
    print("------------")
    print("Button Name / ID:")
    if ply:GetEyeTrace().Entity:MapCreationID() == Entity(0):MapCreationID() then
        print("ERROR: You are not looking at a 'button'!")
        return
    end
    print("Name:")
    print(ply:GetEyeTrace().Entity:GetSaveTable(true)["m_iName"])
    print("ID:")
    print(ply:GetEyeTrace().Entity:MapCreationID())
    print("---")
end)

print("[luctus_buttons] sv loaded")
