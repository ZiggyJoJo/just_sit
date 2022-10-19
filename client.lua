local oElement = {}
local InUse = false
local PlyLastPos = 0
local Anim = 'sit'

-- Fast Thread
RegisterNetEvent('just_sit:startLoop')
AddEventHandler('just_sit:startLoop', function()
    local ply = PlayerPedId()
    FreezeEntityPosition(ply, true)
    lib.disableControls:Add(73)
    CreateThread(function()
        while InUse do
            lib.disableControls()
            local plyCoords = GetEntityCoords(ply)
            if IsDisabledControlJustPressed(0, Config.objects.ButtonToStandUp) or (#(plyCoords) - #(PlyLastPos)) > 5 then
                lib.disableControls:Remove(73)
                InUse = false
                TriggerServerEvent('just_sit:Leave', oElement.fObjectCoords)
                ClearPedTasksImmediately(ply)
                FreezeEntityPosition(ply, false)

                local x, y, z = table.unpack(PlyLastPos)
                SetEntityCoords(ply, x, y, z, true, false, false, false)
            end
            Wait(0)
        end
    end)
end)

RegisterNetEvent('just_sit:Animation')
AddEventHandler('just_sit:Animation', function(v, coords)
    local object = v.fObject
    local vertx = v.fObjectcX
    local verty = v.fObjectcY
    local vertz = v.fObjectcZ
    local dir = v.fObjectDir
    local isBed = v.fObjectIsBed
    local objectcoords = coords
    local ped = PlayerPedId()
    InUse = true
    if not isBed then
        if Config.objects.SitAnimation.dict ~= nil then
            SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
            SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
            local dict = Config.objects.SitAnimation.dict
            local anim = Config.objects.SitAnimation.anim

            AnimLoadDict(dict, anim, ped)
        else
            TaskStartScenarioAtPosition(ped, Config.objects.SitAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, dir, 0, true, true)
        end
    else
        if Anim == 'back' then
            if Config.objects.BedBackAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedBackAnimation.dict
                local anim = Config.objects.BedBackAnimation.anim

                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedBackAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + dir, 0, true, true)
            end
            FreezeEntityPosition(ped, true)

        elseif Anim == 'stomach' then
            if Config.objects.BedStomachAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedStomachAnimation.dict
                local anim = Config.objects.BedStomachAnimation.anim

                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedStomachAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + dir, 0, true, true)
            end
        elseif Anim == 'sit' then
            if Config.objects.BedSitAnimation.dict ~= nil then
                SetEntityCoords(ped, objectcoords.x, objectcoords.y, objectcoords.z + 0.5)
                SetEntityHeading(ped, GetEntityHeading(object) - 180.0)
                local dict = Config.objects.BedSitAnimation.dict
                local anim = Config.objects.BedSitAnimation.anim

                Animation(dict, anim, ped)
            else
                TaskStartScenarioAtPosition(ped, Config.objects.BedSitAnimation.anim, objectcoords.x + vertx, objectcoords.y + verty, objectcoords.z - vertz, GetEntityHeading(object) + 180.0, 0, true, true)
            end
        end
    end
    TriggerEvent('just_sit:startLoop')
end)

function Animation(dict, anim, ped)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(0)
    end

    TaskPlayAnim(ped, dict, anim, 8.0, 1.0, -1, 1, 0, 0, 0, 0)
end

RegisterNetEvent('just_sit:sit')
AddEventHandler('just_sit:sit', function(data)
    local coordsObject = GetEntityCoords(data.entity)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(data.entity)
    PlyLastPos = GetEntityCoords(ped)
    Anim = data.anim

    for _, element in pairs(Config.objects.locations) do
        if GetHashKey(element.object) == GetEntityModel(data.entity) then
            print(heading, element.direction)
            print(element.bed)
            heading = (heading + element.direction)
                oElement = {
                    fObject = data.entity,
                    fObjectCoords = coordsObject,
                    fObjectcX = element.verticalOffsetX,
                    fObjectcY = element.verticalOffsetY,
                    fObjectcZ = element.verticalOffsetZ,
                    fObjectDir = heading,
                    fObjectIsBed = element.bed
                }

            TriggerServerEvent('just_sit:Enter', oElement, oElement.fObjectCoords)
            break
        end
    end
end)

Citizen.CreateThread(function()
	local Chairs = {}
    local Beds = {}

    for i=1, #Config.objects.locations, 1 do
        if not Config.objects.locations[i].bed then
            local model = GetHashKey(Config.objects.locations[i].object)
		    table.insert(Chairs, model)
        else
            local model = GetHashKey(Config.objects.locations[i].object)
		    table.insert(Beds, model)
        end
    end
	Wait(100)
    exports.ox_target:addModel(Chairs,
    {
        {
            name = "Chairs",
            event = 'just_sit:sit',
            icon = "fas fa-chair",
            label = 'Sit Down',
            distance = Config.MaxDistance
        }
    })

    exports.ox_target:addModel(Beds,
    {
        {
            name = "sitBed",
            event = 'just_sit:sit',
            icon = "fas fa-bed",
            label = 'Sit Down',
            anim = "sit",
            distance = Config.MaxDistance
        },
        {
            name = "layOnBed",
            event = 'just_sit:sit',
            icon = "fas fa-bed",
            label = 'Lay Down',
            anim = "back",
            distance = Config.MaxDistance

        },
        {
            name = "layOnStomach",
            event = 'just_sit:sit',
            icon = "fas fa-bed",
            label = 'Lay On Stomach',
            anim = "stomach",
            distance = Config.MaxDistance
        }
    })
end)