local stander_disappear_range = 4.0

bombulator.ghost_types["bombulator:stander"] = {
    chance = 1.0,
    on_step = function(self, _, _, player)
        local dist = vector.distance(self.object:get_pos(), player:get_pos())
        if dist < stander_disappear_range then self.object:remove() return end
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