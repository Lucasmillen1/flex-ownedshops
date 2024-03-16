Config = {}
Config.Debug = true
Config.inventorylink = 'qb-inventory/html/images/' --Path of your inventory images

Config.Banking = 'qb' -- fd for fd_banking / qb for banking

Config.Management = 'new' -- 'new' for qb-banking handling management, 'old' for qb-management


-- Still working on getting none job/gang shops to work, please only use shop with job name.
-- Use ped models, having issues with vending machines endlessly spawning 

Config.Shops = {
    [1] = {
        shopname = 'testing', -- Name of shop
        shopprice = 1000, -- Price of this shop. When it is gang or job owned no need for price
        manageloc = vector4(-321.62, 6193.39, 31.48, 249), -- Place where you manage the shop
        buyloc = vector4(-314.82, 6200.14, 31.51, 339), -- Location to buy from shop
        target = false, -- leave this false for now! If true it will spawn a vendingmachine at buyloc to target on
        isjob = {
            name = 'police', -- false to disable job
            everyone = true, -- true if all ranks can access
            dutyloc = vector4(-205.95, -627.39, 48.22, 248.61), -- nil to disable
        },
        isgang = {
            name = false, -- false to disable gang
            everyone = false, -- true if all ranks can access
        },
        machine = {
            model = nil, -- Modelname or nil
            offset = { -- Ofset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14', -- Name of the ped or nil to disable
            scenario = 'WORLD_HUMAN_CLIPBOARD', -- Scenario the ped will be dpoing
        },
        boxzone = {
            width = 2.0, -- Width of the target / box zone
            depth = 2.0, -- Depth of the target / box zone
            minZ = 2.0, -- Minz of the target zone (No need if not target)
            maxZ = 1.0, -- Maxz of the target zone (No need if not target)
        },
    },
    [2] = {
        shopname = '247shop2', -- Name of shop
        shopprice = 50000, -- Price of this shop. When it is gang or job owned no need for price
        manageloc = vector4(-305.25, 6211.41, 31.48, 214), -- Place where you manage the shop
        buyloc = vector4(-310.05, 6207.30, 31.44, 220), -- Location to buy from shop
        target = false, -- leave this false for now! If true it will spawn a vendingmachine at buyloc to target on
        isjob = {
            name = 'false', -- false to disable job (not working right now)
            everyone = true, -- true if all ranks can access
            dutyloc = nil, -- nil to disable
        },
        isgang = {
            name = false, -- false to disable gang
            everyone = false, -- true if all ranks can access
        },
        machine = {
            model = nil, -- Modelname or nil
            offset = { -- Ofset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14', -- Name of the ped or nil to disable
            scenario = 'WORLD_HUMAN_CLIPBOARD', -- Scenario the ped will be dpoing
        },
        boxzone = {
            width = 2.0, -- Width of the target / box zone
            depth = 2.0, -- Depth of the target / box zone
            minZ = 2.0, -- Minz of the target zone (No need if not target)
            maxZ = 1.0, -- Maxz of the target zone (No need if not target)
        },
    },
}
