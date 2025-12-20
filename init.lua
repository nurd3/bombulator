bombulator = {}

local path = core.get_modpath "bombulator"
local S = core.get_translator "bombulator"

bombulator.get_modpath = path
bombulator.get_translator = S

dofile (path .. "/functions.lua")
dofile (path .. "/register.lua")
dofile (path .. "/bombulation.lua")
dofile (path .. "/cheating.lua")

deploader.load_depends()

bombulator.random_sound()