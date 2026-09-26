local helpers = {}

function helpers.format_time(seconds)
    seconds = math.max(0, math.floor(tonumber(seconds) or 0))

    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    local parts = {}
    if days > 0 then
        table.insert(parts, days .. "d")
    end
    if hours > 0 then
        table.insert(parts, hours .. "h")
    end
    if minutes > 0 then
        table.insert(parts, minutes .. "m")
    end
    if secs > 0 or #parts == 0 then
        table.insert(parts, secs .. "s")
    end

    return table.concat(parts, " ")
end

return helpers
