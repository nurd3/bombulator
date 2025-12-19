function bombulator.leap(player)
    local controls = player:get_player_control()

    if controls.jump then player:add_velocity(vector.new(0, 10, 0)) end
end

bombulator.register_bombulation("bombulator:leap", {
    interval = 45.0,
    per_player = function(player)
        bombulator.leap(player)
    end
})