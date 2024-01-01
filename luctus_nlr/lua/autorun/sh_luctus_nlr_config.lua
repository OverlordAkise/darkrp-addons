--Luctus NLR
--Made by OverlordAkise

--How long should the NLR sphere last?
LUCTUS_NLR_DURATION = 30
--How big should the NLR sphere be?
LUCTUS_NLR_SIZE = 20
--What material should the NLR sphere have?
LUCTUS_NLR_MATERIAL = "models/wireframe"
--The text that is displayed if you enter NLR
LUCTUS_NLR_TEXT = "Please leave NLR"
--Command to remove a players NLR, e.g. !clearnlr <name>
LUCTUS_NLR_REMCMD = "!clearnlr"
--Which usergroups can use the clear nlr chatcommand
LUCTUS_NLR_ADMINS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["moderator"] = true,
    ["supporter"] = true,
}

print("[luctus_nlr] config loaded")
