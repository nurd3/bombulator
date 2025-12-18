local stander_disappear_range = 4.0

bombulator.ghost_types["bombulator:stander"] = {
    chance = 1.0,
    on_step = function(self, _, _, player)
        local dist = vector.distance(self.object:get_pos(), player:get_pos())
        if dist < stander_disappear_range then self.object:remove() return end
    end
}

local stander_disappear_range = 4.0

bombulator.ghost_types["bombulator:spawner"] = {
    chance = 1.0,
    on_step = function(self, _, _, player)
        local dist = vector.distance(self.object:get_pos(), player:get_pos())
        if dist < stander_disappear_range then
            core.add_entity(self.object:get_pos(), self._ent_name)
            self.object:remove()
            return
        end
    end
}

local chaser_speed = 8.0
local chaser_chase_range = 32.0

bombulator.ghost_types["bombulator:chaser"] = {
    chance = 0.5,
    on_step = function(self, dtime, _, player)
        local pos = self.object:get_pos()
        local dist = vector.distance(pos, player:get_pos())
        
        if dist < stander_disappear_range then
            self.object:remove() return
        elseif dist < chaser_chase_range then
            self.object:set_velocity(vector.direction(pos, player:get_pos()) * chaser_speed)
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
        local dist = vector.distance(pos, tpos)

        if dist < killer_min_distance then
            local dir = vector.direction(pos, tpos)
            self.object:set_pos(pos + dir * killer_min_distance)
        end

        self._timer = killer_timer

        self._sound_loop = core.sound_play("bombulator_chase_loop", {
            to_player = self._observer,
            object = self.object,
            loop = true,
            max_hear_distance = 64.0
        })
    end,
    on_step = function(self, dtime, _, player)
        local pos = self.object:get_pos()
        local dist = vector.distance(pos, player:get_pos())

        self.object:set_velocity(vector.direction(pos, player:get_pos()) * killer_speed)

        if player:get_hp() <= 0 then self.object:remove() end
        
        if dist < killer_kill_distance then
            self.object:remove()
            player:set_hp(0)
        end
    end,
    on_deactivate = function(self, removal)
        if removal then core.sound_stop(self._sound_loop) end
    end
}