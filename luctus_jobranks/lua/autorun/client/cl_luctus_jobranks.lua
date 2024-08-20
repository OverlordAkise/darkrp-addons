--Luctus Jobranks
--Made by OverlordAkise

--This is only for the optional HUD element

local accent_color = Color(0, 195, 165)
local background_color = Color(0,0,0,230)
local color_white = Color(255,255,255,255)
local xPos = ScrW()-230
local yPos = 30
local width = 200
local height = 80

local lastJobrank = ""
local curJobrankname = ""
local curJobid = -1
local maxJobid = -1

hook.Add("HUDPaint", "luctus_jobranks", function()
    if not LUCTUS_JOBRANKS_HUD_ENABLED then
        hook.Remove("HUDPaint","luctus_jobranks")
        return
    end

    local ply = LocalPlayer()
    local jobrankname = ply:GetNWString("l_nametag","")
    if jobrankname == "" then return end

    if lastJobrank != jobrankname then
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
    surface.SetDrawColor(accent_color)
    surface.DrawOutlinedRect(xPos,yPos,width,height,1)
    draw.RoundedBox(0,xPos+1,yPos+1,width-2,height-2,background_color)
    draw.SimpleText(curJobrankname,"Trebuchet24",xPos+width/2,yPos+15,color_white,TEXT_ALIGN_CENTER)
    draw.SimpleText("Hierarchy: "..curJobid.."/"..maxJobid,"Trebuchet24",xPos+width/2,yPos+45,color_white,TEXT_ALIGN_CENTER)
end)

print("[luctus_jobranks] cl loaded")
