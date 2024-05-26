# luctus_rpscore

This is known in german as "RP-Punkte System".

It is a very simple system that lets you give and take "Roleplay-Score".  
Rp-Score is a number that represents how many good RP situation you were involved in.

Functions:

ply:getRPScore()
ply:setRPScore()
ply:addRPScore()

Hooks:

hook.Run("LuctusRPScoreSet",ply,amount,adminPly)
hook.Run("LuctusRPScoreAdd",ply,amount,adminPly)
hook.Run("LuctusRPScoreAddID",steamid,amount,adminPly)

Warning: The above adminPly can be nil
