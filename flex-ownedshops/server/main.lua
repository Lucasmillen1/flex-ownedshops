
local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback("flex-ownedshop:server:loadshop", function(source, cb, name)
    local result = MySQL.Sync.fetchAll('SELECT * FROM ownedshops WHERE shopname = ?', { name })
    if result[1] then
        cb(result[1].stock)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("flex-ownedshop:server:loadinv", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.items then
        cb(Player.PlayerData.items)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback("flex-ownedshop:server:isowner", function(source, cb, shop)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local result = MySQL.Sync.fetchAll('SELECT owner FROM ownedshops WHERE shopname = ?', { shop })
    if result[1] then
        if result[1].owner == Player.PlayerData.citizenid then
            cb(2)
        elseif result[1].owner ~= nil then
            cb(1)
        else
            cb(0)
        end
    else
        cb(0)
    end
end)

RegisterNetEvent('flex-ownedshops:server:buyshop', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local BankMoney = Player.PlayerData.money['bank']
    local CashMoneyMoney = Player.PlayerData.money['cash']
    if src == nil or Player == nil then return end
    local HasMoney = false
    if BankMoney >= data.shopprice and not HasMoney then
        HasMoney = true
        Player.Functions.RemoveMoney("bank", data.shopprice, data.shopname)
    elseif CashMoneyMoney >= data.shopprice and not HasMoney then
        HasMoney = true
        Player.Functions.RemoveMoney("cash", data.shopprice, data.shopname)
    end
    if HasMoney then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.boughtshop", {value = data.shopprice}), 'success', 5000)
        MySQL.Async.insert('INSERT INTO ownedshops (shopname, owner) VALUES (:shopname, :owner)', { ['shopname'] = data.shopname, ['owner'] = Player.PlayerData.citizenid})
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.broke"), 'error', 5000)
    end
end)

RegisterNetEvent('flex-ownedshops:server:restock', function(itemname, amount, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.Functions.RemoveItem(itemname, amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemname], "remove", amount)
        local shop = MySQL.prepare.await('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
        local NewStock = {}
        local alreadyadded = false
        if shop ~= nil then
            if table.type(shop) == "empty" and not shop or shop == nil then return end
            local items = json.decode(shop)
            if shop ~= '[]' or shop ~= nil then
                for slot, item in pairs(items) do
                    if items[slot] then
                        if item.name == itemname then
                            NewStock[#NewStock+1] = {
                                name = itemname,
                                amount = tonumber(item.amount) + amount,
                                price = item.price or 0,
                            }
                            alreadyadded = true
                        else
                            NewStock[#NewStock+1] = {
                                name = item.name or itemname,
                                amount = tonumber(item.amount) or amount,
                                price = item.price or 0,
                            }
                            if #items == slot then
                                if not alreadyadded then
                                    NewStock[#NewStock+1] = {
                                        name = itemname,
                                        amount = amount,
                                        price = item.price or 0,
                                    }
                                end
                            end
                        end
                    else
                        NewStock[#NewStock+1] = {
                            name = itemname,
                            amount = amount,
                            price = item.price or 0,
                        }
                    end
                end
            else
                NewStock[#NewStock+1] = {
                    name = itemname,
                    amount = amount,
                    price = item.price or 0,
                }
            end
        else
            NewStock[#NewStock+1] = {
                name = itemname,
                amount = amount,
                price = 0,
            }
        end
        alreadyadded = false
        if shop ~= nil then
            MySQL.update.await("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname})
        else
            MySQL.insert('INSERT INTO ownedshops (shopname, owner, stock) VALUES (?, ?, ?)', {
                shopname,
                '',
                json.encode(NewStock),
            })
        end
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.stockrefilled"), 'success', 5000)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
end)

RegisterNetEvent('flex-ownedshops:server:buy', function(itemName, itemAmount, price, label, shopName, jobName, gangName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalCost = price * itemAmount

    -- Check if the player has enough money
    if Player.PlayerData.money['bank'] < totalCost and Player.PlayerData.money['cash'] < totalCost then
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.broke"), 'error', 5000)
        return
    end

    -- Retrieve shop stock and owner
    local shop = MySQL.prepare.await('SELECT stock, owner FROM ownedshops WHERE shopname = ?', { shopName })
    local owner = shop.owner
    local Target = QBCore.Functions.GetOfflinePlayerByCitizenId(owner)

    -- Update shop stock
    local newStock = {}
    local items = json.decode(shop.stock)
    for _, item in ipairs(items) do
        if item.name == itemName then
            if item.amount - itemAmount >= 0 then
                newStock[#newStock + 1] = {
                    name = itemName,
                    amount = item.amount - itemAmount,
                    price = item.price
                }
            end
        else
            newStock[#newStock + 1] = item
        end
    end

    -- Update player inventory and money
    if #newStock > 0 then
        MySQL.update.await("UPDATE ownedshops SET stock=? WHERE shopname=?", { json.encode(newStock), shopName })
        Player.Functions.RemoveMoney("bank", totalCost, itemName)
        Player.Functions.AddItem(itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add", itemAmount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.successbuy", { value = itemAmount, value2 = label, value3 = totalCost }))

        -- Handle banking based on configuration
        if Config.Banking == 'fd' then
            if jobName then
                exports.fd_banking:AddMoney(jobName, totalCost, itemName)
            elseif gangName then
                exports.fd_banking:AddMoney(gangName, totalCost, itemName)
            else
                Target.Functions.AddMoney("bank", totalCost, itemName)
            end
        elseif Config.Banking == 'qb' then
            if Config.Management == 'old' then
                if jobName then
                    exports['qb-management']:AddMoney(jobName, totalCost)
                elseif gangName then
                    exports['qb-management']:AddMoney(gangName, totalCost)
                else
                    Target.Functions.AddMoney("bank", totalCost, itemName)
                end
            elseif Config.Management == 'new' then
                if jobName then
                    exports['qb-banking']:AddMoney(jobName, totalCost)
                elseif gangName then
                    exports['qb-banking']:AddMoney(gangName, totalCost)
                else
                    Target.Functions.AddMoney("bank", totalCost, itemName)
                end
            else
                Target.Functions.AddMoney("bank", totalCost, itemName)
            end
        else
            Target.Functions.AddMoney("bank", totalCost, itemName)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
end)

RegisterNetEvent('flex-ownedshops:server:setprice', function(itemname, price, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shop = MySQL.prepare.await('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}
    if table.type(shop) ~= "empty" and shop then
        local items = json.decode(shop)
        if shop ~= '[]' then
            for slot, item in pairs(items) do
                if items[slot] then
                    if item.name == itemname then
                        NewStock[#NewStock+1] = {
                            name = itemname,
                            amount = tonumber(item.amount),
                            price = price,
                        }
                    else
                        NewStock[#NewStock+1] = {
                            name = item.name,
                            amount = tonumber(item.amount),
                            price = item.price,
                        }
                    end
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
    MySQL.update.await("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname})
end)

RegisterNetEvent('flex-ownedshops:server:changeDuty', function(duty)
    local Player = QBCore.Functions.GetPlayer(source)
    local Job = Player.PlayerData.job

    if Job and Job.onduty and not duty then
        Player.Functions.SetJobDuty(false)
        QBCore.Functions.Notify(source, Lang:t("info.offduty"), 'primary')
        TriggerClientEvent('QBCore:Client:SetDuty', source, false)
    elseif Job and not Job.onduty and duty then
        Player.Functions.SetJobDuty(true)
        QBCore.Functions.Notify(source, Lang:t("info.onduty"), 'primary')
        TriggerClientEvent('QBCore:Client:SetDuty', source, true)
    end
end)
