--Luctus LUA dumper
--Made by OverlordAkise

--[[
This function loads all wanted lua files into your data folder for analyzation and debugging.
This file is only meant to help debug server problems within workshop addons!

Example Usage:

GetRecursiveWorkshopFiles("lua/","WORKSHOP")
GetRecursiveWorkshopFiles("addons/","GAME")

--]]

function GetRecursiveWorkshopFiles(curfolder,base)
    local files,folders = file.Find(curfolder.."*",base)
    if not file.Exists("_dump/"..curfolder,"DATA") then
        file.CreateDir("_dump/"..curfolder)
    end
    for k,v in pairs(files) do
        --print("v",string.find(v,".lua"))
        if not string.find(v,".lua") then continue end
        file.Write("_dump/"..curfolder..v..".txt",file.Read(curfolder..v,base))
    end
    for k,v in pairs(folders) do
        GetRecursiveWorkshopFiles(curfolder..v.."/",base)
    end
end

print("[luctus_luadumper] cl loaded")