local path = bombulator.get_modpath
local gamedata = core.get_game_info()

-- util function for checking if file exists
local function file_exists(name)
    local f = io.open(name,"r")
    
    if f == nil then return false end

    io.close(f)
    return true
end

for _, modname in ipairs(core.get_modnames()) do
    local src = path.."/compat/" .. modname .. "/init.lua"
    -- game is supported?
    if file_exists(src) then
        core.log("info", "[MOD] bombulator supported mod: " .. modname)
        bombulator.compat_path = path .. "/compat/" .. modname
        dofile(src)
    else
        core.log("warning", "[MOD] bombulator unsupports mod: " .. modname)
    end
end

bombulator.begin()