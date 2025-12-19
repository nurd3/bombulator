local trap_range = 128.0

function bombulator.big_trap(origin, speed_mult_min, speed_mult_max, velocity)
    local cube_centre = origin + velocity * trap_range
    local _, ray_hit = core.line_of_sight(origin, cube_centre)

    cube_centre = ray_hit or cube_centre

    core.log("info", "bombulator.big_trap")

    for x = -1, 1 do for y = -1, 1 do for z = -1, 1 do
        local pos = vector.round(vector.offset(cube_centre, x, y, z))
        local node = core.get_node(pos)
        local speed_mult = math.random(speed_mult_min, speed_mult_max)

        if node.name and bombulator.registered_nodes[node.name] then
            bombulator.add_fake_node(pos, speed_mult, node)
        end
    end end end

end

bombulator.register_bombulation("bombulator:big_trap", {
    interval = 30.0,
    per_player = function(player)
        bombulator.big_trap(player:get_pos(), 0.5, 2.0, player:get_velocity())
    end
})

function bombulator.small_trap(origin, speed_mult_min, speed_mult_max, velocity)
    local cube_centre = origin + velocity * trap_range
    local _, ray_hit = core.line_of_sight(origin, cube_centre)

    cube_centre = ray_hit or cube_centre

    core.log("info", "bombulator.small_trap")

    local pos = vector.round(cube_centre)
    local node = core.get_node(pos)
    local speed_mult = math.random(speed_mult_min, speed_mult_max)

    if node.name and bombulator.registered_nodes[node.name] then
        bombulator.add_fake_node(pos, speed_mult, node)
    end

end


bombulator.register_bombulation("bombulator:small_trap", {
    interval = 15.0,
    per_player = function(player)
        bombulator.small_trap(player:get_pos(), 0.5, 2.0, player:get_velocity())
    end
})