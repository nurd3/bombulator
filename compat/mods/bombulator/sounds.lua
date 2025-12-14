function bombulator.sound_play(spec)
    return function(player)
        core.sound_play(spec, {to_player = player:get_player_name()})
    end
end

bombulator.register_bombulation("bombulator:fart", {
    interval = 5,
    func = bombulator.sound_play "bombulator_fart"
})

bombulator.register_bombulation("bombulator:bombulator_name", {
    interval = 15,
    func = bombulator.sound_play "bombulator_bombulator_name"
})

bombulator.register_sounds {
    ["bombulator_fart"] = {chance = 0.005},
    ["bombulator_bombulator_name"] = {chance = 0.005},
}