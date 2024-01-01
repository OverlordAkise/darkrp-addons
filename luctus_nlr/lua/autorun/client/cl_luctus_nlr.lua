--Luctus NLR
--Made by OverlordAkise

net.Receive("luctus_nlr_showzone",function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent:SetNoDraw(false)
end)

net.Receive("luctus_nlr_greyscreen",function()
    local toggle = net.ReadBool()
    if toggle then
        local grey = Color(50, 50, 50, 210)
        local white = Color(255,255,255,255)
        local black = Color(0,0,0,255)
        local w, h = ScrW(), ScrH()
        hook.Add("HUDPaintBackground", "luctus_nlr_greyscreen", function()
            surface.SetDrawColor(grey)
            surface.DrawRect(0, 0, w, h)
            draw.SimpleTextOutlined(LUCTUS_NLR_TEXT, "DermaLarge", w/2, h/2, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, black)
        end)
    else
        hook.Remove("HUDPaintBackground", "luctus_nlr_greyscreen")
    end
end)

print("[luctus_nlr] cl loaded")
