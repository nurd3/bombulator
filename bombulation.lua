local registered_bombulations, random, get_connected_players =
    bombulator.registered_bombulations, math.random, core.get_connected_players

local memory = {}

local timer = 0.0
local iterator

local default_interval = 5
local default_func = function() end

local function staggered_pairs(t)
    local iter, state, key = pairs(t)
    
    return function()
        key = iter(state, key)
        if key == nil then return nil end
        return key, t[key]
    end
end

local chaos = core.settings:get("bombulator_chaos") or 1.0

local function globalstep(dtime)
    if not iterator then iterator = staggered_pairs(registered_bombulations) end
    local name, def = iterator()

    if not name or not def then
        iterator = staggered_pairs(registered_bombulations)
        return
    end

    local interval = def.interval or default_interval
    local inverse_interval = 1.0 / interval * dtime

    if def.global and random() < inverse_interval then def.global(memory[name]) end

    if def.per_player then
        for _, player in ipairs(get_connected_players()) do
            local playername = player:get_player_name()
            if random() < inverse_interval * chaos then
                def.per_player(player, memory[name])
            end
        end
    end
end

core.register_globalstep(function(dtime)
    globalstep(dtime)
    globalstep(dtime)
end)