--Lucid FPS Booster
--Made by OverlordAkise


CreateClientConVar("lucid_enable_multicore", "0", true, false, "Automatically enables multicore upon joining the server")

local color_grey_1 = Color(32, 34, 37)
local color_grey_2 = Color(54, 57, 62)
local color_grey_3 = Color(47, 49, 54)
local color_grey_4 = Color(66, 70, 77)
local color_turquoise = Color(0, 195, 165)

local function OpenMulticoreWindow()
    local window = vgui.Create("DFrame")
    window:SetTitle("")
    window:SetSize(400, 150)
    window:Center()
    window:MakePopup()
    window:ShowCloseButton(false)
    function window.Paint(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_grey_1)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, color_grey_2)
    end

    local btns = vgui.Create("DPanel", window)
    btns:SetDrawBackground(false)
    btns:Dock(BOTTOM)
    btns:DockMargin(4, 4, 4, 4)
            
    local title = vgui.Create("DLabel", window)
    title:SetText("Enable Multicore Rendering?")
    title:SetFont("DermaLarge")
    title:Center()
    title:SetTextColor( color_white )
    title:SetContentAlignment(8)
    title:Dock(FILL)
    title:DockMargin(0, 0, 0, 0)

    local subtext = vgui.Create("DLabel", window)
    subtext:SetText("This could boost your FPS!")
    subtext:SetFont("Trebuchet18")
    subtext:Center()
    subtext:SetTextColor( color_turquoise )
    subtext:SetContentAlignment(5)
    subtext:Dock(FILL)
    subtext:DockMargin(0, 0, 0, 0)
        
    local btn_yes = vgui.Create("DButton", btns)
    btn_yes:SetText("Yes")
    btn_yes:SetFont("DermaDefault")
    btn_yes:Center()
    btn_yes:SetTextColor( color_white )
    btn_yes:SetWide(window:GetWide() * 0.5 - 14)
    btn_yes:Dock(LEFT)
    function btn_yes.Paint(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_grey_3)
        
        if (s.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, color_grey_4)
        end
    end
    btn_yes:SetTextColor( color_white )
    btn_yes.DoClick = function()
        RunConsoleCommand("gmod_mcore_test", "1")
        RunConsoleCommand("mat_queue_mode", "-1")
        RunConsoleCommand("cl_threaded_bone_setup", "1")
        RunConsoleCommand("cl_threaded_client_leaf_system", "1")
        RunConsoleCommand("r_threaded_client_shadow_manager", "1")
        RunConsoleCommand("r_threaded_particles", "1")
        RunConsoleCommand("r_threaded_renderables", "1")
        RunConsoleCommand("r_queued_ropes", "1")
        RunConsoleCommand("studio_queue_mode", "1")
        RunConsoleCommand("lucid_enable_multicore","1")
        window:Remove()
        surface.PlaySound( "garrysmod/ui_click.wav" )
        LocalPlayer():ChatPrint("Multicore Rendering successfully enabled!")
    end

    local btn_no = vgui.Create("DButton", btns)
    btn_no:SetText("No")
    btn_no:SetFont("DermaDefault")
    btn_no:Center()
    btn_no:SetWide(window:GetWide() * 0.5 - 14)
    btn_no:Dock(RIGHT)
    function btn_no.Paint(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, color_grey_3)

        if (s.Hovered) then
            draw.RoundedBox(0, 0, 0, w, h, color_grey_4)
        end
    end
    btn_no:SetTextColor( color_white )
    btn_no.DoClick = function()
        RunConsoleCommand("lucid_enable_multicore","0")
        window:Remove()
        surface.PlaySound( "garrysmod/ui_click.wav" )
        LocalPlayer():ChatPrint( "Multicore Rendering not enabled." )
    end

end
                
hook.Add("InitPostEntity","lucid_open_fps",function()
    timer.Simple(5,function()
        if(GetConVar("lucid_enable_multicore"):GetString() != "1")then
            OpenMulticoreWindow()
        else
            LocalPlayer():ChatPrint("Multicore Rendering automatically enabled!")
        end
    end)
end)

hook.Add( "OnPlayerChat", "lucid_open_fps", function( ply, strText, bTeam, bDead ) 
  if ( ply == LocalPlayer() and strText == "!fps") then
        OpenMulticoreWindow()
    end
end)

concommand.Add("lucid_fps", OpenMulticoreWindow)
