local doorulation_radius = 64.0
local doorulation_chance = 0.5

function bombulator.doorulation(origin)
    core.log("info", "bombulator.doorulation")

    for _ = 1, doorulation_radius * doorulation_radius do
        local pos = vector.round(origin + vector.random_direction() * math.random() * doorulation_radius)
        local node = core.get_node(pos)
        local dir = vector.random_direction()
        if math.random() < doorulation_chance then nc.operate_door(pos, node, dir) end
    end
end

bombulator.register_bombulation("bombulator:doorulation", {
    interval = 5.0,
    per_player = function (player)
        bombulator.doorulation(player:get_pos())
    end
})