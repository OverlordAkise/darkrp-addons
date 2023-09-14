--Luctus Ingame Config
--Made by OverlordAkise

hook.Add("OnPlayerChat","luctus_ingame_config",function(ply,text,isteam,isdead)
    if ply ~= LocalPlayer() then return end
    if text ~= LUCTUS_INGAME_CONFIG_CMD_CL then return end
    LuctusOpenIngameConfig(LuctusIngameConfigGetAll(),false)
end)

net.Receive("luctus_ingame_config",function()
    local configTable = net.ReadTable()
    LuctusOpenIngameConfig(configTable,true)
end)

LuctusIngameConfigFrame = nil
function LuctusOpenIngameConfig(configTable,isServer)
    if IsValid(LuctusIngameConfigFrame) then LuctusIngameConfigFrame:Close() end
    LuctusIngameConfigFrame = vgui.Create("DFrame")
    LuctusIngameConfigFrame:SetTitle("Luctus' Ingame Config")
    LuctusIngameConfigFrame:SetSize(700,500)
    LuctusIngameConfigFrame:Center()
    LuctusIngameConfigFrame:SetX(-600)
    LuctusIngameConfigFrame:MakePopup()
    LuctusIngameConfigFrame:ShowCloseButton(false)
    LuctusIngameConfigFrame:MoveTo(ScrW()/2-LuctusIngameConfigFrame:GetWide()/2,LuctusIngameConfigFrame:GetY(),0.5,0)
    function LuctusIngameConfigFrame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(32, 34, 37))
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end
    
    --Close Button Top Right
    local CloseButton = vgui.Create("DButton", LuctusIngameConfigFrame)
    CloseButton:SetText("X")
    CloseButton:SetPos(700-22,2)
    CloseButton:SetSize(20,20)
    CloseButton:SetTextColor(Color(255,0,0))
    CloseButton.DoClick = function()
        gui.EnableScreenClicker( false )
        LuctusIngameConfigFrame:SetMouseInputEnabled( false )
        LuctusIngameConfigFrame:SetKeyboardInputEnabled( false )
        LuctusIngameConfigFrame:MoveTo(2*ScrW(), LuctusIngameConfigFrame:GetY(),0.5,0)
        timer.Simple(0.5,function()
            LuctusIngameConfigFrame:Close()
        end)
    end
    CloseButton.Paint = function(self,w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local DProperties = vgui.Create("DProperties", LuctusIngameConfigFrame)
    DProperties:Dock( FILL )

    for category,data in pairs(configTable) do
        for name,value in pairs(data) do
            local row = DProperties:CreateRow(category,name)
            row:Setup("Generic",{["waitforenter"] = true})
            row:SetValue(value)
            row.category = category
            row.name = name
            row.DataChanged = function(self,newvalue)
                print("[luctus_config] updating value of",self.name)
                if isServer then
                    net.Start("luctus_ingame_config")
                        net.WriteString(self.name)
                        net.WriteString(newvalue)
                    net.SendToServer()
                else
                    LuctusIngameConfigChange(self.name,newvalue,LocalPlayer())
                end
            end
        end
    end
end

print("[luctus_config] CL loaded!")
