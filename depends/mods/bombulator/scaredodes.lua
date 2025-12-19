local scaredodes_timer_min = 1.0
local scaredodes_timer_max = 15.0

local function on_activate(self, data)
    local statdat = core.deserialize(data)

    if not statdat then self.object:remove() return end

    self._node = statdat.node
    self._speed = statdat.speed
    self._timer = statdat.timer or math.max(scaredodes_timer_min, scaredodes_timer_max)
    self._meta = statdat.meta or {}

    if not self._node or not self._speed then self.object:remove() return end

    self.object:set_properties {
        makes_footstep_sound = true,
        visual = "node",
        node = self._node
    }

    self._path = {}
    self._index = 1
end

local function on_step(self, dtime, moveresult)
    local pos = self.object:get_pos()
    local below = core.get_node(vector.floor(vector.offset(pos, 0, -0.25, 0)))
    local below_def = core.registered_nodes[below.name]
    local next_pos = self._path and self._index and self._path[self._index]

    self._timer = self._timer - dtime

    if self._timer < 0.0 then
        self.object:remove()
        core.set_node(vector.floor(pos), self._node)
        core.get_meta(pos):from_table(self._meta)
        return
    end

    if below_def and below_def.walkable then 
        if next_pos then
            local dir = vector.direction(pos, next_pos)
            self.object:set_velocity(dir * self._speed)
            if vector.distance(pos, next_pos) < 0.5 then
                self._index = (self._index or 0) + 1
            end
        else
            local goal = pos + vector.random_direction() * 8 * math.random()
            if core.get_node(vector.floor(goal)).name == "air" then
                self._path = core.find_path(pos, goal, 128, 1, 1)
                self._index = 1
            end
            self.object:set_velocity(vector.zero())
        end
    else self.object:add_velocity(vector.new(0, -9.8, 0) * dtime) end
end

local function on_punch(self, puncher, _, tool_capabilities)
    local wielded_item = puncher:get_wielded_item()
    local pos = vector.round(self.object:get_pos())
    local node = self._node

    core.set_node(pos, node)
    core.get_meta(pos):from_table(self._meta)

    self.object:remove()

    if wielded_item and tool_capabilities then
        local wear = wielded_item:get_wear()
        local params = core.get_hit_params({}, tool_capabilities)

        wielded_item:set_wear(wear - params.wear) 
        puncher:set_wielded_item(wielded_item)
    end

    return true
end

local function get_staticdata(self)
    return core.serialize({ node = self._node, speed = self._speed, timer = self._timer, meta = self._meta })
end

core.register_entity("bombulator:scaredodes", {
    stepheight = 0.5,
    visual = "node",
    on_activate = on_activate,
    on_step = on_step,
    on_punch = on_punch,
    get_staticdata = get_staticdata
})

local player_speed = core.settings:get("movement_speed_walk") or 4.0

function bombulator.add_fake_node(pos, speed_mult, node)
    local node = node or core.get_node(pos)
    local node_meta = core.get_meta(pos):to_table()

    core.set_node(pos, { name = "air" })

    local ref = core.add_entity(pos, "bombulator:scaredodes", core.serialize({ node = node, speed = player_speed * speed_mult, meta = node_meta }))
    local ent = ref:get_luaentity()

    return ref
end

bombulator.register_bombulation("bombulator:scaredodes", {
    interval = 2.0,
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