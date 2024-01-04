# luctus taser

An old and very minimalistic taser addon.  
The "taser-ropes" that shoot out the gun have been made by "SgtSGt".

Hooks:

`hook.Run("LuctusTaserPreRagdoll",ply,attacker)`

This hook gets called when a player gets tazered but before being "turned into" a ragdoll.


`hook.Run("LuctusTaserPostRagdoll",ply,attacker,ragdoll)`

This hook gets called after a player has been "turned into" a ragdoll, it also supplies the ragdoll entity as its 3rd argument.
