AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Humans/Group02/male_03.mdl")
	self:SetHullType(HULL_HUMAN)
	self:SetHullSizeNormal()
	self:SetNPCState(NPC_STATE_SCRIPT)
	self:SetSolid(SOLID_BBOX)
	self:SetUseType(SIMPLE_USE)
	self:SetBloodColor(BLOOD_COLOR_RED)
	
	self.Removed = true
end

function ENT:AcceptInput(name, activator, caller)	
	if (!self.nextUse or CurTime() >= self.nextUse) then
    local moneyAmount = caller:GetNWInt("player_meth")
		if (name == "Use" and caller:IsPlayer() and (moneyAmount == 0)) then
			--self:EmitSound("vo/npc/male01/gethellout.wav");		
      DarkRP.notify(caller, 1, 5, "[meth] You don't have meth! Get out!")
			self:EmitSound(EML_Meth_Salesman_NoMeth_Sound, 100, 100)
		elseif (name == "Use") and (caller:IsPlayer()) and (moneyAmount > 0) then
			caller:addMoney(moneyAmount)
      DarkRP.notify(caller, 0, 5, "[meth] You sold your meth for "..moneyAmount.."$!")
			caller:SetNWInt("player_meth", 0)
			if (EML_Meth_MakeWanted) then
				caller:wanted(nil, "Selling Meth")
			end
			self:EmitSound(EML_Meth_Salesman_GotMeth_Sound, 100, 100)
			timer.Simple(2.0, function() self:EmitSound("vo/npc/male01/moan0"..math.random(1, 5)..".wav") end)
		end
		self.nextUse = CurTime() + 1
	end
end

function ENT:OnTakeDamage(dmginfo)
	return false
end

function ENT:OnTakeDamage(dmginfo)
	return false
end