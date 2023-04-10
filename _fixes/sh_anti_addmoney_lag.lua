--Anti formatMoney lag
--Made by OverlordAkise

--According to fprofiler the formatMoney function
--takes 150ms to complete for a single payDay

local function overwriteMoney()
    DarkRP.formatMoney = function(i) return i.."$" end
end

hook.Add("PostGamemodeLoaded","luctus_money_antilag",overwriteMoney)
hook.Add("InitPostEntity","luctus_money_antilag",overwriteMoney)
