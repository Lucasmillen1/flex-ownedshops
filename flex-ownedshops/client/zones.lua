local QBCore = exports['qb-core']:GetCoreObject()

local ShopZones = {}
local DutyZones = {}
local TargetZones = {}
local BuyZone = {}
local ManagementZones = {}
local PurchaseZone = {} 
local Peds = {}
local Machines = {}

 -- BORING 

 AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        PlayerJob = QBCore.Functions.GetPlayerData().job
        PlayerGang = QBCore.Functions.GetPlayerData().gang
        onDuty = PlayerJob.onduty
        InitiateZones()
    end
end)

function InitiateZones()
    for k, v in pairs(Config.Shops) do
        CreateDutyZone(k, v)
        CreateManagementZone(k, v)
        CreatePurchaseZone(k, v)
        CreateVendingMachineAndPed(k, v)
        CreateBuyZone(k, v)
    end
end

function CreateDutyZone(index, shop)
    if shop.isjob.name ~= false and shop.isjob.dutyloc ~= nil then
        local dloc = vec3(shop.isjob.dutyloc.x, shop.isjob.dutyloc.y, shop.isjob.dutyloc.z)
        DutyZones[index] = BoxZone:Create(dloc, 1.0, 1.0, {
            name = shop.shopname .. '_dutyloc',
            useZ = true,
            heading = shop.isjob.dutyloc.w,
            debugPoly = Config.Debug
        })

        DutyZones[index]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText('[E] - '..Lang:t("info.dutychange"), 'left')
                while isPointInside do
                    if IsControlJustReleased(0, 38) and DutyZones[index]:isPointInside(GetEntityCoords(PlayerPedId())) then
                        QBCore.Functions.TriggerCallback('flex-ownedshop:server:isowner', function(owner)
                            if (owner == 1) or
                               (shop.isjob.name ~= false and PlayerJob.name == shop.isjob.name and PlayerJob.grade.level >= shop.isjob.minrank)
                            then
                                exports['qb-core']:KeyPressed()
                                exports['qb-core']:HideText()
                                local PlayData = QBCore.Functions.GetPlayerData()
                                onDuty = not PlayData.job.onduty
                                TriggerServerEvent('flex-ownedshops:server:changeDuty', not PlayData.job.onduty)
                            end
                        end, shop.shopname)
                    end
                    Wait(0)
                end
            else
                exports['qb-core']:HideText()
            end
        end)
    end
end

function CreateManagementZone(index, shop)
    local mloc = vec3(shop.manageloc.x, shop.manageloc.y, shop.manageloc.z)
    ManagementZones[index] = BoxZone:Create(mloc, shop.boxzone.depth, shop.boxzone.width, {
        name = shop.shopname .. '_manageloc',
        useZ = true,
        heading = shop.manageloc.w,
        debugPoly = Config.Debug
    })

    ManagementZones[index]:onPlayerInOut(function(isPointInside)
        if isPointInside then
            exports['qb-core']:DrawText('[E] - '..Lang:t("info.manageshop"), 'left')
            while isPointInside do
                if IsControlJustReleased(0, 38) and ManagementZones[index]:isPointInside(GetEntityCoords(PlayerPedId())) then
                    exports['qb-core']:KeyPressed()
                    exports['qb-core']:HideText()
                    QBCore.Functions.TriggerCallback('flex-ownedshop:server:isowner', function(isOwner)
                        if isOwner then
                            TriggerEvent('flex-ownedshops:client:manageshop', shop.shopname)
                        else
                            QBCore.Functions.Notify(Lang:t("error.notauthorized"), "error", 4500)
                        end
                    end, shop.shopname)
                end
                Wait(0)
            end
        else
            exports['qb-core']:HideText()
        end
    end)
end

function CreatePurchaseZone(index, shop)
    if shop.purchaseloc then
        local ploc = vec3(shop.purchaseloc.x, shop.purchaseloc.y, shop.purchaseloc.z)
        PurchaseZone[index] = BoxZone:Create(ploc, shop.boxzone.depth, shop.boxzone.width, {
            name = shop.shopname .. '_purchaseloc',
            useZ = true,
            heading = shop.purchaseloc.w,
            debugPoly = Config.Debug
        })

        PurchaseZone[index]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText('[E] - '..Lang:t("info.buyshop"), 'left')
                while isPointInside do
                    if IsControlJustReleased(0, 38) and PurchaseZone[index]:isPointInside(GetEntityCoords(PlayerPedId())) then
                        exports['qb-core']:KeyPressed()
                        exports['qb-core']:HideText()

                        QBCore.Functions.TriggerCallback('flex-ownedshop:server:checkShopOwnership', function(isOwned)
                            if not isOwned then
                                TriggerEvent('flex-ownedshops:client:buyshop', shop.shopname, shop.shopprice)
                            else
                                QBCore.Functions.Notify(Lang:t("error.alreadyowned"), 'error', 5000)
                            end
                        end, shop.shopname)
                    end
                    Wait(0)
                end
            else
                exports['qb-core']:HideText()
            end
        end)
    end
end

function CreateVendingMachineAndPed(index, shop)
    if shop.machine.model ~= nil then
        Machines[index] = CreateObject(shop.machine.model, shop.buyloc.x + shop.machine.offset.x, shop.buyloc.y + shop.machine.offset.y, shop.buyloc.z + shop.machine.offset.z, true, true, true)
        PlaceObjectOnGroundProperly(Machines[index])
        SetEntityHeading(Machines[index], shop.buyloc.w)
    end

    if shop.ped.model ~= nil then
        local model = GetHashKey(shop.ped.model)
        while not HasModelLoaded(model) do
            RequestModel(model)
            Wait(0)
        end
        Peds[index] = CreatePed(0, model, shop.buyloc.x, shop.buyloc.y, shop.buyloc.z - 1.0, shop.buyloc.w, false, false)
        TaskStartScenarioInPlace(Peds[index], shop.ped.scenario, 0, true)
        FreezeEntityPosition(Peds[index], true)
        SetEntityInvincible(Peds[index], true)
        SetEntityCollision(Peds[index], true, true)
        SetBlockingOfNonTemporaryEvents(Peds[index], true)
    end
end

function CreateBuyZone(index, shop)
    local bloc = vec3(shop.buyloc.x, shop.buyloc.y, shop.buyloc.z)
    if shop.target then
        TargetZones[index] = exports['qb-target']:AddBoxZone(shop.shopname .. '_buyloc', bloc, shop.boxzone.depth, shop.boxzone.width, {
            name = shop.shopname .. '_buyloc',
            heading = shop.buyloc.w,
            debugPoly = Config.Debug,
            minZ = bloc.z - shop.boxzone.minZ,
            maxZ = bloc.z + shop.boxzone.maxZ,
        }, {
            options = {
                {
                    type = "client",
                    icon = "fas fa-sign-in-alt",
                    label = Lang:t("info.openshop"),
                    action = function()
                        OpenShop(shop.shopname)
                    end,
                },
            },
            distance = 2.5
        })
    else
        BuyZone[index] = BoxZone:Create(bloc, shop.boxzone.depth, shop.boxzone.width, {
            name = shop.shopname .. '_buyloc',
            useZ = true,
            heading = shop.buyloc.w,
            debugPoly = Config.Debug
        })

        BuyZone[index]:onPlayerInOut(function(isPointInside)
            if isPointInside then
                exports['qb-core']:DrawText('[E] - '..Lang:t("info.openshop"), 'left')
                while isPointInside do
                    if IsControlJustReleased(0, 38) and BuyZone[index]:isPointInside(GetEntityCoords(PlayerPedId())) then
                        exports['qb-core']:KeyPressed()
                        exports['qb-core']:HideText()
                        OpenShop(shop.shopname)
                    end
                    Wait(0)
                end
            else
                exports['qb-core']:HideText()
            end
        end)
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    DestroyAllZones()
    for k in pairs(Machines) do DeleteEntity(Machines[k]) end
    for k, v in pairs(Peds) do DeleteEntity(v) end
end)

DestroyAllZones = function()
    for k in pairs(ShopZones) do ShopZones[k]:destroy() end
    for k in pairs(DutyZones) do DutyZones[k]:destroy() end
    for k in pairs(ManagementZones) do ManagementZones[k]:destroy() end
    for k in pairs(PurchaseZone) do PurchaseZone[k]:destroy() end
    for k in pairs(BuyZone) do BuyZone[k]:destroy() end
    for k in pairs(TargetZones) do exports['qb-target']:RemoveZone(TargetZones[k]) end
end


