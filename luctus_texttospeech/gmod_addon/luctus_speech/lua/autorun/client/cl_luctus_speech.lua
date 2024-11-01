--Luctus Speech
--Made by OverlordAkise

local noGC
function LuctusSpeechPlaySound(link)
    sound.PlayURL(link, "", function(station)
        if IsValid(station) then
            station:Play()
            noGC = station
        end
    end)
end

net.Receive("luctus_speech",function()
    local hash = net.ReadString()
    print("[luctus_speech] Playing sound for hash: ",hash)
    LuctusSpeechPlaySound(LUCTUS_SPEECH_URL_PLAY..hash)
end)

print("[luctus_speech] cl loaded")
