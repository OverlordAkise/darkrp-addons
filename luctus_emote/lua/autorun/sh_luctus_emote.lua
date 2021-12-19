--Luctus Emote System
--Made by OverlordAkise
--Base animations vectors and applyAnimation function made by EGM and ​Mattzimann

--Optimizations: Less digits with the angles, replaced createmove with timer, menu for all emotes, net emote changer
--Added: An HUD element that shows if you are currently in emote pose or not

AnimationList = {
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
    ["ValveBiped.Bip01_R_Finger4"] = Angle(4., -53, 0),
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

    local la_old_animation = ply:GetNWString("la_old_animation")
    if la_old_animation ~= class and AnimationList[la_old_animation] then
      for boneName, angle in pairs(AnimationList[la_old_animation]) do
        local bone = ply:LookupBone(boneName)

        if bone then
          ply:ManipulateBoneAngles( bone, angle * 0)
        end
      end
    end

    ply:SetNWString("la_old_animation",class)

    if AnimationList[class] then
      for boneName, angle in pairs(AnimationList[class]) do
        local bone = ply:LookupBone(boneName)

        if bone then
          ply:ManipulateBoneAngles( bone, angle * ply.animationSWEPAngle)
        end
      end
    end
  end

  hook.Add("Think", "AnimationSWEP.Think", function ()
    for _, ply in pairs( player.GetHumans() ) do
      local la_animation = ply:GetNWString("la_animation")

      if la_animation ~= "" then
        if not ply.animationSWEPAngle then
          ply.animationSWEPAngle = 0
        end

        if ply:GetNWBool("la_in_animation") then
          applyAnimation(ply, 1, la_animation)
        else
          applyAnimation(ply, 0, la_animation)
        end
      end 
    end
	end)

else

  util.AddNetworkString("luctus_set_animation")
    
  timer.Create("luctus_animations_reset_on_movement",0.3,0,function()
    for k,ply in pairs(player.GetAll()) do
      if not ply:GetNWBool("la_in_animation",false) then return end
      if math.Round(ply:GetVelocity():Length(),2) > ply:GetNWInt("la_max_speed", 10) then
        ToggleEmoteStatus(ply, false)
      end
      if ply:KeyDown(IN_DUCK) then
        ToggleEmoteStatus(ply, false)
      end
      if ply:KeyDown(IN_USE) then
        ToggleEmoteStatus(ply, false)
      end
      if ply:KeyDown(IN_JUMP) then
        ToggleEmoteStatus(ply, false)
      end
    end
  end)
    
  net.Receive("luctus_set_animation",function(len,ply)
    local animName = net.ReadString()
    if not ply.emoteNetCooldown then ply.emoteNetCooldown = 0 end
    if ply.emoteNetCooldown > CurTime() then return end
    ply.emoteNetCooldown = CurTime() + 1
    
    if AnimationList[animName] then
      ply:SetNWString("la_animation", animName)
    end
  end)
    
  hook.Add("PlayerInitialSpawn", "luctus_animations_setdefault", function(ply)
    ply:SetNWString("la_animation", "salute")
  end)

  function ToggleEmoteStatus(ply, crossing)
    if crossing then
      --PrintMessage(3, "Toggling on!")
      ply:SetNWBool("la_in_animation", true)
      ply:SetNWInt("la_max_speed", 110)
    else
      --PrintMessage(3, "Toggling off!")
      ply:SetNWBool("la_in_animation", false)
      ply:SetNWInt("la_max_speed", 5)
    end
  end
end
