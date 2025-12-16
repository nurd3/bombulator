local doorulation_radius = 64.0
local doorulation_chance = 0.5

function bombulator.doorulation(origin)
    core.log("info", "bombulator.doorulation")

    for _ = 1, doorulation_radius * doorulation_radius do
        local pos = vector.round(origin + vector.random_direction() * math.random() * doorulation_radius)
        local door = doors.get(pos)
        if door and math.random() < doorulation_chance then door:toggle() end
    end
end

bombulator.register_bombulation("bombulator:doorulation", {
    interval = 5.0,
    per_player = function (player)
        bombulator.doorulation(player:get_pos())
    end
})