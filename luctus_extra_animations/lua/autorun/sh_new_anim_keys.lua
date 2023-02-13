--Luctus Extra Anims
--Made by OverlordAkise


--Config start

NewPrebuiltAnimations = {
    [ACT_SIGNAL_FORWARD] =  "Vorraus",
    [ACT_SIGNAL_GROUP] = "Sammeln",
    [ACT_SIGNAL_HALT] = "Stop",
    [ACT_GMOD_GESTURE_DISAGREE] = "Nein",
    [ACT_GMOD_GESTURE_AGREE] = "Ja",
    [ACT_GMOD_GESTURE_BECON] = "Come"
}

--Config end


hook.Add("loadCustomDarkRPItems", "luctus_extra_anims", function()
    for k,v in pairs(NewPrebuiltAnimations) do
        DarkRP.addPlayerGesture(k, v)
    end
    print("[SH] Luctus ExtraAnims added new animations!")
end)

hook.Add("PostGamemodeLoaded", "luctus_extra_key_menu", function()
  
    concommand.Remove("_DarkRP_AnimationMenu")
    timer.Simple(1,function()
        local AnimFrame
        function NewAnimationMenu()
            if AnimFrame then return end
            AnimFrame = vgui.Create("DFrame")
            AnimFrame:SetTitle("Emote Menu")
            AnimFrame:SetSize(200,300)
            AnimFrame:ShowCloseButton(false)
            AnimFrame:Center()
            AnimFrame:MakePopup()
            function AnimFrame:Paint(w,h)
                draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
                draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
            end
            
            local closeButton = vgui.Create("DButton",AnimFrame)
            closeButton:SetPos(200-32,2)
            closeButton:SetSize(30,20)
            closeButton:SetText("X")
            closeButton:SetTextColor( Color(255,0,0) )
            closeButton.DoClick = function(s)
                AnimFrame:Close()
                AnimFrame = nil
            end
            function closeButton:Paint(w,h)
                draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
                if (self.Hovered) then
                    draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
                end
            end
            
            local helpText = vgui.Create("DLabel",AnimFrame)
            helpText:SetFont("Trebuchet18")
            helpText:SetText("Custom Animations!")
            helpText:SetTextColor( Color(0, 195, 165) )
            helpText:SetContentAlignment(5)
            helpText:DockMargin(1,1,1,1)
            helpText:Dock(TOP)
            local DScrollPanel = vgui.Create( "DScrollPanel", AnimFrame )
            DScrollPanel:Dock( FILL )
            
            for k,v in pairs(NewPrebuiltAnimations) do
                local emotebutton = DScrollPanel:Add("DButton")
                emotebutton:SetText(v)
                emotebutton.key = k
                emotebutton:DockMargin(1,1,1,1)
                emotebutton:SetTextColor( Color(255, 255, 255) )
                emotebutton:Dock(TOP)
                emotebutton.DoClick = function(s)
                    RunConsoleCommand("_DarkRP_DoAnimation", s.key)
                    AnimFrame:Close()
                    AnimFrame = nil
                end
                function emotebutton:Paint(w,h)
                    draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
                    if (self.Hovered) then
                        draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
                    end
                end
            end
        end
        
        if CLIENT then
            concommand.Add("_DarkRP_AnimationMenu", NewAnimationMenu)
        end
        print("[CL] Luctus ExtraAnims finished loading new key menu!")
    end)
end)

print("[SH] Luctus ExtraAnims loaded!")
