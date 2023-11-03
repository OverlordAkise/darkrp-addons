--Luctus Site99 entitycount fix
--Made by OverlordAkise

--DarkRP's FPP creates errors around 6800 entities because of network limitations
--By default gmod supports 8192 entities and rp_site99_v3 has ~6700 from the map alone
--This small codepiece removes ~2000 lights from the map, making the ent count ~4150

hook.Add("InitPostEntity","luctus_fix_site99",function()
    if game.GetMap() ~= "rp_site99_v3" then return end
    print("[rp_site99] Optimizing by removing lights...")
    local st = SysTime()
    for k,v in ipairs(ents.FindByClass("env_lightglow")) do SafeRemoveEntity(v) end
    for k,v in ipairs(ents.FindByClass("light")) do SafeRemoveEntity(v) end
    for k,v in ipairs(ents.FindByClass("light_spot")) do SafeRemoveEntity(v) end
    print("[rp_site99] Optimized, time taken:",SysTime()-st)
end)

print("[luctus_site99] sv fix loaded")
