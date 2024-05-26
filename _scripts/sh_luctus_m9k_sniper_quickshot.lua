--Luctus M9k sniper quickshot
--Made by OverlordAkise and M9k-Creator

--All this script does is remove the delay between sprinting->shooting when using M9k snipers
--Someone wanted it so here it is

--This function is copied from M9k weapons (bobs_scoped_base), I did not create it!
function M9kIronSight(self)
    local owner = self.Owner
    if not IsValid(self) or not IsValid(owner) then return end
    
    if self.SelectiveFire and self.NextFireSelect < CurTime() and not (self.Weapon:GetNWBool("Reloading")) then
        if owner:KeyDown(IN_USE) and owner:KeyPressed(IN_RELOAD) then
            self:SelectFireMode()
        end
    end
    
    if owner:KeyDown(IN_USE) and owner:KeyPressed(IN_ATTACK2) then return end
    
    if owner:KeyPressed(IN_SPEED) and not (self.Weapon:GetNWBool("Reloading")) then
        -- if self.Weapon:GetNextPrimaryFire() <= (CurTime()+0.3) then
            -- self.Weapon:SetNextPrimaryFire(CurTime()+0.3)
        -- end
        self.IronSightsPos = self.RunSightsPos
        self.IronSightsAng = self.RunSightsAng
        self:SetIronsights(true, owner)
        owner:SetFOV( 0, 0.2 )
    end
    
    -- if owner:KeyDown(IN_SPEED) and not (self.Weapon:GetNWBool("Reloading")) then
        -- if self.Weapon:GetNextPrimaryFire() <= (CurTime()+0.3) then
            -- self.Weapon:SetNextPrimaryFire(CurTime()+0.3)
        -- end
    -- end
    
    if owner:KeyReleased(IN_USE) || owner:KeyReleased (IN_SPEED) then
        self:SetIronsights(false, owner)
        self.DrawCrosshair = self.XHair
    end
    
    if owner:KeyPressed(IN_SPEED) || owner:KeyPressed(IN_USE) then    -- If you run then
        owner:SetFOV( 0, 0.2 )
        self.DrawCrosshair = false
        if CLIENT then return end
        owner:DrawViewModel(true)
    end    
    
    if owner:KeyPressed(IN_ATTACK2) and not owner:KeyDown(IN_SPEED) and not (self.Weapon:GetNWBool("Reloading")) then
        self.Owner:SetFOV( 75/self.Secondary.ScopeZoom, 0.15 )                              
        self.IronSightsPos = self.SightsPos                    -- Bring it up
        self.IronSightsAng = self.SightsAng                    -- Bring it up
        self.DrawCrosshair = false
        self:SetIronsights(true, owner)
        if CLIENT then return end
        owner:DrawViewModel(false)
    elseif owner:KeyPressed(IN_ATTACK2) and not (self.Weapon:GetNWBool("Reloading")) and owner:KeyDown(IN_SPEED) then
        if self.Weapon:GetNextPrimaryFire() <= (CurTime()+0.3) then
            self.Weapon:SetNextPrimaryFire(CurTime()+0.3)
        end
        self.IronSightsPos = self.RunSightsPos
        self.IronSightsAng = self.RunSightsAng
        self:SetIronsights(true, owner)
        owner:SetFOV( 0, 0.2 )
    end
    
    if (owner:KeyReleased(IN_ATTACK2) or owner:KeyDown(IN_SPEED)) and not owner:KeyDown(IN_USE) and not owner:KeyDown(IN_SPEED) then
        owner:SetFOV( 0, 0.2 )
        self:SetIronsights(false, owner)
        self.DrawCrosshair = self.XHair
        -- Set the ironsight false
        if CLIENT then return end
        owner:DrawViewModel(true)
    end
    
    if owner:KeyDown(IN_ATTACK2) and not owner:KeyDown(IN_USE) and not owner:KeyDown(IN_SPEED) then
        self.SwayScale     = 0.05
        self.BobScale     = 0.05
    else
        self.SwayScale     = 1.0
        self.BobScale     = 1.0
    end
end

LUCTUS_M9K_SNIPER_QUICKSHOT_LIST = {"m9k_aw50","m9k_barret_m82","m9k_m98b","m9k_svu","m9k_sl8","m9k_intervention","m9k_m24","m9k_psg1","m9k_remington7615p","m9k_dragunov","m9k_svt40","m9k_contender"}

--Load after all the other addons (m9k weapons)
hook.Add("InitPostEntity","luctus_m9k_quickshot_sniper",function()
    local m9kaw50 = weapons.GetStored("m9k_aw50")
    if not m9kaw50 then
        ErrorNoHaltWithStack("ERROR: No M9k sniper found. This script only allows you to quick-shoot after sprinting with m9k snipers!")
        return
    end

    for k,wep in ipairs(LUCTUS_M9K_SNIPER_QUICKSHOT_LIST) do
        weapons.GetStored(wep)["IronSight"] = M9kIronSight
    end
end)

print("[luctus_m9k_sniper_quickshot] sh loaded")
