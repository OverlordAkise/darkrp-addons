--Luctus Emote System
--Made by OverlordAkise
--Base animations vectors and applyAnimation function made by EGM and ​Mattzimann

SWEP.Author          = "OverlordAkise"
SWEP.Purpose        = "Do emotes!"
SWEP.Instructions       = "Leftclick to play, rightclick to select"
SWEP.Category         = "Emotes"

SWEP.PrintName        = "Emote"
SWEP.Slot          = 0
SWEP.SlotPos        = 5
SWEP.DrawAmmo        = false

SWEP.Spawnable        = true

SWEP.ViewModel         = "models/weapons/v_357.mdl"
SWEP.WorldModel       = "models/weapons/w_357.mdl"

SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip  = -1
SWEP.Primary.Automatic    = false
SWEP.Primary.Ammo      = "none"

SWEP.Secondary.ClipSize    = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic  = false
SWEP.Secondary.Ammo      = "none"

SWEP.Weight          = 1
SWEP.AutoSwitchTo      = false
SWEP.AutoSwitchFrom      = false
SWEP.deactivateOnMove    = 0

SWEP.window = nil

function SWEP:DrawWorldModel() end

function SWEP:PreDrawViewModel()
    return true
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

if CLIENT then
    function SWEP:PrimaryAttack() end
    
    function SWEP:SecondaryAttack()
        if IsValid(self.window) then return end
        self.window = vgui.Create("DFrame")
        self.window:SetTitle("Emote Menu")
        self.window:SetSize(200,300)
        self.window:ShowCloseButton(false)
        self.window:Center()
        self.window:MakePopup()
        function self.window:Paint(w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
            draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
        end

        local closeButton = vgui.Create("DButton",self.window)
        closeButton:SetPos(200-32,2)
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

        local helpText = vgui.Create("DLabel",self.window)
        helpText:SetFont("Trebuchet18")
        helpText:SetText("Select your emote!")
        helpText:SetTextColor( Color(0, 195, 165) )
        helpText:SetContentAlignment(5)
        helpText:DockMargin(1,1,1,1)
        helpText:Dock(TOP)
        local DScrollPanel = vgui.Create("DScrollPanel", self.window)
        DScrollPanel:Dock(FILL)

        for name,v in pairs(LUCTUS_EMOTE_LIST) do
            local emotebutton = DScrollPanel:Add("DButton")
            emotebutton:SetText(name)
            emotebutton.key = name
            emotebutton:DockMargin(1,1,1,1)
            emotebutton:SetTextColor(color_white)
            emotebutton:Dock(TOP)
            emotebutton.DoClick = function(s)
                net.Start("luctus_set_animation")
                    net.WriteString(s.key)
                net.SendToServer()
                self.window:Close()
            end
            function emotebutton:Paint(w,h)
                draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
                if self.Hovered then
                    draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
                end
            end
        end
    end
    
    local col_inactive = Color(100,100,100,240)
    local col_active = Color(255,255,255,255)
    local col_black = Color(0,0,0,255)
    function SWEP:DrawHUD()
    local col = col_inactive
        if LocalPlayer():GetNW2Bool("la_in_animation") then
            col = col_active
        end
        draw.SimpleTextOutlined(LocalPlayer():GetNW2String("la_animation"), "DermaLarge", ScrW()/2, ScrH()*0.6, col, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP, 3, col_black)
    end
  
    function SWEP:OnRemove()
        if IsValid(self.window) then self.window:Close() end
    end
    function SWEP:Holster()
        if IsValid(self.window) then self.window:Close() end
        return true
    end
    function SWEP:OnDrop()
        if IsValid(self.window) then self.window:Close() end
    end
end

if CLIENT then return end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()

    if not ply:GetNW2Bool("la_in_animation") then
        if not ply:Crouching() and ply:GetVelocity():Length() < 5 and not ply:InVehicle() then
            ToggleEmoteStatus(ply, true)
        end
    else
        ToggleEmoteStatus(ply, false)
    end
end

function SWEP:SecondaryAttack() end

function SWEP:OnRemove()
    local ply = self.Owner
    ToggleEmoteStatus(ply, false)
end

function SWEP:OnDrop()
    local ply = self.Owner
    ToggleEmoteStatus(ply, false)
end

function SWEP:Holster()
    ToggleEmoteStatus(self.Owner, false)
    return true
end
