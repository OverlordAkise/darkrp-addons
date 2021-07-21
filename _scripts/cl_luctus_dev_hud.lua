--Luctus Debug HUD
--Made by OverlordAkise

--search for entities with the 'search' console command
--example: search "class C_BaseEntity" func_door
--toggle close class display with 'close'

local netsPerSecond = 0
local netsLastSecond = 0
local netMessages = {}

local marked = {}
local showCloseClasses = true
local markAll = false

concommand.Add("search",function(ply,cmd,args,argStr)
  marked = {}
  for k,v in pairs(args) do
    marked[v] = true
  end
  if args[1] and args[1] == "*" then
    markAll = true
  else
    markAll = false
  end
end)

concommand.Add("close",function(ply,cmd,args,argStr)
  showCloseClasses = not showCloseClasses
end)

hook.Add("HUDPaint", "luctus_devtools", function()
  local lp = LocalPlayer()
  local scrh = ScrH()
  local localEnts = ents.FindInSphere(lp:GetPos(),512)
  local allEnts = ents.GetAll()
  
  draw.DrawText("General","Default",10,scrh/2-200)
  draw.DrawText("#ents: "..#allEnts,"Default",10,scrh/2-190)
  --draw.DrawText("#ents custom: "..customEnts,"Default",10,scrh/2-180)
  draw.DrawText("#ents in 512units: "..#localEnts,"Default",10,scrh/2-170)
  draw.DrawText("#nets/s: "..netsPerSecond,"Default",10,scrh/2-160)

  draw.DrawText("You","Default",10,scrh/2-80,Color(0,255,0))
  draw.DrawText("Model: "..lp:GetModel(),"Default",10,scrh/2-70)
  draw.DrawText("Pos: "..math.Round(lp:GetPos().x,2).." "..math.Round(lp:GetPos().y,2).." "..math.Round(lp:GetPos().z,2),"Default",10,scrh/2-60)
  draw.DrawText("Vel: "..math.Round(lp:GetVelocity():Length(),2),"Default",10,scrh/2-50)
  draw.DrawText("Wep WorldModel: "..(lp:GetActiveWeapon().WorldModel or "NIL"),"Default",10,scrh/2-40)
  draw.DrawText("Wep ViewModel: "..(lp:GetActiveWeapon().ViewModel or "NIL"),"Default",10,scrh/2-30)
  draw.DrawText("Distance: "..lp:GetPos():Distance(lp:GetEyeTrace().HitPos),"Default",10,scrh/2-20)
  --if lp:GetEyeTrace().Entity and IsValid(lp:GetEyeTrace().Entity) then
    local eye = lp:GetEyeTrace()
    local ent = lp:GetEyeTrace().Entity
    draw.DrawText("Entity","Default",10,scrh/2-10,Color(0,0,255))
    draw.DrawText("Class: "..ent:GetClass(),"Default",10,scrh/2)
    draw.DrawText("Model: "..ent:GetModel(),"Default",10,scrh/2+10)
    draw.DrawText("Pos: "..math.Round(ent:GetPos().x,2).." "..math.Round(ent:GetPos().y,2).." "..math.Round(ent:GetPos().z,2),"Default",10,scrh/2+20)
    draw.DrawText("Vel.: "..math.Round(ent:GetVelocity():Length(),2),"Default",10,scrh/2+30)
    draw.DrawText("EntIndex: "..ent:EntIndex(),"Default",10,scrh/2+40)
    draw.DrawText("HitTexture: "..eye.HitTexture,"Default",10,scrh/2+50)
    --draw.DrawText("MapCreationID: "..(ent.MapCreationID and ent:MapCreationID() or "NIL"),"Default",10,scrh/2+50)
    if ent:IsPlayer() then
      draw.DrawText("Name: "..ent:Nick(),"Default",10,scrh/2+60)
      draw.DrawText("SteamID: "..ent:SteamID(),"Default",10,scrh/2+70)
      draw.DrawText("Ping: "..(ent:Ping()),"Default",10,scrh/2+80)
      draw.DrawText("Health: "..ent:Health(),"Default",10,scrh/2+90)
      draw.DrawText("Weapon: "..(IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() or "NIL"),"Default",10,scrh/2+100)
    end
  --end
  for k,v in pairs(netMessages) do
    draw.DrawText(v[3],"Default",ScrW()-10,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
    draw.DrawText(v[2],"Default",ScrW()-170,scrh/2-200+(k*10))
    draw.DrawText(v[1],"Default",ScrW()-220,scrh/2-200+(k*10))
  end
  if showCloseClasses then
    for k,v in pairs(localEnts) do
      local point = v:GetPos() + v:OBBCenter()
      local data2D = point:ToScreen()
      if ( not data2D.visible ) then continue end
      draw.DrawText(v:GetClass(),"Default", data2D.x, data2D.y)
    end
  end
  for k,v in pairs(allEnts) do
    if marked[v:GetClass()] or markAll then
      local point = v:GetPos() + v:OBBCenter()
      local data2D = point:ToScreen()
      if ( not data2D.visible ) then continue end
      draw.DrawText(v:GetClass(),"Default", data2D.x, data2D.y)
    end
  end
end)



local zeroAngle = Angle(0, 0, 0)
hook.Add("PostDrawOpaqueRenderables", "HitboxRender", function()
	local ants = {LocalPlayer():GetEyeTrace().Entity}
  if not ants[1] then return end
  if markAll then ants = ents.GetAll() end
  
  for k,ent in pairs(ants) do
    if ent:GetHitBoxGroupCount() == nil then continue end
    for group=0, ent:GetHitBoxGroupCount() - 1 do
      for hitbox=0, ent:GetHitBoxCount( group ) - 1 do
        local pos, ang =  ent:GetBonePosition( ent:GetHitBoxBone(hitbox, group) )
        local mins, maxs = ent:GetHitBoxBounds(hitbox, group)
        render.DrawWireframeBox( pos, ang, mins, maxs, Color(51, 204, 255, 255), true )
      end
    end
    render.DrawWireframeBox( ent:GetPos(), zeroAngle, ent:OBBMins(), ent:OBBMaxs(), Color(255, 204, 51, 255), true )
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

--usermessage_IncomingMessage = usermessage.IncomingMessage
function usermessage.IncomingMessage(name,msg)
  ldevAddMessage("umsg",name)
  usermessage.GetTable()[name]["Function"](msg,usermessage.GetTable()[name]["PreArgs"])
end

function ldevAddMessage(src,name)
  netsLastSecond = netsLastSecond + 1
  table.insert(netMessages,{math.Round(CurTime(),2),src,name})
  if #netMessages > 50 then
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
