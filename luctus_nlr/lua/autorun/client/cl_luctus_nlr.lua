--Luctus NLR
--Made by OverlordAkise

net.Receive("luctus_nlr_greyscreen",function()
  local toggle = net.ReadBool()
  if toggle then
    local grey = Color(50, 50, 50, 210)
    local w, h = ScrW(), ScrH()
    hook.Add("HUDPaintBackground", "luctus_nlr_greyscreen", function()
      surface.SetDrawColor(grey)
      surface.DrawRect(0, 0, w, h)
      draw.SimpleTextOutlined(LUCTUS_NLR_TEXT, "DermaLarge", ScrW()/2, ScrH()/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color( 0, 0, 0, 255 ) )
    end)
  else
    hook.Remove("HUDPaintBackground", "luctus_nlr_greyscreen")
  end
end)

print("[luctus_nlr] CL loaded")
