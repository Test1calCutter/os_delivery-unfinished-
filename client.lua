ESX = nil

local circleCenter = vector3(-4.720875, -668.6241, 32.32971) -- Where the circle is.
local circleRadius = 2.0 -- Circle radius
local spawn = vector4(-4.720875, -668.6241, 32.32971, -180) -- Where the vehicle will spawn
local onMission = false -- Is player on a mission?
local drawMarker = true  -- to store the second markers id and removing it after player interacted
local canInteract = true -- to disable the functions from the second circle after player interacted
local finished = false -- Check if player has finished a mission so he can recieve his money afterwards

local coords = { -- Locations of mission. Adding more means more possible missions. After finishing one you have to go back to the position of circleCenter and start a new mission.
    {
        x = -2.663731,
        y = -709.2659,
        z = 32.32971
    },
    {
        x = -2.663731,
        y = -709.2659,
        z = 32.32971
    }
    -- Add more locations if needed
}

local random = math.random(1, #coords) -- getting random item from list "coords"
local paga = math.random(500, 2500)
local waypointX = coords[random].x
local waypointY = coords[random].y
local waypointZ = coords[random].z

local circleCenter2 = vector3(waypointX, waypointY, waypointZ) -- Second circle center
local circleRadius2 = 2.0 -- Second circle radius


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj)
            ESX = obj
        end)
        Citizen.Wait(10)
    end
end)


-- Magic
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local distance = GetDistanceBetweenCoords(playerCoords, circleCenter, true)

        if distance <= 150 then -- If player is inside 150 meter the circle will show. If outside, circle will disappear
            DrawMarker(1, circleCenter.x, circleCenter.y, circleCenter.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius * 2.0, circleRadius * 2.0, 1.0, 255, 0, 0, 200, false, false, 2, nil, nil, false) -- Circle :d

            if distance <= circleRadius then -- If player inside the circle
                
                if onMission and not finished then -- If player is on mission
                    DisplayHelpText('Press ~INPUT_CONTEXT~ to stop the current delivery')
                    if IsControlJustReleased(0, 38) then
                        ESX.ShowNotification('You have canceled your delivery.')
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        DeleteVehicle(vehicle)
                        onMission = false
                    end
                elseif finished then -- if player has a mission and already was at the waypoint and pressed E 
                    DisplayHelpText('Press ~INPUT_CONTEXT~ to finish the current delivery')
                    if IsControlJustReleased(0, 38) then
                        ESX.ShowNotification('You have finished your delivery.')
                        local vehicle = GetVehiclePedIsIn(playerPed, false)
                        DeleteVehicle(vehicle)
                        onMission = false -- set to false so player can start a new mission
                        finished = false
                        drawMarker = true
                        canInteract = true
                        -- set to false so player can start a new mission
                        -- giving the player money as a reward.
                        print("Triggering os:p event")
                        --how to give money?
                    end
                else-- if not on mission
                    DisplayHelpText("Press ~INPUT_CONTEXT~ to start a delivery.")

                    if IsControlJustReleased(0, 38) then
                        ESX.ShowNotification('You have started a delivery. Drive to the marker on your map.')
                        local model = GetHashKey("stockade") -- Vehicle model the player will spawn in

                        SetNewWaypoint(waypointX, waypointY, waypointZ)

                        onMission = true -- change the boolian of onMission to true so he cant start another mission
                        RequestModel(model)

                        --local playerCoords = GetEntityCoords(playerPed)
                        --local playerHeading = GetEntityHeading(playerPed)
                        local vehicle = CreateVehicle(model, spawn.x, spawn.y, spawn.z, 0.0, true, false) -- spawning the vehicle
                        SetPedIntoVehicle(playerPed, vehicle, -1) -- sitting the player inside the car
                        SetModelAsNoLongerNeeded(model)
                    end
                end
            end
        else
            RemoveHelpText()
        end

        -- same magic as above. not commented as i am lazy
        local distance2 = GetDistanceBetweenCoords(playerCoords, circleCenter2, true)
        if distance2 <= 150 and onMission then
            if drawMarker and canInteract then
                DrawMarker(1, circleCenter2.x, circleCenter2.y, circleCenter2.z - 1.0, 0, 0, 0, 0, 0, 0, circleRadius2 * 2.0, circleRadius2 * 2.0, 1.0, 0, 255, 0, 200, false, false, 2, nil, nil, false)
            end

            if distance2 <= circleRadius2 and canInteract then
                DisplayHelpText('Press ~INPUT_CONTEXT~ to finish your delivery.')
                if IsControlJustReleased(0, 38) then
                    drawMarker = false
                    canInteract = false
                    finished = true
                    ESX.ShowNotification('You\'ve finished your delivery. Return to the HQ.')
                    SetNewWaypoint(circleCenter)
                end

            end
        end

    end
end)

function DisplayHelpText(text)
    SetTextComponentFormat("STRING")
    AddTextComponentString(text)
    DisplayHelpTextFromStringLabel(0, 0, 1, -1)
end

function RemoveHelpText()
    BeginTextCommandDisplayHelp("STRING")
    EndTextCommandDisplayHelp(0, false, true, -1)
end
