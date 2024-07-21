--Luctus SecVar
--Made by OverlordAkise

--This notifies you if a malicious actor tries to overwrite server functionality

local lprint = print
local lErrorNoHaltWithStack = ErrorNoHaltWithStack
local ldebugGetinfo = debug.getinfo
local timerSimple = timer.Simple
local list = {
    ["print"] = print,
    ["Msg"] = Msg,
    ["MsgC"] = MsgC,
    ["MsgN"] = MsgN,
    ["MsgAll"] = MsgAll,
    ["RunString"] = RunString,
    ["RunStringEx"] = RunStringEx,
    ["CompileString"] = CompileString,
    ["RunConsoleCommand"] = RunConsoleCommand,
    ["HTTP"] = HTTP,
    ["http.Fetch"] = http.Fetch,
    ["http.Post"] = http.Post,
    ["game.KickID"] = game.KickID,
    ["debug.getinfo"] = debug.getinfo,
}

local function alert(name,is,should)
    lErrorNoHaltWithStack("[secvar] WARNING: "..name.." function was overwritten!")
    lprint("[secvar] is/should",is,should,ldebugGetinfo(is).source)
    lprint("[secvar] Please contact your dev")
end

function SecVarReset()
    lprint("[secvar] Overwriting...")
    print = list["print"]
    Msg = list["Msg"]
    MsgC = list["MsgC"]
    MsgN = list["MsgN"]
    MsgAll = list["MsgAll"]
    RunString = list["RunString"]
    RunStringEx = list["RunStringEx"]
    CompileString = list["CompileString"]
    RunConsoleCommand = list["RunConsoleCommand"]
    HTTP = list["HTTP"]
    http.Fetch = list["http.Fetch"]
    http.Post = list["http.Post"]
    game.KickID = list["game.KickID"]
    debug.getinfo = list["debug.getinfo"]
    lprint("[secvar] Overwritten.")
end
local lSecVarReset = SecVarReset

--gen: lprint\("$1",list["$1"],$1,ldebugGetinfo\($1\).source\)
function SecVarPrint()
    lprint("[secvar] infos start")
    lprint("print",list["print"],print,ldebugGetinfo(print).source)
    lprint("Msg",list["Msg"],Msg,ldebugGetinfo(Msg).source)
    lprint("MsgC",list["MsgC"],MsgC,ldebugGetinfo(MsgC).source)
    lprint("MsgN",list["MsgN"],MsgN,ldebugGetinfo(MsgN).source)
    lprint("MsgAll",list["MsgAll"],MsgAll,ldebugGetinfo(MsgAll).source)
    lprint("RunString",list["RunString"],RunString,ldebugGetinfo(RunString).source)
    lprint("RunStringEx",list["RunStringEx"],RunStringEx,ldebugGetinfo(RunStringEx).source)
    lprint("CompileString",list["CompileString"],CompileString,ldebugGetinfo(CompileString).source)
    lprint("RunConsoleCommand",list["RunConsoleCommand"],RunConsoleCommand,ldebugGetinfo(RunConsoleCommand).source)
    lprint("HTTP",list["HTTP"],HTTP,ldebugGetinfo(HTTP).source)
    lprint("http.Fetch",list["http.Fetch"],http.Fetch,ldebugGetinfo(http.Fetch).source)
    lprint("http.Post",list["http.Post"],http.Post,ldebugGetinfo(http.Post).source)
    lprint("game.KickID",list["game.KickID"],game.KickID,ldebugGetinfo(game.KickID).source)
    lprint("debug.getinfo",list["debug.getinfo"],debug.getinfo,ldebugGetinfo(debug.getinfo).source)
    lprint("[secvar] infos end")
end
local lSecVarPrint = SecVarPrint

--gen: if list["$1"] ~= $1 then alert\("$1",$1,list["$1"]\) end
local function VerifyVariables()
    if list["print"] ~= print then alert("print",print,list["print"]) end
    if list["Msg"] ~= Msg then alert("Msg",Msg,list["Msg"]) end
    if list["MsgC"] ~= MsgC then alert("MsgC",MsgC,list["MsgC"]) end
    if list["MsgN"] ~= MsgN then alert("MsgN",MsgN,list["MsgN"]) end
    if list["MsgAll"] ~= MsgAll then alert("MsgAll",MsgAll,list["MsgAll"]) end
    if list["RunString"] ~= RunString then alert("RunString",RunString,list["RunString"]) end
    if list["RunStringEx"] ~= RunStringEx then alert("RunStringEx",RunStringEx,list["RunStringEx"]) end
    if list["CompileString"] ~= CompileString then alert("CompileString",CompileString,list["CompileString"]) end
    if list["RunConsoleCommand"] ~= RunConsoleCommand then alert("RunConsoleCommand",RunConsoleCommand,list["RunConsoleCommand"]) end
    if list["HTTP"] ~= HTTP then alert("HTTP",HTTP,list["HTTP"]) end
    if list["http.Fetch"] ~= http.Fetch then alert("http.Fetch",http.Fetch,list["http.Fetch"]) end
    if list["http.Post"] ~= http.Post then alert("http.Post",http.Post,list["http.Post"]) end
    if list["game.KickID"] ~= game.KickID then alert("game.KickID",game.KickID,list["game.KickID"]) end
    if list["debug.getinfo"] ~= debug.getinfo then alert("debug.getinfo",debug.getinfo,list["debug.getinfo"]) end
    SecVarPrint = lSecVarPrint
    SecVarReset = lSecVarReset
    timerSimple(5,VerifyVariables)
end
VerifyVariables()

--Init check
--gen: if ldebugGetinfo\($1\).source ~= "=[C]" then lprint\("[secvar] WARNING: $1 has source != [C]"\) end
if ldebugGetinfo(print).source ~= "=[C]" then lprint("[secvar] WARNING: print has source != [C]") end
if ldebugGetinfo(Msg).source ~= "=[C]" then lprint("[secvar] WARNING: Msg has source != [C]") end
if ldebugGetinfo(MsgC).source ~= "=[C]" then lprint("[secvar] WARNING: MsgC has source != [C]") end
if ldebugGetinfo(MsgN).source ~= "=[C]" then lprint("[secvar] WARNING: MsgN has source != [C]") end
if ldebugGetinfo(MsgAll).source ~= "=[C]" then lprint("[secvar] WARNING: MsgAll has source != [C]") end
if ldebugGetinfo(RunString).source ~= "=[C]" then lprint("[secvar] WARNING: RunString has source != [C]") end
if ldebugGetinfo(RunStringEx).source ~= "=[C]" then lprint("[secvar] WARNING: RunStringEx has source != [C]") end
if ldebugGetinfo(CompileString).source ~= "=[C]" then lprint("[secvar] WARNING: CompileString has source != [C]") end
if ldebugGetinfo(RunConsoleCommand).source ~= "=[C]" then lprint("[secvar] WARNING: RunConsoleCommand has source != [C]") end
if ldebugGetinfo(HTTP).source ~= "=[C]" then lprint("[secvar] WARNING: HTTP has source != [C]") end
if ldebugGetinfo(http.Fetch).source ~= "@lua/includes/modules/http.lua" then lprint("[secvar] WARNING: http.Fetch has source != [C]") end
if ldebugGetinfo(http.Post).source ~= "@lua/includes/modules/http.lua" then lprint("[secvar] WARNING: http.Post has source != [C]") end
if ldebugGetinfo(game.KickID).source ~= "=[C]" then lprint("[secvar] WARNING: game.KickID has source != [C]") end
if ldebugGetinfo(debug.getinfo).source ~= "=[C]" then lprint("[secvar] WARNING: debug.getinfo has source != [C]") end


lprint("[luctus_secvar] sv loaded")
