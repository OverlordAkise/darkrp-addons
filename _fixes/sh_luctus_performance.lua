--Luctus Performance
--Made by OverlordAkise

--This file should give your server a boost
--in performance by lowering cpu usage


--No reason to not do this, so true
local remove_widgets = true

--If you do not use DarkRP weapons set this on true
local remove_slowwalk_scope = true

--If its ok that players jump with a doorram set this to true
local remove_antidorramjump = true

--If your weapons dont override HUDShouldDraw then set this to true
local remove_hudshoulddraw_weps = true

--If your players are not able to spawn props
--or if you don't need prop-protection then set this to true
--This will disable fpp, saving you a lot of networking and CPU
local remove_fpp = true

--If you don't use the darkrp inbuilt drugs then set this to true
local remove_drugs = true

--If you don't use PLAYER:Move hooks (on a single player directly)
--or the entity:drive system then set this to true
local remove_gm_moves = true

--If you do not use the arrest / unarrest stick
--and do not use the wep:startDarkRPCommand function then set this to true
local remove_startcommand = true

--CONFIG END


hook.Add("DarkRPPreLoadModules","luctus_performance",function()
    if remove_fpp then
        DarkRP.disabledDefaults["modules"]["fpp"] = true
    end
    DarkRP.disabledDefaults["modules"]["events"] = true
end)

hook.Add("InitPostEntity","luctus_performance",function()
    if remove_widgets then
        hook.Remove("PlayerTick","TickWidgets")
        function widgets.PlayerTick() end
    end
    if remove_hudshoulddraw_weps then
        function GAMEMODE:HUDShouldDraw(name) return true end
        local noDraw = {
            ["CHudHealth"] = true,
            ["CHudBattery"] = true,
            ["CHudSuitPower"] = true,
            ["CHUDQuickInfo"] = true
        }
        function GAMEMODE:HUDShouldDraw(name)
            if noDraw[name] then
                return false
            end
            return true
        end
    end
    if remove_antidorramjump then
        hook.Remove("SetupMove","DarkRP_DoorRamJump")
    end
    if remove_slowwalk_scope then
        hook.Remove("SetupMove","DarkRP_WeaponSpeed")
    end
    if remove_drugs then
        hook.Remove("Move","DruggedPlayer")
    end
    if remove_gm_moves then
        function GAMEMODE:SetupMove(ply,mv,cmd) end
        function GAMEMODE:FinishMove(ply,mv) end
        function GAMEMODE:Move(ply,mv) end
    end
    if remove_startcommand then
        function GAMEMODE:StartCommand(ply,usrcmd) end
    end
end)

print("[luctus_performance] sh loaded")
