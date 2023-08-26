--Luctus Quests
--Made by OverlordAkise

LUCTUS_QUESTS_ACTIVE = LUCTUS_QUESTS_ACTIVE or {}
LUCTUS_QUESTS_MAX = LUCTUS_QUESTS_MAX or {}
LUCTUS_QUESTS_COUNT = LUCTUS_QUESTS_COUNT or 0

local color_accent = Color(0,195,165)
local bgcol = Color(26,26,26)
local color_green = Color(20,240,20)
hook.Add("HUDPaint","luctus_quests",function()
    if not input.IsKeyDown(KEY_C) then return end
    local w = ScrW()-5
    surface.SetFont("Trebuchet18")
    local wx, wy = surface.GetTextSize("     ---Active Quests---")
    draw.RoundedBox(0, ScrW()-wx-10, 125, wx+10, 40+18*LUCTUS_QUESTS_COUNT, color_accent)
    draw.RoundedBox(0, ScrW()-wx-10+1, 125+1, wx+10-2, 40+18*LUCTUS_QUESTS_COUNT-2, bgcol)
    draw.DrawText("Active Quests", "Trebuchet18", w, 130, color_white, TEXT_ALIGN_RIGHT)
    local c = 1
    for k,v in pairs(LUCTUS_QUESTS_ACTIVE) do
        local col = (v[1] >= v[2]) and color_green or color_white
        draw.DrawText(k, "Trebuchet18", w, 130+c*20, col, TEXT_ALIGN_RIGHT)
        draw.DrawText(v[1].."/"..v[2], "Trebuchet18", w-wx, 130+c*20, col, TEXT_ALIGN_LEFT)
        c = c + 1
    end
end)

hook.Add("InitPostEntity", "luctus_quests_init", function()
    net.Start("luctus_quests_syncall")
    net.SendToServer()
end)

net.Receive("luctus_quests_syncall", function()
    LUCTUS_QUESTS_ACTIVE = {}
    local amount = net.ReadInt(32)
    local unfinished = false
    for i=1,amount do
        local name = net.ReadString()
        local current = net.ReadInt(32)
        local needed = net.ReadInt(32)
        LUCTUS_QUESTS_ACTIVE[name] = {current,needed}
        if current < needed then
            unfinished = true
        end
    end
    if unfinished then
        chat.AddText(color_accent,"[quest]",Color(255,255,255)," You have unfinished quests! Press 'c' to view")
        --surface.PlaySound("HL1/fvox/beep.wav")
        --Too early to hear sounds well
    end
    LUCTUS_QUESTS_COUNT = table.Count(LUCTUS_QUESTS_ACTIVE)
end)

net.Receive("luctus_quests_sync", function()
    local name = net.ReadString()
    local amount = net.ReadInt(32)
    LUCTUS_QUESTS_ACTIVE[name][1] = amount
end)

print("[luctus_quests] cl loaded")
