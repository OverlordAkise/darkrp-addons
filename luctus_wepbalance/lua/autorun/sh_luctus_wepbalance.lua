--Luctus Weaponbalance
--Made by OverlordAkise

LUCTUS_BALANCE_RESET_TABLE = LUCTUS_BALANCE_RESET_TABLE or {}

function LuctusWbSendTable(tab)
    local t = util.TableToJSON(tab)
    local a = util.Compress(t)
    net.WriteInt(#a,17)
    net.WriteData(a,#a)
end

function LuctusWbReceiveTable()
    local lenge = net.ReadInt(17)
    local data = net.ReadData(lenge)
    local jtext = util.Decompress(data)
    local tab = util.JSONToTable(jtext)
    return tab
end

function LuctusWbBalanceWeapon(class,weptab)
    if not isstring(class) then print("LuctusWbBalanceWeapon has non-string input") return end
    if not istable(weptab) then print("LuctusWbBalanceWeapon has non-table input") return end
    print("---Balance weapon start",class)
    local wep = weapons.GetStored(class)
    if not wep then print("Couldn't find weapontable for "..class) return end
    if not LUCTUS_BALANCE_RESET_TABLE[class] then
        LUCTUS_BALANCE_RESET_TABLE[class] = weapons.Get(class)
    end
    LuctusWbUpdateWeapon(wep,weptab)
    print("---Balance weapon success",class)
end

function LuctusWbResetWeapon(class)
    if not isstring(class) then print("LuctusWbResetWeapon has non-string input") return end
    print("---Reset weapon start",class)
    if not LUCTUS_BALANCE_RESET_TABLE[class] then
        print("ERROR: reset table doesn't have: "..tostring(class))
        return
    end
    local wep = weapons.GetStored(class)
    if not wep then print("Couldn't find weapontable for "..class) return end
    LuctusWbResetWeaponLoop(wep,LUCTUS_BALANCE_RESET_TABLE[class])
    print("---Reset weapon success",class)
    if CLIENT then return end
    LUCTUS_BALANCE_TABLE[class] = nil
    LuctusWbSave()
    net.Start("luctus_weaponbalance_reset")
        net.WriteString(class)
    net.Broadcast()
end

function LuctusWbResetWeaponLoop(wepTab, origTab)
    for k,v in pairs(wepTab) do
        if (origTab[k] or origTab[k]==false) and (wepTab[k] or wepTab[k]==false) then
            if istable(wepTab[k]) and istable(origTab[k]) then
                LuctusWbResetWeaponLoop(v,origTab[k])
            else
                if wepTab[k] == origTab[k] then
                    continue
                end
                --print("reset",k,v,"->",origTab[k])
                wepTab[k] = origTab[k]
            end
        end
    end
end

function LuctusWbUpdateWeapon(wep,weptab)
    for k,v in pairs(wep) do
        if weptab[k] or weptab[k]==false then
            if istable(weptab[k]) then
                LuctusWbUpdateWeapon(v,weptab[k])
            else
                --print("change",k,v,"->",weptab[k])
                wep[k] = LuctusWbType(weptab[k])
            end
        end
    end
end

function LuctusWbType(input)
    if input == "true" or input == "false" then
        return tobool(input)
    end
    if string.match(input,"^[-0-9.]+ [-0-9.]+ [-0-9.]+$") == input then
        local Vec = Vector(input)
        if not (Vec.x == 0 and Vec.y == 0 and Vec.z == 0) then
            return Vec
        end
    end
    if tonumber(input) then
        return tonumber(input)
    end
    return input
end

print("[luctus_wepbalance] sh loaded")
