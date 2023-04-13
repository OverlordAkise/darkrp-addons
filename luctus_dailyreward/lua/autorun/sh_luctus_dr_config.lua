--Luctus Daily Rewards
--Made by OverlordAkise

LUCTUS_DAYWARD_TYPES = {
    [1] = {"XP", function(ply,amount) ply:AddXP(amount) end},
    [2] = {"Money", function(ply,amount) ply:addMoney(amount) end},
}

LUCTUS_DAYWARD_AMOUNT = {
    [1] = {100,0},
    [2] = {150,0},
    [3] = {200,100},
}

--should the rewards loop or stay at highest if highest day is reached?
LUCTUS_DAYWARD_STAY_HIGHEST_REWARD = true
--get 50% more from daily rewards if you have the tag in your name
LUCTUS_DAYWARD_NAME_MULTIPLIER = 1.5 
--the text you have to have in your name
LUCTUS_DAYWARD_NAME_TAG = "[ME]"

print("[luctus_dailyrewards] config loaded")
