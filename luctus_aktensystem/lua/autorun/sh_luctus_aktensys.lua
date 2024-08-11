--Luctus Aktensystem
--Made by OverlordAkise

function LuctusAktensysHasAccess(ply)
    if not IsValid(ply) then return false end
    local jobName = team.GetName(ply:Team())
    if LUCTUS_AKTENSYS_ALLOWED_JOBS[jobName] or LUCTUS_AKTENSYS_ADMINS[jobName] or LUCTUS_AKTENSYS_ADMINS[ply:GetUserGroup()] then return true end
    return false
end

function LuctusAktensysIsAdmin(ply)
    if LUCTUS_AKTENSYS_ADMINS[ply:getJobTable().name] then return true end
    if LUCTUS_AKTENSYS_ADMINS[ply:GetUserGroup()] then return true end
    return false
end

print("[luctus_aktensystem] sh loaded")
