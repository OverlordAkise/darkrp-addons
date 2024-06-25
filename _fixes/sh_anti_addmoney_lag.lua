--Anti formatMoney lag
--Made by OverlordAkise

--According to fprofiler the formatMoney function
--takes 150ms to complete for a single payDay
--Now also checks if input is nil because some void* addon provides that

local function overwriteMoney()
    DarkRP.formatMoney = function(i) 
        if not i then return "0$" end
        return i.."$"
    end
end

hook.Add("PostGamemodeLoaded","luctus_money_antilag",overwriteMoney)
hook.Add("InitPostEntity","luctus_money_antilag",overwriteMoney)
