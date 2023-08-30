# luctus_popups

This is a very simple ticket system for handling RDM or similar cases.  
It is heavily inspired by the admin-popups addon that was quite common a few years ago.

There are 3 hooks you can use:

    hook.Run("LuctusPopupCreated",ply,text)
    hook.Run("LuctusPopupClaimed",ply,admin)
    hook.Run("LuctusPopupClosed",ply,admin) --admin can be nil here

