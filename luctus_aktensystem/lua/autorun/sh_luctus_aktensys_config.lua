--Luctus Aktensystem
--Made by OverlordAkise

--This addon lets you create "entries" (also called "reports") for players
--This is supposed to be for e.g. Police and similar jobs

--What chat command should open the menu
LUCTUS_AKTENSYS_CHAT_COMMAND = "!akten"
--Button to open the menu
LUCTUS_AKTENSYS_OPEN_BIND = KEY_F7
--Only open the menu by pressing E on the PC
LUCTUS_AKTENSYS_PC_ONLY = false
--TODO: Multiple jobs for view,create,edit,delete
--Which jobs are allowed to create aktensys
LUCTUS_AKTENSYS_ALLOWED_JOBS = {
    ["Citizen"] = true,
    ["Civil Protection"] = true,
    ["Wissenschaftler"] = true,
}
--Which jobs or usergroups are allowed to delete/edit papers
LUCTUS_AKTENSYS_ADMINS = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["O5"] = true,
    ["Team on duty"] = true,
}

--The title of the windows (and above the PC)
LUCTUS_AKTENSYS_TITLE = "Aktensystem"

--The template when creating new papers
LUCTUS_AKTENSYS_PAPER_TEMPLATE = [[ENTER REPORT HERE]]

print("[luctus_aktensystem] loaded config")
