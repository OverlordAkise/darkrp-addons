--Luctus Leaderboard
--Made by OverlordAkise

net.Receive("luctus_leaderboard_menu",function()
    LuctusLeaderboardMenu(net.ReadTable())
end)

local accent_col = Color(0, 195, 165)
local lbFrame = nil
local leaderboardList = nil
local color_red = Color(255,0,0)
local color_white = Color(255,255,255)
local color_black = Color(32, 34, 37)

local function LuctusPrettifyScrollbar(el)
    function el:Paint() return end
    function el.btnGrip:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)

    end
    function el.btnUp:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
    end
    function el.btnDown:Paint(w, h)
        draw.RoundedBox(0,0,0,w,h,accent_col)
        draw.RoundedBox(0, 1, 1, w-2, h-2, color_black)
    end
end

function DrawHighlightBorder(el,w,h,col)
    surface.SetDrawColor(col)
    surface.DrawLine(0,0,w,0)
    surface.DrawLine(w-1,0,w-1,h-1)
    surface.DrawLine(w-1,h-1,0,h-1)
    surface.DrawLine(0,h-1,0,0)
end

function LuctusLeaderboardMenu(tab)
    if table.IsEmpty(tab) then return end
    if IsValid(lbFrame) then 
        lbFrame:Close()
    end
    
    lbFrame = vgui.Create("DFrame")
    lbFrame:SetSize(600, 400)
    lbFrame:Center()
    lbFrame:SetTitle("Luctus | Leaderboards")
    lbFrame:SetDraggable(true)
    lbFrame:ShowCloseButton(false)
    lbFrame:MakePopup()
    function lbFrame:Paint(w,h)
        draw.RoundedBox(0, 0, 0, w, h, color_black)
        draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(54, 57, 62))
    end

    local parent_x, parent_y = lbFrame:GetSize()
    local CloseButton = vgui.Create( "DButton", lbFrame )
    CloseButton:SetPos( parent_x-26, 1 )
    CloseButton:SetSize( 25, 25 )
    CloseButton:SetText("X")
    CloseButton:SetTextColor(color_red)
    CloseButton.DoClick = function()
        lbFrame:Close()
    end
    CloseButton.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(47, 49, 54))
        if self.Hovered then
            draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
        end
    end
    
    local leftPanel = vgui.Create("DPanel", lbFrame)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(150)
    leftPanel:DockMargin(5,5,5,5)
    leftPanel:SetPaintBackground(false)
    
    local categoryButtons = vgui.Create("DScrollPanel", leftPanel)
    categoryButtons:Dock(FILL)
    LuctusPrettifyScrollbar(categoryButtons:GetVBar())
    
    local mainPanel = vgui.Create("DPanel", lbFrame)
    mainPanel:Dock(FILL)
    mainPanel:SetPaintBackground(false)
    
    leaderboardList = vgui.Create("DListView",mainPanel)
    leaderboardList:Dock(FILL)
    leaderboardList:AddColumn("name")
    leaderboardList:AddColumn("score")
    for k,v in pairs(leaderboardList.Columns) do
        v.Header:SetTextColor(accent_col)
        v.Header.Paint = function(self,w,h)
            draw.RoundedBox(0, 0, 0, w, h, Color(27, 29, 34))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
        end
    end
    for k,board in pairs(tab) do
        local skillBut = vgui.Create("DButton",categoryButtons)
        skillBut.board = board
        skillBut:Dock(TOP)
        skillBut:SetSize(CategoryWidth, 30)
        skillBut:SetCursor("hand")
        skillBut:SetText("")
        skillBut.Paint = function(self, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(44, 47, 52))
            if self.Hovered then
                draw.RoundedBox(0, 0, 0, w, h, Color(66, 70, 77))
            end
            if mainPanel.board == self.board then
                DrawHighlightBorder(self,w,h,accent_col)
            end
            draw.DrawText(self.board, "Trebuchet18", 10, 7, color_white)
        end
        skillBut.DoClick = function(self)
            mainPanel.board = self.board
            LuctusLeaderboardGetBoard(self.board)
        end
    end
end

function LuctusLeaderboardGetBoard(board)
    net.Start("luctus_leaderboard_data")
        net.WriteString(board)
    net.SendToServer()
end

net.Receive("luctus_leaderboard_data",function()
    local tab = net.ReadTable()
    if not IsValid(leaderboardList) then return end
    leaderboardList:Clear()
    for k,v in pairs(tab) do
        leaderboardList:AddLine(v[1],v[2])
    end
end)

print("[luctus_leaderboard] cl loaded")
