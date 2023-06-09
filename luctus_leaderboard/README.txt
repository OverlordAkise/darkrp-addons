# Luctus Leaderboard

An extensible but simple leaderboard addon for gmod.

It enables you to have a single window for all your ingame leaderboards.

To add a new Leaderboard simply serverside-hook into "LuctusLeaderboardAdd" and use the function "LuctusLeaderboardAdd(name,func)" to add a new leaderboard.

The function has to return a sequential table where value1 of each row is the player and value2 is the value of that leaderboard.


Example from the code:

    hook.Add("LuctusLeaderboardAdd","darkrp_money",function()
        LuctusLeaderboardAdd("DarkRP Money",function()
            local res = sql.Query("SELECT DISTINCT rpname,wallet FROM darkrp_player ORDER BY wallet DESC LIMIT 20;")
            if res and res[1] then
                local tab = {}
                for k,v in pairs(res) do
                    table.insert(tab,{v.rpname,v.wallet})
                end
                return tab
            end
            return {}
        end)
    end)


The example response table:

    tab = {
        {"Player1",5},
        {"Player2",2},
    }
