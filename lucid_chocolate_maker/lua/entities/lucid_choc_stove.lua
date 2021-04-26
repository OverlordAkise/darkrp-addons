AddCSLuaFile()
ENT.Type = 'anim'
ENT.Base = "base_gmodentity"
 
ENT.PrintName = "Chocolate Stove"
ENT.Category = "Chocolate Maker"
ENT.Author = "OverlordAkise"
ENT.Purpose = "Make Chocolate"
ENT.Instructions = "N/A"
ENT.Model = "models/props_c17/furnitureStove001a.mdl"

ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.MaxTime = 180
ENT.HP = 200

function ENT:SetupDataTables()
    self:NetworkVar("Int", 1, "Cocoa")
    self:NetworkVar("Int", 2, "Sugar")
    self:NetworkVar("Int", 3, "Milk")
    self:NetworkVar("Int", 5, "CookStartTime")    
end

if CLIENT then

  function ENT:OnRemove()
    self:StopSound("ambient/machines/engine1.wav")
  end

  function ENT:Draw()
    self:DrawModel() 
    local Pos = self:GetPos()
    local Ang = self:GetAngles()

    local dist = Pos:DistToSqr(LocalPlayer():GetPos())
    
    if (dist > 400*400) then return end
    local owner = self:GetNWEntity("owner",nil)
    local Cocoa = self:GetCocoa()
    local Sugar = self:GetSugar()
    local Milk = self:GetMilk()
    local cookStartTime = self:GetCookStartTime()

    Ang:RotateAroundAxis(Ang:Right(),-90)
    Ang:RotateAroundAxis(Ang:Up(),90)
    cam.Start3D2D(Pos + (Ang:Up() * 15),Ang,0.10)
      local w = 170
      draw.RoundedBox(0,-160,-130,320,w,Color( 0, 0, 0, 240 ))
      if IsValid(owner) then
        draw.SimpleTextOutlined(owner:Nick(),"DWall",0,-130,Color(255,255,255),TEXT_ALIGN_CENTER,0,2,Color(0,0,0,255))
      end
      draw.SimpleTextOutlined("Cocoa " .. Cocoa .. " /2","DWall",0,-100,(Cocoa == 2 and Color(0,255,0) ) or Color(255,0,0),TEXT_ALIGN_CENTER,0,2,Color(0,0,0,255))
      draw.SimpleTextOutlined("Sugar " .. Sugar .. " /1","DWall",0,-70,(Sugar == 1 and Color(0,255,0) ) or Color(255,0,0),TEXT_ALIGN_CENTER,0,2,Color(0,0,0,255))
      draw.SimpleTextOutlined("Milk " .. Milk .. " /1","DWall",0,-35,(Milk == 1 and Color(0,255,0) ) or Color(255,0,0),TEXT_ALIGN_CENTER,0,2,Color(0,0,0,255))

      if cookStartTime > 0 then
        local current = ((os.time()-self:GetCookStartTime())*100)/self.MaxTime
        self.tt = (current * 296)/100
        if self.tt <= 295 then
          if not self.Sound then
            self.Sound = true
            self:EmitSound("ambient/machines/engine1.wav", 75, 100, 0.2, CHAN_AUTO)
          end
        end
        draw.RoundedBox(0,-150,-195,300,30,Color( 0, 0, 0, 240 ))
        draw.RoundedBox(0,-148,-193,self.tt,26,Color(0,250,0,255))
        draw.SimpleTextOutlined("Cooking...","DWallSmall",0,-189,Color(255,255,255),TEXT_ALIGN_CENTER,0,2,Color(0,0,0,255))
        
      else
        if self.Sound then 
          self.Sound = false
          self:StopSound("ambient/machines/engine1.wav")
          self:EmitSound("items/ammocrate_open.wav",75,100,0.7,CHAN_AUTO)
        end
      end
    cam.End3D2D() 
  end
end

if SERVER then
  
  function ENT:OnTakeDamage(cDamage)
    self.HP = self.HP - cDamage:GetDamage()
    if self.HP <= 0 then
      local vPoint = self:GetPos()
      local effectdata = EffectData()
      effectdata:SetStart(vPoint)
      effectdata:SetOrigin(vPoint)
      effectdata:SetScale(1)
      util.Effect("Explosion", effectdata)
      self:Remove()
    end
  end
  
  function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:GetPhysicsObject():SetMass(105) -- to make the gravitygun work
    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
      phys:Wake()
    end
  end
   
  function ENT:Use( activator, caller )
      return
  end
   
  function ENT:Think()
  end
 
  --ENT:TakeDamage(amount,ent_attacker,ent_inflictor)
  function ENT:StartTouch(entity)
    if entity:GetClass() == "lucid_choc_milk" then
      if self:GetMilk() >= 1 then return end
      self:SetMilk(self:GetMilk()+1)
      entity:Remove()
    end
    if entity:GetClass() == "lucid_choc_sugar" then
      if self:GetSugar() >= 1 then return end
      self:SetSugar(self:GetSugar()+1)
      entity:Remove()
    end
    if entity:GetClass() == "lucid_choc_cocoa" then
      if self:GetCocoa() >= 2 then return end
      self:SetCocoa(self:GetCocoa()+1)
      entity:Remove()
    end
    if self:GetCocoa() < 2 or self:GetMilk() < 1 or self:GetSugar() < 1 then return end
    if self:GetCookStartTime() ~= 0 then return end
    --Start work
    self:SetCookStartTime(os.time())
    timer.Simple(self.MaxTime,function()
      if not IsValid(self) then return end
      self:SetCookStartTime(0)
      self:SetMilk(0)
      self:SetCocoa(0)
      self:SetSugar(0)
      DarkRP.notify(self:CPPIGetOwner(), 3, 5, "[choc] Your chocolate is done!")
      local chocolate = ents.Create("lucid_choc_chocolate")
      chocolate:SetPos(self:GetPos()+Vector(0,0,30))
      chocolate:SetAngles(self:GetAngles())
      chocolate:Spawn()
      chocolate:Activate()
    end)
  end
end