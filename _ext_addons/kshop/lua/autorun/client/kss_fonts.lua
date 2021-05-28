surface.CreateFont("ks1", {
	font = "Roboto",
	extended = false,
	size = 25,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("ks2", {
	font = "Roboto",
	extended = false,
	size = 13,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("ks3", {
	font = "Roboto",
	extended = false,
	size = 20,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("ks4", {
	font = "Roboto",
	extended = false,
	size = 60,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("ks5", {
	font = "Roboto",
	extended = false,
	size = 128,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont("ks6", {
	font = "Roboto",
	extended = false,
	size = 40,
	weight = 500,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

local PANEL = {}
function PANEL:Init()
    self:SetColor( Color(255,255,255) )
end
function PANEL:Paint( w, h )
    draw.RoundedBox( 3, 0, 0, w, h, Color( 75, 72, 69, 40 ) )
    draw.RoundedBox( 3, 0, 0, w, h, Color( 255, 255, 255, 20 ) )
end

function PANEL:OnCursorEntered()
    function self:Paint( w, h )
        draw.RoundedBox( 3, 0, 0, w, h, Color( 70, 155, 70, 225 ) )
    end
end

function PANEL:OnCursorExited()
    function self:Paint( w, h )
        draw.RoundedBox( 3, 0, 0, w, h, Color( 75, 72, 69, 40 ) )
        draw.RoundedBox( 3, 0, 0, w, h, Color( 255, 255, 255, 20 ) )
    end
end
vgui.Register( "KShop_Button", PANEL, "DButton" )
