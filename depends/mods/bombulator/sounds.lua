function bombulator.sound_play(spec)
    return function(player)
        core.log("info", "bombulator.sound_play()")
        core.sound_play(spec, {to_player = player:get_player_name()})
    end
end

bombulator.register_bombulation("bombulator:fart", {
    interval = 30.0,
    per_player = bombulator.sound_play {
        name = "bombulator_fart",
        gain = 0.1
    }
})

bombulator.register_bombulation("bombulator:bombulator_name", {
    interval = 60.0,
    per_player = bombulator.sound_play {
        name = "bombulator_bombulator_name",
        gain = 0.2
    }
})

local spatial_sound_range = 64.0

function bombulator.spatial_sound(origin, playername)
    local pos = vector.round(origin + vector.random_direction() * math.random() * spatial_sound_range)

    core.sound_play(bombulator.random_sound(), {
        to_player = playername,
        pos = pos,
        gain = 0.5
    })
end

bombulator.register_bombulation("bombulator:spatial_sound", {
    interval = 15.0,
    per_player = function(player)
        bombulator.spatial_sound(player:get_pos(), player:get_player_name())
    end
})

bombulator.register_bombulation("bombulator:buncha_spatial_sound", {
    interval = 15.0,
    per_player = function(player)
        local pos, playername = player:get_pos(), player:get_player_name()
        for _ = 1, math.random(25) do
            bombulator.spatial_sound(pos, playername)
        end
    end
})

local node_sound_range = 64.0

local function random_key(tbl)
    local temp = {}

    for k, v in pairs(tbl) do
        table.insert(temp, k)
    end

    return temp[math.random(#temp)]
end

function bombulator.node_sound(origin, playername)
    for _ = 1, node_sound_range * node_sound_range do
        local pos = vector.round(origin + vector.random_direction() * math.random() * node_sound_range)
        local node_name = core.get_node(pos).name
        local sounds = core.registered_nodes[node_name] and core.registered_nodes[node_name].sounds

        if sounds then
            core.sound_play(random_key(sounds), {
                to_player = playername,
                pos = pos
            })
        end   
    end
end

bombulator.register_bombulation("bombulator:node_sound", {
    interval = 15.0,
    per_player = function(player)
        bombulator.node_sound(player:get_pos(), player:get_player_name())
    end
})

bombulator.register_bombulation("bombulator:buncha_node_sound", {
    interval = 15.0,
    per_player = function(player)
        local pos, playername = player:get_pos(), player:get_player_name()
        for _ = 1, math.random(25) do
            bombulator.node_sound(pos, playername)
        end
    end
})

bombulator.register_sounds {
    ["bombulator_fart"] = { chance = 0.005 },
    ["bombulator_bombulator_name"] = { chance = 0.005 },
    ["player_damage"] = { chance = 1.0 },
}