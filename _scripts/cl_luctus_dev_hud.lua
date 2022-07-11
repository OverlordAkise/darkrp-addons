--Luctus Debug HUD
--Made by OverlordAkise

--search for entities with the 'search' console command
--example: search "class C_BaseEntity" func_door
--toggle close class display with 'close'

local netsPerSecond = 0
local netsLastSecond = 0
local netMessages = {}

local transmitsAddPerSecond = 0
local transmitsRemPerSecond = 0
local transmitsAddLastSecond = 0
local transmitsRemLastSecond = 0
local transmitAdded = {}
local transmitRemoved = {}

local entitiesAddedPerSecond = 0
local entitiesRemovedPerSecond = 0
local entitiesAddedLastSecond = 0
local entitiesRemovedLastSecond = 0
local entitiesAdded = {}
local entitiesRemoved = {}

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

hook.Add("NotifyShouldTransmit","luctus_devtools",function(ent, shouldTransmit)
    if shouldTransmit then
        ldevAddTransAdd(ent)
    else
        ldevAddTransRem(ent)
    end
end)

concommand.Add("close",function(ply,cmd,args,argStr)
  showCloseClasses = not showCloseClasses
end)

local color_dark = Color(40,40,40,230)

hook.Add("HUDPaint", "luctus_devtools", function()
  local lp = LocalPlayer()
  local scrh = ScrH()
  local scrw = ScrW()
  local localEnts = ents.FindInSphere(lp:GetPos(),512)
  local allEnts = ents.GetAll()
  
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
  
  if lp:KeyDown(IN_WALK) then
    draw.RoundedBox(0,0,0,scrw,scrh,color_dark)
  end
  
  draw.DrawText("General","Default",10,scrh/2-200)
  draw.DrawText("#ents: "..#allEnts,"Default",10,scrh/2-190)
  draw.DrawText("#ents in 512units: "..#localEnts,"Default",10,scrh/2-170)
  draw.DrawText("#nets/s: "..netsPerSecond,"Default",10,scrh/2-160)
  draw.DrawText("#trans+/s: "..transmitsAddPerSecond,"Default",10,scrh/2-150)
  draw.DrawText("#trans-/s: "..transmitsRemPerSecond,"Default",10,scrh/2-140)
  draw.DrawText("#ents+/s: "..entitiesAddedLastSecond,"Default",10,scrh/2-130)
  draw.DrawText("#ents-/s: "..entitiesRemovedLastSecond,"Default",10,scrh/2-120)

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
    
    local owner = ent:CPPIGetOwner()
    if owner then
    draw.DrawText("Owner: "..owner:Name(),"Default",10,scrh/2+60)
    draw.DrawText("SteamName: "..owner:SteamName(),"Default",10,scrh/2+70)
    draw.DrawText("SteamID: "..owner:SteamID(),"Default",10,scrh/2+80)
    end
    
    if ent:IsPlayer() then
      draw.DrawText("Name: "..ent:Nick(),"Default",10,scrh/2+100)
      draw.DrawText("SteamName: "..ent:SteamName(),"Default",10,scrh/2+110)
      draw.DrawText("SteamID: "..ent:SteamID(),"Default",10,scrh/2+120)
      draw.DrawText("Ping: "..(ent:Ping()),"Default",10,scrh/2+130)
      draw.DrawText("Health: "..ent:Health(),"Default",10,scrh/2+140)
      draw.DrawText("Weapon: "..(IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() or "NIL"),"Default",10,scrh/2+150)
    end
  --end
  
  --Details
  if not lp:KeyDown(IN_WALK) then return end
  
  draw.DrawText("incoming net/umsg from server","Default",scrw-80,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_RIGHT)
  for k,v in pairs(netMessages) do
    draw.DrawText(v[3],"Default",scrw-10,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
    draw.DrawText(v[2],"Default",scrw-230,scrh/2-200+(k*10))
    draw.DrawText(v[1],"Default",scrw-280,scrh/2-200+(k*10))
  end
  draw.DrawText("ent added/removed from your PVS","Default",scrw-440,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_CENTER)
  for k,v in pairs(transmitAdded) do
    draw.DrawText("+ "..v,"Default",scrw-320,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  for k,v in pairs(transmitRemoved) do
    draw.DrawText("- "..v,"Default",scrw-490,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  draw.DrawText("ents created/removed","Default",scrw-800,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_CENTER)
  for k,v in pairs(entitiesAdded) do
    draw.DrawText("+ "..v,"Default",scrw-660,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  for k,v in pairs(entitiesRemoved) do
    draw.DrawText("- "..v,"Default",scrw-840,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
end)


local zeroAngle = Angle(0, 0, 0)
hook.Add("PostDrawOpaqueRenderables", "HitboxRender", function()
  local ants = {LocalPlayer():GetEyeTrace().Entity}
  if not ants[1] then return end
  if markAll then ants = ents.GetAll() end
  
  for k,ent in pairs(ants) do
    if not ent:IsValid() then return end
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
    ldevAddMessage("net",strName:lower())
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

function ldevAddTransAdd(ent)
    transmitsAddLastSecond = transmitsAddLastSecond + 1
    table.insert(transmitAdded,ent:GetClass())
    if #transmitAdded > 50 then
        table.remove( transmitAdded, 1 )
    end
end

function ldevAddTransRem(ent)
    transmitsRemLastSecond = transmitsRemLastSecond + 1
    table.insert(transmitRemoved,ent:GetClass())
    if #transmitRemoved > 50 then
        table.remove( transmitRemoved, 1 )
    end
end

function ldevEntitiesAdded(entClass)
    if string.StartWith(entClass,"class C_") then return end
    entitiesAddedLastSecond = entitiesAddedLastSecond + 1
    table.insert(entitiesAdded,entClass)
    if #entitiesAdded > 50 then
        table.remove( entitiesAdded, 1 )
    end
end

function ldevEntitiesRemoved(entClass)
    if string.StartWith(entClass,"class C_") then return end
    entitiesRemovedLastSecond = entitiesRemovedLastSecond + 1
    table.insert(entitiesRemoved,entClass)
    if #entitiesRemoved > 50 then
        table.remove( entitiesRemoved, 1 )
    end
end

timer.Create("ldev_nets_per_second",5,0,function()
  netsPerSecond = netsLastSecond
  netsLastSecond = 0
end)

timer.Create("ldev_trans_per_second",5,0,function()
  transmitsAddPerSecond = transmitsAddLastSecond
  transmitsAddLastSecond = 0
  transmitsRemPerSecond = transmitsRemLastSecond
  transmitsRemLastSecond = 0
end)

timer.Create("ldev_ents_per_second",5,0,function()
  entitiesAddedPerSecond = entitiesAddedLastSecond
  entitiesAddedLastSecond = 0
  entitiesRemovedPerSecond = entitiesRemovedLastSecond
  entitiesRemovedLastSecond = 0
end)

old_netStart = old_netStart or net.Start
function net.Start(name)
  ldevAddMessage("netOUT",name)
  old_netStart(name)
end

hook.Add("EntityRemoved", "luctus_devtools", function(ent)
    if IsValid(ent) then ldevEntitiesRemoved(ent:GetClass()) end
end)

hook.Add("OnEntityCreated", "luctus_devtools", function(ent)
    if IsValid(ent) then ldevEntitiesAdded(ent:GetClass()) end
end)

print("[luctus] dev mode activated!")
