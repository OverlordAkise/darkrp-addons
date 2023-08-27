--Luctus Weaponbalance
--Made by OverlordAkise

local current_weapon_fields = {}

hook.Add("OnPlayerChat","luctus_weapon_balance",function(ply,text,team,isdead)
    if ply ~= LocalPlayer() or not LocalPlayer():IsAdmin() or not LocalPlayer():GetActiveWeapon() or text ~= "!balance" then return end
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) then return end
    if not weapons.Get(wep:GetClass()) then
        notification.AddLegacy("You can not balance this weapon",1,3)
        surface.PlaySound("buttons/button11.wav")
        return
    end
    LuctusOpenBalanceMenu(wep:GetClass())
end)

function LuctusOpenBalanceMenu(wepclass)
    current_weapon_fields = {}
    local wep = weapons.Get(wepclass)
    local wepframe = vgui.Create("DFrame")
    wepframe:SetSize( 400, 700 )
    wepframe:SetTitle("Balance: "..wepclass)
    wepframe:SetDraggable(true)
    wepframe:SetVisible(true)
    wepframe:ShowCloseButton(true)
    wepframe:Center()
    wepframe:MakePopup()
    
    local attrlist = vgui.Create("DPanelList", wepframe)
    attrlist:Dock(FILL)
    attrlist:SetSpacing(2)
    attrlist:EnableVerticalScrollbar(true)
    
    local searchKey = vgui.Create("DTextEntry", wepframe)
    searchKey:Dock(TOP)
    searchKey:SetPlaceholderText("Type here to search...")
    function searchKey:OnChange()
        local hasToMatch = string.lower(self:GetText())
        for k,v in pairs(current_weapon_fields) do
            if not v.label or not v.textfield then continue end
            local labelText = string.lower(v.label:GetText())
            local fieldText = string.lower(v.textfield:GetText())
            if string.find(labelText,hasToMatch) or string.find(fieldText,hasToMatch) then
                v:Show()
            else
                v:Hide()
            end
        end
        attrlist:InvalidateLayout()
    end
    
    LuctusAddToBalanceList(attrlist,wep,{},"")
    
    local savebtn = vgui.Create("DButton", attrlist)
    savebtn:Dock(BOTTOM)
    savebtn:SetText("SAVE")
    savebtn.DoClick = function()
        LuctusSaveBalance(wepclass)
        wepframe:Close()
    end
    attrlist:AddItem(savebtn)
    
    local resetbtn = vgui.Create("DButton", attrlist)
    resetbtn:Dock(BOTTOM)
    resetbtn:SetText("RESET (click twice)")
    resetbtn.click = 0
    resetbtn.DoClick = function(self)
        if self.click < 2 then
            self.click = self.click + 1
            return
        end
        net.Start("luctus_weaponbalance_reset")
            net.WriteString(wepclass)
        net.SendToServer()
        wepframe:Close()
    end
    attrlist:AddItem(resetbtn)
end

function LuctusSaveBalance(wepclass)
    local wepTable = {}
    for k,v in pairs(current_weapon_fields) do
        if not v.textfield then continue end
        v = v.textfield
        if v:GetText() == tostring(v.orig_value) then continue end
        if not table.IsEmpty(v.history) then
            local wt = wepTable
            for k,v in pairs(v.history) do
                if not wt[v] then wt[v] = {} end
                wt = wt[v]
            end
            wt[v.key] = v:GetText()
        end
        wepTable[v.key] = v:GetText()
    end
    net.Start("luctus_weaponbalance_one")
        net.WriteString(wepclass)
        LuctusWbSendTable(wepTable)
    net.SendToServer()
end

function LuctusAddToBalanceList(attrlist,wepTable,history,prefix)
    --SortedPairs only works for non-int tables, but some are mixed, so:
    local loopFunc = SortedPairs
    if table.Count(wepTable) ~= #wepTable then
        loopFunc = pairs
    end
    for k,v in loopFunc(wepTable) do
        if k == "BaseClass" then continue end
        if string.find(k,"ActivityTranslate") then continue end
        if isfunction(v) then continue end
        if istable(v) then
            table.insert(history,k)
            LuctusAddToBalanceList(attrlist,v,history,k.." - ")
            table.RemoveByValue(history,k)
            continue
        end
        local item = vgui.Create("DTextEntry", attrlist)
        item:SetText("")
        item.Paint = function( me, w, h )
            draw.RoundedBox(0,0,0,300,1,color_white)
        end
        local label = vgui.Create("DLabel", item)
        label:Dock(LEFT)
        label:SetText(prefix..k)
        label:SetWide(150)
        local field = vgui.Create("DTextEntry", item)
        field:Dock(RIGHT)
        field:SetWide(150)
        field:SetDrawLanguageID(false)
        field.history = table.Copy(history)
        field.key = k
        field.orig_value = v
        field:DockMargin(0,0,5,0)
        field:SetText(tostring(v))
        function field:OnChange()
            if self:GetText() != tostring(self.orig_value) then
                self:SetTextColor(Color(255,0,0))
            else
                self:SetTextColor(Color(0,0,0))
            end
        end
        item.textfield = field
        item.label = label
        attrlist:AddItem(item)
        table.insert(current_weapon_fields,item)
    end
end

net.Receive("luctus_weaponbalance_one",function()
    local name = net.ReadString()
    local tab = LuctusWbReceiveTable()
    LuctusWbBalanceWeapon(name,tab)
end)

net.Receive("luctus_weaponbalance_getall",function()
    print("[luctus_wepbalance] Received init data")
    local allweptable = LuctusWbReceiveTable()
    for k,v in pairs(allweptable) do
        LuctusWbBalanceWeapon(k,v)
    end
end)

net.Receive("luctus_weaponbalance_reset",function(len,ply)
    local wepclass = net.ReadString()
    LuctusWbResetWeapon(wepclass)
end)

hook.Add("InitPostEntity","luctus_weaponbalance",function()
    net.Start("luctus_weaponbalance_getall")
    net.SendToServer()
end)

print("[luctus_wepbalance] cl loaded")
