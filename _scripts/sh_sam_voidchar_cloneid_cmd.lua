--Made by OverlordAkise

--This is a SAM command that changes the clone_id of an online player
--(I am no expert in SAM)


sam.command.new("cloneid")
    :SetPermission("cloneid", "admin")
    :AddArg("player", {single_target = true, allow_higher_target = true})
    :AddArg("number", {hint = "CloneID", min = 0, round = true})
    :Help("Change the CloneID for a player")
    :OnExecute(function(ply,targets,clone_id)
        local target = targets[1]
        if not IsValid(target) then return end
        VoidChar.SQL.UpdateValue(target:GetCharacterID(), "clone_id", clone_id)
        VoidChar.Print("CloneID changed, reloading in 1s")
        timer.Simple(1,function()
            if not IsValid(target) then return end
            VoidChar.SQL.UpdateCharacters(target, function(succ, tbl)
                VoidChar.Print(string.format("Re-Loading characters for %s, success: %s",target:Name(),tostring(succ)))
                
                if not succ then
                    if not IsValid(ply) or not ply:IsPlayer() then return end
                    DarkRP.notify(ply,1,5,"Failed to change CloneID")
                    return
                end
                local character = target:GetCharacterByID(target:GetCharacterID())
                --Rest of this is taken straight from voidchar
                local hashtag = (VoidChar.Config.ShowHashtag and VoidChar.Config.CustomSymbol) or ""
                if VoidChar.Config.DisplayAsSuffix then
                    target:setDarkRPVar("rpname", hashtag .. character.clone_id.. " " .. character.name)
                else
                    target:setDarkRPVar("rpname", character.name.. " " .. hashtag .. character.clone_id)
                end
            end)
        end)
    end)
:End()
