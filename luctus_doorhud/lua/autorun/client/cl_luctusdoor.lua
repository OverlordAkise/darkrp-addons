--Luctus Door HUD
--Made by OverlordAkise

surface.CreateFont("luctus_door_title", {
    font = "Arial",
    weight = 1000,
    size = 50,
})

surface.CreateFont("luctus_door_text", {
    font = "Arial",
    weight = 1000,
    size = 25,
})

local doorCache = {}
local doorEnts = {} --door entities near you

--cache
local color_white = Color(255,255,255,255)
local heightOffset = Vector(0,0,15)
local scale = 0.1

hook.Add("PreDrawEffects", "luctus_doorhud_draw", function()

for i=1,#doorEnts do
    local door = doorEnts[i]
    if not IsValid(door) then continue end
    --Position stuff
    local displayData = doorCache[door]
    if not displayData then continue end
    local doorAngles = door:GetAngles()

    cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos1),displayData.DrawAngles + doorAngles,displayData.scale)
        draw.SimpleText(displayData.doorHeader,"luctus_door_title",displayData.canvasWidth / 2,0,color_white, TEXT_ALIGN_CENTER)
        draw.SimpleText(displayData.doorSubHeader,"luctus_door_text",displayData.canvasWidth / 2,50,color_white, TEXT_ALIGN_CENTER)
        for i = 1,#displayData.extraText do
            draw.SimpleText(displayData.extraText[i],"luctus_door_text",displayData.canvasWidth / 2,90 + i * 20,color_white, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
  
    cam.Start3D2D(door:LocalToWorld(displayData.CanvasPos2),displayData.DrawAngles + Angle(doorAngles.pitch,doorAngles.yaw,-doorAngles.roll) + Angle(0,180,0),displayData.scale)
    draw.SimpleText(displayData.doorHeader,"luctus_door_title",displayData.canvasWidth / 2,0,color_white, TEXT_ALIGN_CENTER)
    draw.SimpleText(displayData.doorSubHeader,"luctus_door_text",displayData.canvasWidth / 2,50,color_white, TEXT_ALIGN_CENTER)
    for i = 1,#displayData.extraText do
        draw.SimpleText(displayData.extraText[i],"luctus_door_text",displayData.canvasWidth / 2,90 + i * 20,color_white, TEXT_ALIGN_CENTER)
    end
    cam.End3D2D()
  
end
end)


--Set doors which should be drawn by hook above
timer.Create("luctus_doors_finder",0.3,0,function()
    if not IsValid(LocalPlayer()) then return end
    doorEnts = {}
    local entities = ents.FindInSphere(LocalPlayer():EyePos(),250)
    for i = 1,#entities do
        local curEnt = entities[i]
        if curEnt:isKeysOwnable() and curEnt:GetClass() ~= "prop_dynamic" and not curEnt:GetNoDraw() then
            table.insert(doorEnts,curEnt)
            --if door hasn't been set up:
            if not doorCache[curEnt] then
                luctusDoorSetup(curEnt)
            end
            --always update door text
            luctusDoorCacheText(curEnt)
        end
    end
end)

--Generate door text, owner, buyable, etc.
function luctusDoorCacheText(door)
    local doorData = door:getDoorData()
    local doorHeader = "FOR SALE"
    local doorSubHeader = "PRESS F2 TO BUY"
    local extraText = {}
    if table.Count(doorData) > 0 then
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
                    if not IsValid(doorData.allowedToOwn[k]) then
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
                    if not IsValid(doorData.extraOwners[k]) then
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
    
    doorCache[door].doorHeader = string.Left(doorHeader,25)
    doorCache[door].doorSubHeader = string.Left(doorSubHeader,35)
    doorCache[door].extraText = extraText
end

--Generate text position, angle, etc.
function luctusDoorSetup(door)
    local OBBCenter = door:OBBCenter()
    local size = door:OBBMins() - door:OBBMaxs()
    size = Vector(math.abs(size.x),math.abs(size.y),math.abs(size.z))
    local obbCenterToWorld = door:LocalToWorld(OBBCenter)
    local traceTbl = {
        endpos = obbCenterToWorld,
        filter = function(ent)
            return not (ent:IsPlayer() or ent:IsWorld())
        end
    }

    --if size.y >= size.x -- This is way more common cause doors
    local DrawAngles = Angle(0,90,90)
    traceTbl.start = obbCenterToWorld + door:GetForward() * (size.x / 2)
    local thickness = (1 - util.TraceLine(traceTbl).Fraction) * (size.x / 2) + 1
    local offset = Vector(-thickness,size.y / 2,0)
    local canvasWidth = size.y / scale

    if size.x > size.y then
      DrawAngles = Angle(0,0,90)
      traceTbl.start = obbCenterToWorld + door:GetRight() * (size.y / 2)
      offset = Vector(size.x / 2,util.TraceLine(traceTbl).Fraction * (size.y / 2) + 1,0)
      canvasWidth = size.x / scale
    end
    
    

    doorCache[door] = {
        DrawAngles = DrawAngles,
        CanvasPos1 = OBBCenter - offset + heightOffset,
        CanvasPos2 = OBBCenter + offset + heightOffset,
        scale = scale,
        canvasWidth = canvasWidth,
        start = traceTbl.start,
    }
end

--Disable standard door info
hook.Add("HUDDrawDoorData", "luctus_doors_nodefault", function(ent)
    return true
end)

print("[luctus_doorhud] cl loaded")
