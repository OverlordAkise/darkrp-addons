--Luctus Speech
--Made by OverlordAkise

--Command to play sounds for everyone
LUCTUS_SPEECH_CMD = "!tts"
--Command to play sounds only for yourself
LUCTUS_SPEECH_CMD_SELF = "!metts"
--Setup your URLs from the golang executable
LUCTUS_SPEECH_URL_GEN = "http://127.0.0.1:5267/gen?q="
LUCTUS_SPEECH_URL_PLAY = "http://127.0.0.1:5267/audio.wav?q="
--Allowed ranks that can use the command
LUCTUS_SPEECH_ALLOWED_RANKS = {
    ["superadmin"] = true,
    ["admin"] = true,
}
--Allowed jobs that can use this command
LUCTUS_SPEECH_ALLOWED_JOBS = {
    -- ["Hobo"] = true,
}

print("[luctus_speech] config loaded")
