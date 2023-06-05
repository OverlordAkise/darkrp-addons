--Luctus Kevlar
--Made by OverlordAkise

hook.Add("PlayerCanPickupWeapon", "luctus_kevlar_noautopickup", function(ply, wep)
    if string.StartsWith(wep:GetClass(),"luctus_kevlar_") then
        if ply:HasWeapon(wep:GetClass()) then return false end
        if (not ply:KeyDown(IN_USE) and wep.InitTime<CurTime()-0.01) then return false end
	end
end)

print("[luctus_kevlar] sv loaded!")
