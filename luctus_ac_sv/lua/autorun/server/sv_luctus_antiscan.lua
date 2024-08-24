--Luctus Anti Backdoorscan
--Made by OverlordAkise

--This creates a random net message that we listen on
--If someone sends anything here we ban them

local lprint = print
local kick = game.KickID
local lErrorNoHaltWithStack = ErrorNoHaltWithStack
local getSteamID = FindMetaTable("Player").SteamID

local randomString = string.format("%c%c%c%c%c%c%c%c",math.random(97,122),math.random(97,122),math.random(97,122),math.random(97,122),math.random(97,122),math.random(97,122),math.random(97,122),math.random(97,122))

util.AddNetworkString(randomString)
net.Receive(randomString,function(len,ply)
    lprint("[antiscan] !!! WARNING !!!")
    lprint("[antiscan] ",ply:Nick(),ply:SteamID(),"tried to send an unsolicited net message, kicking...")
    lErrorNoHaltWithStack("[antiscan] ",ply:Nick()," (",ply:SteamID(),") tried to send an unsolicited net message")
    kick(getSteamID(ply),"suspicion of hacking")
end)
lprint("[antiscan] Created:",randomString)

lprint("[luctus_antiscan] sv loaded")
