--Luctus UlxEchoOnlyToAdmins
--Made by OverlordAkise

--If the players who can see the echo are already limited
--then we do not want to overwrite it, hence if args#2==table then do nothing end
--Else we add the "hidden_echo" true into the mix of arguments
--which makes all commands (SILENT)

hook.Add("InitPostEntity","luctus_ulx_echo_overwrite",function()
    ulx.oldFancyLogAdmin = ulx.fancyLogAdmin
    ulx.fancyLogAdmin = function(a,b,...)
        if not istable(b) then
            ulx.oldFancyLogAdmin(a,true,b,...)
        else
            ulx.oldFancyLogAdmin(a,b,...)
        end
    end

end)

print("[luctus_ulxechoadmins] sv loaded")
