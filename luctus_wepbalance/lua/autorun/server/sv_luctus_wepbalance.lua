--Luctus Weaponbalance
--Made by OverlordAkise

util.AddNetworkString("luctus_weaponbalance_one")
util.AddNetworkString("luctus_weaponbalance_reset")
util.AddNetworkString("luctus_weaponbalance_getall")

LUCTUS_BALANCE_TABLE = LUCTUS_BALANCE_TABLE or {}

net.Receive("luctus_weaponbalance_one",function(len,ply)
    if not ply:IsAdmin() then return end
    local wepclass = net.ReadString()
    local weptable = LuctusWbReceiveTable()
    LUCTUS_BALANCE_TABLE[wepclass] = weptable
    LuctusWbBalanceWeapon(wepclass,weptable)
    LuctusWbNetworkOne(wepclass,weptable)
    LuctusWbSave()
    LuctusWbRefresh(ply,wepclass)
end)

function LuctusWbRefresh(ply,wepclass)
    ply:StripWeapon(wepclass)
    ply:Give(wepclass)
    ply:SelectWeapon(wepclass)
end

net.Receive("luctus_weaponbalance_reset",function(len,ply)
    if not ply:IsAdmin() then return end
    local wepclass = net.ReadString()
    LuctusWbResetWeapon(wepclass)
    LuctusWbRefresh(ply,wepclass)
end)

function LuctusWbNetworkOne(name,tab)
    net.Start("luctus_weaponbalance_one")
        net.WriteString(name)
        LuctusWbSendTable(tab)
    net.Broadcast()
end


net.Receive("luctus_weaponbalance_getall",function(len,ply)
    if ply.weaponBalanceSent then return end
    ply.weaponBalanceSent = true
    net.Start("luctus_weaponbalance_getall")
        LuctusWbSendTable(LUCTUS_BALANCE_TABLE)
    net.Send(ply)
end)

hook.Add("InitPostEntity","luctus_weaponbalance",function()
    local f = file.Read("luctus_weapon_balance.txt","DATA")
    if not f then
        print("[luctus_wepbalance] No data found")
        return
    end
    local jf = util.JSONToTable(f)
    LUCTUS_BALANCE_TABLE = jf
    print("[luctus_wepbalance] Loading...")
    for k,v in pairs(LUCTUS_BALANCE_TABLE) do
        LuctusWbBalanceWeapon(k,v)
    end
    print("[luctus_wepbalance] Finished, count:",table.Count(LUCTUS_BALANCE_TABLE))
end)

function LuctusWbSave()
    file.Write("luctus_weapon_balance.txt",util.TableToJSON(LUCTUS_BALANCE_TABLE))
end

function LuctusWbDisplayLoop(balTab, origTab)
    for k,v in pairs(balTab) do
        if (origTab[k] or origTab[k]==false) and (balTab[k] or balTab[k]==false) then
            if istable(balTab[k]) and istable(origTab[k]) then
                LuctusWbDisplayLoop(v,origTab[k])
            else
                if balTab[k] == origTab[k] then
                    continue
                end
                print(k,v,"->",origTab[k])
            end
        end
    end
end

concommand.Add("luctus_weaponbalance_print", function(ply, cmd, args)
    if IsValid(ply) then return end
    print("----Luctus Weaponbalances")
    print("Date:",os.date("%Y.%m.%d %H:%M:%S"))
    for k,v in pairs(LUCTUS_BALANCE_TABLE) do
        local default = LUCTUS_BALANCE_RESET_TABLE[k]
        if not default then
            print("ERROR: No default values for "..k.." found!")
            continue
        end
        print("--"..k)
        LuctusWbDisplayLoop(v,default)
    end
end)


print("[luctus_wepbalance] sv loaded")
