--Luctus Safezones
--Made by OverlordAkise

local white = color_white
local black = Color(0,0,0,255)

net.Receive("luctus_safezone",function()
  local toggle = net.ReadBool()
  if toggle then
    local w, h = ScrW(), ScrH()
    hook.Add("HUDPaintBackground", "luctus_safezone_display", function()
      draw.SimpleTextOutlined(LUCTUS_SAFEZONE_TEXT, "DermaLarge", w/2, h/4, white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, black )
    end)
  else
    hook.Remove("HUDPaintBackground", "luctus_safezone_display")
  end
end)

print("[luctus_safezones] CL loaded!")
