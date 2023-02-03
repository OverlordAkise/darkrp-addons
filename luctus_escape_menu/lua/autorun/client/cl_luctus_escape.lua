--Luctus Escape Menu
--Made by OverlordAkise


-- text left
local SERVERNAME = "EternityRP - Your place for fun"
--text right
local EXTRA_TEXT = "Check it out at https://github.com/OverlordAkise"
--buttons
local ESC_BUTTONS = {
    {"Continue", function() ToggleEscapeMenu() end},
    {"Forums", function() gui.OpenURL("https://duckduckgo.com/") end},
    {"Collection", function() gui.OpenURL("https://duckduckgo.com/") end},
    {"Donate", function() gui.OpenURL("https://duckduckgo.com/") end},
    {"Disconnect", function() RunConsoleCommand("disconnect") end},
}

background_color = Color(0,0,0,150)
button_color = Color(40, 40, 40)
text_color = Color(0, 195, 165)
button_hover_color = Color(0, 195, 165)
text_hover_color = Color(40, 40, 40)

--CONFIG END

surface.CreateFont("EscapeFont", {font = "Arial", size = 20, weight = 400})

local ESCAPE_FRAME = nil

local blur = Material('pp/blurscreen')
function draw.Blur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	local scrW, scrH = ScrW(), ScrH()
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat('$blur', (i / 3) * (amount or 6))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, scrW, scrH)
	end
end

hook.Add("PreRender", "luctus_escape_menu", function()
	if input.IsKeyDown(KEY_ESCAPE) and gui.IsGameUIVisible() then
        gui.HideGameUI()
        ToggleEscapeMenu()
	end
end)

function ToggleEscapeMenu()
	if IsValid(ESCAPE_FRAME) and ESCAPE_FRAME:IsVisible() then 
		ESCAPE_FRAME:SetVisible(false)
		return
	elseif IsValid(ESCAPE_FRAME) and ESCAPE_FRAME:IsVisible() then
		ESCAPE_FRAME:SetVisible(true) 
		return
	end

	ESCAPE_FRAME = vgui.Create("DPanel")
	ESCAPE_FRAME:SetSize(ScrW(), ScrH())
	ESCAPE_FRAME:MakePopup()
	ESCAPE_FRAME.Paint = function(self, w, h)
		draw.Blur(self, 10)
        surface.SetDrawColor(background_color)
        surface.DrawRect(0, 0, w, h)
	end
    
    local y_offset = ScrH()-107-(#ESC_BUTTONS*30)

	for k, v in ipairs(ESC_BUTTONS) do
		local btn = vgui.Create('DButton', ESCAPE_FRAME)
		btn:SetPos(20, y_offset + k*30)
		btn:SetSize(ScrW() * .25, 27)
		btn:SetText("")
		btn.Name = (v[1] or 'ERROR'):upper()
		btn.DoClick = v[2]
		btn.Paint = function(self, w, h)
            surface.SetDrawColor(self.Hovered and button_hover_color or button_color)
            surface.DrawRect(0, 0, w, h)
			draw.SimpleText(self.Name, 'EscapeFont', 5, self:GetTall() * .5, self.Hovered and text_hover_color or text_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		end
	end
    

	local bar = vgui.Create('DPanel', ESCAPE_FRAME)
	bar:SetPos(20, ScrH() - 57)
	bar:SetSize(ScrW() - 40, 27)
	bar.Paint = function(self, w, h)
        surface.SetDrawColor(button_color)
        surface.DrawRect(0, 0, w, h)
		draw.SimpleText(SERVERNAME, 'EscapeFont', 5, self:GetTall() * .5, text_color, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
		draw.SimpleText(EXTRA_TEXT, "EscapeFont", self:GetWide() - 5, self:GetTall() * .5, text_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER) 
	end
end

print("[luctus_escape] cl loaded!")
