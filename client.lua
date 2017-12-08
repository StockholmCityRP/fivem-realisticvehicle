------------------------------------------
--	iEnsomatic RealisticVehicleFailure  --
------------------------------------------
--
--	Created by Jens Sandalgaard
--	
--	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--
--	https://github.com/iEns/RealisticVehicleFailure
--

local damageFactor = 8.0					-- Sane values are 1 to 100. Higher values means more damage to vehicle. A good starting point is 10
local cascadingFailureSpeedFactor = 10.0	-- Sane values are 1 to 100. When vehicle health drops below a certain point, cascading failure sets in, and the health drops rapidly until the vehicle dies. Higher values means faster failure. A good starting point is 10
local displayBlips = true					-- Show blips for mechanics locations
local preventExplosions = true				-- If true, most explosions will be prevented while in the vehicle




-- id=446 for wrench icon, id=72 for spraycan icon
local mechanics = {
	{name="Mechanic", id=446, r=20.0, x=-337.0,  y=-135.0,  z=39.0},	-- LSC Burton
	{name="Mechanic", id=446, r=20.0, x=-1155.0, y=-2007.0, z=13.0},	-- LSC by airport
	{name="Mechanic", id=446, r=20.0, x=734.0,   y=-1085.0, z=22.0},	-- LSC La Mesa
	{name="Mechanic", id=446, r=20.0, x=1177.0,  y=2640.0,  z=37.0},	-- LSC Harmony
	{name="Mechanic", id=446, r=20.0, x=108.0,   y=6624.0,  z=31.0},	-- LSC Paleto Bay
	{name="Mechanic", id=446, r=15.0, x=538.0,   y=-183.0,  z=54.0},	-- Mechanic Hawic
	{name="Mechanic", id=446, r=10.0, x=1774.0,  y=3333.0,  z=41.0},	-- Mechanic Sandy Shores Airfield
	{name="Mechanic", id=446, r=10.0, x=1143.0,  y=-776.0,  z=57.0},	-- Mechanic Mirror Park
	{name="Mechanic", id=446, r=25.0, x=2508.0,  y=4103.0,  z=38.0},	-- Mechanic East Joshua Rd.
	{name="Mechanic", id=446, r=12.0, x=2006.0,  y=3792.0,  z=32.0},	-- Mechanic Sandy Shores gas station
	{name="Mechanic", id=446, r=22.0, x=484.0,   y=-1316.0, z=29.0},	-- Hayes Auto, Little Bighorn Ave.
	{name="Mechanic", id=446, r=30.0, x=-1419.0, y=-450.0,  z=36.0},	-- Hayes Auto Body Shop, Del Perro
	{name="Mechanic", id=446, r=30.0, x=268.0,   y=-1810.0, z=27.0},	-- Hayes Auto Body Shop, Davis
--	{name="Mechanic", id=446, r=20.0, x=288.0,   y=-1730.0, z=29.0},	-- Hayes Auto, Rancho (Disabled, looks like a warehouse for the Davis branch)
	{name="Mechanic", id=446, r=25.0, x=1915.0,  y=3729.0,  z=32.0},	-- Otto's Auto Parts, Sandy Shores
	{name="Mechanic", id=446, r=45.0, x=-29.0,   y=-1665.0, z=29.0},	-- Mosley Auto Service, Strawberry
	{name="Mechanic", id=446, r=42.0, x=-212.0,  y=-1378.0, z=31.0},	-- Glass Heroes, Strawberry
	{name="Mechanic", id=446, r=30.0, x=258.0,   y=2594.0,  z=44.0},	-- Mechanic Harmony
	{name="Mechanic", id=446, r=15.0, x=-32.0,   y=-1090.0, z=26.0},	-- Simeons
	{name="Mechanic", id=446, r=20.0, x=-211.0,  y=-1325.0, z=31.0},	-- Bennys
	{name="Mechanic", id=446, r=20.0, x=903.0,   y=3563.0,  z=34.0},	-- Auto Repair, Grand Senora Desert
	{name="Mechanic", id=446, r=20.0, x=437.0,   y=3568.0,  z=38.0}		-- Auto Shop, Grand Senora Desert
}

local fixMessages = {
	"You put the oil plug back in",
	"You stopped the oil leak using chewing gum",
	"You repaired the oil tube with gaffer tape",
	"You tightened the oil pan screw, no more dripping",
	"You kicked the engine and it magically came back to life",
	"You removed some rust from the spark tube",
	"You yelled at your car, and it somehow had an effect"
}
local fixMessageCount = 7
local fixMessagePos = math.random(fixMessageCount)

local noFixMessages = {
	"You checked the oil plug. It's still there",
	"You looked at your engine, it seems fine",
	"You made sure that the gaffer tape was still holding the engine together",
	"You turned up the radio volume. It just drowned out the weird engine noises",
	"You added rust-preventer to the spark tube. It made no difference",
	"Never fix something that ain't broken they said. You didn't listen. At least it didn't get worse"
}
local noFixMessageCount = 6
local noFixMessagePos = math.random(noFixMessageCount)

local healthEngineLast = 9999.9
local healthBodyLast = 9999.9
local healthPetrolTankLast = 9999.9
local healthEngineCurrent = 1000.0
local healthEngineNew = 1000.0
local healthBodyCurrent = 1000.0
local healthBodyNew = 1000.0
local healthBodyDelta = 0.0
local healthPetrolTankCurrent = 1000.0
local healthPetrolTankNew = 1000.0
local healthPetrolTankDelta = 0.0

-- Display blips on map
Citizen.CreateThread(function()
		if (displayBlips == true) then
	  for _, item in pairs(mechanics) do
		item.blip = AddBlipForCoord(item.x, item.y, item.z)
		SetBlipSprite(item.blip, item.id)
		SetBlipAsShortRange(item.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(item.name)
		EndTextCommandSetBlipName(item.blip)
	  end
	end
end)
  
RegisterNetEvent('iens:repair')
AddEventHandler('iens:repair', function()
	local ped = GetPlayerPed(-1)
	if IsPedInAnyVehicle(ped, false) then
		local vehicle = GetVehiclePedIsIn(ped, false)
		if IsNearMechanic() then
			SetVehicleUndriveable(vehicle,false)
			SetVehicleFixed(vehicle)
			healthBodyLast=1000.0
			healthEngineLast=1000.0
			healthPetrolTankLast=1000.0
			SetVehicleEngineOn(vehicle, true, false )
			notification("~g~The mechanic repaired your car!")
			return
		end
		if GetVehicleEngineHealth(vehicle) < 2 then
			if GetVehicleOilLevel(vehicle) > 0 then
				SetVehicleUndriveable(vehicle,false)
				SetVehicleEngineHealth(vehicle, 305.0)
				SetVehiclePetrolTankHealth(vehicle, 750.0)
				healthEngineLast=305.0
				healthPetrolTankLast=750.0
					SetVehicleEngineOn(vehicle, true, false )
				SetVehicleOilLevel(vehicle,(GetVehicleOilLevel(vehicle)/3)-0.5)
				notification("~g~" .. fixMessages[fixMessagePos] .. ", now go to a mechanic!")
				fixMessagePos = fixMessagePos + 1
				if fixMessagePos > fixMessageCount then fixMessagePos = 1 end
			else
				notification("~r~Your vehicle was too badly damaged. Unable to repair!")
			end
		else
			notification("~y~" .. noFixMessages[noFixMessagePos] )
			noFixMessagePos = noFixMessagePos + 1
			if noFixMessagePos > noFixMessageCount then noFixMessagePos = 1 end
		end
	else
		notification("~y~You must be in a vehicle to be able to repair it")
	end
end)

RegisterNetEvent('iens:notAllowed')
AddEventHandler('iens:notAllowed', function()
	notification("~r~You don't have permission to repair vehicles")
end)

function notification(msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(false, false)
end

function IsNearMechanic()
	local ped = GetPlayerPed(-1)
	local pedLocation = GetEntityCoords(ped, 0)
	for _, item in pairs(mechanics) do
	  local distance = GetDistanceBetweenCoords(item.x, item.y, item.z,  pedLocation["x"], pedLocation["y"], pedLocation["z"], true)
	  if distance <= item.r then
		return true
	  end
	end
  end

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(50)
		local ped = GetPlayerPed(-1)
		if IsPedInAnyVehicle(ped, false) then
			vehicle = GetVehiclePedIsUsing(ped)
			healthEngineCurrent = GetVehicleEngineHealth(vehicle)
			if healthEngineCurrent == 1000 then healthBodyLast = 1000.0 end
			healthEngineNew = healthEngineCurrent
			healthBodyCurrent = GetVehicleBodyHealth(vehicle)
			if healthBodyCurrent == 1000 then healthBodyLast = 1000.0 end
			healthBodyNew = healthBodyCurrent
			healthPetrolTankCurrent = GetVehiclePetrolTankHealth(vehicle)
			if healthPetrolTankCurrent == 1000 then healthPetrolTankLast = 1000.0 end
			healthPetrolTankNew = healthPetrolTankCurrent 
			if healthEngineCurrent > 2 and healthPetrolTankCurrent > 2 then
				SetVehicleUndriveable(vehicle,false)
			end

			if healthEngineCurrent < 2 then
				SetVehicleUndriveable(vehicle,true)
			elseif healthEngineLast ~= 9999.9 then
				if healthEngineLast - healthEngineCurrent > 0 then
					healthEngineNew = healthEngineLast - ((healthEngineLast - healthEngineCurrent) * damageFactor)
				end
				if healthEngineNew < 300 then
					healthEngineNew = healthEngineNew-(0.1 * cascadingFailureSpeedFactor)
				end
				if healthEngineNew < 1 then
					healthEngineNew = 1.0
				end
			end

			if healthBodyLast ~= 9999.9 then
				healthBodyDelta = healthBodyLast - healthBodyCurrent
				if healthBodyDelta > 0 then
					healthBodyNew = healthBodyLast - ((healthBodyLast - healthBodyCurrent) * damageFactor)
				end
				if healthBodyNew < 0 then
					healthBodyNew = 0.0
				end
				SetVehicleBodyHealth(vehicle, healthBodyNew)
				healthBodyLast = healthBodyNew
			else
				if healthBodyCurrent < 300 then
					SetVehicleBodyHealth(vehicle,300.0)
					healthBodyCurrent=300.0
					healthBodyLast=300.0
				end
			end

			if healthPetrolTankLast ~= 9999.9 then
				healthPetrolTankDelta = healthPetrolTankLast-healthPetrolTankCurrent
				if healthPetrolTankDelta > 0 then
					healthPetrolTankLast = healthPetrolTankCurrent
				end
				if healthPetrolTankCurrent < 750 and preventExplosions == true then
					SetVehiclePetrolTankHealth(vehicle, 750.0)
					healthPetrolTankLast = 750
				end
			end

			healthEngineNew = healthEngineNew - (healthPetrolTankDelta * damageFactor * 8) - (healthBodyDelta * damageFactor)
			if healthEngineNew < 1 then healthEngineNew = 1.0 end
			SetVehicleEngineHealth(vehicle, healthEngineNew)

			healthEngineLast = healthEngineNew
			healthBodyLast = GetVehicleBodyHealth(vehicle)
			healthPetrolTankLast = GetVehiclePetrolTankHealth(vehicle)
		else
			healthEngineLast = 9999.9
			healthBodyLast = 9999.9
			healthPetrolTankLast = 9999.9
		end
	end
end)

