--Luctus Speech
--Made by OverlordAkise

util.AddNetworkString("luctus_speech")

hook.Add("PlayerSay","luctus_speech",function(ply,text)
    if string.StartsWith(text,LUCTUS_SPEECH_CMD) then
        if not LuctusSpeechCanPlaySound(ply) then return end
        print("[luctus_speech] Generate:",text,"from",ply,ply:SteamID())
        LuctusSpeechPlaySound(string.Split(text,LUCTUS_SPEECH_CMD.." ")[2])
    end
    if string.StartsWith(text,LUCTUS_SPEECH_CMD_SELF) then
        if not LuctusSpeechCanPlaySound(ply) then return end
        LuctusSpeechPlaySoundPly(ply,string.Split(text,LUCTUS_SPEECH_CMD_SELF.." ")[2])
    end
end)

local function urlescape(str)
    return str:gsub("([^%w])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
end

function LuctusSpeechPlaySound(text)
    hook.Run("LuctusSpeechPlaySound",text)
    http.Fetch(LUCTUS_SPEECH_URL_GEN..urlescape(text),function(b,l,h,c)
        net.Start("luctus_speech")
            net.WriteString(b)
        net.Broadcast()
    end,
    function(err)
        print("[luctus_speech] Error generating sound:",err)
    end)
end

function LuctusSpeechPlaySoundPly(ply,text)
    hook.Run("LuctusSpeechPlaySoundPly",ply,text)
    http.Fetch(LUCTUS_SPEECH_URL_GEN..urlescape(text),function(b,l,h,c)
        net.Start("luctus_speech")
            net.WriteString(b)
        net.Send(ply)
    end,
    function(err)
        print("[luctus_speech] Error generating sound:",err)
    end)
end

function LuctusSpeechCanPlaySound(ply)
    return LUCTUS_SPEECH_ALLOWED_RANKS[ply:GetUserGroup()] or LUCTUS_SPEECH_ALLOWED_JOBS[team.GetName(ply:Team())]
end

print("[luctus_speech] sv loaded")
