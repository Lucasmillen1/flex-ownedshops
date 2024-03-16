Config = {}


Config.Debug = false -- Enable debug mode for logging (true/false)

Config.inventorylink = 'qb-inventory/html/images/' -- Path for inventory images, change to whatever your pathway is

Config.Banking = 'qb' -- Banking system used: 'fd' for fd_banking, 'qb' for qb-banking

Config.Management = 'new' -- Management system used: 'new' for qb-banking management, 'old' for qb-management


-- List of shops with their properties

Config.Shops = {
    [1] = {
        shopname = 'testing',  -- Name of the shop
        bank = 'true',  -- True = money gets deposited into store account, false = society account
        shopprice = 1000,  -- Price of the shop (gang or job-owned shops don't change price)
        manageloc = vector4(-321.62, 6193.39, 31.48, 249),  -- Location to manage the shop
        buyloc = vector4(-314.82, 6200.14, 31.51, 339),  -- Location to buy items from the shop
        target = false,  -- Spawn a vending machine at buyloc to target (leave false until update)
        isjob = {
            name = 'police',  -- Job associated with the shop, false if gang true
            everyone = true,  -- All ranks can access if true
            dutyloc = nil,  -- Location for duty access (nil to disable)
        },
        isgang = {
            name = false,  -- Gang associated with the shop (false to disable gang)
            everyone = false,  -- All ranks can access if true
        },
        machine = {
            model = nil,  -- Vending machine model or nil (leave nil, this is in testing!!)
            offset = {  -- Offset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14',  -- Ped model or nil to disable
            scenario = 'WORLD_HUMAN_CLIPBOARD',  -- Scenario for the ped
        },
        boxzone = {
            width = 2.0,  -- Width of the target/box zone
            depth = 2.0,  -- Depth of the target/box zone
            minZ = 2.0,  -- Min Z of the target zone (no need if not target)
            maxZ = 1.0,  -- Max Z of the target zone (no need if not target)
        },
    },
    [2] = {
        shopname = '247shop',  -- Name of the shop
        bank = 'true',  -- True = money gets deposited into store account, false = society account
        shopprice = 50000,  -- Price of the shop (gang or job-owned shops don't need a price)
        manageloc = vector4(-305.25, 6211.41, 31.48, 214),  -- Location to manage the shop
        buyloc = vector4(-310.05, 6207.30, 31.44, 220),  -- Location to buy items from the shop
        target = false,  -- Spawn a vending machine at buyloc to target (leave false until update)
        isjob = {
            name = 'realestate',  -- Job associated with the shop, false if gang true
            everyone = true,  -- All ranks can access if true
            dutyloc = vector4(-205.95, -627.39, 48.22, 248.61),  -- Location for duty access (nil to disable)
        },
        isgang = {
            name = false,  -- Gang associated with the shop (false to disable gang)
            everyone = false,  -- All ranks can access if true
        },
        machine = {
            model = nil,  -- Vending machine model or nil
            offset = {  -- Offset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14',  -- Vending machine model or nil (leave nil, this is in testing!!)
            scenario = 'WORLD_HUMAN_CLIPBOARD',  -- Scenario for the ped
        },
        boxzone = {
            width = 2.0,  -- Width of the target/box zone
            depth = 2.0,  -- Depth of the target/box zone
            minZ = 2.0,  -- Min Z of the target zone (no need if not target)
            maxZ = 1.0,  -- Max Z of the target zone (no need if not target)
        },
    },
}
