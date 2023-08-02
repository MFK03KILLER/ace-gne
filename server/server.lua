local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('qb-gne:server:HasGNE', function(source, cb, data)
    local Player = QBCore.Functions.GetPlayer(source)
    local Price = Config.Shop[data.k].items[data.i] * data.amount
    if Player.PlayerData.money.cash >= Price then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Commands.Add('addgne', 'Add GNE', {{name = 'Id', help = "Target Player Id"}, {name = 'Amount', help = "GNE Amount"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "galaxy" and Player.PlayerData.job.isboss then
        local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if Target then
            local amount = tonumber(args[2])
            if amount and amount > 0 then
                TriggerClientEvent('QBCore:Notify', source, 'Added '..amount..'x GNE for '..args[1], 'success')
                Target.Functions.AddMoney('gne', amount)
            else
                TriggerClientEvent('QBCore:Notify', source, 'Enter number more than zero!', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Player is not online!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'You donot have access', 'error')
    end
end)

QBCore.Commands.Add('removegne', 'Remove GNE', {{name = 'Id', help = "Target Player Id"}, {name = 'Amount', help = "GNE Amount"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "galaxy" and Player.PlayerData.job.isboss then
        local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if Target then
            local amount = tonumber(args[2])
            if amount and amount > 0 then
                TriggerClientEvent('QBCore:Notify', source, 'Removed '..amount..'x GNE for '..args[1], 'success')
                Target.Functions.RemoveMoney('gne', amount)
            else
                TriggerClientEvent('QBCore:Notify', source, 'Enter number more than zero!', 'error')
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Player is not online!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'You donot have access', 'error')
    end
end)

QBCore.Commands.Add('gmailid', 'Send Email to Player', {{name = 'Id', help = "Target Player Id"}, {name = 'Sender', help = "From Who?"}, {name = 'Subject', help = "Title of Email"}, {name = 'Message', help = "Body of Email"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "galaxy" then
        local Target = QBCore.Functions.GetPlayer(tonumber(args[1]))
        if Target then
            local sender = args[2]
            local subject = args[3]
            local message = args[4]
            TriggerClientEvent('ace-gne:client:sendMail', tonumber(args[1]), sender, subject, message)
        else
            TriggerClientEvent('QBCore:Notify', source, 'Player is not online!', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'You donot have access', 'error')
    end
end)

QBCore.Commands.Add('gmailgne', 'Send Email to Player as Has GNE', {{name = 'amount', help = "GNE amount that Target has enough"}, {name = 'Sender', help = "From Who?"}, {name = 'Subject', help = "Title of Email"}, {name = 'Message', help = "Body of Email"}}, true, function(source, args)
    local Player = QBCore.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "galaxy" then
        local sender = args[2]
        local subject = args[3]
        local message = args[4]
        local amount = tonumber(args[1])
        if amount then
            local Players = QBCore.Functions.GetQBPlayers()
            if next(Players) then
                for id, Target in pairs(Players) do
                    if Target then
                        if Target.PlayerData.money.gne >= amount then
                            TriggerClientEvent('ace-gne:client:sendMail', Target.PlayerData.source, sender, subject, message)
                        end
                    end
                end
            end
        else
            TriggerClientEvent('QBCore:Notify', source, 'Enter Number as Amount', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', source, 'You donot have access', 'error')
    end
end)

RegisterNetEvent('qb-gne:server:buyItem', function(data)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Price = Config.Shop[data.k].items[data.i] * data.amount
    if Player.PlayerData.money.cash >= Price then
        Player.Functions.RemoveMoney('cash', Price)
        Player.Functions.AddItem(data.i, data.amount)
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items[data.i], "add", data.amount)
    else
        TriggerClientEvent('QBCore:Notify', src, "Where is your GNE? Go fuck off!", "error")
    end
end)

RegisterNetEvent('qb-gne:server:sellGNE', function(amount, key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Price = Config.Sell[key].price * amount
    if Player.PlayerData.money.gne >= amount then
        Player.Functions.RemoveMoney('gne', amount)
        Player.Functions.AddMoney('cash', Price)
        TriggerClientEvent('QBCore:Notify', src, "You sell "..amount.."x GNE for $"..Price, "success")
    else
        TriggerClientEvent('QBCore:Notify', src, "You donnot have enough GNE!", "error")
    end
end)

RegisterNetEvent('qb-gne:server:sellGNEStick', function(amount, key)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local Price = math.random(Config.Trade[key].eachamount.min, Config.Trade[key].eachamount.max) * amount
    if Player.Functions.RemoveItem('gnesticks', amount) then
        TriggerClientEvent("inventory:client:ItemBox", src, QBCore.Shared.Items['gnesticks'], "remove", amount)
        Player.Functions.AddMoney('gne', Price, 'Sell GNE Sticks')
    else
        TriggerClientEvent('QBCore:Notify', src, "You donnot have enough GNE Sticks!", "error")
    end
end)