--Luctus Jobranks
--Made by OverlordAkise

--This is only for the optional HUD element

local accent_color = Color(0, 195, 165)
local background_color = Color(0,0,0,230)

local xPos = ScrW()-170
local yPos = 20
local width = 150
local height = 60

local lastJobrank = ""
local curJobrankname = ""
local curJobid = -1
local maxJobid = -1

function LuctusJobranksHUDPaint()
    local ply = LocalPlayer()
    local jobrankname = ply:GetNWString("l_nametag","")
    if jobrankname == "" then return end

    surface.SetDrawColor(accent_color)
    surface.DrawOutlinedRect(xPos,yPos,width,height,1)
    draw.RoundedBox(0,xPos+1,yPos+1,width-2,height-2,background_color)
    draw.SimpleText(curJobrankname,"HudDefault",xPos+width/2,yPos+12,color_white,TEXT_ALIGN_CENTER)
    draw.SimpleText(string.format(LUCTUS_JOBRANKS_HUD_TEXT_HIERARCHY,curJobid,maxJobid),"HudDefault",xPos+width/2,yPos+35,color_white,TEXT_ALIGN_CENTER)
    
    if lastJobrank == jobrankname then return end
    local tab = luctus_jobranks[team.GetName(ply:Team())]
    if not tab then return end
    for k,v in ipairs(tab) do
        if v[1] ~= jobrankname then continue end
        curJobrankname = v[2]
        curJobid = k
        maxJobid = table.Count(tab)
        lastJobrank = jobrankname
        break
    end
end


if LUCTUS_JOBRANKS_HUD_ENABLED then
    hook.Add("HUDPaint", "luctus_jobranks", LuctusJobranksHUDPaint)
end

print("[luctus_jobranks] cl loaded")
