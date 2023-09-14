--Luctus Safezones
--Made by OverlordAkise

AddCSLuaFile()

SWEP.Author      = "OverlordAkise"
SWEP.Instructions  = "Set Safezones"

SWEP.Spawnable      = true
SWEP.AdminOnly      = true
SWEP.UseHands      = true
SWEP.Category       = "Safezones"

SWEP.ViewModel      = "models/weapons/c_pistol.mdl"
SWEP.WorldModel     = "models/weapons/w_pistol.mdl"

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip  = -1
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo      = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic  = false
SWEP.Secondary.Ammo      = "none"

SWEP.AutoSwitchTo      = false
SWEP.AutoSwitchFrom      = false

SWEP.PrintName        = "SafezoneTool"
SWEP.Slot          = 0
SWEP.SlotPos        = 1
SWEP.DrawAmmo        = false


SWEP.pos_one = nil
SWEP.pos_two = nil
SWEP.window = nil
SWEP.deployed = false

function SWEP:Initialize()
    self:SetHoldType("pistol")
end

function SWEP:Deploy()
    hook.Add("PostDrawOpaqueRenderables","luctus_safezones_display",function()
        if not self.pos_one then return end
        local Col = COLOR_BLACK
        local Start = self.pos_one
        local End = self.pos_two or LocalPlayer():GetEyeTrace().HitPos
        local Min = Vector(math.min(Start.x, End.x), math.min(Start.y, End.y), math.min(Start.z, End.z))
        local Max = Vector(math.max(Start.x, End.x), math.max(Start.y, End.y), math.max(Start.z, End.z))
        local B1, B2, B3, B4 = Vector(Min.x, Min.y, Min.z), Vector(Min.x, Max.y, Min.z), Vector(Max.x, Max.y, Min.z), Vector(Max.x, Min.y, Min.z)
        local T1, T2, T3, T4 = Vector(Min.x, Min.y, Max.z), Vector(Min.x, Max.y, Max.z), Vector(Max.x, Max.y, Max.z), Vector(Max.x, Min.y, Max.z)
        render.DrawLine( B1, B2, Col, true )
        render.DrawLine( B2, B3, Col, true )
        render.DrawLine( B3, B4, Col, true )
        render.DrawLine( B4, B1, Col, true )

        render.DrawLine( T1, T2, Col, true )
        render.DrawLine( T2, T3, Col, true )
        render.DrawLine( T3, T4, Col, true )
        render.DrawLine( T4, T1, Col, true )

        render.DrawLine( B1, T1, Col, true )
        render.DrawLine( B2, T2, Col, true )
        render.DrawLine( B3, T3, Col, true )
        render.DrawLine( B4, T4, Col, true )
    end)
    return true
end

function SWEP:Holster()
    self.deployed = false
    self.pos_one = nil
    self.pos_two = nil
    hook.Remove("PostDrawOpaqueRenderables","luctus_safezones_display")
    return true
end

function SWEP:OnRemove()
    return true
end

function SWEP:Think() end

function SWEP:PrimaryAttack()
    self.pos_one = self:GetOwner():GetEyeTrace().HitPos
end

function SWEP:SecondaryAttack()
    if not self.pos_one then
        self:GetOwner():PrintMessage(HUD_PRINTTALK, "Please set the first point first! (leftclick)")
    return
    end
    self.pos_two = self:GetOwner():GetEyeTrace().HitPos
    if SERVER then
        luctusSaveSafezone(self.pos_one, self.pos_two)
    end
    self.pos_one = nil
    self.pos_two = nil
end

function SWEP:FireAnimationEvent( event )
   return true
end

if SERVER then return end

function SWEP:Think()
    if not self.deployed then
        self:Deploy()
        self.deployed = true
    end
end

function SWEP:DrawHUD()
    draw.SimpleTextOutlined("Leftclick = place first point", "DermaLarge", 10, ScrH()/2.5, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
    draw.SimpleTextOutlined("Rightclick = place second point & save", "DermaLarge", 10, ScrH()/2.5+40, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
    draw.SimpleTextOutlined("Reload = Open menu to delete safezones", "DermaLarge", 10, ScrH()/2.5+80, Color(255,255,255,255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP, 2, Color(0,0,0,255))
end

function SWEP:Reload()
    if SERVER then return end
    if IsValid(self.window) then return end
    self.window = vgui.Create("DFrame")
    self.window:SetTitle("Safezone Menu")
    self.window:SetSize(400,300)
    self.window:ShowCloseButton(false)
    self.window:Center()
    self.window:MakePopup()
    function self.window:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
  
    local closeButton = vgui.Create("DButton",self.window)
    closeButton:SetPos(400-32,2)
    closeButton:SetSize(30,20)
    closeButton:SetText("X")
    closeButton:SetTextColor( Color(255,0,0) )
    closeButton.DoClick = function(s)
        self.window:Close()
    end
    function closeButton:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
  
    local helpText = nil
    local text = {"Click to delete!","How To: Go to the safezone you want to delete","click on the one with the smallest distance to you!"}
    for k,v in pairs(text) do
        helpText = vgui.Create("DLabel",self.window)
        helpText:SetFont("Trebuchet18")
        helpText:SetText(v)
        helpText:SetTextColor(Color(0,195,165))
        helpText:SetContentAlignment(5)
        helpText:DockMargin(1,1,1,1)
        helpText:Dock(TOP)
    end

    local DScrollPanel = vgui.Create( "DScrollPanel", self.window )
    DScrollPanel:Dock(FILL)

    local safezones = {}
    for k,v in ipairs(ents.FindByClass("luctus_safezone")) do
        table.insert(safezones,v)
    end
  
    for k,v in pairs(safezones) do
        local zonebutton = DScrollPanel:Add("DButton")
        zonebutton:SetText("  "..v:GetID().." - Distance to zone: "..v:GetPos():Distance(LocalPlayer():GetPos()))
        zonebutton.id = v:GetID()
        zonebutton.ent = v
        zonebutton:DockMargin(1,1,1,1)
        zonebutton:SetTextColor( Color(255, 255, 255) )
        zonebutton:Dock(TOP)
        zonebutton:SetContentAlignment(4) --middle-left
        zonebutton.DoClick = function(s)
            net.Start("luctus_safezone_delete")
            net.WriteString(s.id)
            net.SendToServer()
            self.window:Close()
        end
        function zonebutton:Paint(w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
        --[[function zonebutton:Think()
        if not self.cd then self.cd = 0 end
        if self.cd > CurTime() then return end
        self.cd = CurTime() + 1
        self:SetText("   "..self.ent:GetID().." - Distance to zone: "..self.ent:GetPos():Distance(LocalPlayer():GetEyeTrace().HitPos))
        end--]]
    end
end
