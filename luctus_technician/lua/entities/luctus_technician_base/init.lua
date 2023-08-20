AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetUseType(ONOFF_USE)
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:Wake()
        phys:SetMass(2000)
    end
    --Vars
    self.alarmed = false
    self.UsingPlayer = nil
    self.UseStart = nil	
    self.BeingUsed = false
    self.NextSearch = 0
    self.LootProgress = 0
    self.NextSound = 0
end
 
function ENT:Use( activator, caller, usetype )
    self._pos = self:GetPos()
    if activator:IsPlayer() then
        if usetype == USE_ON and not self.BeingUsed and self:GetStatus() then
            self:StartUse(caller)
        elseif usetype == USE_OFF and self.BeingUsed then
            self:CancelUse()
        end
    end
end

function ENT:StartUse(ply)
    if RPExtraTeams[ply:Team()].name ~= LUCTUS_TECHNICIAN_JOBNAME then return end
    if not self:GetBroken() then
        DarkRP.notify(ply, 3, 5, "This doesn't need repairing!")
        return
    end
    self:EnableProgressBar(ply, true)
    DarkRP.notify(ply, 3, 5, "You started repairing!")
    self.UsingPlayer = ply
    self.UseStart = CurTime()
    self.BeingUsed = true
end

function ENT:CancelUse()
    self:EnableProgressBar(self.UsingPlayer, false)
    self.UsingPlayer = nil
    self.UseStart = nil	
    self.BeingUsed = false
end

function ENT:EnableProgressBar(ply, enabled)
    net.Start("luctus_technician_repair")
        net.WriteBool(enabled)
    net.Send(ply)
end

function ENT:Think()
    if self.BeingUsed then
        if not IsValid(self.UsingPlayer) or not self.UsingPlayer:KeyDown(IN_USE) or self.UsingPlayer:GetEyeTraceNoCursor().Entity != self or self._pos:DistToSqr(self.UsingPlayer:GetPos()) > 65536 then self:CancelUse() return end
        
        self.LootProgress = ((CurTime() - self.UseStart) / 10) * 100
        
        if self.NextSound < CurTime() then
            self:EmitSound("ambient/energy/spark6.wav", 50, 100)
            self.NextSound = CurTime() + 1
        end
        if self.LootProgress >= 100 then
            self:SetBroken(false)
            local gainMoney = math.random(LUCTUS_TECHNICIAN_MIN_REWARD,LUCTUS_TECHNICIAN_MAX_REWARD)
            DarkRP.notify(self.UsingPlayer, 3, 5, "You repaired the object and got "..gainMoney.."$!")
            self.UsingPlayer:addMoney(gainMoney)
            self:CancelUse() 
            return 
        end
    end
    self:NextThink( CurTime() + 0.3 )
    return true
end
