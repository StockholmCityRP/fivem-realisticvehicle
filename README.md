# Realistic Vehicle Failure

This is a mod for FiveM / GTA V that aims to create realistic vehicle failure.

## Features:
### Realistic Vehicle Failure
* Shooting windows, kicking the car, throwing baseballs or snowballs at it will NOT disable the car!
* Shooting at the engine or fuel tank will damage the vehicle, but not necessarily disable it completely.
* When sustaining a certain amount of damage, the car will begin to degrade quickly and finally die.
* Car doesn't just stop suddenly when hitting something, but will often degrade, smoke and sputter before dying, and finally roll to a stop.
* Car will not catch fire or explode, not even when landing on the roof.
* Car is still reenterable, so you can fix it with a trainer.
* Two variables at the top of the .lua file lets you adjust damage factor and cascading failure speed factor.
* You can still put armor on the car to improve its resistance to abuse.
* Some cars are tougher than others. Especially mid-engine and rear-engine cars can take more frontal collisions before dying.

### Realistic Vehicle Repair
* Type /repair in the chat to repair your vehicle. There are two types of repairs, depending on your location:
#### At the mechanic
* If you are at a mechanic your vehicle will be completely fixed, as good as new.
* Mechanics are located several places in San Andreas. Look for the blips on the map.
#### Not at a mechanic
* If you are not at a mechanic, you may be able to perform a DIY emergency repair in the field.
* You can only reattach the oil plug once or twice, but after that, the vehicle will be beyond repair.
* An emergency repair in the field will only make the car drivable, not completely fixed. A minor accident will most likely kill the car again.
* If you let the damaged car sit too long, the oil will drain completely, preventing further repairs.
* Electric vehicles can not be fixed by you, only by a mechanic. Technology is complex, and chewing gum just won't fix a dead battery.

## Configuration

At the top of client.lua and server.lua you can change a few things.

In client.lua you can set a multiplier for damage, and a speed factor for engine self-destruction if enough damage has been done to the engine.
You may also disable mechanics blips on the map.

In server.lua you can enforce whitelisting for repairs. If you only want certain people on your server to be able to repair vehicles, turn on whitelisting and enter the steam ID's for the users.

## Download

https://github.com/iEns/RealisticVehicleFailure/archive/master.zip

## Installation

Disable or remove other vehicle health scripts. Running two or more vehicle health scripts will give unpredictable results 

### FiveM Server

If you run a FiveM server, you know what to do... but these are the basic instructions, in case you forgot:

* Copy the .lua files to a new folder in your Resources folder
* Add a line to your config: start [foldername]
* Restart server or
* Refresh + start [foldername]

Where [foldername] is the folder in Resources where the two .lua files are located.