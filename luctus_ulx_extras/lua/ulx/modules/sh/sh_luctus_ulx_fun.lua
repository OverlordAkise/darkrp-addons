--Luctus ULX Extras
--Made by OverlordAkise

local ulx_category_name = "Fun"

function ulx.launch(calling_ply, target_plys)
    for k,ply in ipairs(target_plys) do
        ply:SetVelocity(Vector(0, 0, 2500))
    end
    ulx.fancyLogAdmin(calling_ply, "#A launched #T", target_plys)
end
local launch = ulx.command(ulx_category_name, "ulx launch", ulx.launch, "!launch")
launch:addParam{type = ULib.cmds.PlayersArg}
launch:defaultAccess(ULib.ACCESS_ADMIN)
launch:help("Send players straight up very quickly")


function ulx.timescale(calling_ply, number, bReset)
    number = tonumber(number)
    number = math.Clamp(number,0.1,5)
    game.SetTimeScale(number)
    ulx.fancyLogAdmin(calling_ply, "#A set the game timescale to #i", number)
end
local timescale = ulx.command(ulx_category_name, "ulx timescale", ulx.timescale, "!timescale")
timescale:addParam{type = ULib.cmds.NumArg, default=1, hint="default=1"}
timescale:defaultAccess(ULib.ACCESS_SUPERADMIN)
timescale:help("Change the timescale of the server")


function ulx.gravity(calling_ply, target_plys, grav)
    for k,ply in ipairs(target_plys) do
        ply:SetGravity(grav)
    end
    ulx.fancyLogAdmin(calling_ply, "#A set the gravity for #T to #i", target_plys, grav)
end
local gravity = ulx.command(ulx_category_name, "ulx gravity", ulx.gravity, "!gravity")
gravity:addParam{type = ULib.cmds.PlayersArg}
gravity:addParam{type = ULib.cmds.NumArg, default=1,min=0,max=9999}
gravity:defaultAccess(ULib.ACCESS_SUPERADMIN)
gravity:help("Set the gravity multiplier of players (def:1)")


function ulx.runspeed(calling_ply, target_plys, amount)
    for k,ply in ipairs(target_plys) do
        ply:SetRunSpeed(amount)
        ulx.fancyLogAdmin(calling_ply, "#A set the runspeed for #T to #i", target_plys,amount)
    end
end
local runspeed = ulx.command(ulx_category_name, "ulx runspeed", ulx.runspeed, "!runspeed")
runspeed:addParam{type = ULib.cmds.PlayersArg}
runspeed:addParam{type = ULib.cmds.NumArg, default=240,min=0,max=9999}
runspeed:defaultAccess(ULib.ACCESS_ADMIN)
runspeed:help("Set the runspeed for players (def:240)")


function ulx.model(calling_ply, target_plys, model)
    for k,ply in ipairs(target_plys) do
        ply:SetModel(model)
    end
    ulx.fancyLogAdmin(calling_ply, "#A set the model for #T to #s", target_plys, model)
end
local model = ulx.command(ulx_category_name, "ulx model", ulx.model, "!model")
model:addParam{type = ULib.cmds.PlayersArg}
model:addParam{type = ULib.cmds.StringArg, hint = "model"}
model:defaultAccess(ULib.ACCESS_ADMIN)
model:help("Set the model of players")


function ulx.jumppower(calling_ply, target_plys, power)
    for k,ply in ipairs(target_plys) do
        ply:SetJumpPower(power)
    end
    ulx.fancyLogAdmin(calling_ply, "#A set the jumppower for #T to #s", target_plys, power)
end
local jumppower = ulx.command(ulx_category_name, "ulx jumppower", ulx.jumppower, "!jumppower")
jumppower:addParam{type = ULib.cmds.PlayersArg}
jumppower:addParam{type = ULib.cmds.NumArg, default=200, hint="jumppower, default=200"}
jumppower:defaultAccess(ULib.ACCESS_ADMIN)
jumppower:help("Set the jumpheight of players")


function ulx.scale(calling_ply, target_plys, scale)
    scale = math.Clamp(scale,0.01,60000)
    for k,ply in ipairs(target_plys) do
        ply:SetModelScale(scale, 0.1)
        ply:SetViewOffset(Vector(0,0,64*scale))
        ply:SetViewOffsetDucked(Vector(0,0,28*scale))
    end
    ulx.fancyLogAdmin(calling_ply, "#A set the scale for #T to #i", target_plys, scale)
end
local scale = ulx.command(ulx_category_name, "ulx scale", ulx.scale, "!scale")
scale:addParam{type = ULib.cmds.PlayersArg}
scale:addParam{type = ULib.cmds.NumArg, default=1, min=0, hint="scale multiplier"}
scale:defaultAccess(ULib.ACCESS_ADMIN)
scale:help("Set the height/scale of players")


local example_materials = {
    "models/wireframe",
    "debug/env_cubemap_model",
    "models/shadertest/shader3",
    "models/shadertest/shader4",
    "models/shadertest/shader5",
    "models/shiny",
    "models/debug/debugwhite",
    "Models/effects/comball_sphere",
    "Models/effects/comball_tape",
    "Models/effects/splodearc_sheet",
    "Models/effects/vol_light001",
    "models/props_combine/stasisshield_sheet",
    "models/props_combine/portalball001_sheet",
    "models/props_combine/com_shield001a",
    "models/props_c17/frostedglass_01a",
    "models/props_lab/Tank_Glass001",
    "models/props_combine/tprings_globe",
    "models/rendertarget",
    "models/screenspace",
    "brick/brick_model",
    "models/props_pipes/GutterMetal01a",
    "models/props_pipes/Pipesystem01a_skin3",
    "models/props_wasteland/wood_fence01a",
    "models/props_foliage/tree_deciduous_01a_trunk",
    "models/props_c17/FurnitureFabric003a",
    "models/props_c17/FurnitureMetal001a",
    "models/props_c17/paper01",
    "models/flesh",
    "phoenix_storms/metalset_1-2",
    "phoenix_storms/metalfloor_2-3",
    "phoenix_storms/plastic",
    "phoenix_storms/wood",
    "phoenix_storms/bluemetal",
    "phoenix_storms/cube",
    "phoenix_storms/dome",
    "phoenix_storms/gear",
    "phoenix_storms/stripes",
    "phoenix_storms/wire/pcb_green",
    "phoenix_storms/wire/pcb_red",
    "phoenix_storms/wire/pcb_blue",
    "hunter/myplastic"
}

function ulx.material(calling_ply, target_plys, material, bReset)
    if bReset then
        for k,ply in ipairs(target_plys) do
            ply:SetMaterial("")
        end
        ulx.fancyLogAdmin(calling_ply, "#A reset the material for #T", target_plys)
    else
        for k,ply in ipairs(target_plys) do
            ply:SetMaterial(material)
        end
        ulx.fancyLogAdmin(calling_ply, "#A set the material for #T to #s", target_plys, material)
    end
end
local material = ulx.command(ulx_category_name, "ulx material", ulx.material, "!material")
material:addParam{type = ULib.cmds.PlayersArg}
material:addParam{type = ULib.cmds.StringArg, hint="material", completes=example_materials}
material:addParam{type = ULib.cmds.BoolArg, invisible = true}
material:help("Set the material of player's models")
material:defaultAccess(ULib.ACCESS_ADMIN)
material:setOpposite("ulx resetmaterial", {_, _, _, true}, "!resetmaterial")
