local QBCore = exports['qb-core']:GetCoreObject()
local ShopZones = {}
local TargetZones = {}
local DutyZones = {}
local Machines = {}
local Peds = {}
local PlayerJob = {}
local PlayerGang = {}
local onDuty = false

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

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        PlayerGang = QBCore.Functions.GetPlayerData().gang
        onDuty = PlayerJob.onduty
        InitiateZones()
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    PlayerGang = QBCore.Functions.GetPlayerData().gang
    PlayerJob = QBCore.Functions.GetPlayerData().job
    onDuty = PlayerJob.onduty
    SetTimeout(3000, function()
        InitiateZones()
    end)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    PlayerJob = JobInfo
    onDuty = JobInfo.onduty
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(InfoGang)
    PlayerGang = InfoGang
end)

function InitiateZones()
    for k, v in pairs(Config.Shops) do
        if v.isjob.name ~= false and v.isjob.dutyloc ~= nil then
            local dloc = vec3(v.isjob.dutyloc.x, v.isjob.dutyloc.y, v.isjob.dutyloc.z)
            DutyZones[#DutyZones..k] = BoxZone:Create(dloc, 1.0, 1.0, {
                name = v.shopname..k..'dutyloc',
                useZ = true,
                heading = v.isjob.dutyloc.w,
                debugPoly = Config.Debug
            })

            DutyZones[#DutyZones..k]:onPlayerInOut(function(isPointInside)
                isInEnterZone = isPointInside
                if isPointInside then
                    exports['qb-core']:DrawText('[E] - '..Lang:t("info.dutychange"), 'left')
                    CreateThread(function()
                        while isInEnterZone do
                            if IsControlJustReleased(0, 38) then
                                QBCore.Functions.TriggerCallback('flex-ownedshop:server:isowner', function(owner)
                                    if (owner == 2) or (v.isjob.name ~= false and PlayerJob.name == v.isjob.name and v.isjob.everyone)
                                    or (v.isjob.name ~= false and PlayerJob.name == v.isjob.name and PlayerJob.isboss)
                                    or (v.isgang.name ~= false and PlayerGang.name == v.isgang.name and not v.isgang.everyone and PlayerGang.isboss)
                                    or (v.isgang.name ~= false and PlayerGang.name == v.isgang.name and v.isgang.everyone) then
                                        exports['qb-core']:KeyPressed()
                                        exports['qb-core']:HideText()
                                        local PlayData = QBCore.Functions.GetPlayerData()
                                        onDuty = not PlayData.job.onduty
                                        TriggerServerEvent('flex-ownedshops:server:changeDuty', not PlayData.job.onduty)
                                    end
                                end, v.shopname)
                            end
                            Wait(0)
                        end
                    end)
                else
                    exports['qb-core']:HideText()
                end
            end)
        end

        local mloc = vec3(v.manageloc.x, v.manageloc.y, v.manageloc.z)
        ShopZones[#ShopZones+1] = BoxZone:Create(mloc, v.boxzone.depth, v.boxzone.width, {
            name = v.shopname..k..'manageloc',
            useZ = true,
            heading = v.manageloc.w,
            debugPoly = Config.Debug
        })

        ShopZones[#ShopZones]:onPlayerInOut(function(isPointInside)
            isInEnterZone = isPointInside
            if isPointInside then
                exports['qb-core']:DrawText('[E] - '..Lang:t("info.manageshop"), 'left')
                CreateThread(function()
                    Wait(500)
                    while isInEnterZone do
                        if IsControlJustReleased(0, 38) then
                            exports['qb-core']:KeyPressed()
                            exports['qb-core']:HideText()
                            QBCore.Functions.TriggerCallback('flex-ownedshop:server:isowner', function(owner)
                                if owner == 2 then
                                    TriggerEvent('flex-ownedshops:client:manageshop', v.shopname)
                                elseif (v.isjob.name ~= false) and (PlayerJob.name == v.isjob.name) and ((v.isjob.everyone) or (PlayerJob.isboss)) or
                                       (v.isgang.name ~= false) and (PlayerGang.name == v.isgang.name) and ((v.isgang.everyone) or (PlayerGang.isboss)) then
                                    if onDuty or v.isgang.name ~= false then
                                        if v.isjob.everyone or v.isgang.everyone then
                                            TriggerEvent('flex-ownedshops:client:manageshop', v.shopname)
                                        else
                                            if PlayerJob.isboss or PlayerGang.isboss then
                                                TriggerEvent('flex-ownedshops:client:manageshop', v.shopname)
                                            else
                                                QBCore.Functions.Notify(Lang:t("error.notboss"), "error", 4500)
                                            end
                                        end
                                    else
                                        QBCore.Functions.Notify(Lang:t("error.notonduty"), "error", 4500)
                                    end
                                elseif owner == 0 and v.isjob.name == false and v.isgang.name == false then
                                    TriggerEvent('flex-ownedshops:client:manageshop', v.shopname)
                                else
                                    QBCore.Functions.Notify(Lang:t("error.notworkinghere"), "error", 4500)
                                end
                            end, v.shopname)
                        end
                        Wait(0)
                    end
                end)
            else
                exports['qb-core']:HideText()
            end
        end)

        if v.machine.model ~= nil then
            Machines[k] = CreateObject(v.machine.model, v.buyloc.x + v.machine.offset.x, v.buyloc.y+ v.machine.offset.y, v.buyloc.z+ v.machine.offset.z, true, true, true)
            PlaceObjectOnGroundProperly(Machines[k])
            SetEntityHeading(Machines[k], v.buyloc.w)
        end

        if v.ped.model ~= nil then
            local model = GetHashKey(v.ped.model)
            while not HasModelLoaded(model) do RequestModel(model) Wait(0); end
            Peds[k] = CreatePed(0, model, v.buyloc.x, v.buyloc.y, v.buyloc.z-1, v.buyloc.w, false, false)
            TaskStartScenarioInPlace(Peds[k], v.ped.scenario, 0, true)
            FreezeEntityPosition(Peds[k], true)
            SetEntityInvincible(Peds[k], true)
            SetEntityCollision(Peds[k], false, true)
            SetBlockingOfNonTemporaryEvents(Peds[k], true)
        end
        if v.target then
            local v3 = vec3(v.buyloc.x, v.buyloc.y, v.buyloc.z)
            TargetZones[v.shopname..k..'buyloc'] = exports['qb-target']:AddBoxZone(v.shopname..k..'buyloc', v3, v.boxzone.depth, v.boxzone.width, {
                name = v.shopname..k..'buyloc',
                heading = v.buyloc.w,
                debugPoly = Config.Debug,
                minZ = v3.z - v.boxzone.minZ,
                maxZ = v3.z + v.boxzone.maxZ,
            }, {
                options = {
                    {
                        type = "client",
                        icon = "fas fa-sign-in-alt",
                        label = Lang:t("info.openshop"),
                        action = function()
                            OpenShop(v.shopname, v.isjob.name, v.isgang.name)
                        end,
                    },
                },
                distance = 2.5
            })
        else
            local v3 = vec3(v.buyloc.x, v.buyloc.y, v.buyloc.z)
            ShopZones[#ShopZones..k] = BoxZone:Create(v3, v.boxzone.depth, v.boxzone.width, {
                name = v.shopname..k..'buyloc',
                useZ = true,
                heading = v.buyloc.w,
                debugPoly = Config.Debug
            })

            ShopZones[#ShopZones..k]:onPlayerInOut(function(isPointInside, point)
                isInEnterZone = isPointInside
                if isPointInside then
                    exports['qb-core']:DrawText('[E] - '..Lang:t("info.openshop"), 'left')
                    CreateThread(function()
                        while isInEnterZone do
                            if IsControlJustReleased(0, 38) then
                                exports['qb-core']:KeyPressed()
                                exports['qb-core']:HideText()
                                OpenShop(v.shopname, v.isjob.name, v.isgang.name)
                            end
                            Wait(0)
                        end
                    end)
                else
                    exports['qb-core']:HideText()
                end
            end)
        end
    end
end

RegisterNetEvent('flex-ownedshops:client:buyshop', function(shopid, price)
    local BuyShop = {
        {
            header = Lang:t("managemenu.buyshopheader"),
            icon = "fa-solid fa-circle-info",
            isMenuHeader = true,
        },
        {
            header = Lang:t("managemenu.buyshop", {value = price}),
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
                if itemlist[v.name] then
                    itemlist[v.name].amount = itemlist[v.name].amount + tonumber(v.amount)
                else
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

AddEventHandler('onResourceStop', function(resource) if resource ~= GetCurrentResourceName() then return end
    for k in pairs(ShopZones) do ShopZones[k]:destroy() end
    for k in pairs(DutyZones) do DutyZones[k]:destroy() end
    for k in pairs(Machines) do DeleteEntity(Machines[k]) end
    for t in pairs(TargetZones) do exports['qb-target']:RemoveZone(t) end
    for k, v in pairs(Peds) do DeleteEntity(v) end
end)
