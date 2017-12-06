------------------------------------------------------
--	iEnsomatic RealisticVehicleFailure v0.1 beta	--
------------------------------------------------------
--
--	Created by Jens Sandalgaard
--	
--	This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
--

local damageFactor = 15.0				-- Sane values are 1 to 100. Higher values means more damage to vehicle. A good starting point is 15
local cascadingFailureSpeedFactor = 10	-- Sane values are 1 to 100. When vehicle health drops below a certain point, cascading failure sets in, and the health drops rapidly until the vehicle dies. Higher values means faster failure. A good starting point is 10


local healthEngineLast = 9999.9
local healthBodyLast = 9999.9
local healthPetrolLast = 9999.9

Citizen.CreateThread(function()
	while true do
	Citizen.Wait(50)
		local ped = GetPlayerPed(-1)
		if IsPedInAnyVehicle(ped, false) then
			local vehicle = GetVehiclePedIsUsing(ped)
			local healthEngineCurrent = GetVehicleEngineHealth(vehicle)
			local healthEngineNew = healthEngineCurrent
			local healthBodyCurrent = GetVehicleBodyHealth(vehicle)
			local healthBodyNew = healthBodyCurrent
			local healthPetrolTankCurrent = GetVehiclePetrolTankHealth(vehicle)
			local healthPetrolTankNew = healthPetrolTankCurrent 
			if healthEngineCurrent > 2 and healthPetrolTankCurrent > 2 then
				SetVehicleUndriveable(vehicle,false)
			end
			if healthEngineCurrent < 2 and healthPetrolTankCurrent < 2 then
				SetVehicleUndriveable(vehicle,true)
			elseif healthEngineLast ~= 9999.9 then
				if healthEngineLast - healthEngineCurrent > 0 then
					healthEngineNew = healthEngineLast - ((healthEngineLast - healthEngineCurrent) * damageFactor)
				end
				if healthEngineNew < 1 then
					healthEngineNew = 1.0
				end
				SetVehicleEngineHealth(vehicle, healthEngineNew)
				healthEngineLast = healthEngineNew
				if healthEngineNew < 300 then
					local t = GetVehiclePetrolTankHealth(vehicle)-(0.01 * cascadingFailureSpeedFactor)
					if t < 0 then
						t = 0
					end
					SetVehiclePetrolTankHealth(vehicle, t) 
				end
			else
				healthEngineLast = GetVehicleEngineHealth(vehicle)
			end
			if healthBodyLast ~= 9999.9 then
				if healthBodyLast - healthBodyCurrent > 0 then
					healthBodyNew = healthBodyLast - ((healthBodyLast - healthBodyCurrent) * 10.0)
				end
				if healthBodyNew < 0 then
					healthBodyNew = 0.0
				end
				SetVehicleBodyHealth(vehicle, healthBodyNew)
				healthBodyLast = healthBodyNew
			else
				healthBodyLast = GetVehicleBodyHealth(vehicle)
			end
			if healthPetrolLast ~= 9999.9 then
				if healthPetrolLast - healthPetrolTankCurrent > 0 then
					healthPetrolTankNew = healthPetrolLast - ((healthPetrolLast - healthPetrolTankCurrent ) * damageFactor * 5)
				end
				if healthPetrolTankNew < 0 then
					healthPetrolTankNew = 0.0
				end
				if healthPetrolTankNew ~= healthPetrolLast then
					SetVehiclePetrolTankHealth(vehicle, healthPetrolTankNew)
				end
				healthPetrolLast = healthPetrolTankNew
				if healthPetrolTankNew < 702 then
					local t = GetVehicleEngineHealth(vehicle)-(0.05 * cascadingFailureSpeedFactor)
					if t < 1 then
						t = 1
					end
					SetVehicleEngineHealth(vehicle, t) 
				end
			else
				healthPetrolLast = GetVehiclePetrolTankHealth(vehicle)
			end
		else
			healthEngineLast = 9999.9
			healthBodyLast = 9999.9
			healthPetrolLast = 9999.9
		end
	end
end)
