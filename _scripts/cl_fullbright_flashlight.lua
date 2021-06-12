--Luctus Fullbright Flashlight
--Idea & Code Made by BB Skill Surf
--ConVar and local toggle command added by OverlordAkise

local flashEnabled = false

CreateClientConVar("luctus_fullbright", "0", true, false, "Toggles fullbright mode, making the whole map light up like a christmas tree", 0, 1)

cvars.AddChangeCallback("luctus_fullbright", function(convar_name, value_old, value_new)
  if value_new == "0" then
    flashEnabled = false
  end
  if value_new == "1" then
    flashEnabled = true
  end
end)

hook.Add("OnPlayerChat","luctus_fullbright",function(ply,text,team,bdead)
  if ply == LocalPlayer() and text == "!togglebright" then
    if flashEnabled then
      RunConsoleCommand("luctus_fullbright","0")
    else
      RunConsoleCommand("luctus_fullbright","1")
    end
  end
end)


hook.Add( "PreRender", "platflash", function()
	if !flashEnabled then
		render.SetLightingMode(0)
		return
	end
	render.SetLightingMode(1)
	render.SuppressEngineLighting(false)
end)

hook.Add("PostRender", "platflash", function()
	render.SetLightingMode(0)
	render.SuppressEngineLighting(false)
end)

hook.Add("PreDrawHUD", "FixFullbrightOnHUD", function()
	render.SetLightingMode(0)
end)

hook.Add("PreDrawEffects", "FixFullbrightOnEffects", function()
	if !flashEnabled then return end
	render.SetLightingMode(0)
end)

hook.Add("PostDrawEffects", "FixFullbrightOnEffects", function()
	if !flashEnabled then return end
	render.SetLightingMode(0)
end)

hook.Add( "PreDrawOpaqueRenderables", "FixFullbrightOpaqueRenderables", function(boolDrawingDepth, boolDrawingSkybox)
	if !flashEnabled then return end
	render.SetLightingMode(0)
end)

hook.Add("PreDrawSkyBox", "ImproveSkyboxFlickering", function()
	if !flashEnabled then return end
end)

hook.Add( "SetupWorldFog", "ForceFullbrightWorld", function()
	if !flashEnabled then
		return 
	end
	render.SuppressEngineLighting(true)
	render.SetLightingMode(1)
	render.SuppressEngineLighting(false)
end)

hook.Add("PostDrawTranslucentRenderables", "FixFullbrightOnTranslucentRenders", function(boolDrawingDepth, boolDrawingSkybox)
	if !flashEnabled then return end
	render.SetLightingMode(0)
end)
