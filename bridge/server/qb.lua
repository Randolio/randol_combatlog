if GetResourceState('qb-core') ~= 'started' then return end

local QBCore = exports['qb-core']:GetCoreObject()

function GetPlayer(id)
    return QBCore.Functions.GetPlayer(id)
end

function DoNotification(src, text, nType)
    TriggerClientEvent('QBCore:Notify', src, text, nType)
end

function GetCharacterName(Player)
    return Player.PlayerData.charinfo.firstname.. ' ' ..Player.PlayerData.charinfo.lastname
end

function GetPlyIdentifier(Player)
    return Player.PlayerData.citizenid
end

function GetPlyLicense(Player)
    return Player.PlayerData.license
end

function GetPlayerSkinData(cid)
    local result = MySQL.single.await('SELECT skin FROM playerskins WHERE citizenid = ? AND active = ?', {cid, 1})
    if result and result.skin then
        local skinData = json.decode(result.skin)
        if skinData then
            return skinData, skinData.model
        end
    end
    return false
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(source)
    OnPlayerUnload(source)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function()
    OnPlayerLoaded(source)
end)