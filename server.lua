local oArray = {}
local oPlayerUse = {}


AddEventHandler('playerDropped', function()
    local oSource = source
    if oPlayerUse[oSource] ~= nil then
        oArray[oPlayerUse[oSource]] = nil
        oPlayerUse[oSource] = nil
    end
end)


RegisterServerEvent('just_sit:Enter')
AddEventHandler('just_sit:Enter', function(object, objectcoords)
    local oSource = source
    if oArray[objectcoords] == nil then
        oPlayerUse[oSource] = objectcoords
        oArray[objectcoords] = true
        TriggerClientEvent('just_sit:Animation', oSource, object, objectcoords)
    end
end)


RegisterServerEvent('just_sit:Leave')
AddEventHandler('just_sit:Leave', function(objectcoords)
    local oSource = source

    oPlayerUse[oSource] = nil
    oArray[objectcoords] = nil
end)

