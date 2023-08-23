--Luctus Charsystem
--Made by OverlordAkise


local HoverSound = "UI/buttonrollover.wav"
local ClickSound = "UI/buttonclick.wav"
local color_accent = Color(0, 195, 165)
local color_button = Color(20,20,20,255)
local color_button_lighter = Color(40,40,40,255)

local color_white = Color(255,255,255,255)
local color_black = Color(0,0,0,255)

local BgFrame = nil
local NameInputMenu = nil
local DeleteMenu = nil

net.Receive("luctus_char_open", function()
    local CharTable = net.ReadTable()
    LuctusCharOpenMenu(CharTable)
end)

--Add it here to always be there no matter the config
--table.insert(LUCTUS_CHAR_UI_BUTTONS,{"Disconnect", function() RunConsoleCommand("disconnect") end})

function LuctusCharMakeClickable(el,optCol,optWidth,optSmall)
    el.accentWidth = optSmall or 2
    el.accentTarget = optSmall or 2
    el.accentSwitch = 0
    el:SetTextColor(color_white)
    function el:Paint(w, h)
        self.accentWidth = Lerp(SysTime()-self.accentSwitch,self.accentWidth,self.accentTarget)
        draw.RoundedBox(0, 0, 0, w, h, optCol or color_accent)
        draw.RoundedBox(0, 0, 0, w, h-self.accentWidth, self:IsHovered() and color_button_lighter or color_button)
    end
    function el:OnCursorEntered()
        surface.PlaySound(HoverSound)
        self.accentSwitch = SysTime()
        self.accentTarget = optWidth or 5
    end
    function el:OnCursorExited()
        --self.bcolor = color_button
        self.accentSwitch = SysTime()
        self.accentTarget = optSmall or 2
    end
end

function LuctusCharDeleteMenuOpen(slot,name)
    if not IsValid(BgFrame) then return end
    if IsValid(DeleteMenu) then return end
  
    local DeleteMenu = vgui.Create( "DFrame", BgFrame)
    DeleteMenu:SetPos(ScrW()/2 - 200, ScrH()/2 - 100)
    DeleteMenu:SetSize(400, 200)
    DeleteMenu:SetTitle("confirmationbox")
    DeleteMenu:SetDraggable(true)
    DeleteMenu:ShowCloseButton(false)
    DeleteMenu.StartTime = SysTime()
    function DeleteMenu.Paint(self, w, h)
        Derma_DrawBackgroundBlur(self,self.StartTime)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
        draw.RoundedBox(0, 1, 1, w-2, 24, color_button)
        draw.SimpleText("Really delete this character?", "Trebuchet24", w/2, h/2 - 30, Color(255,0,0,255), TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "Trebuchet24", w/2, h/2, color_white, TEXT_ALIGN_CENTER)
    end

    local CloseButton = vgui.Create("DButton", DeleteMenu)
    CloseButton:SetPos(376, 2)
    CloseButton:SetSize(22, 24)
    CloseButton:SetFont("Trebuchet18")
    CloseButton:SetText("X")
    LuctusCharMakeClickable(CloseButton,Color(255,0,0))
    function CloseButton.DoClick()
        DeleteMenu:Close()
    end

    local YesButton = vgui.Create("DButton", DeleteMenu)
    YesButton:SetText("Yes")
    YesButton:SetSize(198,30)
    YesButton:SetPos(200,168)
    YesButton:SetFont("Trebuchet18")
    LuctusCharMakeClickable(YesButton,Color(0,255,0))
    function YesButton.DoClick()
        surface.PlaySound("buttons/button16.wav")
        net.Start("luctus_char_delete")
            net.WriteUInt(slot, 8)
        net.SendToServer()
        DeleteMenu:Close()
    end
  
    local NoButton = vgui.Create("DButton", DeleteMenu)
    NoButton:SetText("No")
    NoButton:SetSize(198,30)
    NoButton:SetPos(2,168)
    NoButton:SetFont("Trebuchet18")
    LuctusCharMakeClickable(NoButton,Color(255,0,0))
    function NoButton.DoClick()
        surface.PlaySound( "buttons/combine_button1.wav" )
        DeleteMenu:Close()
    end
end


function LuctusCharNameInputMenuOpen(slot)
    if not IsValid(BgFrame) then return end
    if IsValid(NameInputMenu) then return end
    
    local NameError = ""
    local NameInputMenu = vgui.Create( "DFrame", BgFrame)
    NameInputMenu:SetPos(ScrW()/2 - 200, ScrH()/2 - 100)
    NameInputMenu:SetSize(400, 200)
    NameInputMenu:SetTitle("Please enter your name")
    NameInputMenu:SetDraggable(true)
    NameInputMenu:ShowCloseButton(false)
    NameInputMenu.StartTime = SysTime()
    function NameInputMenu:Paint(w, h)
        Derma_DrawBackgroundBlur(self,self.StartTime)
        draw.RoundedBox(0,0,0,w,h,color_accent)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
        draw.RoundedBox(0, 1, 1, w-2, 22, color_button)
        draw.SimpleText(NameError, "Trebuchet18", w/2, h-50, Color(255,0,0,255), TEXT_ALIGN_CENTER)
    end

    local CloseButton = vgui.Create("DButton", NameInputMenu)
    CloseButton:SetPos(376 ,2)
    CloseButton:SetSize(22, 24)
    CloseButton:SetFont("Trebuchet18")
    CloseButton:SetText("X")
    LuctusCharMakeClickable(CloseButton,Color(255,0,0),5,2)
    function CloseButton.DoClick()
        surface.PlaySound(ClickSound)
        NameInputMenu:Close()
    end
  
    local NameEntry = vgui.Create( "DTextEntry", NameInputMenu )
    NameEntry:SetPos(100, NameInputMenu:GetTall()/2-10)
    NameEntry:SetSize(200,20)
    NameEntry:SetPlaceholderText("Jack ingof")
    NameEntry:SetDrawLanguageID(false)
    function NameEntry.OnChange() -- Same as DarkRP Namecheck function
        local NameText = NameEntry:GetValue()
        if not NameText or string.Trim(NameText) == "" then 
            NameError = "Name is empty!"
        elseif string.len(NameText) < 2 then
            NameError = "Name is too short!"
        elseif string.len(NameText) > 31 then
            NameError = "Name is too long!"
        elseif not string.match(NameText, "^[a-zA-ZЀ-џ0-9 ]+$") then
            NameError = "Forbidden characters in name!"
        else
            NameError = ""
        end
    end

    local AcceptButton = vgui.Create("DButton", NameInputMenu)
    AcceptButton:SetText("Create")
    AcceptButton:SetSize(396,30)
    AcceptButton:SetPos(2,168)
    AcceptButton:SetFont("Trebuchet24")
    LuctusCharMakeClickable(AcceptButton,Color(0,255,0),5,2)
    function AcceptButton.DoClick()
        if NameError == "" then
            surface.PlaySound(ClickSound)
            net.Start("luctus_char_create")
                net.WriteUInt(slot, 8)
                net.WriteString(NameEntry:GetValue())
            net.SendToServer()
            surface.PlaySound("buttons/button16.wav")
            NameInputMenu:Close()
        else
            surface.PlaySound( "buttons/combine_button1.wav" )
        end
    end
end


function LuctusCharOpenMenu(CharTable)
    if IsValid(BgFrame)  then BgFrame:Close() end
    BgFrame = vgui.Create( "DFrame" )
    BgFrame:SetSize( ScrW() , ScrH() )
    BgFrame:SetPos( 0 , 0 )
    BgFrame:SetDraggable( false )
    BgFrame:ShowCloseButton( false )
    BgFrame:MakePopup()
    BgFrame.StartTime = SysTime()
    function BgFrame:Paint(w, h)
        Derma_DrawBackgroundBlur(self,self.StartTime)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 175))
    end
    function BgFrame:OnKeyCodePressed(key) 
        if key == 93 then --F2
            self:Close()
        end
    end

    local TopPanel = vgui.Create("DPanel" , BgFrame)
    TopPanel:SetPos( 0 , 0 )
    TopPanel:SetSize( ScrW(), 60)
    function TopPanel:Paint(w , h)
        draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 200))
    end



    local WelcomeText = vgui.Create("DLabel", BgFrame)
    surface.SetFont("DermaLarge")
    local x,y = surface.GetTextSize(LUCTUS_CHAR_WELCOMEMSG)
    WelcomeText:SetPos((ScrW()/2)-(x/2), 100)
    WelcomeText:SetSize(x+10, 50)
    WelcomeText:SetFont("DermaLarge")
    WelcomeText:SetText(LUCTUS_CHAR_WELCOMEMSG)


    local firstButtonPadding = (ScrW()/2)-(#LUCTUS_CHAR_UI_BUTTONS*75)
  
    for k,v in pairs(LUCTUS_CHAR_UI_BUTTONS) do
        local CustomButton = vgui.Create( "DButton" , TopPanel ) -- 1st Custom Button
        CustomButton:SetPos(firstButtonPadding+((k-1)*5)+((k-1)*150), 0)
        CustomButton:SetSize( 150 , 60 )
        CustomButton:SetText( v[1] )
        CustomButton:SetFont( "Trebuchet24" )
        LuctusCharMakeClickable(CustomButton)
        function CustomButton.DoClick()
            surface.PlaySound(ClickSound)
            if type(v[2]) == "string" then
                gui.OpenURL( v[2] )
            else
                v[2]()
            end
        end
    end
    
    --TODO: Calculate this dynamically
    local PanelPosi = {
        {0.052, 0.277},
        {0.364, 0.277},
        {0.677, 0.277}
    }
    
    for k,v in pairs(PanelPosi) do
        local px = ScrW() * 0.260
        local py = ScrH() * 0.555
        local character = CharTable[k]
        if not character then character = {} end

        local CharPanel = vgui.Create("DPanel" , BgFrame)
        CharPanel:SetPos(ScrW() * v[1] , ScrH()* v[2])
        CharPanel:SetSize( px , py )
        CharPanel.Paint = function( self , w , h )
            draw.RoundedBox( 0 , 0 , 0 , w , h , Color( 0 , 0 , 0 , 175 ) )
            draw.RoundedBox(0,0,0,w,h*0.2,Color(0,0,0,190))
        end
        local CharModelPan = vgui.Create( "DModelPanel" , CharPanel )
        CharModelPan:SetPos( 0 , py*0.15 )
        CharModelPan:SetSize( px , py*0.7 )

        local jobcmd = character.job
        local jobmodel = ""

        for k,v in pairs(RPExtraTeams) do
            if v.command == jobcmd then
                if istable(v.model) then
                    jobmodel = v.model[1]
                else
                    jobmodel = v.model
                end
            end
        end
        if CharModelPan:GetModel() != jobmodel then
            CharModelPan:SetModel(jobmodel)
        end


        local CharName1Label = vgui.Create( "DLabel" , CharPanel )
        CharName1Label:SetPos( 0 , py*0.03 )
        CharName1Label:SetContentAlignment(5)
        CharName1Label:SetFont( "DermaLarge" )

        CharName1Label:SetSize( CharPanel:GetWide() , ScrH() * 0.046 )
        CharName1Label:SetText( character.name or "Empty" )

        local Char1JobLabel = vgui.Create( "DLabel" , CharPanel ) -- 1st Character Name
        Char1JobLabel:SetPos( 0 , py*0.1 )
        Char1JobLabel:SetContentAlignment(5)
        Char1JobLabel:SetFont( "Trebuchet24" )
        Char1JobLabel:SetSize( px , 30 )
        Char1JobLabel:SetText(team.GetName(tonumber(character.job)) or "")

        local CharPlay = vgui.Create( "DButton" , CharPanel )
        CharPlay:SetPos( 0 , CharPanel:GetTall() - ScrH() * 0.074)
        CharPlay:SetSize( ScrW() * 0.260 , ScrH() * 0.074 )
        CharPlay:SetFont( "Trebuchet24" )
        LuctusCharMakeClickable(CharPlay,Color(0,250,0),5,1)
        if character.playing then
            CharPlay:SetText( "Currently playing!" )
        elseif not character.name then
            CharPlay:SetText( "Create new character!" )
        elseif character.name then
            CharPlay:SetText( "Play this character!" )
        end
        function CharPlay.DoClick()
            surface.PlaySound(ClickSound)
            if not character.name then
                LuctusCharNameInputMenuOpen(k)
            elseif(character.name and not character.playing) then
                net.Start("luctus_char_play")
                net.WriteUInt(k, 8)
                net.SendToServer()
                BgFrame:Close()
            end
        end
        
        if character.name then
            local CharDeleteButton = vgui.Create( "DButton" , CharPanel )
            CharDeleteButton:SetPos( CharPanel:GetWide() - 33, 0)
            CharDeleteButton:SetSize( 30 , 30 )
            CharDeleteButton:SetText("delete")
            function CharDeleteButton.DoClick()
                surface.PlaySound(ClickSound)
                LuctusCharDeleteMenuOpen(k,character.name)
            end
            LuctusCharMakeClickable(CharDeleteButton,Color(255,0,0),5,2)
        end
        
    end
end

net.Receive("luctus_char_msg",function(len,ply)
    local ColorMessageTable = net.ReadTable()
    if not istable(ColorMessageTable) then return end
    chat.AddText(unpack(ColorMessageTable))
end)


--Admin Menu

local frame = nil
function LuctusCharAdminOpen(characters, steamid)
    if IsValid(frame) then frame:Close() end
    local curChar = 1

    local frame = vgui.Create("DFrame")
    frame:SetTitle("User: "..steamid)
    frame:SetSize(500,500)
    frame:Center()
    frame:MakePopup()
    function frame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(34, 40, 49))
    end
    
    local buttonPanel = vgui.Create("DPanel",frame)
    buttonPanel:Dock(TOP)
    buttonPanel:SetHeight(60)
    function buttonPanel:Paint() end
  
    local infoPanel = vgui.Create("DPanel",frame)
    infoPanel:Dock(FILL)
    infoPanel:DockPadding(20,20,20,20)
    function infoPanel:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, Color(57, 62, 70, 200))
    end
  
    local nameLabel = vgui.Create("DLabel", infoPanel)
    nameLabel:Dock(TOP)
    nameLabel:SetText("Name")
    local nameBox = vgui.Create("DTextEntry", infoPanel)
    nameBox:Dock(TOP)
    local moneyLabel = vgui.Create("DLabel", infoPanel)
    moneyLabel:Dock(TOP)
    moneyLabel:SetText("Money")
    local moneyBox = vgui.Create("DTextEntry", infoPanel)
    moneyBox:Dock(TOP)
    local jobLabel = vgui.Create("DLabel", infoPanel)
    jobLabel:Dock(TOP)
    jobLabel:SetText("Job")
    local jobBox = vgui.Create("DComboBox", infoPanel)
    jobBox:Dock(TOP)
    for k,v in pairs(RPExtraTeams) do
        jobBox:AddChoice(v.command)
    end
  
    local deleteBut = vgui.Create("DButton", infoPanel)
    deleteBut:Dock(BOTTOM)
    deleteBut:SetHeight(50)
    deleteBut:DockMargin(0,5,0,0)
    deleteBut:SetText("Delete Character")
    deleteBut:SetFont("Trebuchet24")
    LuctusCharMakeClickable(deleteBut,Color(255,0,0))
    function deleteBut:DoClick()
        Derma_Query(
            "Do you really want to delete this character?",
            "char | delete confirmation",
            "Yes",
            function()
                net.Start("luctus_char_admin_delete")
                    net.WriteUInt(curChar,8)
                    net.WriteString(steamid)
                net.SendToServer()
                frame:Close()
            end,
            "No",
            function()end
        )
    end

    local saveBut = vgui.Create("DButton", infoPanel)
    saveBut:Dock(BOTTOM)
    saveBut:SetHeight(50)
    saveBut:SetText("Save Changes")
    saveBut:SetFont("Trebuchet24")
    LuctusCharMakeClickable(saveBut,Color(0,255,0))
    function saveBut:DoClick()
        net.Start("luctus_char_admin_update")
            net.WriteString(steamid)
            net.WriteString(nameBox:GetValue())
            net.WriteString(moneyBox:GetValue())
            net.WriteString(jobBox:GetValue())
            net.WriteUInt(curChar,8)
        net.SendToServer()
    end
    
    --Set char#1 as default init
    nameBox:SetText(characters[1] and characters[1].name or "None")
    moneyBox:SetText(characters[1] and characters[1].money or "0")
    jobBox:SetValue(characters[1] and characters[1].job or "None")
    curChar = 1
    local frameW = frame:GetWide()-10 -- -DockPadding
    for i=1,3 do
        local button = vgui.Create("DButton", buttonPanel)
        button:SetSize(frameW/3,50)
        button:Dock(LEFT)
        button:SetText(i)
        button:SetFont("Trebuchet24")
        button.cid = i
        LuctusCharMakeClickable(button)
        function button:Think()
            if curChar == self.cid then
                self.accentTarget = 10
            elseif not self:IsHovered() then
                self.accentTarget = 2
            end
        end
        function button:DoClick()
            local id = self.cid
            nameBox:SetText(characters[id] and characters[id].name or "None")
            moneyBox:SetText(characters[id] and characters[id].money or "0")
            jobBox:SetValue(characters[id] and characters[id].job or "None")
            curChar = id
        end
    end
end

net.Receive("luctus_char_adminmenu", function()
    local CharTable = net.ReadTable()
    local steamid = net.ReadString()
    LuctusCharAdminOpen(CharTable, steamid)
end)

print("[luctus_char] cl loaded")
