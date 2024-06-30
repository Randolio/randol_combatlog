if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    clearEverything()
end)

function hasPlyLoaded()
    return LocalPlayer.state.isLoggedIn
end

function DoNotification(text, nType)
    QBCore.Functions.Notify(text, nType)
end