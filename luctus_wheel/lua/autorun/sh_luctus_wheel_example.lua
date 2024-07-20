--Luctus Wheel Example
--Made by OverlordAkise

--This is example code on how to utilize the luctus_wheel addon
--It allows you to have multiple different options if you press E (+Use) on an entity

--Example: By pressing E on a door you can either use or buy/sell it

hook.Add("LuctusWheelAdd","luctus_wheel_darkrp_doors",function()
    LuctusWheelAdd("func_door_rotating","Buy/Sell Door",function()
        RunConsoleCommand("darkrp", "toggleown")
    end)
    LuctusWheelAdd("prop_door_rotating","Buy/Sell Door",function()
        RunConsoleCommand("darkrp", "toggleown")
    end)
end)

print("[luctus_wheel] sh darkrp door example loaded")
