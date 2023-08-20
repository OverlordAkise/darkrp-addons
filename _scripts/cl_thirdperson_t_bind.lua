--Luctus Thirdperson T bind
--Made by OverlordAkise

--This needs the "Simple Thirdperson" addon installed
--This automatically toggles thirdperson if you press T, no bind needed
--This is v2, hopefully this fixes thirdperson toggles while typing in chat

local on = false

local function simpletoggle()
    on = !on
    if on == true then
        RunConsoleCommand("simple_thirdperson_enabled", 1)
    else
        RunConsoleCommand("simple_thirdperson_enabled", 0)
    end
end
concommand.Add("simple_thirdperson_toggle", simpletoggle)


--earlier this was done with PlayerButtonDown , but this made problems while typing in chat
hook.Add("PlayerBindPress","luctus_toggle_thirdperson",function(ply,bind,pressed,key)
    if key == KEY_T then
        RunConsoleCommand("simple_thirdperson_toggle")
    end
end)

print("[luctus_thirdperson] cl loaded")
