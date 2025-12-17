local function random_key(tbl, predicate)
    local temp = {}
    local predicate = predicate or function() end

    for k, v in pairs(tbl) do
        if predicate(k, v) then
            table.insert(temp, k)
        end
    end

    return temp[math.random(#temp)]
end

local function chance_check(name, def)
    return def.chance and math.random() < def.chance or false
end

function bombulator.random_bombulation()
    return random_key(bombulator.registered_bombulations, chance_check)
end

function bombulator.random_entity()
    return random_key(bombulator.registered_entities, chance_check)
end

function bombulator.random_item()
    return random_key(bombulator.registered_items, chance_check)
end

function bombulator.random_node()
    return random_key(bombulator.registered_nodes, chance_check)
end

function bombulator.random_sound()
    return random_key(bombulator.registered_sounds, chance_check)
end