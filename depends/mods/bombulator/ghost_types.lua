local vrand_dir, vnormalize, vround, 
    vdistance, vdirection, vdir2rot,
    vlength =
    vector.random_direction, vector.round, vector.round,
    vector.distance, vector.direction, vector.dir_to_rotation,
    vector.length

local VECTOR_UP = vector.new(0, 1, 0)

local function look_at_obj(self, target)
    if type(self) == "table" then return look_at_obj(self.object, target) end

    local tpos = target:get_pos()
    local dir = vdirection(self:get_pos(), target:get_pos())

    dir.y = 0

    self:set_rotation( vdir2rot(dir, VECTOR_UP) )
end

local stander_disappear_range = 4.0

bombulator.ghost_types["bombulator:stander"] = {
    chance = 1.0,
    on_step = function(self, _, _, player)
        local obj = self.object
        local tpos = player:get_pos()
        local dist = vdistance(obj:get_pos(), tpos)
        
        look_at_obj(obj, player)

        if dist < stander_disappear_range then obj:remove() return end
    end
}

local stander_disappear_range = 4.0

bombulator.ghost_types["bombulator:spawner"] = {
    chance = 1.0,
    on_step = function(self, _, _, player)
        local obj = self.object
        local tpos = player:get_pos()
        local dist = vdistance(obj:get_pos(), tpos)
        
        look_at_obj(obj, player)

        if dist < stander_disappear_range then
            core.add_entity(obj:get_pos(), self._ent_name)
            obj:remove()
            return
        end
    end
}

local chaser_speed = 8.0
local chaser_chase_range = 32.0

bombulator.ghost_types["bombulator:chaser"] = {
    chance = 0.5,
    on_step = function(self, dtime, _, player)
        local obj = self.object
        local pos = obj:get_pos()
        local tpos = player:get_pos()
        local dist = vdistance(obj:get_pos(), tpos)
        
        look_at_obj(obj, player)
        
        if dist < stander_disappear_range then
            obj:remove() return
        elseif dist < chaser_chase_range then
            local goal = player:get_pos()
            -- adjust for eye_height
            goal.y = goal.y + player:get_properties().eye_height or 1.625

            local path = core.find_path(pos, goal, 128, 16, 16)
            local next_pos = path and path[2] or goal

            obj:set_velocity(vdirection(pos, next_pos) * chaser_speed)
        end
    end
}

local killer_speed = 8.0
local killer_timer = 16.0
local killer_min_distance = 64.0
local killer_kill_distance = 1.0

bombulator.ghost_types["bombulator:killer"] = {
    chance = 0.5,
    on_activate = function(self)
        local pos = self.object:get_pos()
        local tpos = self._observer and core.get_player_by_name(self._observer):get_pos()
        local dist = vdistance(pos, tpos)

        if dist < killer_min_distance then
            local dir = vdirection(pos, tpos)
            self.object:set_pos(pos + dir * killer_min_distance)
        end

        self._timer = killer_timer
    end,
    on_step = function(self, dtime, _, player)
        local obj = self.object
        local pos = obj:get_pos()
        local tpos = player:get_pos()
        local dist = vdistance(obj:get_pos(), tpos)
        
        look_at_obj(obj, player)

        if player:get_hp() <= 0 then self.object:remove() end
        if not self._sound_loop then
            self._sound_loop = core.sound_play("bombulator_chase_loop", {
                to_player = self._observer,
                object = obj,
                max_hear_distance = 64.0
            })
        end

        local goal = tpos
        -- adjust for eye_height
        goal.y = goal.y + player:get_properties().eye_height or 1.625
        local path = core.find_path(pos, goal, 128, 16, 16)
        local next_pos = path and path[2] or goal
        local dir = vdirection(pos, next_pos)

        obj:set_velocity(dir * killer_speed)
        
        if dist < killer_kill_distance then
            obj:remove()
            player:set_hp(0)
        end
    end,
    on_deactivate = function(self, removal)
        if removal and self._sound_loop then core.sound_stop(self._sound_loop) end
    end
}