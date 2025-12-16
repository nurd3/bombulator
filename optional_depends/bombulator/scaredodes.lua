local function on_activate(self, data)
    local statdat = core.deserialize(data)

    if not statdat then self.object:remove() return end

    self._node = statdat.node
    self._speed = statdat.speed

    if not self._node or not self._speed then self.object:remove() return end

    self.object:set_properties {
        makes_footstep_sound = true,
        visual = "node",
        node = self._node
    }

    self._path = {}
    self._index = 1
end

local function on_step(self, dtime)
    local pos = self.object:get_pos()
    local next_pos = self._path and self._index and self._path[self._index]

    if next_pos then
        self.object:set_velocity(vector.direction(pos, next_pos) * self._speed, true)
        if vector.distance(pos, next_pos) < 0.5 then
            self._index = (self._index or 0) + 1
        end
    else
        local goal = pos + vector.random_direction() * 8 * math.random()
        self._path = core.find_path(pos, goal, 128, 1, 1)
        self._index = 1
    end
end

local function get_staticdata(self)
    return core.serialize({ node = self._node, speed = self._speed })
end

local function on_punch(self, puncher)
    local wielded_item = puncher and puncher:get_wielded_item()
    local pos = vector.round(self.object:get_pos())
    local drops = self._node and core.get_node_drops(
        self._node,
        wielded_item:get_name(),
        wielded_item,
        puncher,
        pos
    )

    for _, stack in ipairs(drops) do
        core.add_item(pos, stack)
    end

    self.object:remove()
end

core.register_entity("bombulator:scaredodes", {
    visual = "node",
    on_activate = on_activate,
    on_step = on_step,
    on_punch = on_punch,
    get_staticdata = get_staticdata
})

local player_speed = core.settings:get("movement_speed_walk") or 4.0

function bombulator.add_fake_node(pos, speed_mult, node)
    local node = node or core.get_node(pos)

    core.set_node(pos, { name = "air" })

    local ref = core.add_entity(pos, "bombulator:scaredodes", core.serialize({ node = node, speed = player_speed * speed_mult }))
    local ent = ref:get_luaentity()

    return ref
end

bombulator.register_bombulation("bombulator:scaredodes", {
    interval = 5,
    per_player = function(player)
        if not player:get_player_control().dig then return end

        local wielded_item = player:get_wielded_item() and player:get_wielded_item():get_definition()
        local range = wielded_item and wielded_item.range or 4.0
        local eye_pos = vector.offset(player:get_pos(), 0, player:get_properties().eye_height, 0)
        local selection_pos = eye_pos + player:get_look_dir() * range
        local speed_mult = player:get_physics_override().speed * player:get_physics_override().speed_walk

        for pointed_thing in Raycast(eye_pos, selection_pos, false, false, wielded_item.pointabilities) do
            if pointed_thing.type == "node" then
                local pos = pointed_thing.under
                local node = core.get_node(pos)

                if bombulator.registered_nodes[node.name] then return bombulator.add_fake_node(pos, speed_mult) end
            end
        end
    end
})