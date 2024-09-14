# luctus_introduce

Also called "Kennenlern-System" in german.

The players do not see the names of each other by default.  
You have to press E on them to introduce yourself to them.  
After this they can see your name, but they have to press E on you so that you can see their name too.

To use this in your addons simply use the "ply:IName()" function instead of :Nick() or :Name().  

Hooks (shared):
	hook.Run("LuctusIntroduced",playerWhoIntroducedThemself,playerWhoNowKnowsTheirName)

(clientside this hook will always have LocalPlayer() as the second argument)
