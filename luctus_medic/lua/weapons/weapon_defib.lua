AddCSLuaFile()
local STATE_NONE, STATE_PROGRESS, STATE_ERROR = 0, 1, 2
local color_red = Color(255, 0, 0)

SWEP.HoldType = "slam"
SWEP.ViewModel = "models/weapons/v_c4.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"
SWEP.Contact         = "OverlordAkise"
SWEP.Purpose         = "Revive players!"
SWEP.Instructions    = "LMB to revive!"
SWEP.Spawnable       = true
SWEP.AdminSpawnable  = false
SWEP.Category = "Medic"

SWEP.Primary.Delay       = 0.9
SWEP.Primary.Recoil      = 0
SWEP.Primary.Damage      = 0
SWEP.Primary.NumShots    = 1
SWEP.Primary.Cone        = 0
SWEP.Primary.ClipSize    = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "none"

SWEP.Secondary.Delay        = 0.9
SWEP.Secondary.Recoil       = 0
SWEP.Secondary.Damage       = 0
SWEP.Secondary.NumShots     = 1
SWEP.Secondary.Cone         = 0
SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo         = "none"

if CLIENT then
  SWEP.PrintName = "Defibrillator"
  SWEP.Slot = 4
  SWEP.Author = "Pac_187"     -- Der "Author" der SWEP

  surface.CreateFont("DefibText", {
    font = "Tahoma",
    size = 13,
    weight = 700,
    shadow = true
  })

  function SWEP:DrawHUD()
    local state = self:GetDefibState()
    local scrW, scrH = ScrW(), ScrH()
    local progress = 1
    local outlineCol, progressCol, progressText = color_white, color_white, ""

    if state == STATE_PROGRESS then
      local startTime, endTime = self:GetDefibStartTime(), self:GetDefibStartTime() + 5

      progress = math.TimeFraction(startTime, endTime, CurTime())

      if progress <= 0 then
        return
      end

      outlineCol = Color(0, 100, 0)
      progressCol = Color(0, 255, 0, (math.abs(math.sin(RealTime() * 3)) * 100) + 20)
      progressText = self:GetStateText() or "DEFIBRILLIEREN"
    elseif state == STATE_ERROR then
      outlineCol = color_red
      progressCol = Color(255, 0, 0, math.abs(math.sin(RealTime() * 15)) * 255)
      progressText = self:GetStateText() or ""
    else
      return
    end

    progress = math.Clamp(progress, 0, 1)

    surface.SetDrawColor(outlineCol)
    surface.DrawOutlinedRect(scrW / 2 - (200 / 2) - 1, scrH / 2 + 10 - 1, 202, 16)

    surface.SetDrawColor(progressCol)
    surface.DrawRect(scrW / 2  - (200 / 2), scrH / 2 + 10, 200 * progress, 14)

    surface.SetFont("DefibText")
    local textW, textH = surface.GetTextSize(progressText)

    surface.SetTextPos(scrW / 2 - 100 + 2, scrH / 2 - 20 + textH)
    surface.SetTextColor(color_white)
    surface.DrawText(progressText)
  end
end

function SWEP:SetupDataTables()
  self:NetworkVar("Int", 0, "DefibState")
  self:NetworkVar("Float", 1, "DefibStartTime")

  self:NetworkVar("String", 0, "StateText")
end

function SWEP:Initialize()
  self:SetDefibState(STATE_NONE)
  self:SetDefibStartTime(0)
end

function SWEP:Deploy()
  self:SetDefibState(STATE_NONE)
  self:SetDefibStartTime(0)
  return true
end

function SWEP:Holster()
  self:SetDefibState(STATE_NONE)
  self:SetDefibStartTime(0)
  return true
end


function SWEP:PrimaryAttack()
  if CLIENT then return end

  local tr = util.TraceLine({
    start = self.Owner:EyePos(),
    endpos = self.Owner:EyePos() + self.Owner:GetAimVector() * 80,
    filter = self.Owner
  })

  if IsValid(tr.Entity) and tr.Entity:GetClass() == "prop_ragdoll" then
    local ply = tr.Entity:GetOwner()

    if IsValid(ply) then
      self:BeginDefib(ply, tr.Entity)
    else
      self:FireError("ERROR - ZIEL IST HIRNTOT")
      return
    end
  else
    self:FireError("ERROR - INKORREKTES ZIEL")
  end
end

function SWEP:BeginDefib(ply, ragdoll)
  local spawnPos = self:FindPosition(self.Owner)

  if not spawnPos then
    self:FireError("ERROR - KEIN PLATZ")
    return
  end

  self:SetStateText("DEFIBRILLIEREN - "..string.upper(ply:Name()))
  self:SetDefibState(STATE_PROGRESS)
  self:SetDefibStartTime(CurTime())

  self.TargetPly = ply
  self.TargetRagdoll = ragdoll

  self:SetNextPrimaryFire(CurTime() + 6)
end

function SWEP:FireError(err)
  if err then
    self:SetStateText(err)
  else
    self:SetStateText("")
  end

  self:SetDefibState(STATE_ERROR)

  timer.Simple(1, function()
    if IsValid(self) then
      self:SetDefibState(STATE_NONE)
      self:SetStateText("")
    end
  end)

  self:SetNextPrimaryFire(CurTime() + 1.2)
end

function SWEP:FireSuccess()
  self:SetDefibState(STATE_NONE)
  self:SetNextPrimaryFire(CurTime() + 1)
  
  hook.Call("UsedDefib", GAMEMODE, self.Owner)

  --self:Remove()
end

function SWEP:Think()
  if CLIENT then return end

  if self:GetDefibState() == STATE_PROGRESS then
    if not IsValid(self.Owner) then
      self:FireError()
      return
    end

    if not (IsValid(self.TargetPly) and IsValid(self.TargetRagdoll)) then
      self:FireError("ERROR - SUBJECT BRAINDEAD")
      return
    end

    local tr = util.TraceLine({
      start = self.Owner:EyePos(),
      endpos = self.Owner:EyePos() + self.Owner:GetAimVector() * 80,
      filter = self.Owner
    })

    if tr.Entity ~= self.TargetRagdoll then
      self:FireError("ERROR - ZIEL VERLOREN")
      return
    end

    if CurTime() >= self:GetDefibStartTime() + 5 then
      if self:HandleRespawn() then
        self:FireSuccess()
      else
        self:FireError("ERROR - KEIN PLATZ")
        return
      end
    end


    self:NextThink(CurTime())
    return true
  end
end

function SWEP:HandleRespawn()
  local ply, ragdoll = self.TargetPly, self.TargetRagdoll
  local spawnPos = self:FindPosition(self.Owner)

  if not spawnPos then
    return false
  end

  --local credits = CORPSE.GetCredits(ragdoll, 0)

  ply:Spawn()
  --ply:SpawnForRound(true)
  --ply:SetCredits(credits)
  ply:SetPos(spawnPos)
  ply:SetEyeAngles(Angle(0, ragdoll:GetAngles().y, 0))

  ragdoll:Remove()

  return true
end


local Positions = {}
for i=0,360,22.5 do table.insert( Positions, Vector(math.cos(i),math.sin(i),0) ) end -- Populate Around Player
table.insert(Positions, Vector(0, 0, 1)) -- Populate Above Player

function SWEP:FindPosition(ply)
  local size = Vector(32, 32, 72)
  
  local StartPos = ply:GetPos() + Vector(0, 0, size.z/2)
  
  local len = #Positions
  
  for i = 1, len do
    local v = Positions[i]
    local Pos = StartPos + v * size * 1.5
    
    local tr = {}
    tr.start = Pos
    tr.endpos = Pos
    tr.mins = size / 2 * -1
    tr.maxs = size / 2
    local trace = util.TraceHull(tr)
    
    if(not trace.Hit) then
      return Pos - Vector(0, 0, size.z/2)
    end
  end

  return false
end
