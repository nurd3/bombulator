local get_connected_players, fmt =
    core.get_connected_players, string.format

local followed_orders = {}
local order
local possible_orders = {"jump", "crouch", "dig"}
local timer = 0.0

function bombulator.simon_says()
    core.log("info", "bombulator.simon_says()")
    if order ~= nil then return end

    for _, player in ipairs(get_connected_players()) do
        local playername = player:get_player_name()
        followed_orders[playername] = false
    end

    order = possible_orders[math.random(#possible_orders)]
    timer = 10.0

    bombulator.chat_send_all("Simon says %s", order)
end

bombulator.register_bombulation("bombulator:simon_says", {
    interval = 5.0,
    global = function()
        bombulator.simon_says()
    end
})

local function globalstep(dtime)
    timer = timer - dtime
    if order then
        if timer < 0.0 then 
            for _, player in ipairs(get_connected_players()) do
                local playername = player:get_player_name()
                if not followed_orders[playername] then
                    core.chat_send_all(core.colorize("#ff0000", fmt("%s didn't %s!", playername, order)))
                    player:set_hp(0)
                end
            end
            order = nil
        else
            for _, player in ipairs(get_connected_players()) do
                local playername = player:get_player_name()
                local controls = player:get_player_control()
                if controls[order] then followed_orders[playername] = true end
            end
        end
    end
end

core.register_globalstep(globalstep)