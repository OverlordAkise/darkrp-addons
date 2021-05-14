--Luctus Charsystem
--Made by OverlordAkise

if SERVER then
  include("charsystem/sh_config.lua")
  include("charsystem/sv_commands.lua")
  include("charsystem/sv_main.lua")
  include("charsystem/sv_adminmenu.lua")
  AddCSLuaFile("charsystem/sh_config.lua")
  AddCSLuaFile("charsystem/cl_menu.lua")
  AddCSLuaFile("charsystem/cl_adminmenu.lua")
end

if CLIENT then
  include("charsystem/sh_config.lua")
  include("charsystem/cl_menu.lua")
  include("charsystem/cl_adminmenu.lua")
end

