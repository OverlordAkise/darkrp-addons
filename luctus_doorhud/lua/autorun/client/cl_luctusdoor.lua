--Luctus Door HUD
--Made by OverlordAkise

surface.CreateFont( "luctus_door_title", {
	font = "Arial",
	weight = 1000,
	size = 50,
} )

surface.CreateFont( "luctus_door_text", {
	font = "Arial",
	weight = 1000,
	size = 25,
} )

local doorCache = {}
local doorEnts = {}

--cache
local color_white = Color(255,255,255,255)

hook.Add("PreDrawEffects", "luctus_doorhud_draw", function()

for i=1,#doorEnts do
  local door = doorEnts[i]
  
  --Position stuff
  local displayData = {}
  local doorAngles = door:GetAngles()
  if doorCache[door] then
    displayData = doorCache[door]
  else
    local OBBMaxs = door:OBBMaxs()
    local OBBMins = door:OBBMins()
    local OBBCenter = door:OBBCenter()
    local size = OBBMins - OBBMaxs
    size = Vector(math.abs(size.x),math.abs(size.y),math.abs(size.z))
    local obbCenterToWorld = door:LocalToWorld(OBBCenter)
    local traceTbl = {
      endpos = obbCenterToWorld,
      filter = function( ent )
        return !(ent:IsPlayer() or ent:IsWorld())
      end
    }
    local scale = 0.1
    --if size.y >= size.x -- This is way more common cause doors
    local DrawAngles = Angle(0,90,90)
    traceTbl.start = obbCenterToWorld + door:GetForward() * (size.x / 2)
    local thickness = (1 - util.TraceLine(traceTbl).Fraction) * (size.x / 2) + 1
    local offset = Vector(-thickness,size.y / 2,0)
    local canvasWidth = size.y / scale
    
    if size.x > size.y then
      DrawAngles = Angle(0,0,90)
      traceTbl.start = obbCenterToWorld + door:GetRight() * (size.y / 2)
      local thickness = util.TraceLine(traceTbl).Fraction * (size.y / 2) + 1
      offset = Vector(size.x / 2,thickness,0)
      canvasWidth = size.x / scale
    end
    
    local heightOffset = Vector(0,0,15)
    local CanvasPos1 = OBBCenter - offset + heightOffset
    local CanvasPos2 = OBBCenter + offset + heightOffset

    displayData = {
      DrawAngles = DrawAngles,
      CanvasPos1 = CanvasPos1,
      CanvasPos2 = CanvasPos2,
      scale = scale,
      canvasWidth = canvasWidth,
      start = traceTbl.start
    }
    doorCache[door] = displayData
  end
  
  --Text stuff
  local doorData = door:getDoorData()
  local doorHeader = "FOR SALE"
  local doorSubHeader = "PRESS F2 TO BUY"
  local extraText = {}
  if table.Count( doorData ) > 0 then
    if doorData.groupOwn then
      doorHeader = doorData.title or "Group Door"
      doorSubHeader = "Access: "..doorData.groupOwn
    elseif doorData.nonOwnable then
      doorHeader = doorData.title or ""
      doorSubHeader = ""
    elseif doorData.teamOwn then
      doorHeader = doorData.title or "Team Door"
      doorSubHeader = "Access: "..table.Count(doorData.teamOwn).." job(s)"
      for k,_ in pairs(doorData.teamOwn) do
        table.insert(extraText, team.GetName(k))
      end
    elseif doorData.owner then
      doorHeader = doorData.title or "Sold Door"
      local doorOwner = Player(doorData.owner)
      if IsValid(doorOwner) then
        doorSubHeader = "Owner: "..doorOwner:Name()
      else
        doorSubHeader = "Owner: Unknown"
      end
      if doorData.allowedToOwn then
        for k,v in pairs(doorData.allowedToOwn) do
          doorData.allowedToOwn[k] = Player(k)
          if !IsValid(doorData.allowedToOwn[k]) then
            doorData.allowedToOwn[k] = nil
          end
        end
        if table.Count(doorData.allowedToOwn) > 0 then
          table.insert(extraText,"Allowed Co-Owners:")
          for k,v in pairs(doorData.allowedToOwn) do
            table.insert(extraText,v:Name())
          end
          table.insert(extraText,"")
        end
      end
      if doorData.extraOwners then
        for k,v in pairs(doorData.extraOwners) do
          doorData.extraOwners[k] = Player(k)
          if !IsValid(doorData.extraOwners[k]) then
            doorData.extraOwners[k] = nil
          end
        end
        if table.Count(doorData.extraOwners) > 0 then
          table.insert(extraText,"Co-Owners:")
          for k,v in pairs(doorData.extraOwners) do
            table.insert(extraText,v:Name())
          end
        end
      end
    end
  end
  
  doorHeader = string.Left(doorHeader,25)
  doorSubHeader = string.Left(doorSubHeader,35)
  
  cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos1),displayData.DrawAngles + doorAngles,displayData.scale)
    draw.SimpleText(doorHeader,"luctus_door_title",displayData.canvasWidth / 2,0,color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText(doorSubHeader,"luctus_door_text",displayData.canvasWidth / 2,50,color_white, TEXT_ALIGN_CENTER)
    for i = 1,#extraText do
      draw.SimpleText(extraText[i],"luctus_door_text",displayData.canvasWidth / 2,90 + i * 20,color_white, TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
  
  cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos2),displayData.DrawAngles + Angle(doorAngles.pitch,doorAngles.yaw,-doorAngles.roll) + Angle(0,180,0),displayData.scale)
    draw.SimpleText(doorHeader,"luctus_door_title",displayData.canvasWidth / 2,0,color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText(doorSubHeader,"luctus_door_text",displayData.canvasWidth / 2,50,color_white, TEXT_ALIGN_CENTER)
    for i = 1,#extraText do
      draw.SimpleText(extraText[i],"luctus_door_text",displayData.canvasWidth / 2,90 + i * 20,color_white, TEXT_ALIGN_CENTER)
    end
  cam.End3D2D()
  
end
end)

--hook.Remove("PostDrawOpaqueRenderables","luctus_doorhud_draw")
--hook.Remove("PreDrawEffects","luctus_doorhud_draw")

--Set doors which should be drawn by hook above
timer.Create("luctus_doors_finder",0.3,0,function()
  if not LocalPlayer() or not IsValid(LocalPlayer()) then return end
  doorEnts = {}
  local entities = ents.FindInSphere(LocalPlayer():EyePos(),250)
  for i = 1,#entities do
    local curEnt = entities[i]
    if curEnt:isDoor() and curEnt:GetClass() != "prop_dynamic" and !curEnt:GetNoDraw() then
      table.insert(doorEnts,curEnt)
    end
  end
end)

--Disable standard door info

hook.Add("HUDDrawDoorData", "luctus_doors_nodefault", function(ent)
  return true
end)
