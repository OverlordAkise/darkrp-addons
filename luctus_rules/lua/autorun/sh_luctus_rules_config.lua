--Luctus Rules
--Made by OverlordAkise

--Warning: 32bit gmod only supports TLSv1.0 which is deprecated

--Should the rules automatically be opened after joining?
LUCTUS_RULES_OPEN_ON_JOIN = true
--Chatcommand to open the rules
LUCTUS_RULES_CHATCOMMAND = "!rules"
--URL for the rules window
LUCTUS_RULES_RULES_URL = "https://example.com"
--The window-title for the rules window
LUCTUS_RULES_WINDOW_TITLE = "MyServer | Rules"

--Should jobrules be opened when switching job?
LUCTUS_RULES_JOB_ENABLED = true
--Chatcommand to open the job rules
LUCTUS_RULES_JOBCOMMAND = "!jobrules"
--Should jobrules be set via html anchors? (Only enable if you know what you are doing)
--This makes the job-url use the following: <rules-url>#<jobname>
--(This only works if your html headers have the jobnames as IDs)
LUCTUS_RULES_USE_ANCHORS = false
--URLs for the job rules
--If a job doesn't have an URL then nothing will be opened when switching job
LUCTUS_RULES_JOB_URLS = {
    ["Hobo"] = "https://pastebin.com",
    ["D-Class"] = "https://google.com",
}

print("[luctus_rules] config loaded")
