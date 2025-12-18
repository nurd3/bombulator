core.register_entity("bombulator:builtin_player", {
    visual = "upright_sprite",
    collisionbox = {-0.3, -0.5, -0.3, 0.3, 0.5, 0.3},
    visual_size = {x = 1, y = 2},
    textures = {"player.png", "player_back.png"},
    on_activate = function(self) self.object:remove() end
})

bombulator.register_entities { ["bombulator:builtin_player"] = { chance = 1.0 } }