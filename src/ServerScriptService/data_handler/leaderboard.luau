local dss = game:GetService("DataStoreService")
local plrs = game:GetService("Players")

local stores = {
    wins = dss:GetOrderedDataStore("leaderboard_wins"),
    gold = dss:GetOrderedDataStore("leaderboard_gold"),
    playtime = dss:GetOrderedDataStore("leaderboard_playtime"),
}

local leaderboard = {}

function leaderboard.update(stat, user_id, value)
    local store = stores[stat]
    if not store then
        return
    end

    local success, err = pcall(function()
        store:SetAsync(tostring(user_id), math.floor(value))
    end)

    if not success then
        warn("[Leaderboard] Failed to update " .. stat .. ": " .. tostring(err))
    end
end

function leaderboard.get_top(stat, count)
    local store = stores[stat]
    if not store then
        return "Unknown stat: " .. tostring(stat)
    end

    count = math.clamp(tonumber(count) or 10, 1, 100)

    local success, pages = pcall(function()
        return store:GetSortedAsync(false, count)
    end)

    if not success then
        return "Failed to load " .. stat .. " leaderboard: " .. tostring(pages)
    end

    local lines = {}
    for i, entry in pages:GetCurrentPage() do
        local user_id = tonumber(entry.key)
        local name = "User " .. tostring(entry.key)

        if user_id then
            local name_ok, resolved = pcall(plrs.GetNameFromUserIdAsync, plrs, user_id)
            if name_ok then
                name = resolved
            end
        end

        table.insert(lines, i .. ". " .. name .. " — " .. tostring(entry.value))
    end

    if #lines == 0 then
        return "No " .. stat .. " entries yet."
    end

    return table.concat(lines, "\n")
end

return leaderboard
