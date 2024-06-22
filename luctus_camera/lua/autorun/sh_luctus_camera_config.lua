--Luctus Camera
--Made by OverlordAkise

--How many cameras can be placed with this tool?
--If you permaprop'd the cameras you can set this to 0
LUCTUS_CAMERA_PLACEABLE = 5
--Should you be able to spectate players? (e.g. bodycams)
LUCTUS_CAMERA_BODYCAMS = true
--Which jobs are allowed to be spectated with this?
LUCTUS_CAMERA_BODYCAM_JOBS = {
    ["Citizen"] = true,
    ["Security"] = true,
}
--Text if the end of the cameras was reached
LUCTUS_CAMERA_TEXT_IF_NO_CAMERA_FOUND = "<NO VIDEO FEED>"
--Text if the camera system is offline
LUCTUS_CAMERA_TEXT_IF_OFFLINE = "<SYSTEM OFFLINE>"

print("[luctus_camera] config loaded")
