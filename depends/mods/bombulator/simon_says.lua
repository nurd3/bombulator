-- ALIASES --
local get_connected_players, fmt, log,
    sound_play, announce_fmt =
    core.get_connected_players, string.format, core.log,
    core.sound_play, bombulator.utils.announce_fmt
-------------

local followed_orders = {}
local order
local possible_orders = {"jump", "sneak", "dig", "place", "zoom"}
local timer = 0.0

function bombulator.simon_says()
    if order ~= nil then return end
    log("info", "bombulator.simon_says()")

    for _, player in ipairs(get_connected_players()) do
        local playername = player:get_player_name()
        followed_orders[playername] = false
    end

    order = possible_orders[math.random(#possible_orders)]
    timer = 10.0

    core.sound_play("bombulator_simon_says")
    announce_fmt("Simon says %s", order)
end

bombulator.register_bombulation("bombulator:simon_says", {
    interval = 5.0,
    global = function()
        bombulator.simon_says()
    end
})

local function punish_player(player, playername)
    core.chat_send_all(core.colorize("#ff0000", fmt("%s didn't %s!", playername, order)))
    core.sound_play("bombulator_simon_says_fail", {
        to_player = playername
    })

    if player:get_hp() > 1 then player:set_hp(1)
    else player:set_hp(0) end
end

local function times_up()
    for _, player in ipairs(get_connected_players()) do
        local playername = player:get_player_name()
        if not followed_orders[playername] then punish_player(player, playername) end
    end
    order = nil
end

local function globalstep(dtime)
    timer = timer - dtime

    if not order then return end
    if timer < 0.0 then return times_up() end

    for _, player in ipairs(get_connected_players()) do
        local playername = player:get_player_name()
        local controls = player:get_player_control()
        if controls[order] then followed_orders[playername] = true end
    end
end

core.register_globalstep(globalstep)