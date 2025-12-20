-- ALIASES --
local announce_fmt =
    bombulator.utils.announce_fmt
-------------

local function punish_moved_too_fast(player)
    local playername = player:get_player_name()
    announce_fmt("%s moved too fast !!! >:(", playername)
end

local function punish_interacted_too_far(player)
    local playername = player:get_player_name()
    announce_fmt("%s interacted too far !!! >:(", playername)
end

local function punish_interacted_with_self(player)
    local playername = player:get_player_name()
    announce_fmt("%s interacted too far !!! >:(", playername)
end

local function punish_interacted_while_dead(player)
    local playername = player:get_player_name()
    announce_fmt("%s interacted while dead !!! >:(", playername)
end

local function punish_finished_unknown_dig(player)
    local playername = player:get_player_name()
    announce_fmt("%s finished unknown dig !!! >:(", playername)
end

local function punish_dug_unbreakable(player)
    local playername = player:get_player_name()
    announce_fmt("%s dug unbreakable !!! >:(", playername)
end

local function punish_dug_too_fast(player)
    local playername = player:get_player_name()
    announce_fmt("%s dug too fast !!! >:(", playername)
end

--- Punishes a cheator!!!!!!
---@param player userdata the objectref of the cheator!
---@param cheat table must have the type property defined as a string
function bombulator.punish_cheater(player, cheat)
    local playername = player:get_player_name()

    -- hai :   3

    if cheat.type == "moved_too_fast" then punish_moved_too_fast(player)
    elseif cheat.type == "interacted_too_far" then punish_interacted_too_far(player)
    elseif cheat.type == "interacted_with_self" then punish_interacted_with_self(player)
    elseif cheat.type == "interacted_while_dead" then punish_interacted_while_dead(player)
    elseif cheat.type == "finished_unknown_dig" then punish_finished_unknown_dig(player)
    elseif cheat.type == "dug_unbreakable" then punish_dug_unbreakable(player)
    elseif cheat.type == "dug_too_fast" then punish_dug_too_fast(player) end
end

core.register_on_cheat(bombulator.punish_cheater)