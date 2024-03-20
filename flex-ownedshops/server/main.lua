local QBCore = exports['qb-core']:GetCoreObject()


 -- SETS UP SHOPS AND DATABASE

local function initializeShops()
    for _, shop in pairs(Config.Shops) do
        MySQL.Async.fetchAll('SELECT * FROM ownedshops WHERE shopname = @shopname', {
            ['@shopname'] = shop.shopname
        }, function(result)
            local bankValue = shop.bank and 1 or 0
            local owner = ''
            local isOwned = 0

            if shop.isjob and shop.isjob.name ~= '' then
                owner = shop.isjob.name
                isOwned = 1
            elseif shop.isgang and shop.isgang.name ~= '' then
                owner = shop.isgang.name
                isOwned = 1
            elseif result[1] and result[1].owner ~= '' then
                owner = result[1].owner
                isOwned = 1
            end

            if not result[1] then
                MySQL.Async.insert('INSERT INTO ownedshops (shopname, owner, owned, bank) VALUES (@shopname, @owner, @owned, @bank)', {
                    ['@shopname'] = shop.shopname,
                    ['@owner'] = owner,
                    ['@owned'] = isOwned,
                    ['@bank'] = bankValue
                })
            else
                if result[1].bank ~= bankValue then
                    MySQL.Async.execute('UPDATE ownedshops SET bank = @bank WHERE shopname = @shopname', {
                        ['@shopname'] = shop.shopname,
                        ['@bank'] = bankValue
                    })
                elseif result[1].owner ~= owner or result[1].owned ~= isOwned then
                    MySQL.Async.execute('UPDATE ownedshops SET owner = @owner, owned = @owned WHERE shopname = @shopname', {
                        ['@shopname'] = shop.shopname,
                        ['@owner'] = owner,
                        ['@owned'] = isOwned
                    })
                end
            end
        end)
    end
end

 -- GETTING IT ALL READY

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        initializeShops()
    end
end)

 -- LOADING DATA FOR SHOP

QBCore.Functions.CreateCallback("flex-ownedshop:server:loadshop", function(source, cb, name)
    local shopConfig = nil
    for _, shop in pairs(Config.Shops) do
        if shop.shopname == name then
            shopConfig = shop
            break
        end
    end

    if shopConfig then
        local bankValue = shopConfig.bank == 'true' and 1 or 0
        local result = MySQL.Sync.fetchAll('SELECT * FROM ownedshops WHERE shopname = ?', { name })

        if result[1] then
            if tonumber(result[1].bank) ~= bankValue then
                MySQL.Sync.execute("UPDATE ownedshops SET bank = ? WHERE shopname = ?", {bankValue, name})
            end
            cb(result[1].stock)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

 -- CHECKS OWNERSHIP OF SHOP TO SEE IF SOMEONE CAN PURCHASE

QBCore.Functions.CreateCallback('flex-ownedshop:server:checkShopOwnership', function(source, cb, shopname)
    print("Checking shop ownership for shop: ", shopname)
    local result = MySQL.Sync.fetchAll('SELECT owned FROM ownedshops WHERE shopname = ?', {shopname})
    if result[1] then
        print("Shop found in the database. Owned value: ", result[1].owned)
        if result[1].owned == false then
            print("Shop is not owned. Allowing purchase.")
            cb(false) 
        else
            print("Shop is already owned. Not allowing purchase.")
            cb(true) 
        end
    else
        print("Shop not found in the database. Not allowing purchase.")
        cb(true) 
    end
end)

 -- RUN A SALE

RegisterNetEvent('flex-ownedshops:server:startsale', function(shopname, discount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shop = MySQL.Sync.fetchScalar('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}
    
    if shop then
        local items = json.decode(shop)
        if items then
            for _, item in pairs(items) do
                local discountedPrice = math.floor(item.price * (1 - discount / 100))
                NewStock[#NewStock+1] = {
                    name = item.name,
                    amount = tonumber(item.amount),
                    price = discountedPrice,
                }
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.shopnotfound"), 'error', 5000)
        return
    end
    
    MySQL.Async.execute("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.salecreated"), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.updatefailed"), 'error', 5000)
        end
    end)
end)

RegisterNetEvent('flex-ownedshops:server:changesingleprice', function(itemname, price, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shop = MySQL.Sync.fetchScalar('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}
    
    if shop then
        local items = json.decode(shop)
        if items then
            for _, item in pairs(items) do
                if item.name == itemname then
                    local itemPrice = tonumber(price)
                    if itemPrice then
                        if Config.MaxPrice.AnyPrice or (not Config.MaxPrice.AnyPrice and itemPrice <= Config.MaxPrice.MaxAmount) then
                            NewStock[#NewStock+1] = {
                                name = itemname,
                                amount = tonumber(item.amount),
                                price = itemPrice,
                            }
                        else
                            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.pricetoolarge"), 'error', 5000)
                            return
                        end
                    else
                        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.invalidprice"), 'error', 5000)
                        return
                    end
                else
                    NewStock[#NewStock+1] = {
                        name = item.name,
                        amount = tonumber(item.amount),
                        price = tonumber(item.price),
                    }
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.shopnotfound"), 'error', 5000)
        return
    end
    
    MySQL.Async.execute("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.pricechanged"), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.updatefailed"), 'error', 5000)
        end
    end)
end)

 -- INCREASE PRICES BY %

RegisterNetEvent('flex-ownedshops:server:startincrease', function(shopname, increase)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shop = MySQL.Sync.fetchScalar('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}
    
    if shop then
        local items = json.decode(shop)
        if items then
            for _, item in pairs(items) do
                local increasedPrice = math.ceil(item.price * (1 + increase / 100))
                NewStock[#NewStock+1] = {
                    name = item.name,
                    amount = tonumber(item.amount),
                    price = increasedPrice,
                }
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.shopnotfound"), 'error', 5000)
        return
    end
    
    MySQL.Async.execute("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.priceincrease"), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.updatefailed"), 'error', 5000)
        end
    end)
end)



 -- LOADING INVENTORY

QBCore.Functions.CreateCallback("flex-ownedshop:server:loadinv", function(source, cb)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if Player.PlayerData.items and next(Player.PlayerData.items) ~= nil then
        local filteredItems = {}
        for itemName, itemAmount in pairs(Player.PlayerData.items) do
            if not (Config.InventoryBlacklist and Config.BlacklistItems[itemName]) then
                filteredItems[itemName] = itemAmount
            end
        end
        cb(filteredItems)
    else
        QBCore.Functions.Notify(Lang:t("info.emptyinventory"), "info", 4500) 
        cb(false)
    end
end)

 -- CHECKS TO SEE IF PLAYER CAN BUY A SHOP

RegisterNetEvent('flex-ownedshops:server:buyshop', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if src == nil or Player == nil then
        return
    end

    local result = MySQL.Sync.fetchAll('SELECT owner, owned FROM ownedshops WHERE shopname = ?', { data.shopname })

    if result[1] then
        local BankMoney = Player.PlayerData.money['bank']
        local CashMoney = Player.PlayerData.money['cash']

        local HasMoney = false

        if BankMoney >= data.shopprice then
            HasMoney = true
            Player.Functions.RemoveMoney("bank", data.shopprice, "Purchase of shop: " .. data.shopname)
        elseif CashMoney >= data.shopprice then
            HasMoney = true
            Player.Functions.RemoveMoney("cash", data.shopprice, "Purchase of shop: " .. data.shopname)
        end

        if HasMoney then
            MySQL.Async.execute('UPDATE ownedshops SET owner = @owner, owned = 1 WHERE shopname = @shopname', {
                ['@owner'] = Player.PlayerData.citizenid,
                ['@shopname'] = data.shopname
            })
            
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.boughtshop", {value = data.shopprice}), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.broke"), 'error', 5000)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.notforsale"), 'error', 5000)
    end
end)

 -- CHECKS TO SEE IF PLAYER IS OWNER

QBCore.Functions.CreateCallback('flex-ownedshop:server:isowner', function(source, cb, shopname)
    local Player = QBCore.Functions.GetPlayer(source)
    
    if not Player then
        cb(false)
        return
    end

    local job = Player.PlayerData.job
    local gang = Player.PlayerData.gang

    local shopConfig = nil
    for _, shop in pairs(Config.Shops) do
        if shop.shopname == shopname then
            shopConfig = shop
            break
        end
    end

    if not shopConfig then
        cb(false)
        return
    end

    if shopConfig.isjob and shopConfig.isjob.name ~= '' and shopConfig.isjob.name == job.name and job.grade.level >= shopConfig.isjob.minrank then
        cb(true)
        return
    end

    if shopConfig.isgang and shopConfig.isgang.name ~= '' and shopConfig.isgang.name == gang.name then
        cb(true)
        return
    end

    if shopConfig.isjob.name == '' and shopConfig.isgang.name == '' then
        local ownerResult = MySQL.Sync.fetchAll('SELECT owner FROM ownedshops WHERE shopname = ?', {shopname})
        if ownerResult[1] and ownerResult[1].owner == Player.PlayerData.citizenid then
            cb(true)
            return
        end
    end

    cb(false)
end)

 -- ADDING INVENTORY TO SHOP

RegisterNetEvent('flex-ownedshops:server:restock', function(itemname, amount, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.Functions.RemoveItem(itemname, amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemname], "remove", amount)

        local shopData = MySQL.Sync.fetchAll('SELECT * FROM ownedshops WHERE shopname = ?', { shopname })

        if shopData and shopData[1] then
            local NewStock = {}
            local alreadyadded = false
            local items = json.decode(shopData[1].stock) or {}

            for _, item in ipairs(items) do
                if item.name == itemname then
                    NewStock[#NewStock + 1] = {
                        name = itemname,
                        amount = tonumber(item.amount) + amount,
                        price = item.price or 0,
                    }
                    alreadyadded = true
                else
                    NewStock[#NewStock + 1] = item
                end
            end

            if not alreadyadded then
                NewStock[#NewStock + 1] = {
                    name = itemname,
                    amount = amount,
                    price = 0,
                }
            end

            MySQL.Async.execute('UPDATE ownedshops SET stock = ? WHERE shopname = ?', { json.encode(NewStock), shopname })
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.stockrefilled"), 'success', 5000)
        else
            local NewStock = {
                {
                    name = itemname,
                    amount = amount,
                    price = 0,
                }
            }

            MySQL.Async.insert('INSERT INTO ownedshops (shopname, owner, stock) VALUES (?, ?, ?)', { shopname, '', json.encode(NewStock) })
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.stockrefilled"), 'success', 5000)
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
end)

-- BUYING ITEMS FROM SHOP AND DEPOSITING IN JOB, GANG, OR SHOP BANK 

RegisterNetEvent('flex-ownedshops:server:buy', function(itemName, itemAmount, price, label, shopName, jobName, gangName)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local totalCost = price * itemAmount
    local bankMoney = Player.PlayerData.money.bank
    local cashMoney = Player.PlayerData.money.cash

    if bankMoney >= totalCost then
        Player.Functions.RemoveMoney("bank", totalCost, "Purchased from shop: " .. shopName)
    elseif cashMoney >= totalCost then
        Player.Functions.RemoveMoney("cash", totalCost, "Purchased from shop: " .. shopName)
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.broke"), 'error', 5000)
        return
    end

    local shopQuery = MySQL.prepare.await('SELECT stock, owner, bank_account_balance, bank FROM ownedshops WHERE shopname = ?', {shopName})
    if not shopQuery then
        TriggerClientEvent('QBCore:Notify', src, "Shop not found.", 'error', 5000)
        return
    end

    local bankSetting = shopQuery.bank
    local owner = shopQuery.owner
    local newStock = {}
    local items = json.decode(shopQuery.stock)
    local itemFound = false

    for _, item in ipairs(items) do
        if item.name == itemName then
            itemFound = true
            if item.amount - itemAmount >= 0 then
                local remainingAmount = item.amount - itemAmount
                if remainingAmount > 0 or not Config.DeleteOOS then
                    newStock[#newStock + 1] = {
                        name = itemName,
                        amount = remainingAmount,
                        price = item.price
                    }
                end
            else
                TriggerClientEvent('QBCore:Notify', src, "Not enough stock in the shop.", 'error', 5000)
                return
            end
        else
            newStock[#newStock + 1] = item
        end
    end

    if itemFound then
        MySQL.Sync.execute("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(newStock), shopName})
        Player.Functions.AddItem(itemName, itemAmount)
        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "add", itemAmount)
        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.successbuy", {value = itemAmount, value2 = label, value3 = totalCost}))

        if bankSetting == 1 then
            local newBalance = shopQuery.bank_account_balance + totalCost
            MySQL.Sync.execute("UPDATE ownedshops SET bank_account_balance=? WHERE shopname=?", {newBalance, shopName})
        else
            if Config.Banking == 'fd' then
                exports.fd_banking:AddMoney(owner, totalCost, itemName)
            elseif Config.Banking == 'qb' then
                if Config.Management == 'old' then
                    exports['qb-management']:AddMoney(owner, totalCost)
                elseif Config.Management == 'new' then
                    exports['qb-banking']:AddMoney(owner, totalCost)
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
end)

-- CHANGING PRICE OF ITEMS IN SHOP

RegisterNetEvent('flex-ownedshops:server:setprice', function(itemname, price, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local shop = MySQL.Sync.fetchScalar('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}
    
    if shop then
        local items = json.decode(shop)
        if shop ~= '[]' then
            for slot, item in pairs(items) do
                if item.name == itemname then
                    local itemPrice = tonumber(price)
                    if itemPrice then
                        if Config.MaxPrice.AnyPrice or (not Config.MaxPrice.AnyPrice and itemPrice <= Config.MaxPrice.MaxAmount) then
                            NewStock[#NewStock+1] = {
                                name = itemname,
                                amount = tonumber(item.amount),
                                price = itemPrice,
                            }
                        else
                            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.pricetoolarge"), 'error', 5000)
                            return
                        end
                    else
                        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.invalidprice"), 'error', 5000)
                        return
                    end
                else
                    NewStock[#NewStock+1] = {
                        name = item.name,
                        amount = tonumber(item.amount),
                        price = tonumber(item.price),
                    }
                end
            end
        end
    else
        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.error404item"), 'error', 5000)
    end
    
    MySQL.Async.execute("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname}, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('QBCore:Notify', src, Lang:t("success.pricechanged"), 'success', 5000)
        else
            TriggerClientEvent('QBCore:Notify', src, Lang:t("error.updatefailed"), 'error', 5000)
        end
    end)
end)

 -- REMOVING ITEMS FROM STORE

RegisterNetEvent('flex-ownedshops:server:removestock', function(itemname, amount, shopname)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local shop = MySQL.prepare.await('SELECT stock FROM ownedshops WHERE shopname = ?', { shopname })
    local NewStock = {}

    if shop ~= nil then
        local items = json.decode(shop)
        if items ~= nil then
            for slot, item in pairs(items) do
                if item.name == itemname then
                    if tonumber(item.amount) >= tonumber(amount) then
                        local remainingAmount = tonumber(item.amount) - tonumber(amount)
                        if remainingAmount > 0 then
                            NewStock[#NewStock+1] = {
                                name = itemname,
                                amount = remainingAmount,
                                price = item.price,
                            }
                        end
                        Player.Functions.AddItem(itemname, amount)
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemname], "add", amount)
                        TriggerClientEvent('QBCore:Notify', src, Lang:t("success.removedstock", {value = amount, value2 = QBCore.Shared.Items[itemname].label}), 'success', 5000)
                    else
                        TriggerClientEvent('QBCore:Notify', src, Lang:t("error.notenooughstock"), "error", 4500)
                        return
                    end
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

    MySQL.update.await("UPDATE ownedshops SET stock=? WHERE shopname=?", {json.encode(NewStock), shopname})
end)

 -- CHECKING ACCOUNT BALANCE OF SHOP

RegisterServerEvent('flex-ownedshops:server:getAccountBalance')
AddEventHandler('flex-ownedshops:server:getAccountBalance', function(shopName)
    local source = source
    local currentBalance = 0

    local result = MySQL.Sync.fetchScalar('SELECT bank_account_balance FROM ownedshops WHERE shopname = ?', {shopName})

    if result ~= nil then
        currentBalance = tonumber(result)
    end

    TriggerClientEvent('flex-ownedshops:client:updateAccountBalance', source, currentBalance)
end)

 -- DEPOSIT FUNDS INTO STORE ACCOUNT

RegisterNetEvent('flex-ownedshops:server:depositfunds', function(shopName, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    if Player.PlayerData.money.cash >= amount then
        Player.Functions.RemoveMoney('cash', amount, "Deposited into shop: "..shopName)
        
        local currentBalance = MySQL.Sync.fetchScalar('SELECT bank_account_balance FROM ownedshops WHERE shopname = ?', {shopName})
        if currentBalance then
            local newBalance = currentBalance + amount
            
            MySQL.Sync.execute('UPDATE ownedshops SET bank_account_balance = ? WHERE shopname = ?', {newBalance, shopName})
            TriggerClientEvent('QBCore:Notify', src, "Deposit successful.", "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Shop not found.", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Not enough cash.", "error")
    end
end)

 -- WTIHDRAW MONEY FROM SHOP ACCOUNT

RegisterNetEvent('flex-ownedshops:server:withdrawfunds')
AddEventHandler('flex-ownedshops:server:withdrawfunds', function(shopName, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)

    local currentBalance = MySQL.Sync.fetchScalar('SELECT bank_account_balance FROM ownedshops WHERE shopname = ?', {shopName})
    if currentBalance then
        currentBalance = tonumber(currentBalance) 
        if currentBalance and currentBalance >= amount then 
            local newBalance = currentBalance - amount
            MySQL.Sync.execute('UPDATE ownedshops SET bank_account_balance = ? WHERE shopname = ?', {newBalance, shopName})
            Player.Functions.AddMoney('cash', amount, "Withdrew from shop: "..shopName)
            TriggerClientEvent('QBCore:Notify', src, "Withdrawal successful.", "success")
        else
            TriggerClientEvent('QBCore:Notify', src, "Shop does not have enough funds.", "error")
        end
    else
        TriggerClientEvent('QBCore:Notify', src, "Shop not found.", "error")
    end
end)

 -- ON / OFF DITY

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
