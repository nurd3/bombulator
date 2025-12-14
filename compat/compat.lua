local path = bombulator.get_modpath
local gamedata = core.get_game_info()

-- util function for checking if file exists
local function file_exists(name)
    local f = io.open(name,"r")
    
    if f == nil then return false end

    io.close(f)
    return true
end

core.register_on_mods_loaded(function()
    -- error handling
    if gamedata and gamedata.id then
        local src = path .. "/compat/games/" .. gamedata.id .. "/init.lua"
        -- game is supported?
        if file_exists(src) then
            bombulator.compat_path = path .. "/compat/games/" .. gamedata.id
            dofile(src)
        else
            minetest.log("warning", "[MOD] bombulator unsupports game: " .. gamedata.id)
        end
    else    -- theoretically this message shouldn't show up
        minetest.log("warning", "[MOD] bombuwtf (invalid game data)")
    end

    for _, modname in ipairs(core.get_modnames()) do
        local src = path.."/compat/mods/" .. modname .. "/init.lua"
        -- game is supported?
        if file_exists(src) then
            bombulator.compat_path = path .. "/compat/mods/" .. gamedata.id
            dofile(src)
        else
            minetest.log("warning", "[MOD] bombulator unsupports mod: " .. modname)
        end
    end

    bombulator.begin()
end)