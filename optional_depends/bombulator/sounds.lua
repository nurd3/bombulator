function bombulator.sound_play(spec)
    return function(player)
        core.log("info", "bombulator.sound_play()")
        core.sound_play(spec, {to_player = player:get_player_name()})
    end
end

bombulator.register_bombulation("bombulator:fart", {
    interval = 15.0,
    per_player = bombulator.sound_play {
        name = "bombulator_fart",
        gain = 0.2
    }
})

bombulator.register_bombulation("bombulator:bombulator_name", {
    interval = 30.0,
    per_player = bombulator.sound_play {
        name = "bombulator_bombulator_name",
        gain = 0.2
    }
})

local spatial_sound_range = 16.0

function bombulator.spatial_sound(origin, playername)
    local pos = vector.round(origin + vector.random_direction() * math.random() * spatial_sound_range)

    core.sound_play(bombulator.random_sound(), {
        to_player = playername,
        pos = pos,
        gain = 0.2

    })
end

bombulator.register_bombulation("bombulator:spatial_sound", {
    interval = 30.0,
    per_player = function(player)
        bombulator.spatial_sound(player:get_pos(), player:get_player_name())
    end
})

bombulator.register_sounds {
    ["bombulator_fart"] = { chance = 0.005 },
    ["bombulator_bombulator_name"] = { chance = 0.005 },
    ["player_damage"] = { chance = 1.0 },
}