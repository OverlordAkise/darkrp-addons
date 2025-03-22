--Luctus Scoreboard
--Made by OverlordAkise

local LUCTUS_SCOREBOARD_NAME = "Luctus RP"
local LUCTUS_SCOREBOARD_WEBSITE = "https://mistforums.com/"

--Custom colors and names for groups
local cgroups = {
    ["superadmin"] = { "Super Administrator", Color( 199, 44, 44 ) },
    ["developer"] = { "Developer", Color( 199, 44, 44 ) },
    ["admin"] = { "Administrator", Color( 241, 196, 15 ) },
    ["moderator"] = { "Moderator", Color( 52, 152, 219 ) },
    ["donator"] = { "Donator", Color( 155, 89, 182 ) },
    ["vip"] = { "VIP", Color( 155, 89, 182 ) }
}

rank_categories = {
    {"41st Elite Corps",Color(255,0,0),{
        ["Citizen"] = true,
    }},
    {"104th Battalion",Color(255,255,0),{
        
    }},
    {"14th Infanterie Brigade",Color(0,255,0),{
        
    }},
    {"Stoßtruppen",Color(0,255,255),{
        
    }},
    {"Republic Navy",Color(0,0,255),{
        
    }}
}

--Rightclick options for players
local scoreboard_admin_options = {
    ["Open Profile"] = function(v)  gui.OpenURL("https://steamcommunity.com/profiles/"..v:SteamID64()) end,
    ["copy steamid"] = function(v) SetClipboardText(v:SteamID()) end,
    ["copy steamid64"] = function(v) SetClipboardText(v:SteamID64()) end,
    ["sam bring"] = function(v) RunConsoleCommand("sam", "bring", v:Nick()) end,
    ["sam return"] = function(v) RunConsoleCommand("sam", "return", v:Nick()) end,
    ["sam freeze"] = function(v) RunConsoleCommand("sam", "freeze", v:Nick()) end,
    ["sam unfreeze"] = function(v) RunConsoleCommand("sam", "unfreeze", v:Nick()) end,
    ["sam jail"] = function(v) RunConsoleCommand("sam", "jail", v:Nick()) end,
    ["sam unjail"] = function(v) RunConsoleCommand("sam", "unjail", v:Nick()) end,
    ["sam spectate"] = function(v) RunConsoleCommand("sam", "spectate", v:Nick()) end,
}

--------------------------
-- End of configuration --
--------------------------

local ScoreFrame = nil
  

surface.CreateFont( "LuctusScoreFontBig", { font = "Montserrat", size = 35, weight = 800, antialias = true, bold = true })
surface.CreateFont( "LuctusScoreFontSmall", { font = "Montserrat", size = 20, weight = 700, antialias = true, bold = true })


local function surfaceDrawRectCol( x, y, w, h, col )
    surface.SetDrawColor( col )
    surface.DrawRect( x, y, w, h )
end

local function BeautifyScrollbar(el)
    local sbar = el.VBar
    function sbar:Paint( w, h )
        surfaceDrawRectCol( 0, 0, w, h, Color( 0, 0, 0, 100 ) )
    end
    function sbar.btnUp:Paint( w, h )
        surfaceDrawRectCol( 0, 0, w, h, Color( 44, 44, 44 ) )
    end
    function sbar.btnDown:Paint( w, h )
        surfaceDrawRectCol( 0, 0, w, h, Color( 44, 44, 44 ) )
    end
    function sbar.btnGrip:Paint( w, h )
        surfaceDrawRectCol( 0, 0, w, h, Color( 56, 56, 56 ) )
    end
end

local function RemoveScrollbar(el)
    local sbar = el.VBar
    function sbar:Paint( w, h )
    end
    function sbar.btnUp:Paint( w, h )
    end
    function sbar.btnDown:Paint( w, h )
    end
    function sbar.btnGrip:Paint( w, h )
    end
end

local function CreateScoreboard()
    if ScoreFrame then ScoreFrame:Close() end
    ScoreFrame = vgui.Create( 'DFrame' )
    ScoreFrame:SetSize( 1200, 700 )
    ScoreFrame:SetTitle("")
    ScoreFrame:SetDraggable( false )
    ScoreFrame:SetVisible( true )
    ScoreFrame:ShowCloseButton( false )
    ScoreFrame:Center()
    gui.EnableScreenClicker( true )
    ScoreFrame.Paint = function( self, w, h )
        surfaceDrawRectCol(0, 0, w, h, Color(0,0,0))
        surfaceDrawRectCol(1, 1, w-2, h-2, Color(32, 34, 37, 255))
        surfaceDrawRectCol(10, 73, w - 20, 30, Color(34, 34, 34, 150))
        draw.DrawText(LUCTUS_SCOREBOARD_NAME, "LuctusScoreFontBig", w / 2, 5, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER)
        draw.DrawText("There are currently " .. #player.GetAll() .. " player(s) online.", "LuctusScoreFontSmall", w / 2, h - 21, Color(255,255,255,255), TEXT_ALIGN_CENTER)
    end

    local website = vgui.Create("DLabel", ScoreFrame)
    surface.SetFont("LuctusScoreFontSmall")
    local offsetX, offsetY = surface.GetTextSize(LUCTUS_SCOREBOARD_WEBSITE)
    website:SetPos(ScoreFrame:GetWide() / 2 - (offsetX/2), 45)
    website:SetSize(offsetX, offsetY)
    website:SetFont("LuctusScoreFontSmall")
    website:SetTextColor(Color(0, 195, 165))
    website:SetText(LUCTUS_SCOREBOARD_WEBSITE)
    website:SetCursor("hand")
    website:SetMouseInputEnabled( true )
    website.OnMousePressed = function()
        gui.OpenURL(LUCTUS_SCOREBOARD_WEBSITE)
    end
    
    local headlines = vgui.Create("DPanel", ScoreFrame)
    headlines:SetSize(ScoreFrame:GetWide() - 20, 20)
    headlines:SetPos(10,80)
    function headlines:Paint(w,h) end

    ScoreFrame.PlayerList = vgui.Create("DListLayout", ScoreFrame)
    ScoreFrame.PlayerList:SetSize(ScoreFrame:GetWide() - 20, ScoreFrame:GetTall() - 120)
    ScoreFrame.PlayerList:SetPos(10, 100)
    ScoreFrame.PlayerList.Paint = function( me, w, h )
        surfaceDrawRectCol( 0, 0, w, h, Color( 26, 26, 26, 200 ) )
    end
    
    local CategoryWidth = ScoreFrame.PlayerList:GetWide()/table.Count(rank_categories)
    for nr,cat in pairs(rank_categories) do
        local name = cat[1]
        ScoreFrame[name] = ScoreFrame.PlayerList:Add("DScrollPanel")
        ScoreFrame[name]:Dock(LEFT)
        ScoreFrame[name]:SetHeight(ScoreFrame:GetTall() - 100)
        ScoreFrame[name]:DockPadding(3,0,0,0)
        ScoreFrame[name]:SetWide(CategoryWidth)
        BeautifyScrollbar(ScoreFrame[name])
        --ScoreFrame[name].Paint = function(self,w,h)
        --    surfaceDrawRectCol( 0, 0, CategoryWidth, 18, cat[2])
        --end
        
        
        local CatName = vgui.Create("DButton", headlines)
        CatName:Dock(LEFT)
        CatName:SetText(name)
        CatName:SetWide(CategoryWidth)
        CatName:SetColor(cat[2])
        CatName:SetCursor("pointer")
        CatName.Paint = function(self,w,h)
            surfaceDrawRectCol(0, 0, w, h-1, Color(44, 47, 52))
            surfaceDrawRectCol(0, h-1, w, 1, cat[2])
        end
    end
    --[[local aa = {}
    for i=1,30 do
        table.insert(aa,LocalPlayer())
    end--]]
    for k,v in pairs(player.GetAll()) do
        local cat = nil
        for nr,val in pairs(rank_categories) do
            local jobs = val[3]
            local name = val[1]
            if jobs[v:getJobTable().name] then
                cat = name
            end
        end
        if not cat then return end
        
        local item = ScoreFrame[cat]:Add("DButton")
        item:Dock(TOP)
        item:SetSize(CategoryWidth, 30)
        item:SetCursor("hand")
        item:SetText("")
        --local teamCol = team.GetColor( v:Team() )

        item.Paint = function(me, w, h)
            if !IsValid(v) then item:Remove() return end
            if k % 2 == 0 then
                surfaceDrawRectCol( 0, 0, w, h, Color(54, 57, 62) )
            else
                surfaceDrawRectCol( 0, 0, w, h, Color(44, 47, 52) )
            end
            draw.DrawText(v:Nick(), "Trebuchet18", 10, 7, Color(255,255,255))
        end
        item.ply = v
        item.DoRightClick = function()
            if IsValid( Inspect ) then
                Inspect:Remove()
            end
            Inspect = DermaMenu()
            for k,v in SortedPairs(scoreboard_admin_options) do
                Inspect:AddOption(k)
            end
            function Inspect:OptionSelected(option, optionText)
                if scoreboard_admin_options[optionText] ~= nil then
                    scoreboard_admin_options[optionText](v)
                end
            end
            Inspect:Open()
        end
--[[
        local image = vgui.Create( "AvatarImage", item )
        image:SetSize( 28, 28 )
        image:SetPos( 1, 1 )
        image:SetPlayer( v, 32 )

        local mute = vgui.Create( "DImageButton", item )
        mute:SetSize( 16, 16 )
        mute:SetPos(item:GetWide() + 35, 7 )
        mute:SetImage( v:IsMuted() and 'icon16/sound_mute.png' or 'icon16/sound.png' )

        mute.DoClick = function()
            if !v:IsMuted() then v:SetMuted( true ) else v:SetMuted( false ) end
            mute:SetImage( v:IsMuted() and 'icon16/sound_mute.png' or 'icon16/sound.png' )
        end
--]]
        --ScoreFrame.PlayerList:AddItem( item )
    end
    ScoreFrame:SlideDown(0.2) 
end


hook.Add("ScoreboardShow", "luctus_create_scoreboard", function()
    CreateScoreboard()
    return true
end)

hook.Add("ScoreboardHide", "luctus_hide_scoreboard", function()
    if IsValid( ScoreFrame ) then 
        --ScoreFrame:SetVisible(false)
        ScoreFrame:SlideUp(0.2) 
        gui.EnableScreenClicker(false)
    end
    if IsValid( Inspect ) then Inspect:Remove() end
    return true
end)

-- Fix for removing default Scoreboard B-)
local function repairScoreboard()
    hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
    hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
    timer.Simple(3,function()
        hook.Remove("ScoreboardShow", "FAdmin_scoreboard")
        hook.Remove("ScoreboardHide", "FAdmin_scoreboard")
    end)
end

hook.Add("OnGamemodeLoaded", "luctus_override_FAdmin_scoreboard", repairScoreboard)
hook.Add("DarkRPFinishedLoading", "luctus_override_FAdmin_scoreboard", repairScoreboard)

print("[luctus_scoreboard] cl loaded")
