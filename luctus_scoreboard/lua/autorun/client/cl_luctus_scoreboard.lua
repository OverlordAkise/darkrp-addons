--Luctus Scoreboard
--Made by OverlordAkise

local ScoreFrame = nil
local Inspect = nil
local IsClosing = nil

--Config Start

local LUCTUS_SCOREBOARD_NAME = "Luctus RP"
local LUCTUS_SCOREBOARD_WEBSITE = "https://mistforums.com/"

--Custom colors and names for groups
local cgroups = {
    ["superadmin"] = {"Super Administrator", Color(199, 44, 44)},
    ["developer"] = {"Developer", Color(199, 44, 44)},
    ["admin"] = {"Administrator", Color(241, 196, 15)},
    ["moderator"] = {"Moderator", Color(52, 152, 219)},
    ["donator"] = {"Donator", Color(155, 89, 182)},
    ["vip"] = {"VIP", Color(155, 89, 182)}
}

--Rightclick options for players
local scoreboard_admin_options = {
    ["copy steamid"] = function(v) SetClipboardText(v:SteamID()) end,
    ["copy steamid64"] = function(v) SetClipboardText(v:SteamID64()) end,
    ["ulx bring"] = function(v) RunConsoleCommand("ulx", "bring", v:Nick()) end,
    ["ulx return"] = function(v) RunConsoleCommand("ulx", "return", v:Nick()) end,
    ["ulx freeze"] = function(v) RunConsoleCommand("ulx", "freeze", v:Nick()) end,
    ["ulx unfreeze"] = function(v) RunConsoleCommand("ulx", "unfreeze", v:Nick()) end,
    ["ulx jail"] = function(v) RunConsoleCommand("ulx", "jail", v:Nick()) end,
    ["ulx unjail"] = function(v) RunConsoleCommand("ulx", "unjail", v:Nick()) end,
    ["ulx spectate"] = function(v) RunConsoleCommand("ulx", "spectate", v:Nick()) end,
    ["Set Job"] = function(ply)
        if IsClosing then return end
        Inspect = DermaMenu()
        for k,v in SortedPairsByMemberValue(team.GetAllTeams(), "Name") do
            local uid = ply:UserID()
            Inspect:AddOption(v.Name, function() RunConsoleCommand("_FAdmin", "setteam", uid, k) end)
        end
        Inspect:Open()
    end,
}

--colors for the scoreboard
local color_border = Color(0,195,165)
local color_white = Color(255,255,255,255)
local color_background = Color(32,34,37,255)
local color_plylist = Color(26,26,26,200)
local color_plylist_even = Color(54,57,62)
local color_plylist_uneven = Color(44,47,52)
local color_scrollbar = Color(0,0,0,100)
local color_scrollbar_button = Color(44,44,44)
local color_scrollbar_grip = Color(56,56,56)

--Config end



surface.CreateFont("LuctusScoreFontBig", {font = "Verdana", size = 35, weight = 800, antialias = true, bold = true })
surface.CreateFont("LuctusScore", {font = "Verdana", size = 18, weight = 900, antialias = true, bold = true })

local function CreateScoreboard()
    if ScoreFrame then ScoreFrame:Close() end
    ScoreFrame = vgui.Create("DFrame")
    ScoreFrame:SetSize(1000, 700)
    ScoreFrame:SetTitle("")
    ScoreFrame:SetDraggable(false)
    ScoreFrame:SetVisible(true)
    ScoreFrame:ShowCloseButton(false)
    ScoreFrame:Center()
    gui.EnableScreenClicker(true)
    function ScoreFrame:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_border)
        draw.RoundedBox(0,1,1,w-2,h-2,color_background)
        draw.DrawText("Name", "LuctusScore", 51, 77, color_white)
        draw.DrawText("Job", "LuctusScore", 331, 77, color_white)
        draw.DrawText("Rank", "LuctusScore", 509, 77, color_white)
        draw.DrawText("Kills", "LuctusScore", 750, 77, color_white)
        draw.DrawText("Deaths", "LuctusScore", 810, 77, color_white)
        draw.DrawText("Ping", "LuctusScore", 890, 77, color_white)
        draw.DrawText(LUCTUS_SCOREBOARD_NAME, "LuctusScoreFontBig", w / 2, 5, color_white, TEXT_ALIGN_CENTER)
        draw.DrawText("There are currently " .. #player.GetAll() .. " player(s) online.", "LuctusScore", w/2, h-21, color_white, TEXT_ALIGN_CENTER)
    end

    local website = vgui.Create("DLabel", ScoreFrame)
    surface.SetFont("LuctusScore")
    local offsetX, offsetY = surface.GetTextSize(LUCTUS_SCOREBOARD_WEBSITE)
    website:SetPos(ScoreFrame:GetWide() / 2 - (offsetX/2), 45)
    website:SetSize(offsetX, offsetY)
    website:SetFont("LuctusScore")
    website:SetTextColor(color_border)
    website:SetText(LUCTUS_SCOREBOARD_WEBSITE)
    website:SetCursor("hand")
    website:SetMouseInputEnabled(true)
    website.OnMousePressed = function()
        gui.OpenURL(LUCTUS_SCOREBOARD_WEBSITE)
    end

    ScoreFrame.PlayerList = vgui.Create("DPanelList", ScoreFrame)
    ScoreFrame.PlayerList:SetSize(ScoreFrame:GetWide()-20, ScoreFrame:GetTall()-130)
    ScoreFrame.PlayerList:SetPos(10, 110)
    ScoreFrame.PlayerList:SetSpacing(2)
    ScoreFrame.PlayerList:EnableVerticalScrollbar(true)

    function ScoreFrame.PlayerList:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_plylist)
    end
    local sbar = ScoreFrame.PlayerList.VBar
    function sbar:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_scrollbar)
    end
    function sbar.btnUp:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_scrollbar_button)
    end
    function sbar.btnDown:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_scrollbar_button)
    end
    function sbar.btnGrip:Paint(w,h)
        draw.RoundedBox(0,0,0,w,h,color_scrollbar_grip)
    end

    for k,ply in ipairs(player.GetAll()) do
        local item = vgui.Create("DLabel", ScoreFrame.PlayerList)
        local rowCol = k%2==0 and color_plylist_even or color_plylist_uneven
        item:SetSize(ScoreFrame.PlayerList:GetWide()-70, 30)
        item:SetCursor("hand")

        function item:Paint(w,h)
            if not IsValid(ply) then item:Remove() return end
            draw.RoundedBox(0,0,0,w,h,rowCol)
            local ugrp = ply:GetUserGroup()
            draw.DrawText(ply:Nick(), "LuctusScore", 40, 4, color_white)
            draw.DrawText(ply:getDarkRPVar("job"), "LuctusScore", 320, 4, team.GetColor(ply:Team()))
            draw.DrawText(cgroups[ugrp] and cgroups[ugrp][1] or ugrp, "LuctusScore", 500, 4, cgroups[ugrp] and cgroups[ugrp][2] or color_white)
            draw.DrawText(ply:Frags(), "LuctusScore", 739, 4, color_white)
            draw.DrawText(ply:Deaths(), "LuctusScore", 799, 4, color_white)
            draw.DrawText(ply:Ping(), "LuctusScore", 879, 4, color_white)
        end
        function item:DoRightClick()
            if IsValid(Inspect) then
                Inspect:Remove()
            end
            Inspect = DermaMenu()
            for k,v in SortedPairs(scoreboard_admin_options) do
                Inspect:AddOption(k)
            end
            function Inspect:OptionSelected(option, optionText)
                if scoreboard_admin_options[optionText] ~= nil then
                    timer.Simple(0.1,function()
                        scoreboard_admin_options[optionText](ply)
                    end)
                end
            end
            Inspect:Open()
        end

        local image = vgui.Create("AvatarImage", item)
        image:SetSize(28,28)
        image:SetPos(1,1)
        image:SetPlayer(ply,32)

        local mute = vgui.Create("DImageButton", item)
        mute:SetSize(16,16)
        mute:SetPos(item:GetWide() + 35, 7)
        mute:SetImage(ply:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png")

        function mute:DoClick()
            if not ply:IsMuted() then ply:SetMuted(true) else ply:SetMuted(false) end
            mute:SetImage(ply:IsMuted() and "icon16/sound_mute.png" or "icon16/sound.png")
        end

        ScoreFrame.PlayerList:AddItem(item)
    end
    ScoreFrame:SlideDown(0.2) 
end


hook.Add("ScoreboardShow", "luctus_create_scoreboard", function()
    IsClosing = false
    CreateScoreboard()
    return true
end)

hook.Add("ScoreboardHide", "luctus_hide_scoreboard", function()
    IsClosing = true
    if IsValid(ScoreFrame) then 
        ScoreFrame:SlideUp(0.2) 
        gui.EnableScreenClicker(false)
    end
    if IsValid(Inspect) then Inspect:Remove() end
    return true
end)

-- Fix for removing default Scoreboard B-)
local function repairScoreboard()
    hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
    hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
    timer.Simple(3,function()
        hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
        hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
    end)
end

hook.Add("OnGamemodeLoaded", "luctus_override_FAdmin_scoreboard", repairScoreboard)
hook.Add("DarkRPFinishedLoading", "luctus_override_FAdmin_scoreboard", repairScoreboard)

print("[luctus_scoreboard] cl loaded")
