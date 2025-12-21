bombulator.ghost_types = {}

-- ALIASES --
local vrand_dir, vnormalize, vround,
    push =
        vector.random_direction, vector.round, vector.round,
        bombulator.utils.push
-------------

local function on_activate(self, data, dtime_s)
    local statdat = core.deserialize(data)

    if not statdat then self.object:remove() return end

    self._ghost_type = statdat.type
    self._behaviour = bombulator.ghost_types[self._ghost_type]

    self._ent_name = statdat.ent_name
    local ent_def = core.registered_entities[self._ent_name]

    self._observer = statdat.observer

    if not self._ghost_type
    or not self._behaviour
    or not self._observer
    or not self._ent_name
    or not ent_def
    or ent_def.ghost_incompatible then
        self.object:remove()
        return
    end

    local initial_properties =
        ent_def.initial_properties and ent_def.initial_properties or ent_def

    for k, v in pairs(ent_def) do initial_properties[k] = v end

    local textures = {}

    for _ = 1, math.random(1, 6) do
        push(textures, bombulator.random_texture())
    end

    self.object:set_properties {
        collisionbox = initial_properties.collisionbox,
        selectionbox = initial_properties.selectionbox,
        visual = initial_properties.visual,
        visual_size = initial_properties.visual_size,
        textures = textures,
        mesh = initial_properties.mesh,
        use_texture_alpha = initial_properties.use_texture_alpha,
        spritediv = initial_properties.spritediv,
        initial_sprite_basepos = initial_properties.initial_sprite_basepos,
        makes_footstep_sound = initial_properties.makes_footstep_sound,
        backface_culling = initial_properties.backface_culling,
        glow = initial_properties.glow,
        node = initial_properties.node
    }

    self.object:set_observers { [self._observer] = true }

    local collisionbox = self.object:get_properties().collisionbox
    local pos = vector.offset(self.object:get_pos(), 0, -collisionbox[2], 0)
    self.object:set_pos(pos)

    if self._behaviour.on_activate then self._behaviour.on_activate(self, statdat, dtime_s) end
    
    self._timer = self._timer or statdat.timer or 30.0
end

local function on_step(self, dtime, moveresult)
    local observer = self._observer and core.get_player_by_name(self._observer)

    self._timer = self._timer - dtime

    if not self._behaviour
    or not observer
    or not observer:is_valid()
    or self._timer < 0.0 then
        self.object:remove()
        return
    end

    if self._behaviour.on_step then self._behaviour.on_step(self, dtime, moveresult, observer) end
end

local function on_deactivate(self, removal)
    core.log("info", "bombulator ghost_sighting on_deactivate")
    if self._behaviour and self._behaviour.on_deactivate then self._behaviour.on_deactivate(self, removal) end
end

local function on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage)
    local wielded_item = puncher:get_wielded_item()

    if self._behaviour.on_punch then self._behaviour.on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir, damage) end

    if wielded_item and tool_capabilities then
        local wear = wielded_item:get_wear()
        local params = core.get_hit_params({}, tool_capabilities)

        wielded_item:set_wear(wear - params.wear) 
        puncher:set_wielded_item(wielded_item)
    end

    return true
end

local function get_staticdata(self)
    core.log("info", "bombulator ghost_sighting get_staticdata")
    local temp = { type = self._ghost_type, ent_name = self._ent_name, timer = self._timer, observer = self._observer }

    if self._behaviour and self._behaviour.get_staticdata then self._behaviour.get_staticdata(self, temp) end

    return core.serialize(temp)
end

function bombulator.spawn_ghost(pos, ent_name, type, observer)
    core.log("info", string.format(
        "bombulator %s ghost of %s spawned at %s",
        tostring(type),
        tostring(ent_name),
        vector.to_string(pos)
    ))
    return core.add_entity(pos, "bombulator:ghost", core.serialize {
        type = type,
        ent_name = ent_name,
        observer = observer
    })
end

core.register_entity("bombulator:ghost", {
    ghost_incompatible = true,
    -- physical = true,
    collides_with_objects = false,

    get_staticdata = get_staticdata,
    on_activate = on_activate,
    on_deactivate = on_deactivate,
    on_punch = on_punch,
    on_step = on_step,
})

local ghost_sighting_radius = 128.0
local ghost_sighting_position_iterations_limit = 512

function bombulator.ghost_sighting(player)
    -- make direction only along x, z since y is handled by code below
    local dir = vrand_dir()
    dir.y = 0
    dir = vnormalize(dir)

    local pos = vround(player:get_pos() + dir * ghost_sighting_radius * math.random())

    local ent_name = bombulator.random_entity()
    local temp = {}
    local playername = player:get_player_name()

    if not ent_name then return end

    for name, def in pairs(bombulator.ghost_types) do
        if def and def.chance and math.random() < def.chance then
            push(temp, name)
        end
    end

    if #temp == 0 then return end

    for _ = 1, ghost_sighting_position_iterations_limit do
        local node = core.get_node(pos)
        local below = core.get_node(vector.offset(pos, 0, -1, 0))

        if below.name == "air" then pos.y = pos.y - 1
        elseif node.name ~= "air" then pos.y = pos.y + 1
        -- no more adjustments needed, success state
        else return bombulator.spawn_ghost(pos, ent_name, temp[math.random(#temp)], playername) end
    end

    -- went over the iteration limit, fail state
    return
end

bombulator.register_bombulation("bombulator:ghost_sighting", {
    interval = 15.0,
    per_player = function(player)
        bombulator.ghost_sighting(player)
    end
})