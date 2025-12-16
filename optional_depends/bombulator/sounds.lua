function bombulator.sound_play(spec)
    return function(player)
        core.log("info", "bombulator.sound_play()")
        core.sound_play(spec, {to_player = player:get_player_name()})
    end
end

bombulator.register_bombulation("bombulator:fart", {
    interval = 5,
    per_player = bombulator.sound_play {
        name = "bombulator_fart",
        gain = 0.2
    }
})

bombulator.register_bombulation("bombulator:bombulator_name", {
    interval = 30,
    per_player = bombulator.sound_play {
        name = "bombulator_bombulator_name",
        gain = 0.2
    }
})

bombulator.register_sounds {
    ["bombulator_fart"] = {chance = 0.005},
    ["bombulator_bombulator_name"] = {chance = 0.005},
}