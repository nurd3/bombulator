local global_memory = {}

local default_interval = 5
local default_func = function() end

local function bombulation_loop(bombuname, playername)
    local def = bombulator.registered_bombulations[bombuname]
    local interval = def.interval or default_interval
    local inverse_interval = 0.125 / interval
    local func = def.func or default_func
    local local_memory = {}

    local timeout = function()
        if math.random() < inverse_interval then 
        
            local player = core.get_player_by_name(playername)

            if not player then return end

            local global_memory = global_memory[bombuname]

            func(player, local_memory, global_memory)

        end

        core.after(0.125, timeout)
    end

    core.after(math.random(), timeout)
end

function bombulator.begin()
    for name, _ in pairs(bombulator.registered_bombulations) do
        global_memory[name] = {}
    end
end

local function joinplayer(player)
    for name, _ in pairs(bombulator.registered_bombulations) do
        bombulation_loop(name, player:get_player_name())
    end
end

core.register_on_joinplayer(joinplayer)