--Luctus Stamina
--Made by OverlordAkise

--This is a fully working, clientside only stamina system
--jumping and sprinting uses stamina, not sprinting or ducking while standing still restores it quickly

local LUCTUS_STAMINA_ACTIVE = true
local staminaMax = 100
local staminaUse = 0.02
local staminaCur = staminaMax
local staminaNextRegeneration = 0
local green = Color(0,200,0,200)
local yellow = Color(200,200,0,200)
local red = Color(200,0,0,200)

hook.Add("InitPostEntity","luctus_stamina_load",function()
    hook.Add("HUDPaint","luctus_stamina", function()
        local curWidth = (staminaCur*ScrW())/staminaMax
        local w = ScrW()
        if curWidth == w then return end
        local col = green
        if curWidth/w < 0.66 then
            col = yellow
        end
        if curWidth/w < 0.33 then
            col = red
        end
        draw.RoundedBox(0, 0, ScrH()-6, curWidth, 12, col)
    end)
end)

local OnGroundCache = false
hook.Add("CreateMove","luctus_stamina",function(cmd)
    if not LUCTUS_STAMINA_ACTIVE then return end
    local ply = LocalPlayer()
    local cmdButtons = cmd:GetButtons()
    local isMoving = cmd:KeyDown(IN_FORWARD) or cmd:KeyDown(IN_BACK) or cmd:KeyDown(IN_MOVELEFT) or cmd:KeyDown(IN_MOVERIGHT)
    
    local Change = FrameTime() * 5
    
    if staminaNextRegeneration < CurTime() then
        local staminaRecover = 1
        if isMoving then
            staminaRecover = 0.5
        elseif cmd:KeyDown(IN_DUCK) then
            staminaRecover = 2
        end
        staminaCur = math.Clamp(staminaCur + ( staminaUse * staminaRecover) ,0,staminaMax)
    end
    
    if ply:InVehicle() then return end
    
    if cmd:KeyDown(IN_SPEED) and isMoving and (ply:GetVelocity():Length() > 100) and ply:OnGround() then
        staminaCur = math.Clamp(staminaCur - staminaUse,0,staminaMax)
        staminaNextRegeneration = CurTime() + 1
        if staminaCur < 1 then
            cmdButtons = cmdButtons - IN_SPEED
        end
    end
    
    if cmd:KeyDown(IN_JUMP) and ply:OnGround() then
        if staminaCur < 1 then
            cmdButtons = cmdButtons - IN_JUMP
        else
            if not OnGroundCache then
                if cmd:KeyDown(IN_SPEED) and isMoving then
                    staminaCur = math.Clamp(staminaCur - 10,0,staminaMax)
                else
                    staminaCur = math.Clamp(staminaCur - 5,0,staminaMax)
                end
                staminaNextRegeneration = CurTime() + 1
            end
        end
        OnGroundCache = true
    end
    
    if not cmd:KeyDown(IN_JUMP) then
        OnGroundCache = false
    end
    
    cmd:SetButtons(cmdButtons)
end)

print("[luctus_stamina] cl loaded")
