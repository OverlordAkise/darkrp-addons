--Luctus Treefeller
--Made by OverlordAkise

AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"

ENT.Name = "Log"
ENT.PrintName = "Log"
ENT.Author = ""
ENT.Category = "Treefeller"
ENT.Purpose = "To be cut down with an axe"
ENT.Instructions = "N/A"
ENT.Model = "models/props_docks/channelmarker_gib01.mdl"

ENT.Freeze = true
ENT.Spawnable = true
ENT.AdminSpawnable = true

if CLIENT then
    surface.CreateFont("LuctusTreefellerLog",{font="Arial",size=60,weight=2000})
    local color_white = Color(255,255,255,255)
    local color_black = Color(0,0,0,255)
    function ENT:Draw()
        self:DrawModel()
        local p = self:GetPos()
        if p:Distance(LocalPlayer():GetPos()) > 256 then return end
        p.z = p.z + 10
        local eyeAng = LocalPlayer():EyeAngles()
        p = p + eyeAng:Forward()*-1*10
        cam.Start3D2D(p, Angle(0, eyeAng.y - 90, 90), 0.1)
            draw.SimpleTextOutlined(string.format(LUCTUS_TREEFELLER_LOG_TEXT,LUCTUS_TREEFELLER_LOG_SELLPRICE),"LuctusTreefellerLog",0,0,color_white,TEXT_ALIGN_CENTER,TEXT_ALIGN_TOP,1,color_black)
        cam.End3D2D()
    end
    return
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
    end
end
   
function ENT:Think() end
  
function ENT:Use(ply)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    ply:addMoney(LUCTUS_TREEFELLER_LOG_SELLPRICE)
    DarkRP.notify(ply, 2, 3, string.format(LUCTUS_TREEFELLER_LOG_SOLD_TEXT,LUCTUS_TREEFELLER_LOG_SELLPRICE))
    hook.Run("LuctusTreefellerLogSold",self,LUCTUS_TREEFELLER_LOG_SELLPRICE)
    self:Remove()
end
