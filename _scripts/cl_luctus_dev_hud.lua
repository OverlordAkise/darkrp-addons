--Luctus Debug HUD
--Made by OverlordAkise

local netsPerSecond = 0
local netsLastSecond = 0
local netMessages = {}

hook.Add("HUDPaint", "luctus_devtools", function()
  local lp = LocalPlayer()
  draw.DrawText("General","Default",10,ScrH()/2-200)
  draw.DrawText("#ents: "..#ents.GetAll(),"Default",10,ScrH()/2-190)
  draw.DrawText("#ents in 512units: "..#ents.FindInSphere(lp:GetPos(),512),"Default",10,ScrH()/2-180)
  draw.DrawText("#nets/s: "..netsPerSecond,"Default",10,ScrH()/2-170)

  draw.DrawText("You","Default",10,ScrH()/2-80)
  draw.DrawText("Model: "..lp:GetModel(),"Default",10,ScrH()/2-70)
  draw.DrawText("Pos:   "..math.Round(lp:GetPos().x,2).." "..math.Round(lp:GetPos().y,2).." "..math.Round(lp:GetPos().z,2),"Default",10,ScrH()/2-60)
  draw.DrawText("Vel:   "..math.Round(lp:GetVelocity():Length(),2),"Default",10,ScrH()/2-50)
  draw.DrawText("Wep WorldModel: "..(lp:GetActiveWeapon().WorldModel or "NIL"),"Default",10,ScrH()/2-40)
  draw.DrawText("Wep ViewModel: "..(lp:GetActiveWeapon().ViewModel or "NIL"),"Default",10,ScrH()/2-30)
  if lp:GetEyeTrace().Entity and IsValid(lp:GetEyeTrace().Entity) then
    local ent = lp:GetEyeTrace().Entity
    draw.DrawText("Entity","Default",10,ScrH()/2-10)
    draw.DrawText("Class:   "..ent:GetClass(),"Default",10,ScrH()/2)
    draw.DrawText("Model:  "..ent:GetModel(),"Default",10,ScrH()/2+10)
    draw.DrawText("Pos:     "..math.Round(ent:GetPos().x,2).." "..math.Round(ent:GetPos().y,2).." "..math.Round(ent:GetPos().z,2),"Default",10,ScrH()/2+20)
    draw.DrawText("Vel.:     "..math.Round(ent:GetVelocity():Length(),2),"Default",10,ScrH()/2+30)
    if ent:IsPlayer() then
      draw.DrawText("Name:   "..ent:Nick(),"Default",10,ScrH()/2+50)
      draw.DrawText("SteamID: "..ent:SteamID(),"Default",10,ScrH()/2+60)
      draw.DrawText("Ping: "..(ent:Ping()),"Default",10,ScrH()/2+90)
      draw.DrawText("Health: "..ent:Health(),"Default",10,ScrH()/2+70)
      draw.DrawText("Weapon: "..(IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() or "NIL"),"Default",10,ScrH()/2+80)
    end
  end
  for k,v in pairs(netMessages) do
    draw.DrawText(v[3],"Default",ScrW()-10,ScrH()/2+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
    draw.DrawText(v[2],"Default",ScrW()-150,ScrH()/2+(k*10))
    draw.DrawText(v[1],"Default",ScrW()-200,ScrH()/2+(k*10))
  end
end)

--net and usmg Override

function net.Incoming( len, client )
	local i = net.ReadHeader()
	local strName = util.NetworkIDToString( i )
	if ( !strName ) then return end
	local func = net.Receivers[ strName:lower() ]
	if ( !func ) then return end
  ldevAddMessage("netIN",strName:lower())
	len = len - 16
	func( len, client )
end

for k,v in pairs(usermessage.GetTable()) do
  usermessage.Hook(k, function(msg)
    ldevAddMessage("umsg",k)
  end)
end

function ldevAddMessage(src,name)
  netsLastSecond = netsLastSecond + 1
  table.insert(netMessages,{math.Round(CurTime(),2),src,name})
  if #netMessages > 10 then
    table.remove( netMessages, 1 )
  end
end

timer.Create("ldev_nets_per_second",5,0,function()
  netsPerSecond = netsLastSecond
  netsLastSecond = 0
end)



old_netStart = old_netStart or net.Start
function net.Start(name)
  ldevAddMessage("netOUT",name)
  old_netStart(name)
end

--[[
local tcounter = 0
local lastTicks = 0
timer.Create("ld_tickcount",1,0,function()
  lastTicks = tcounter
  tcounter = 0
end)
hook.Add("Tick","ld_tickcount",function()
  tcounter = tcounter + 1
end)
--]]