--Luctus RP-Score
--Made by OverlordAkise

local color_white = Color(255,255,255,255)


if LUCTUS_RPSCORE_HUD_DISPLAY then
    hook.Add("HUDPaint","luctus_rpscore", function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return end
        draw.SimpleText("RP-Score: "..ply:getRPScore(),"Trebuchet18",ScrW()/1.5,2,color_white)
    end)
end

print("[luctus_rpscore] cl loaded")
