bombulator.registered_bombulations = {}
bombulator.registered_entities = {}
bombulator.registered_items = {}
bombulator.registered_nodes = {}
bombulator.registered_sounds = {}
bombulator.registered_textures = {}

-- stfu complexity calculator

--- sorts a name into bombulator's registries based off of which core registry it's registered to.
--- priority goes:
--- 1. registered_entities
--- 2. registered_items
--- 3. registered_nodes
local function sort_name(name, def)
    if core.registered_entities[name] then
        bombulator.registered_entities[name] = def
    elseif core.registered_items[name] then
        bombulator.registered_items[name] = def
    elseif core.registered_nodes[name] then
        bombulator.registered_nodes[name] = def
    else
        core.log("error", "bombulator.register_names(): unknown name \"" .. name .. "\"")
    end
end

--- register a bombulation
--- definitions have the following properties:
--- - `interval: float` = on average how often this bombulation occurs
--- - `per_player: function(player, global_memory)` = how this bombulation is applied for each player 
function bombulator.register_bombulation(name, def)
    if type(name) ~= "string" then error("bombulator.register_bombulation(): got non-string name") end
    if type(def) ~= "table" then error("bombulator.register_bombulation(): got non-table definition") end

    bombulator.registered_bombulations[name] = def
end

--- sorts a name into bombulator's registries based off of which core registry it's registered to.
--- priority goes:
--- 1. registered_entities
--- 2. registered_items
--- 3. registered_nodes
function bombulator.register_names(registry)
    for name, def in pairs(registry) do
        local name = core.registered_aliases[name] or name

        if type(name) ~= "string" then error("bombulator.register_names(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_names(): got non-table definition") end

        sort_name(name, def)
    end
end

function bombulator.register_entities(registry)
    for name, def in pairs(registry) do
        local name = core.registered_aliases[name] or name

        if type(name) ~= "string" then error("bombulator.register_entities(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_entities(): got non-table definition") end
        if not core.registered_entities[name] then core.log("error", "bombulator.register_entities(): unknown entity \"" .. name .. "\"") end

        bombulator.registered_entities[name] = def
    end
end

function bombulator.register_items(registry)
    for name, def in pairs(registry) do
        local name = core.registered_aliases[name] or name

        if type(name) ~= "string" then error("bombulator.register_items(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_items(): got non-table definition") end
        if not core.registered_items[name] then core.log("error", "bombulator.register_items(): unknown item \"" .. name .. "\"") end

        bombulator.registered_items[name] = def
    end
end

function bombulator.register_nodes(registry)
    for name, def in pairs(registry) do
        local name = core.registered_aliases[name] or name

        if type(name) ~= "string" then error("bombulator.register_nodes(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_nodes(): got non-table definition") end
        if not core.registered_nodes[name] then core.log("error", "bombulator.register_nodes(): unknown node \"" .. name .. "\"") end

        bombulator.registered_nodes[name] = def
    end
end

function bombulator.register_sounds(registry)
    for name, def in pairs(registry) do
        if type(name) ~= "string" then error("bombulator.register_sounds(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_sounds(): got non-table definition") end

        bombulator.registered_sounds[name] = def
    end
end

function bombulator.register_textures(registry)
    for name, def in pairs(registry) do
        if type(name) ~= "string" then error("bombulator.register_textures(): got non-string name") end
        if type(def) ~= "table" then error("bombulator.register_textures(): got non-table definition") end

        bombulator.registered_sounds[name] = def
    end
end