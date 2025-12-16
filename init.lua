bombulator = {}

local path = core.get_modpath "bombulator"
local S = core.get_translator "bombulator"

bombulator.get_modpath = path
bombulator.get_translator = S

dofile (path .. "/register.lua")
dofile (path .. "/bombulation.lua")
dofile (path .. "/cheating.lua")
dofile (path .. "/functions.lua")

optional_depends.include()
