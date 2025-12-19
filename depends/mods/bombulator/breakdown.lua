local breakdown_range = 20

function bombulator.breakdown(origin, speed_mult_min, speed_mult_max)

    core.log("info", "bombulator.breakdown")

    for _ = 1, breakdown_range * breakdown_range do
        local pos = vector.round(origin + vector.random_direction() * math.random() * breakdown_range)
        local node = core.get_node(pos)
        local speed_mult = math.random(speed_mult_min, speed_mult_max)

        if node.name == "air" then
            node.name = bombulator.random_node()
        end

        if not node.name then return end

        if bombulator.registered_bombulations[node.name] then
            bombulator.add_fake_node(pos, speed_mult, node)
        end
    end

end


bombulator.register_bombulation("bombulator:breakdown", {
    interval = 90.0,
    per_player = function(player)
        local speed_mult = player:get_physics_override().speed * player:get_physics_override().speed_walk

        bombulator.breakdown(player:get_pos(), 0.5, speed_mult)
    end
})