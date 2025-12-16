local global_memory = {}

local default_interval = 5
local default_func = function() end

local function bombulation_loop(bombuname)
    core.log("info", "bombulation_loop()")

    local def = bombulator.registered_bombulations[bombuname]
    local interval = def.interval or default_interval
    local inverse_interval = 0.25 / interval
    local func = def.per_player or default_func
    local local_memory = {}

    local timeout = function(self)
        core.log("info", "timeout()")
        
        
        for _, player in ipairs(core.get_connected_players()) do
            local playername = player:get_player_name()
            if math.random() < inverse_interval then
                local_memory[playername] = local_memory[playername] or {}
                func(player, local_memory[playername], global_memory[bombuname])
            end
        end

        core.after(0.25, self, self)
    end



    core.after(math.random(), timeout, timeout)
end

function bombulator.begin()
    core.log("info", "bombulator.begin()")
    for name, _ in pairs(bombulator.registered_bombulations) do
        global_memory[name] = {}
    end
end

local function mods_loaded()
    core.log("info", "mods_loaded()")
    for name, _ in pairs(bombulator.registered_bombulations) do
        core.log("info", name)
        bombulation_loop(name)
    end
end

core.register_on_mods_loaded(mods_loaded)