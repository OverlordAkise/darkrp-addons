--Luctus Aktensystem
--Made by OverlordAkise

luctus_aktensys_windows = luctus_aktensys_windows or {}

function LuctusAktensysUnfocusAllWindows()
    --gui.EnableScreenClicker(false)
    for pnl,n in pairs(luctus_aktensys_windows) do
        if not IsValid(pnl) then
            luctus_aktensys_windows[pnl] = nil
            continue
        end
        pnl:SetMouseInputEnabled(false)
        pnl:SetKeyboardInputEnabled(false)
    end
    hook.Add("KeyPress","luctus_aktensys_focusagain",function(ply,key)
        if key ~= IN_WALK then return end
        --gui.EnableScreenClicker(true)
        for pnl,n in pairs(luctus_aktensys_windows) do
            if not IsValid(pnl) then
                luctus_aktensys_windows[pnl] = nil
                continue
            end
            pnl:SetMouseInputEnabled(true)
            pnl:SetKeyboardInputEnabled(true)
            pnl:RequestFocus()
        end
        hook.Remove("KeyPress","luctus_aktensys_focusagain")
    end)
end

--For adding new frames to windows cache automatically, see 2nd last line
local function createDFrame(title,w,h)
    local win = vgui.Create("DFrame")
    win:SetTitle(title)
    win:SetSize(w,h)
    win:SetSizable(true)
    win:Center()
    win:MakePopup()
    function win:OnKeyCodePressed(but)
        if but == KEY_LALT then
            LuctusAktensysUnfocusAllWindows()
        end
    end
    luctus_aktensys_windows[win] = true
    return win
end

local function addUnfocusKeybind(el)
    function el:OnKeyCode(button)
        if button == KEY_LALT then
            LuctusAktensysUnfocusAllWindows()
        end
    end
end

local function onPlyRowClick(self,lineid,line)
    local steamid = line:GetColumnText(2)
    local jobcmd = line:GetColumnText(3)
    local menu = DermaMenu()
    menu:AddOption("View reports", function()
        net.Start("luctus_aktensys_getply")
            net.WriteString(steamid)
            net.WriteString(jobcmd)
        net.SendToServer()
    end)
    menu:AddOption("Create report", function() LuctusAktensysOpenCreateMenu(steamid) end)
    
    local subMenu, parent = menu:AddSubMenu("Copy...")
    parent:SetIcon("icon16/page_edit.png")
    subMenu:AddOption("Name", function() SetClipboardText(line:GetColumnText(1)) end)
    subMenu:AddOption("SteamID", function() SetClipboardText(steamid) end)
    subMenu:AddOption("Job", function() SetClipboardText(jobcmd) end)
    
    menu:Open()
end

local function onReportRowClick(self,lineid,line)
    local rowid = line:GetColumnText(1)
    local menu = DermaMenu()
    menu:AddOption("View report", function() net.Start("luctus_aktensys_getreport") net.WriteInt(rowid,32) net.SendToServer() end)
    if LuctusAktensysIsAdmin(LocalPlayer()) or line:GetColumnText(5) == LocalPlayer():SteamID() then
        menu:AddOption("Edit (add to) report", function() LuctusAktensysOpenAddToMenu(rowid) end)
    end
    menu:AddOption("Delete report", function() 
        Derma_Query("Really delete report #"..rowid.." ?", "Aktensys | confirmation", "Yes", function() 
            net.Start("luctus_aktensys_delete")
                net.WriteInt(rowid,32)
            net.SendToServer()
        end, "No", function()end)
    end)
    
    local subMenu, parent = menu:AddSubMenu("Copy...")
    parent:SetIcon("icon16/page_edit.png")
    subMenu:AddOption("ID", function() SetClipboardText(line:GetColumnText(1)) end)
    subMenu:AddOption("Date", function() SetClipboardText(line:GetColumnText(2)) end)
    subMenu:AddOption("Job", function() SetClipboardText(line:GetColumnText(3)) end)
    subMenu:AddOption("Creator", function() SetClipboardText(line:GetColumnText(4)) end)
    subMenu:AddOption("CreatorSID", function() SetClipboardText(line:GetColumnText(5)) end)
    subMenu:AddOption("Summary", function() SetClipboardText(line:GetColumnText(6)) end)

    menu:Open()
end

function LuctusAktensysOpenMenu()
    local frame = createDFrame(LUCTUS_AKTENSYS_TITLE.." | v1.0",500,600)

    local liste = vgui.Create("DListView",frame)
    liste:Dock(FILL)
    liste:SetMultiSelect(false)
    liste:AddColumn("Name"):SetWidth(200)
    liste:AddColumn("SteamID"):SetWidth(150)
    liste:AddColumn("Job"):SetWidth(150)
    liste.DoDoubleClick = onPlyRowClick
    liste.OnRowRightClick = onPlyRowClick

    for k,ply in ipairs(player.GetAll()) do
        liste:AddLine(ply:Nick(),ply:SteamID(),RPExtraTeams[ply:Team()].command)
    end
    
    local b = vgui.Create("DButton",frame)
    b:Dock(BOTTOM)
    b:SetText("Search Offline Player")
    function b:DoClick()
        Derma_StringRequest(LUCTUS_AKTENSYS_TITLE.." | search for steamid", "Please enter steamid of player to request reports for", "-", function(sid)
            if not string.match(sid,"^STEAM_%d:%d:%d+$") then
                Derma_Message("Please enter a valid steamid!", LUCTUS_AKTENSYS_TITLE.." | error", "OK" )
                return
            end
            net.Start("luctus_aktensys_getply") 
                net.WriteString(sid)
                net.WriteString("")
            net.SendToServer()
        end, function()end, "Search")
    end
    local b = vgui.Create("DButton",frame)
    b:Dock(BOTTOM)
    b:SetText("Create report for offline player")
    function b:DoClick()
        Derma_StringRequest(LUCTUS_AKTENSYS_TITLE.." | create report for steamid", "Please enter steamid of player to report", "-", function(sid)
            if not string.match(sid,"^STEAM_%d:%d:%d+$") then
                Derma_Message("Please enter a valid steamid!", LUCTUS_AKTENSYS_TITLE.." | error", "OK" )
                return
            end
            LuctusAktensysOpenCreateMenu(sid)
        end, function()end, "Search")
    end
    
end

function LuctusAktensysOpenPlyMenu(tab)
    local plyName = "// NO REPORTS FOUND //"
    if tab[1] then
        plyName = "reports for "..tab[1].plyName
    end
    local frame = createDFrame(plyName,800,600)
    --tab. = rowid,date,plyName,plyJobc,creatorName,summary
    local list = vgui.Create("DListView",frame)
    list:Dock(FILL)
    list:SetMultiSelect(false)
    list:AddColumn("ID"):SetWidth(20)
    list:AddColumn("Date")
    list:AddColumn("Job")
    list:AddColumn("Creator")
    list:AddColumn("CreatorSID")
    list:AddColumn("Summary")
    list.DoDoubleClick = onReportRowClick
    list.OnRowRightClick = onReportRowClick
    for k,l in ipairs(tab) do
        list:AddLine(l.rowid, l.date, l.plyJobc, l.creatorName, l.creatorSID, l.summary)
    end
end

local function createLabelEntry(parent,label,entry)
    local l = vgui.Create("DLabel",parent) l:Dock(TOP) l:SetText(label)
    local t = vgui.Create("DTextEntry",parent) t:Dock(TOP) t:SetText(entry) t:SetDrawLanguageID(false)
end
function LuctusAktensysOpenReportMenu(row)
    local frame = createDFrame("Report #"..row.rowid,800,600)
    --rowid,date, plySID, plyName, plyJobc, creatorName, creatorSID, summary, fulltext
    createLabelEntry(frame,"Date",row.date)
    createLabelEntry(frame,"Summary",row.summary)
    createLabelEntry(frame,"Creator",row.creatorName.." ("..row.creatorSID..")")
    createLabelEntry(frame,"Subject","'"..row.plyName.."' as '"..row.plyJobc.."' ("..row.creatorSID..")")
    local l = vgui.Create("DLabel",frame) l:Dock(TOP) l:SetText("Report:")
    local descText = vgui.Create("DTextEntry",frame)
    descText:Dock(FILL)
    descText:SetDrawLanguageID(false)
    descText:SetMultiline(true)
    descText:SetText(row.fulltext)
end

function LuctusAktensysOpenCreateMenu(steamid,jobcommand)
    local ply = player.GetBySteamID(steamid)
    local name = ply and ply:Nick() or "<OFFLINE>"
    local jobname = ply and RPExtraTeams[ply:Team()].command or jobcommand
    local frame = createDFrame("create report for "..steamid,500,600)
    local jobDropdown
    if not jobname then
        jobDropdown = vgui.Create("DComboBox",frame)
        jobDropdown:Dock(TOP)
        for k,job in pairs(RPExtraTeams) do
            jobDropdown:AddChoice(job.command)
        end
        jobDropdown:SetValue("<please select targets job at the time>")
    end
    --fields for: summary, body
    local summaryLabel = vgui.Create("DLabel",frame)
    summaryLabel:Dock(TOP)
    summaryLabel:SetText("Summary / Headline")
    local summaryText = vgui.Create("DTextEntry",frame)
    summaryText:Dock(TOP)
    summaryText:SetDrawLanguageID(false)
    summaryText:SetPlaceholderText("Put your short summary here")
    summaryText:SetText(tab and tab.summary or "")
    function summaryText:OnKeyCode(button)
        if button == KEY_LALT then
            LuctusAktensysUnfocusAllWindows()
        end
    end
    local descLabel = vgui.Create("DLabel",frame)
    descLabel:Dock(TOP)
    descLabel:SetText("Content")
    local descText = vgui.Create("DTextEntry",frame)
    descText:Dock(FILL)
    descText:SetDrawLanguageID(false)
    descText:SetMultiline(true)
    descText:SetPlaceholderText("")
    descText:SetText(tab and tab.fulltext or LUCTUS_AKTENSYS_PAPER_TEMPLATE)
    addUnfocusKeybind(descText)
    local saveButton = vgui.Create("DButton",frame)
    saveButton:SetText("Submit report")
    saveButton:Dock(BOTTOM)
    function saveButton:DoClick()
        local psummary = summaryText:GetText()
        local pcontent = descText:GetText()
        if psummary == "" or pcontent == "" then
            Derma_Message("Please fill in every field!", LUCTUS_AKTENSYS_TITLE.." | error", "OK")
            return
        end
        local jname = jobname
        if not jobname then
            local j,_ = jobDropdown:GetSelected()
            if not j then
                Derma_Message("Please select a job!", LUCTUS_AKTENSYS_TITLE.." | error", "OK")
                return
            end
            jname = j
        end
        net.Start("luctus_aktensys_save")
        net.WriteString(steamid)
        net.WriteString(name)
        net.WriteString(jname)
        net.WriteString(psummary)
        local a = util.Compress(pcontent)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
        net.SendToServer()
        
        frame:Close()
    end
end

function LuctusAktensysOpenAddToMenu(rowid)
    local frame = createDFrame("add to report #"..rowid,500,600)
    local descLabel = vgui.Create("DLabel",frame)
    descLabel:Dock(TOP)
    descLabel:SetText("Addition:")
    local descText = vgui.Create("DTextEntry",frame)
    descText:Dock(FILL)
    descText:SetDrawLanguageID(false)
    descText:SetMultiline(true)
    descText:SetPlaceholderText("")
    descText:SetText(tab and tab.fulltext or LUCTUS_AKTENSYS_PAPER_TEMPLATE)
    addUnfocusKeybind(descText)
    local saveButton = vgui.Create("DButton",frame)
    saveButton:SetText("Add to report")
    saveButton:Dock(BOTTOM)
    function saveButton:DoClick()
        local pcontent = descText:GetText()
        if pcontent == "" then
            Derma_Message("Please add text!", LUCTUS_AKTENSYS_TITLE.." | error", "OK")
            return
        end
        net.Start("luctus_aktensys_edit")
        net.WriteInt(rowid,32)
        local a = util.Compress(pcontent)
        net.WriteInt(#a,17)
        net.WriteData(a,#a)
        net.SendToServer()
        
        frame:Close()
    end
end


hook.Add("PlayerButtonDown","luctus_aktensys_open",function(ply,button)
    if ply ~= LocalPlayer() then return end
    if not LUCTUS_AKTENSYS_ALLOWED_JOBS[team.GetName(LocalPlayer():Team())] and not LUCTUS_AKTENSYS_ADMINS[LocalPlayer():GetUserGroup()] then return end
    if button ~= LUCTUS_AKTENSYS_OPEN_BIND then return end
    RunConsoleCommand("say",LUCTUS_AKTENSYS_CHAT_COMMAND)
end)


net.Receive("luctus_aktensys",LuctusAktensysOpenMenu)

net.Receive("luctus_aktensys_getply",function()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    if tab == nil then return end
    LuctusAktensysOpenPlyMenu(tab)
end)

net.Receive("luctus_aktensys_getreport",function()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    if tab == nil then return end
    LuctusAktensysOpenReportMenu(tab)
end)

net.Receive("luctus_aktensys_getid",function(len,ply)
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    if tab == nil then return end
    luctusOpenPaperWindow(tab)
end)


print("[luctus_aktensys] cl loaded")
