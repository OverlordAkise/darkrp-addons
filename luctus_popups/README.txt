# luctus_popups

WARNING: This addon requires ulx !

This is a very simple ticket system for handling RDM or similar cases.  
It is heavily inspired by the admin-popups addon that was quite common a few years ago.

To write a "ticket" (aka. popup in the top left) you use the @ chat (=ulx asay).  
Example:

    @ Help, im stuck!


## For Developers

There are 3 hooks you can use:

    hook.Run("LuctusPopupCreated",ply,text)
    hook.Run("LuctusPopupClaimed",ply,admin)
    hook.Run("LuctusPopupClosed",ply,admin) --admin can be nil here, e.g. if a player leaves

