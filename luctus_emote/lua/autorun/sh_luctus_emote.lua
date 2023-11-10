--Luctus Emote System
--Made by OverlordAkise
--Base animations vectors and applyAnimation function made by EGM and ​Mattzimann

--Optimizations: Less digits with the angles, replaced createmove with timer, menu for all emotes, net emote changer
--Added: An HUD element that shows if you are currently in emote pose or not


--How fast you can walk until your animation stops
LUCTUS_EMOTE_MAXSPEED = 110
--List of emotes that players can use
LUCTUS_EMOTE_LIST = {
    ["Comlink"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(33, -104, 2),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-90, -31, -42),
        ["ValveBiped.Bip01_R_Hand"] = Angle(0,0,-24),
    },
    ["Crossed Arms (infront)"] = {
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-44,-107,16),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(20, -57, -6),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-29, -59, 1),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(5, -6, -0),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(-8, -0, 0),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(51, -120, -19),
        ["ValveBiped.Bip01_R_Hand"] = Angle(14, -33, -7),
        ["ValveBiped.Bip01_L_Hand"] = Angle(26, 32, -15),
    },
    ["Crossed arms (back)"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(4, 15, 3),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-64, 2 , -85),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(4, 15, 3),
        ["ValveBiped.Bip01_L_Forearm"] = Angle(54, -30, 31),
        ["ValveBiped.Bip01_R_Thigh"] = Angle(5, 0, 0),
        ["ValveBiped.Bip01_L_Thigh"] = Angle(-9, 0, 0),
    },
    ["High Five"] = {
        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
    },
    ["Hololink"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(10,-20),
        ["ValveBiped.Bip01_R_Hand"] = Angle(0,1,50),
        ["ValveBiped.Bip01_Head1"] = Angle(0,-30,-20),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-65,39.8863),
    },
    ["Middlefinger"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(15,-55,-0),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(0,-55,-0),
        ["ValveBiped.Bip01_R_Hand"] = Angle(20,20,90),
        ["ValveBiped.Bip01_R_Finger1"] = Angle(20,-40,-0),
        ["ValveBiped.Bip01_R_Finger3"] = Angle(0,-30,0),
        ["ValveBiped.Bip01_R_Finger4"] = Angle(-10,-40,0),
        ["ValveBiped.Bip01_R_Finger11"] = Angle(-0,-70,-0),
        ["ValveBiped.Bip01_R_Finger31"] = Angle(0,-70,0),
        ["ValveBiped.Bip01_R_Finger41"] = Angle(0,-70,0),
        ["ValveBiped.Bip01_R_Finger12"] = Angle(-0,-70,-0),
        ["ValveBiped.Bip01_R_Finger32"] = Angle(0,-70,0),
        ["ValveBiped.Bip01_R_Finger42"] = Angle(0,-70,-0),
    },
    ["Point"] = {
        ["ValveBiped.Bip01_R_Finger2"] = Angle(4, -53, 0),
        ["ValveBiped.Bip01_R_Finger21"] = Angle(0, -59, 0),
        ["ValveBiped.Bip01_R_Finger3"] = Angle(4, -53, 0),
        ["ValveBiped.Bip01_R_Finger31"] = Angle(0, -59, 0),
        ["ValveBiped.Bip01_R_Finger4"] = Angle(4, -53, 0),
        ["ValveBiped.Bip01_R_Finger41"] = Angle(0, -59, 0),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(25, -87, -0),
    },
    ["Salute"] = {
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(80, -95, -77.5),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(35, -125, -5),
    },
    ["Surrender"] = {
        ["ValveBiped.Bip01_L_Forearm"] = Angle(25,-65,25),
        ["ValveBiped.Bip01_R_Forearm"] = Angle(-25,-65,-25),
        ["ValveBiped.Bip01_L_UpperArm"] = Angle(-70,-180,70),
        ["ValveBiped.Bip01_R_UpperArm"] = Angle(70,-180,-70),
    }
}

if CLIENT then

    local function applyAnimation(ply, targetValue, class)
        if not IsValid(ply) then return end
        if ply.animationSWEPAngle ~= targetValue then
            ply.animationSWEPAngle = Lerp(FrameTime() * 5, ply.animationSWEPAngle, targetValue)
        end

        local la_old_animation = ply:GetNW2String("la_old_animation")
        if la_old_animation ~= class and LUCTUS_EMOTE_LIST[la_old_animation] then
            for boneName, angle in pairs(LUCTUS_EMOTE_LIST[la_old_animation]) do
                local bone = ply:LookupBone(boneName)
                if bone then
                    ply:ManipulateBoneAngles(bone, angle_zero)
                end
            end
            ply:SetNW2String("la_old_animation",class)
        end
        
        if not LUCTUS_EMOTE_LIST[class] then return end
        for boneName, angle in pairs(LUCTUS_EMOTE_LIST[class]) do
            local bone = ply:LookupBone(boneName)
            if bone then
                ply:ManipulateBoneAngles(bone, angle * ply.animationSWEPAngle)
            end
        end
    end
    
    hook.Add("Think", "luctus_emote_animations", function()
        for k,ply in ipairs(player.GetHumans()) do
            local la_animation = ply:GetNW2String("la_animation")

            if la_animation == "" then return end
            if not ply.animationSWEPAngle then
                ply.animationSWEPAngle = 0
            end

            if ply:GetNW2Bool("la_in_animation") then
                applyAnimation(ply, 1, la_animation)
            else
                applyAnimation(ply, 0, la_animation)
            end
        end
    end)
    print("[luctus_emotes] sh loaded")
end


if CLIENT then return end

util.AddNetworkString("luctus_set_animation")

timer.Create("luctus_animations_reset_on_movement",0.3,0,function()
    for k,ply in ipairs(player.GetHumans()) do
        if not ply:GetNW2Bool("la_in_animation",false) then continue end
        if ply:GetVelocity():Length() > LUCTUS_EMOTE_MAXSPEED then
            ToggleEmoteStatus(ply, false)
        end
        if ply:KeyDown(IN_DUCK) or ply:KeyDown(IN_USE) or ply:KeyDown(IN_JUMP) then
            ToggleEmoteStatus(ply, false)
        end
    end
end)

net.Receive("luctus_set_animation",function(len,ply)
    local animName = net.ReadString()
    if not ply.emoteNetCooldown then ply.emoteNetCooldown = 0 end
    if ply.emoteNetCooldown > CurTime() then return end
    ply.emoteNetCooldown = CurTime() + 0.3
    if LUCTUS_EMOTE_LIST[animName] then
        ply:SetNW2String("la_old_animation",ply:GetNW2String("la_animation"))
        ply:SetNW2String("la_animation", animName)
    end
end)

hook.Add("PlayerInitialSpawn", "luctus_animations_setdefault", function(ply)
    ply:SetNW2String("la_animation", "<unknown>")
    for animName,v in pairs(LUCTUS_EMOTE_LIST) do
        ply:SetNW2String("la_animation",animName)
        break
    end
end)

function ToggleEmoteStatus(ply, shouldAnimate)
    ply:SetNW2Bool("la_in_animation", shouldAnimate)
end

print("[luctus_emotes] sh loaded")
