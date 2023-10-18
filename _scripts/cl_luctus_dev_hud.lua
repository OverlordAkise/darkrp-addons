--Luctus Debug HUD
--Made by OverlordAkise

--search for entities with the 'devsearch' console command
--example: devsearch "class C_BaseEntity" func_door
--toggle close class display with 'devclose'

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

--local mouseX = 0
--local mouseY = 0

local marked = {}
local showCloseClasses = true
local markAll = false
local showBBox = false

concommand.Add("devsearch",function(ply,cmd,args,argStr)
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

concommand.Add("devclose",function(ply,cmd,args,argStr)
    showCloseClasses = not showCloseClasses
end)

concommand.Add("devbox",function(ply,cmd,args,argStr)
    showBBox = not showBBox
end)

hook.Add("NotifyShouldTransmit","luctus_devtools",function(ent, shouldTransmit)
    if shouldTransmit then
        ldevAddTransAdd(ent)
    else
        ldevAddTransRem(ent)
    end
end)

--Garbage Collection

concommand.Add("devgcdelay",function(ply,cmd,args,argStr)
    if not tonumber(argStr) then return end
    GC_CACHE_TIMER = tonumber(argStr)
    LuctusStartGCWatcher()
end)

GC_CACHE = {}
GC_CACHE_TIMER = 1
GC_CACHE_AVG = 0
GC_CACHE_AVG_DYN = 0
GC_CACHE_HIGHEST = -1
GC_CACHE_LOWEST = math.huge
GC_CACHE_SUM = 0
function LuctusStartGCWatcher()
    timer.Create("gc_watcher",GC_CACHE_TIMER,0,function()
        --GC_CACHE_HIGHEST = -1
        --GC_CACHE_LOWEST = math.huge
        local gc = math.floor(collectgarbage("count"))
        table.insert(GC_CACHE,gc)
        GC_CACHE_SUM = GC_CACHE_SUM + gc
        if #GC_CACHE > 100 then
            GC_CACHE_SUM = GC_CACHE_SUM - table.remove(GC_CACHE,1)
        end
        if gc > GC_CACHE_HIGHEST then GC_CACHE_HIGHEST = gc end
        if gc < GC_CACHE_LOWEST then GC_CACHE_LOWEST = gc end
        GC_CACHE_AVG_DYN = GC_CACHE_SUM/#GC_CACHE
        GC_CACHE_AVG = (GC_CACHE_HIGHEST+GC_CACHE_LOWEST)/2
        --print("GC",gc)
    end)
end
LuctusStartGCWatcher()


--HUD

local color_dark = Color(40,40,40,230)

LstartHeight = 100
Lwidth = 10
local function lineheight(num)
    LstartHeight = LstartHeight + 10
    if num then
        LstartHeight = LstartHeight + num
    end
    if LstartHeight > ScrH() then
        LstartHeight = 100
        Lwidth = Lwidth + 400
    end
    return LstartHeight
end

hook.Add("HUDPaint", "luctus_devtools", function()
  local lp = LocalPlayer()
  local scrh = ScrH()
  local scrw = ScrW()
  local localEnts = ents.FindInSphere(lp:GetPos(),512)
  local allEnts = ents.GetAll()
  LstartHeight = 100
  Lwidth = 10
  draw.RoundedBox(0,scrw/2-1,scrh/2-1,2,2,color_white)
  
  --mouse
  --surface.SetDrawColor(0,0,255)
  --surface.DrawLine(scrw/2, scrh/2, scrw/2+(mouseX*3), scrh/2+(mouseY*3) )
  
  if showCloseClasses then
    for k,v in ipairs(localEnts) do
      local point = v:GetPos() + v:OBBCenter()
      local data2D = point:ToScreen()
      if ( not data2D.visible ) then continue end
      draw.DrawText(v:GetClass(),"Default", data2D.x, data2D.y)
    end
  end
  for k,v in ipairs(allEnts) do
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
  
  draw.DrawText("General","Default",Lwidth,lineheight())
  draw.DrawText("#ents: "..#allEnts,"Default",Lwidth,lineheight())
  draw.DrawText("#ents in 512units: "..#localEnts,"Default",Lwidth,lineheight(10))
  draw.DrawText("#nets/s: "..netsPerSecond,"Default",Lwidth,lineheight())
  draw.DrawText("#trans+/s: "..transmitsAddPerSecond,"Default",Lwidth,lineheight())
  draw.DrawText("#trans-/s: "..transmitsRemPerSecond,"Default",Lwidth,lineheight())
  draw.DrawText("#ents+/s: "..entitiesAddedLastSecond,"Default",Lwidth,lineheight())
  draw.DrawText("#ents-/s: "..entitiesRemovedLastSecond,"Default",Lwidth,lineheight())
  
  draw.DrawText("max ram: "..GC_CACHE_HIGHEST,"Default",Lwidth,lineheight(10))
  draw.DrawText("avg ram: "..GC_CACHE_AVG_DYN,"Default",Lwidth,lineheight())
  draw.DrawText("min ram: "..GC_CACHE_LOWEST,"Default",Lwidth,lineheight())

  draw.DrawText("You","Default",Lwidth,lineheight(10),Color(0,255,0))
  draw.DrawText("Model: "..lp:GetModel(),"Default",Lwidth,lineheight())
  draw.DrawText("Pos: "..math.Round(lp:GetPos().x,2).." "..math.Round(lp:GetPos().y,2).." "..math.Round(lp:GetPos().z,2),"Default",Lwidth,lineheight())
  draw.DrawText("Ang: "..math.Round(lp:GetAngles().p,2).." "..math.Round(lp:GetAngles().y,2).." "..math.Round(lp:GetAngles().r,2),"Default",Lwidth,lineheight())
  draw.DrawText("Vel: "..math.Round(lp:GetVelocity():Length(),2),"Default",Lwidth,lineheight())
  draw.DrawText("Wep WorldModel: "..(lp:GetActiveWeapon().WorldModel or "NIL"),"Default",Lwidth,lineheight())
  draw.DrawText("Wep ViewModel: "..(lp:GetActiveWeapon().ViewModel or "NIL"),"Default",Lwidth,lineheight())
  draw.DrawText("Distance: "..lp:GetPos():Distance(lp:GetEyeTrace().HitPos),"Default",Lwidth,lineheight())
  --if lp:GetEyeTrace().Entity and IsValid(lp:GetEyeTrace().Entity) then
  local eye = lp:GetEyeTrace()
  local ent = eye.Entity
  if math.Round(lp:GetAngles().p,2) >= 89 then
    ent = lp
  end
  if IsValid(ent) then
    draw.DrawText("Entity","Default",Lwidth,lineheight(10),Color(0,0,255))
    draw.DrawText("Class: "..ent:GetClass(),"Default",Lwidth,lineheight())
    draw.DrawText("Model: "..ent:GetModel(),"Default",Lwidth,lineheight())
    draw.DrawText("Pos: "..math.Round(ent:GetPos().x,2).." "..math.Round(ent:GetPos().y,2).." "..math.Round(ent:GetPos().z,2),"Default",Lwidth,lineheight())
    draw.DrawText("Vel.: "..math.Round(ent:GetVelocity():Length(),2),"Default",Lwidth,lineheight())
    draw.DrawText("EntIndex: "..ent:EntIndex(),"Default",Lwidth,lineheight())
    draw.DrawText("HitTexture: "..eye.HitTexture,"Default",Lwidth,lineheight())
    draw.DrawText("HitMaterials: ","Default",Lwidth,lineheight(10),Color(200,100,255))
    if ent:GetClass() ~= "worldspawn" then
        for k,v in ipairs(ent:GetMaterials()) do
            draw.DrawText(k.."->"..v,"Default",Lwidth,lineheight())
            if k >= 4 then 
                draw.DrawText(#ent:GetMaterials().." more","Default",Lwidth,lineheight())
                break
            end
        end
    end
    if ent.CPPIGetOwner then
        local owner = ent:CPPIGetOwner()
        if owner and IsValid(owner) then
        draw.DrawText("Owner: "..owner:Name(),"Default",Lwidth,lineheight())
        draw.DrawText("SteamName: "..owner:SteamName(),"Default",Lwidth,lineheight())
        draw.DrawText("SteamID: "..owner:SteamID(),"Default",Lwidth,lineheight())
        end
    end
    
    if ent:IsPlayer() then
      draw.DrawText("Name: "..ent:Nick(),"Default",Lwidth,lineheight(10))
      draw.DrawText("SteamName: "..(ent.SteamName and ent:SteamName() or ent:Nick()),"Default",Lwidth,lineheight())
      draw.DrawText("SteamID: "..ent:SteamID(),"Default",Lwidth,lineheight())
      draw.DrawText("Ping: "..(ent:Ping()),"Default",Lwidth,lineheight())
      draw.DrawText("Health: "..ent:Health(),"Default",Lwidth,lineheight())
      draw.DrawText("Weapon: "..(IsValid(ent:GetActiveWeapon()) and ent:GetActiveWeapon():GetClass() or "NIL"),"Default",Lwidth,lineheight())
    end
    
    draw.DrawText("NWVar:","Default",Lwidth,lineheight(10),Color(255,255,0))
    for k,v in pairs(ent:GetNWVarTable()) do
        draw.DrawText(k.." -> "..tostring(v),"Default",Lwidth,lineheight())
    end
    
    draw.DrawText("NetworkVar:","Default",Lwidth,lineheight(10),Color(0,255,255))
    if ent.GetNetworkVars and ent:GetNetworkVars() then
        for k,v in pairs(ent:GetNetworkVars()) do
            draw.DrawText(k.." -> "..tostring(v),"Default",Lwidth,lineheight())
        end
    end
  end
  
  --Details
  if not lp:KeyDown(IN_WALK) then return end
  
  draw.DrawText("incoming net/umsg from server","Default",scrw-80,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_RIGHT)
  for k,v in ipairs(netMessages) do
    draw.DrawText(v[3],"Default",scrw-10,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
    draw.DrawText(v[2],"Default",scrw-230,scrh/2-200+(k*10))
    draw.DrawText(v[1],"Default",scrw-280,scrh/2-200+(k*10))
  end
  draw.DrawText("ent added/removed from your PVS","Default",scrw-440,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_CENTER)
  for k,v in ipairs(transmitAdded) do
    draw.DrawText("+ "..v,"Default",scrw-320,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  for k,v in ipairs(transmitRemoved) do
    draw.DrawText("- "..v,"Default",scrw-490,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  draw.DrawText("ents created/removed","Default",scrw-800,scrh/2-210,COLOR_WHITE,TEXT_ALIGN_CENTER)
  for k,v in ipairs(entitiesAdded) do
    draw.DrawText("+ "..v,"Default",scrw-660,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  for k,v in ipairs(entitiesRemoved) do
    draw.DrawText("- "..v,"Default",scrw-840,scrh/2-200+(k*10),COLOR_WHITE,TEXT_ALIGN_RIGHT)
  end
  --GC Details
  surface.SetDrawColor(255,255,255,255)
  surface.DrawLine(300,100,300+105*10,100)
  local prev = GC_CACHE_AVG
  local highest = -1
  local lowest = math.huge
  for i=1, #GC_CACHE do
    local val = GC_CACHE[i]
    surface.DrawLine(300+i*10,200-(prev/GC_CACHE_AVG)*100,300+(i+1)*10,200-(val/GC_CACHE_AVG)*100)
    prev = val
    if val > highest then highest = val end
    if val < lowest then lowest = val end
  end
  draw.DrawText(highest,"DermaDefault",300,10,color_white,TEXT_ALIGN_RIGHT)
  draw.DrawText(lowest,"DermaDefault",300,200,color_white,TEXT_ALIGN_RIGHT)
  draw.DrawText("RAM Usage","DermaDefault",280,93,color_white,TEXT_ALIGN_RIGHT)
end)

--[[
hook.Add("CreateMove","luctus_dev_hud_mouse",function(cmd)
    mouseX = cmd:GetMouseX()
    mouseY = cmd:GetMouseY()
end)
--]]

local zeroAngle = Angle(0, 0, 0)
hook.Add("PostDrawOpaqueRenderables", "HitboxRender", function()
  if not showBBox then return end
  local ants = {LocalPlayer():GetEyeTrace().Entity}
  if not ants[1] then return end
  if markAll then ants = ents.GetAll() end
  
  for k,ent in ipairs(ants) do
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
