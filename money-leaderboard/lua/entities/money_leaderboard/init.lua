--Edited by OverlordAkise
--Added only code in the Timer below
--Added an inner join in the SQL statement for blue atm support

include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

util.AddNetworkString("SendMoneyLeaderboard")

function CompareMoneyLeaderboard(a,b)
  return a[2] > b[2]
end

timer.Create("SendMoneyLeaderboard", 60, 0, function()
    local Leaderboard = MySQLite.query ([[SELECT rpname,wallet,accountinfo FROM darkrp_player INNER JOIN batm_personal_accounts WHERE darkrp_player.uid = batm_personal_accounts.steamid;]])
    local maxMoneys = {}
    for k,v in pairs(Leaderboard) do
      local mtab = util.JSONToTable(v["accountinfo"])
      table.insert(maxMoneys,{v["rpname"],v["wallet"]+mtab["balance"]})
    end
    table.sort(maxMoneys,CompareMoneyLeaderboard)
    local plyLeader = {}
    local counter = 0
	for k,v in pairs(maxMoneys) do
      local t = {}
      t["rpname"] = v[1]
      t["wallet"] = v[2]
      table.insert(plyLeader,t)
      counter = counter + 1
      if counter >= 10 then
        break
      end
    end
    net.Start("SendMoneyLeaderboard")
    net.WriteTable(plyLeader)
    net.Broadcast()
end)

function ENT:Initialize()
    
    if gmod.GetGamemode().Name != "DarkRP" then
        self.Owner = self:GetOwner()
        if self.Owner and self.Owner:IsValid() then
            self.Owner:ChatPrint("The money leaderboard entity requires the DarkRP Gamemode, entity removed!")
        end
        error("MoneyLeaderboard addon requires DarkRP!")
        self:Remove()
        return
    end
    
    self:SetModel("models/hunter/plates/plate2x2.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetUseType(SIMPLE_USE)

    self:SetMaterial("Models/effects/vol_light001")

    local phys = self:GetPhysicsObject()

    if phys and IsValid(phys) then
        phys:Wake()
    end
    
end

function ENT:OnRemove()

end
