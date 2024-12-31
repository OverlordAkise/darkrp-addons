--Luctus LUA dumper
--Made by OverlordAkise

--[[
This function loads all wanted lua files into your data folder for analyzation and debugging.
This file is only meant to help debug server problems within workshop addons!

Example Usage:

GetRecursiveWorkshopFiles("lua/","WORKSHOP")
GetRecursiveWorkshopFiles("addons/","GAME")

--]]

local function GetAllFiles(curfolder,base)
    local files,folders = file.Find(curfolder.."*",base)
    if not file.Exists("_dump/"..curfolder,"DATA") then
        file.CreateDir("_dump/"..curfolder)
    end
    if files then
        for k,v in pairs(files) do
            --print("v",string.find(v,".lua"))
            if not string.find(v,".lua") then continue end
            local err, errStr = pcall(function() file.Write("_dump/"..curfolder..v..".txt",file.Read(curfolder..v,base)) end)
            if not err then print(errStr) end
            
        end
    else
        print("ERROR:",curfolder,"no files found")
    end
    if folders then
        for k,v in pairs(folders) do
            GetAllFiles(curfolder..v.."/",base)
        end
    end
end

function GetRecursiveWorkshopFiles(curfolder,base)
    print("[luctus_luadumper] start")
    GetAllFiles(curfolder,base)
    print("[luctus_luadumper] done")
end

print("[luctus_luadumper] loaded")
