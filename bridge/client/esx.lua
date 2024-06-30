if GetResourceState('es_extended') ~= 'started' then return end

local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('esx:onPlayerLogout', function()
    clearEverything()
    ESX.PlayerLoaded = false
end)

function hasPlyLoaded()
    return ESX.PlayerLoaded
end

function DoNotification(text, nType)
    ESX.ShowNotification(text, nType)
end
