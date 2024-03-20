Config = {}

Config.Debug = true 						-- IF THIS IS TRUE YOU WILL SEE POLYZONES ITS TO HELP YOU SET UP THE SHOPS

Config.inventorylink = 'qb-inventory/html/images/' 		-- PATH FOR INVENTORY IMAGES, CHANGE TO WHATEVER YOUR PATHWAY IS

Config.Banking = 'qb' 						-- BANKING SYSTEM USED: 'FD' FOR FD_BANKING, 'QB' FOR QB-BANKING

Config.Management = 'old' 					-- MANAGEMENT SYSTEM USED: 'NEW' FOR QB-BANKING MANAGEMENT, 'OLD' FOR QB-MANAGEMENT

Config.DeleteOOS = true 					-- TRUE WILL REMOVE ITEMS FROM STORE IF THEY ARE SOLD OUT, FALSE WILL SHOW ITEM BUT STOCK 0

Config.MaxPrice = {						-- CONTROL PRICES OF ALL SHOPS
	AnyPrice = true,					-- SET TO TRUE IF YOU WANT TO CONTROL PRICING
	MaxAmount = 5000					-- MAX PRICE IF 'ANYPRICE' IS TRUE
}

Config.InventoryBlacklist = false				-- IF TRUE, USES BLACKLIST ITEMS TABLE TO PREVENT PLAYERS FROM ADDING THOSE ITEMS
Config.BlacklistItems = {
	'meth',
	'crack_baggy',
}

-- List of shops with their propertiess


Config.Shops = {

	-- CONFIG FOR JOB RAN STORE, ANYONE WITH JOB CAN ACCESS (DEPENDING ON MINRANK)

    [1] = {
        shopname = 'JOBEXAMPLE',  				-- NAME OF THE SHOP
        purchaseloc = nil, 					-- VECTOR 4 OF WHERE TO PURCHASE SHOP IF PLAYER OWNED
        bank = 'true',  					-- TRUE = MONEY FROM SALES IN SHOP ACCOUNT, FALSE = MONEY TO GANG OR SOCIETY THAT OWNS STORE
        shopprice = 1000,  					-- THIS IS HOW MUCH THE SHOP COSTS IF SOMEONE IS PURCHASING IT
        manageloc = vector4(-61.61, 2915.97, 63.21, 328),  	-- THIS IS WHERE YOU MANAGE THE SHOP AND ACCESS THE MENU
        buyloc = vector4(-64.44, 2912.73, 63.21, 233.94),  	-- THIS IS WHERE YOUR CUSTOMERS WILL ACCESS THE PED OR VENDING MACHINE TO BUY ITEMS
        target = false,  					-- THIRD EYE INSTEAD OF FLEX 'E' AT PED AND MACHINE
        isjob = {
            name = 'police',  					-- JOB YOU WANT IN CHARGE OF SHOP, USE '' IF USING GANG OR PLAYER OWNED
            minrank = 0,  					-- MINIMUM RANK THAT CAN ACCESS SHOP
            dutyloc = nil,  					-- ON / OFF DUTY, dutyloc = nil, TO DISABLE THIS FEATURE
        },
        isgang = {
            name = '',  					-- GANG YOU WANT IN CHARGE OF SHOP, USE '' IF USING JOB OR PLAYER OWNED
            everyone = false,  					--MINIMUM RANK THAT CAN ACCESS SHOP
        },
        machine = {
            model = nil,  					-- MODEL OF VENDING MACHINE, nil IF USING PED, model = 'prop_vend_snak_01', (YOU CAN CHANGE OBJECT TO WHATEVER)
            offset = {  					-- OFFSET TO THE ZONE, DONT TOUCH!
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'csb_tomcasino',  				-- PED MODEL IF MACHINE nil, model = 'ig_mp_agent14', OR WHATEVER MODEL YOU WANT 
            scenario = 'WORLD_HUMAN_CLIPBOARD',  		-- DOESN'T MATTER IF YOU USE PED OR NOT, THIS WONT AFFECT ANYTHING JUST LEAVE IT
        },
        boxzone = {
            width = 2.0,  					-- WIDTH OF TARGET/BOX ZONE
            depth = 2.0,  					-- DEPTH OF TARGET/BOX ZONE
            minZ = 2.0,  					-- MIN Z OF TARGET ZONE (NO NEED TO CHANGE IF target = false,)
            maxZ = 1.0,  					-- MAX Z OF TARGET ZONE (NO NEED TO CHANGE IF target = false,)
        },
    },


	-- CONFIG FOR PLAYER RAN STORE, ONLY PLAYER CAN ACCESS

    [2] = {
        shopname = 'PLAYEROWNEDEXAMPLE',  			-- NAME OF THE SHOP
        purchaseloc = vector4(-298.71, 6254.82, 31.49, 47),     -- VECTOR 4 OF WHERE TO PURCHASE SHOP IF PLAYER OWNED
        bank = 'true',  					-- TRUE = MONEY FROM SALES IN SHOP ACCOUNT, FALSE = MONEY TO GANG OR SOCIETY THAT OWNS STORE
        shopprice = 50000,  					-- Price of the shop (gang or job-owned shops don't need a price)
        manageloc = vector4(-272.74, 6279.84, 31.48, 315.49),  	-- Location to manage the shop
        buyloc = vector4(-266.28, 6251.34, 31.46, 189.05),  	-- Location to buy items from the shop
        target = false,  					-- Spawn a vending machine at buyloc to target (leave false until update)
        isjob = {
            name = '',  					-- Job associated with the shop, false if gang true
            minrank = 0,  					-- All ranks can access if 0, set your minium rank
            dutyloc = vector4(-205.95, -627.39, 48.22, 248.61), -- Location for duty access (nil to disable)
        },
        isgang = {
            name = '',  					-- Gang associated with the shop (false to disable gang)
            everyone = false,  					-- All ranks can access if true
        },
        machine = {
            model = nil,  					-- Vending machine model or nil
            offset = {  					-- Offset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14',  				-- Vending machine model or nil (leave nil, this is in testing!!)
            scenario = 'WORLD_HUMAN_CLIPBOARD',  		-- Scenario for the ped
        },
        boxzone = {
            width = 2.0,  					-- Width of the target/box zone
            depth = 2.0,  					-- Depth of the target/box zone
            minZ = 2.0,  					-- Min Z of the target zone (no need if not target)
            maxZ = 1.0,  					-- Max Z of the target zone (no need if not target)
        },
    },

	-- CONFIG FOR GANG RAN STORE, GANG CAN ACCESS (DEPENDING ON MINRANK)

    [3] = {
        shopname = 'JUSTGANGEXAMPLE',  				-- Name of the shop
        purchaseloc = vector4(-326.17, 6224.16, 31.49, 43), 	--
        bank = false,  						-- True = money gets deposited into store account, false = society account
        shopprice = 50000,  					-- Price of the shop (gang or job-owned shops don't need a price)
        manageloc = vector4(-321.44, 6228.51, 31.49, 314),  	-- Location to manage the shop
        buyloc = vector4(-319.40, 6221.22, 31.33, 194),  	-- Location to buy items from the shop
        target = false,  					-- Spawn a vending machine at buyloc to target (leave false until update)
        isjob = {
            name = '',  					-- Job associated with the shop, false if gang true
            minrank = 0,  					-- All ranks can access if 0, set your minium rank
            dutyloc = vector4(-205.95, -627.39, 48.22, 248.61), -- Location for duty access (nil to disable)
        },
        isgang = {
            name = 'vagos',  					-- Gang associated with the shop (false to disable gang)
            everyone = true,  					-- All ranks can access if true
        },
        machine = {
            model = nil,  					-- Vending machine model or nil
            offset = {  					-- Offset to the zone
                x = 0.0,
                y = 0.0,
                z = 0.0,
            }
        },
        ped = {
            model = 'ig_mp_agent14',  				-- Vending machine model or nil (leave nil, this is in testing!!)
            scenario = 'WORLD_HUMAN_CLIPBOARD',  		-- Scenario for the ped
        },
        boxzone = {
            width = 2.0,  					-- Width of the target/box zone
            depth = 2.0,  					-- Depth of the target/box zone
            minZ = 2.0,  					-- Min Z of the target zone (no need if not target)
            maxZ = 1.0,  					-- Max Z of the target zone (no need if not target)
        },
    },

}
