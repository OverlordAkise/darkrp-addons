--Luctus Wheel
--Made by OverlordAkise


LUCTUS_WHEEL_CLASS_FUNCS = LUCTUS_WHEEL_CLASS_FUNCS or {}

LUCTUS_WHEEL_CAN_USE = LUCTUS_WHEEL_CAN_USE or false
LUCTUS_WHEEL_USE_DELAY = LUCTUS_WHEEL_USE_DELAY or false
LUCTUS_WHEEL_MENU = LUCTUS_WHEEL_MENU or nil
LUCTUS_WHEEL_ACTIVE_PANEL = LUCTUS_WHEEL_ACTIVE_PANEL or 1
LUCTUS_WHEEL_PANELS = LUCTUS_WHEEL_PANELS or 1

local color_accent = Color(0, 195, 165)
local color_black = Color(0,0,0,255)
local color_white = Color(255,255,255,255)

function LuctusWheelAdd(entClass,name,func)
    if not LUCTUS_WHEEL_CLASS_FUNCS[entClass] then
        LUCTUS_WHEEL_CLASS_FUNCS[entClass] = {{"Use",function()
            LUCTUS_WHEEL_CAN_USE = true
            RunConsoleCommand("+use")
            timer.Simple(0.1,function()
                RunConsoleCommand("-use")
                LUCTUS_WHEEL_CAN_USE = false
            end)
        end}}
    end
    table.insert(LUCTUS_WHEEL_CLASS_FUNCS[entClass],{name,func})
end

hook.Add("InitPostEntity","luctus_wheel_load",function()
    LUCTUS_WHEEL_CLASS_FUNCS = {}
    hook.Run("LuctusWheelAdd")
end)


local dontDraw = {["CHudWeaponSelection"] = true}
hook.Add("HUDShouldDraw","luctus_wheel",function(name)
    if LUCTUS_WHEEL_MENU and dontDraw[name] then return false end
end)

local cd = 0
hook.Add("CreateMove","luctus_wheel",function(cmd)
    local mWheel = cmd:GetMouseWheel()
    if mWheel ~= 0 and LUCTUS_WHEEL_MENU and cd < CurTime() then
        LuctusWheelScroll(mWheel)
        surface.PlaySound("UI/buttonrollover.wav")
        cd = CurTime()+0.1
    end
    if not cmd:KeyDown(IN_USE) then
        LUCTUS_WHEEL_USE_DELAY = false
        return
    end
    local ent = LocalPlayer():GetEyeTrace().Entity
    if not IsValid(ent) then
        if LUCTUS_WHEEL_MENU then
            LUCTUS_WHEEL_MENU:Remove()
            LUCTUS_WHEEL_MENU = nil
        end
        return
    end
    if not LUCTUS_WHEEL_CLASS_FUNCS[ent:GetClass()] then return end
    if not LUCTUS_WHEEL_CAN_USE then
        cmd:RemoveKey(IN_USE)
        if LUCTUS_WHEEL_USE_DELAY then return end
        LUCTUS_WHEEL_USE_DELAY = true
        if not LUCTUS_WHEEL_MENU then
            LuctusWheelOpenMenu(ent)
        else
            local curpanel = LUCTUS_WHEEL_PANELS[LUCTUS_WHEEL_ACTIVE_PANEL]
            if IsValid(curpanel) then curpanel.efunc() end
            LUCTUS_WHEEL_MENU:Remove()
            LUCTUS_WHEEL_MENU = nil
        end
    end
end,-1)

function LuctusWheelOpenMenu(ent)
    LUCTUS_WHEEL_ACTIVE_PANEL = 1
    local list = LUCTUS_WHEEL_CLASS_FUNCS[ent:GetClass()]
    LUCTUS_WHEEL_MENU = vgui.Create("DPanel")
    LUCTUS_WHEEL_MENU:ParentToHUD()
    LUCTUS_WHEEL_MENU:SetSize(150, 30*table.Count(list))
    LUCTUS_WHEEL_MENU:SetPos(ScrW()/2+10,ScrH()/2)
    LUCTUS_WHEEL_PANELS = {}
    for id,nameAndFunc in ipairs(list) do
        local curpanel = vgui.Create("DPanel",LUCTUS_WHEEL_MENU)
        curpanel:Dock(TOP)
        curpanel:SetHeight(30)
        curpanel.text = nameAndFunc[1]
        curpanel.efunc = nameAndFunc[2]
        curpanel.id = id
        function curpanel:Paint(w,h)
            if LUCTUS_WHEEL_ACTIVE_PANEL == self.id then
                draw.RoundedBox(0,0,0,w,h,color_accent)
                draw.SimpleText(">"..self.text,"Trebuchet24",7,2,color_black)
            else
                draw.RoundedBox(0,0,0,w,h,color_black)
                draw.SimpleText(self.text,"Trebuchet24",7,2,color_accent)
            end
            
        end
        table.insert(LUCTUS_WHEEL_PANELS,curpanel)
    end
end
function LuctusWheelScroll(num)
    -- if not LUCTUS_WHEEL_MENU then return end
    local newnum = LUCTUS_WHEEL_ACTIVE_PANEL + num
    if newnum > #LUCTUS_WHEEL_PANELS then
        newnum = newnum - #LUCTUS_WHEEL_PANELS
    end
    if newnum < 1 then
        newnum = newnum + #LUCTUS_WHEEL_PANELS
    end
    LUCTUS_WHEEL_ACTIVE_PANEL = newnum
end

print("[luctus_wheel] cl loaded")
