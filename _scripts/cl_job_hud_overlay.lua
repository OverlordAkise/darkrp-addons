--Luctus Job Overlay
--Made by OverlordAkise

--[[
Gives a job a different "view" via an material overlay.
To use this simply add, for example, the following to your jobs.lua:

    customOverlay = "effects/combine_binocoverlay",

Like the following example:

    TEAM_POLICE = DarkRP.createJob("Civil Protection", {
        [...]
        customOverlay = "effects/combine_binocoverlay",
        [...]
    })

--]]

hook.Add("OnPlayerChangedTeam","luctus_overlay",function(ply, before, after)
    local job = RPExtraTeams[after]
    if job.customOverlay then
        hook.Add("RenderScreenspaceEffects", "luctus_overlay", function()
            DrawMaterialOverlay(job.customOverlay, 0)
        end)
    else
        hook.Remove("RenderScreenspaceEffects", "luctus_overlay")
    end
end)

print("[luctus_overlay] cl loaded")
