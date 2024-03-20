local QBCore = exports['qb-core']:GetCoreObject()
local PlayerJob = {}
local PlayerGang = {}
local onDuty = false

  -- BORING 

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = PlayerJob.onduty
    SetTimeout(3000, function()
        InitiateZones()
    end)
end)

  -- BORING 

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = JobInfo.onduty
end)

  -- BORING 

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

 -- CORRECT MONEY FORMAT

function formatMoney(amount)
    local formatted = tostring(amount)
    
    formatted = formatted:match("([^.]*).?")

    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    
    return formatted
end


  -- MAIN SHOP MENU

RegisterNetEvent('flex-ownedshops:client:manageshop', function(shopid)
    local ManagementMenu = {
        {
            header = Lang:t("managemenu.header"),
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        },
        {
            header = Lang:t("managemenu.checkstock"),
            icon = "fa-solid fa-list",
            params = {
                event = "flex-ownedshops:client:checkstock",
                args = {
                    shopname = shopid
                },
            }
        },
        {
            header = Lang:t("managemenu.managepricing"),
            icon = "fa-solid fa-tags",
            params = {
                event = "flex-ownedshops:client:managepricing",
                args = {
                    shopname = shopid
                },
            }
        },
        {
            header = Lang:t("managemenu.restock"),
            icon = "fa-solid fa-list",
            params = {
                event = "flex-ownedshops:client:checkinv",
                args = {
                    shopname = shopid
                },
            }
        },
        {
            header = Lang:t("managemenu.removestock"),
            icon = "fa-solid fa-list",
            params = {
                event = "flex-ownedshops:client:removestock",
                args = {
                    shopname = shopid
                },
            }
        },
        {
            header = Lang:t("managemenu.managefunds"),
            icon = "fa-solid fa-money-bill-wave",
            params = {
                event = "flex-ownedshops:client:managefunds",
                args = {
                    shopname = shopid
                },
            }
        },
        {
            header = Lang:t("managemenu.close"),
            icon = "fa-solid fa-angle-left",
            params = {
                event = "qb-menu:closeMenu",
            }
        },
    }

    exports['qb-menu']:openMenu(ManagementMenu)
end)

RegisterNetEvent('flex-ownedshops:client:managepricing', function(data)
    local PricingMenu = {
        {
            header = Lang:t("managemenu.pricingheader"),
            isMenuHeader = true,
        },
        {
            header = Lang:t("managemenu.changesingleprice"),
            params = {
                event = "flex-ownedshops:client:changesingleprice",
                args = {
                    shopname = data.shopname
                },
            }
        },
        {
            header = Lang:t("managemenu.storewidesale"),
            params = {
                event = "flex-ownedshops:client:startsale",
                args = {
                    shopname = data.shopname
                },
            }
        },
        {
            header = Lang:t("managemenu.storewideincrease"),
            params = {
                event = "flex-ownedshops:client:startincrease",
                args = {
                    shopname = data.shopname
                },
            }
        },
        {
            header = Lang:t("managemenu.goback"),
            params = {
                event = 'flex-ownedshops:client:manageshop',
                args = data.shopname
            }
        }
    }
    exports['qb-menu']:openMenu(PricingMenu)
end)

RegisterNetEvent('flex-ownedshops:client:changesingleprice', function(data)
    QBCore.Functions.TriggerCallback('flex-ownedshop:server:loadshop', function(items)
        if items then
            local inventory = {
                {
                    header = Lang:t("managemenu.selectitem"),
                    isMenuHeader = true,
                },
            }
            local itemlist = {}
            for _, v in pairs(json.decode(items)) do
                if tonumber(v.amount) > 0 then
                    itemlist[v.name] = {
                        amount = tonumber(v.amount),
                        price = tonumber(v.price),
                    }
                end
            end
            for k, v in pairs(itemlist) do
                local item = {}
                item.header = "<img src=nui://" .. Config.inventorylink .. QBCore.Shared.Items[k].image .. " width=35px style='margin-right: 10px'> " .. QBCore.Shared.Items[k].label .. " (" .. v.amount .. ")"
                item.text = Lang:t("managemenu.currentprice") .. ": $" .. v.price
                item.params = {
                    event = 'flex-ownedshops:client:setprice',
                    args = {
                        item = k,
                        shopname = data.shopname,
                    }
                }
                table.insert(inventory, item)
            end
            local goback = {
                header = Lang:t("managemenu.goback"),
                params = {
                    event = 'flex-ownedshops:client:managepricing',
                    args = {
                        shopname = data.shopname
                    }
                }
            }
            table.insert(inventory, goback)
            exports['qb-menu']:openMenu(inventory)
        else
            QBCore.Functions.Notify(Lang:t("info.emptyshop"), "info", 4500)
        end
    end, data.shopname)
end)

 -- RUN A DISCOUNT 

RegisterNetEvent('flex-ownedshops:client:startsale', function(data)
    local discount = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.discountamount'),
        submitText = Lang:t('managemenu.startsale'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.enterpercentage')
            }
        }
    })
    if discount then
        if tonumber(discount.amount) > 0 and tonumber(discount.amount) <= 100 then
            TriggerServerEvent('flex-ownedshops:server:startsale', data.shopname, tonumber(discount.amount))
        else
            QBCore.Functions.Notify(Lang:t("error.invalidpercentage"), "error", 4500)
        end
    end
end)

 -- PURCHASE SHOP MENU

RegisterNetEvent('flex-ownedshops:client:buyshop', function(shopid, price)
    local BuyShop = {
        {
            header = Lang:t("managemenu.buyshopheader"),
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        },
        {
            header = Lang:t("managemenu.buyshop", {value = "$" .. formatMoney(price)}),
            icon = "fa-solid fa-list",
            params = {
                isServer = true,
                event = "flex-ownedshops:server:buyshop",
                args = {
                    shopname = shopid,
                    shopprice = price
                },
            }
        },
        {
            header = Lang:t("managemenu.close"),
            icon = "fa-solid fa-angle-left",
            params = {
                event = "qb-menu:closeMenu",
            }
        },
    }
    exports['qb-menu']:openMenu(BuyShop)
end)

 -- ADDING ITEMS TO SHOP

RegisterNetEvent('flex-ownedshops:client:restock', function(data)
    local restock = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.stockamount', {value = data.label, value2 = data.amount}),
        submitText = Lang:t('managemenu.confirm'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.amountstock')
            }
        }
    })
    if restock then
        if tonumber(data.amount) >= tonumber(restock.amount) then
            TriggerServerEvent('flex-ownedshops:server:restock', data.item, restock.amount, data.shopname)
            QBCore.Functions.Notify(Lang:t("success.refillstock",{value = restock.amount, value2 = data.label}), "success", 4500)
        else
            QBCore.Functions.Notify(Lang:t("error.notenooughinv"), "error", 4500)
        end
    end
end)

 -- REMOVE STOCK MENU

RegisterNetEvent('flex-ownedshops:client:removestock', function(data)
    QBCore.Functions.TriggerCallback('flex-ownedshop:server:loadshop', function(items)
        if items then
            local inventory = {
                {
                    header = Lang:t("managemenu.removestock"),
                    isMenuHeader = true,
                },
            }
            local itemlist = {}
            for _, v in pairs(json.decode(items)) do
                if tonumber(v.amount) > 0 then 
                    itemlist[v.name] = {
                        amount = tonumber(v.amount),
                        price = tonumber(v.price),
                    }
                end
            end
            for k, v in pairs(itemlist) do
                local item = {}
                item.header = "<img src=nui://" .. Config.inventorylink .. QBCore.Shared.Items[k].image .. " width=35px style='margin-right: 10px'> " .. QBCore.Shared.Items[k].label .. " (" .. v.amount .. ")"
                item.params = {
                    event = 'flex-ownedshops:client:removeamount',
                    args = {
                        item = k,
                        shopname = data.shopname,
                        amount = v.amount,
                    }
                }
                table.insert(inventory, item)
            end
            local goback = {
                header = Lang:t("managemenu.goback"),
                icon = "fa-solid fa-angle-left",
                params = {
                    event = 'flex-ownedshops:client:manageshop',
                    args = data.shopname
                }
            }
            table.insert(inventory, goback)
            exports['qb-menu']:openMenu(inventory)
        else
            QBCore.Functions.Notify(Lang:t("info.emptyshop"), "info", 4500)
        end
    end, data.shopname)
end)

 -- REMOVE AMOUNT

RegisterNetEvent('flex-ownedshops:client:removeamount', function(data)
    local remove = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.removeamount', {value = QBCore.Shared.Items[data.item].label, value2 = data.amount}),
        submitText = Lang:t('managemenu.confirm'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.amountremove')
            }
        }
    })
    if remove then
        if tonumber(data.amount) >= tonumber(remove.amount) then
            TriggerServerEvent('flex-ownedshops:server:removestock', data.item, remove.amount, data.shopname)
        else
            QBCore.Functions.Notify(Lang:t("error.notenooughstock"), "error", 4500)
        end
    end
end)

 -- OPEN SHOP MENU (CUSTOMER POV)

function OpenShop(shopid, job, gang)
    QBCore.Functions.TriggerCallback('flex-ownedshop:server:loadshop', function(items)
        if items then
            local store = {
                {
                    header = Lang:t("managemenu.buyheader"),
                    isMenuHeader = true,
                },
            }
            local itemlist = {}
            for _, v in pairs(json.decode(items)) do
                if itemlist[v['name']] then
                    itemlist[v['name']].amount = itemlist[v['name']].amount --+ tonumber(v['amount'])
                else
                    itemlist[v['name']] = {
                        amount = tonumber(v['amount']),
                        price = tonumber(v['price'])
                    }
                end
            end
            for k, v in pairs(itemlist) do
                local item = {}
                item.header = "<img src=nui://"..Config.inventorylink..QBCore.Shared.Items[k].image.." width=35px style='margin-right: 10px'> " .. QBCore.Shared.Items[k].label
                local text = Lang:t("managemenu.amount") .. v.amount .. ' </br> ' .. Lang:t("managemenu.priceperlabel", {value = '$' .. formatMoney(v.price)})
                item.text = text
                item.params = {
                    event = 'flex-ownedshops:client:buy',
                    args = {
                        item = k,
                        amount = v.amount,
                        label = QBCore.Shared.Items[k].label,
                        price = v.price,
                        shopname = shopid,
                        jobname = job,
                        gangname = gang,
                    }
                }
                table.insert(store, item)
            end
            exports['qb-menu']:openMenu(store)
        else
            QBCore.Functions.Notify(Lang:t("info.emptyshop"), "info", 4500)
        end
    end, shopid)
end
exports('OpenShop', OpenShop)

 -- AMOUNT CUSTOMER IS BUYING MENU

RegisterNetEvent('flex-ownedshops:client:buy', function(data)
    local buying = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.buyamount', {value = data.label, value2 = '$' .. formatMoney(data.price), value3 = data.amount}),
        submitText = Lang:t('managemenu.buy'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.amountstock')
            }
        }
    })
    if buying then
        if tonumber(data.amount) >= tonumber(buying.amount) then
            if tonumber(buying.amount) > 0 then
                TriggerServerEvent('flex-ownedshops:server:buy', data.item, buying.amount, data.price, data.label, data.shopname, data.jobname, data.gangname)
            else
                QBCore.Functions.Notify(Lang:t("error.buycantbezero"), "error", 4500)
            end
        else
            QBCore.Functions.Notify(Lang:t("error.notenooughstock"), "error", 4500)
        end
    end
end)

 -- CHANGE PRICE OF ITEM

RegisterNetEvent('flex-ownedshops:client:setprice')
AddEventHandler('flex-ownedshops:client:setprice', function(data)
    local price = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.whatprice', {value =  QBCore.Shared.Items[data.item].label}),
        submitText = Lang:t('managemenu.setprice'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.howmuch')
            }
        }
    })
    if price then
        if tonumber(price.amount) >= 0 then
            TriggerServerEvent('flex-ownedshops:server:setprice', data.item, price.amount, data.shopname)
        else
            QBCore.Functions.Notify(Lang:t("error.nonegativeprice"), "error", 4500)
        end
    end
end)

 -- MONEY MANAGEMENT MENU

RegisterNetEvent('flex-ownedshops:client:managefunds')
AddEventHandler('flex-ownedshops:client:managefunds', function(args)
    if args and args.shopname then
        local shopname = args.shopname

        TriggerServerEvent('flex-ownedshops:server:getAccountBalance', shopname)

        local currentBalance = nil

        RegisterNetEvent('flex-ownedshops:client:updateAccountBalance')
        AddEventHandler('flex-ownedshops:client:updateAccountBalance', function(balance)
            currentBalance = balance

            local formattedBalance = formatMoney(currentBalance)

            local headerString = Lang:t("managefunds.header", { shopname = shopname }) .. " - $" .. formattedBalance

            local manageFundsMenu = {
                {
                    header = headerString,
                    isMenuHeader = true,
                },
                {
                    header = Lang:t("managefunds.deposit"),
                    txt = Lang:t("managefunds.depositdesc"),
                    params = {
                        event = "flex-ownedshops:client:depositfunds",
                        args = {
                            shopname = shopname
                        },
                    }
                },
                {
                    header = Lang:t("managefunds.withdraw"),
                    txt = Lang:t("managefunds.withdrawdesc"),
                    params = {
                        event = "flex-ownedshops:client:withdrawfunds",
                        args = {
                            shopname = shopname
                        },
                    }
                },
                {
                    header = Lang:t("managefunds.close"),
                    params = {
                        event = "qb-menu:closeMenu",
                    }
                },
            }

            exports['qb-menu']:openMenu(manageFundsMenu)
        end)
    end
end)

 -- TAKE MONEY OUT OF SHOP

RegisterNetEvent('flex-ownedshops:client:withdrawfunds')
AddEventHandler('flex-ownedshops:client:withdrawfunds', function(args)
    if args and args.shopname then
        local shopname = args.shopname

        local withdraw = exports['qb-input']:ShowInput({
            header = Lang:t("managefunds.withdrawheader", {shopname = shopname}),
            submitText = Lang:t("managefunds.withdrawsubmit"),
            inputs = {
                {
                    text = Lang:t("managefunds.withdrawamount"),
                    name = "amount", 
                    type = "number", 
                    isRequired = true,
                },
            }
        })

        if withdraw then
            local amount = tonumber(withdraw.amount)
            if amount and amount > 0 then
                TriggerServerEvent('flex-ownedshops:server:withdrawfunds', shopname, amount)
            else
                QBCore.Functions.Notify(Lang:t("error.invalidamount"), "error")
            end
        end
    else
        print("Error: No shopname provided in args.")
    end
end)

 -- DEPOSIT MONEY


RegisterNetEvent('flex-ownedshops:client:depositfunds')
AddEventHandler('flex-ownedshops:client:depositfunds', function(args)
    if args and args.shopname then
        local shopname = args.shopname

        local deposit = exports['qb-input']:ShowInput({
            header = Lang:t("managefunds.depositheader", {shopname = shopname}),
            submitText = Lang:t("managefunds.depositsubmit"),
            inputs = {
                {
                    text = Lang:t("managefunds.depositamount"),
                    name = "amount", 
                    type = "number", 
                    isRequired = true,
                },
            }
        })

        if deposit then
            if tonumber(deposit.amount) > 0 then
                TriggerServerEvent('flex-ownedshops:server:depositfunds', shopname, tonumber(deposit.amount))
            else
                QBCore.Functions.Notify(Lang:t("error.invalidamount"), "error")
            end
        end
    else
        print("Error: No shopname provided in args.")
    end
end)

 -- CHECKING STOCK 

RegisterNetEvent('flex-ownedshops:client:checkstock', function(data)
    QBCore.Functions.TriggerCallback('flex-ownedshop:server:loadshop', function(items)
        if items then
            local inventory = {
                {
                    header = Lang:t("managemenu.instock"),
                    isMenuHeader = true,
                },
            }
            local itemlist = {}
            for _, v in pairs(json.decode(items)) do
                if itemlist[v.name] then
                    itemlist[v.name].amount = itemlist[v.name].amount + tonumber(v.amount)
                else
                    local price = tonumber(v.price)
                    if price ~= nil then 
                        itemlist[v.name] = {
                            amount = tonumber(v.amount),
                            price = price,
                        }
                    else
                        itemlist[v.name] = {
                            amount = tonumber(v.amount),
                        }
                    end
                end
            end
            for k, v in pairs(itemlist) do
                local item = {}
                item.header = "<img src=nui://" .. Config.inventorylink .. QBCore.Shared.Items[k].image .. " width=35px style='margin-right: 10px'> " .. QBCore.Shared.Items[k].label .. " (" .. v.amount .. ")"
                item.params = {
                    event = 'flex-ownedshops:client:setprice',
                    args = {
                        item = k,
                        shopname = data.shopname,
                    }
                }
                table.insert(inventory, item)
            end
            local goback = {
                header = Lang:t("managemenu.goback"),
                icon = "fa-solid fa-angle-left",
                params = {
                    event = 'flex-ownedshops:client:manageshop',
                    args = data.shopname
                }
            }
            table.insert(inventory, goback)
            exports['qb-menu']:openMenu(inventory)
        else
            QBCore.Functions.Notify(Lang:t("info.emptyshop"), "info", 4500)
        end
    end, data.shopname)
end)

 -- CHECK INVENTORY TO SEE WHAT YOU CAN ADD TO STORE STOCK

RegisterNetEvent('flex-ownedshops:client:checkinv', function(data)
    QBCore.Functions.TriggerCallback('flex-ownedshop:server:loadinv', function(items)
        if items then
            local inventory = {
                {
                    header = Lang:t("managemenu.inventory"),
                    isMenuHeader = true,
                },
            }
            local itemlist = {}
            for k, v in pairs(items) do
                if itemlist[v['name']] then
                    itemlist[v['name']].amount = itemlist[v['name']].amount --+ tonumber(v['amount'])
                else
                    itemlist[v['name']] = {
                        amount = tonumber(v['amount']),
                    }
                end
            end
            for k, v in pairs(itemlist) do
                local item = {}
                item.header = "<img src=nui://"..Config.inventorylink..QBCore.Shared.Items[k].image.." width=35px style='margin-right: 10px'> " .. QBCore.Shared.Items[k].label
                local text = Lang:t("managemenu.amount")..v.amount
                item.text = text
                item.params = {
                    event = 'flex-ownedshops:client:restock',
                    args = {
                        item = k,
                        amount = v.amount,
                        label = QBCore.Shared.Items[k].label,
                        shopname = data.shopname,
                    }
                }
                table.insert(inventory, item)
            end
            
            table.insert(inventory, {
                header = Lang:t("managemenu.goback"),
                txt = "",
                params = {
                    event = "flex-ownedshops:client:manageshop",
                    args = {
                        shopname = data.shopname
                    }
                }
            })

            exports['qb-menu']:openMenu(inventory)
        else
            QBCore.Functions.Notify(Lang:t("info.emptyshop"), "info", 4500)
        end
    end, data.shopname)
end)

 -- INCREASE PRICE OF ALL ITEMS

RegisterNetEvent('flex-ownedshops:client:startincrease', function(data)
    local increase = exports['qb-input']:ShowInput({
        header = Lang:t('managemenu.increaseamount'),
        submitText = Lang:t('managemenu.startincrease'),
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'amount',
                text = Lang:t('managemenu.enterpercentage')
            }
        }
    })
    if increase then
        if tonumber(increase.amount) > 0 and tonumber(increase.amount) <= 100 then
            TriggerServerEvent('flex-ownedshops:server:startincrease', data.shopname, tonumber(increase.amount))
        else
            QBCore.Functions.Notify(Lang:t("error.invalidpercentage"), "error", 4500)
        end
    end
end)
