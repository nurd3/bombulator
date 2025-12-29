-- VECTOR ALIASES --
local vdirection, vdir2rot =
    vector.direction, vector.dir_to_rotation
-- OTHER ALIASES ---
local get_player_by_name, fmt, random,
    unpack =
    core.get_player_by_name, string.format, math.random, unpack or table.unpack
--------------------

local VECTOR_UP = vector.new(0, 1, 0)

--- Utility functions provided by bombulator.
bombulator.utils = {}

--- Error function binded with string.format for the message.
--- NOTE: Unlike error, level comes before message.
---@param level number|nil the level of the error.
---@param message string the format string of the message.
---@vararg any format variables
local function errorfmt(level, message, ...)
    error(
        fmt(message, ...),
        -- add 1 to level
        -- we do this so the error raises at the level of this function's caller,
        -- rather than at the level of this function.
        (level or 1) + 1
    )
end
bombulator.utils.errorfmt = errorfmt

---------------------
-- TABLE FUNCTIONS --
---------------------

--- Modified pairs function that takes responsibility over handling iterator state.
---@param t table the table to iterate over.
---@return function the next() function, takes no arguments.
local function abstract_pairs(t)
    local iter, state, key = pairs(t)
    
    return function()
        key = iter(state, key)
        if key == nil then return nil end
        return key, t[key]
    end
end
bombulator.utils.abstract_pairs = abstract_pairs

--- Like `table.insert` but ignores the (table, pos, value) format.
local function push(t, value)
    return table.insert(t, value)
end
bombulator.utils.push = push

----------------------
-- VECTOR FUNCTIONS --
----------------------

-- is_vector --

--- Checks if thing is a vector, handles any value type.
---@param tabl table the thing being checked
---@return boolean true if thing is a vector, false otherwise
local function is_vector(tabl)
    return type(tabl) == "table"
        and type(tabl.x) == "number"
        and type(tabl.y) == "number"
        and type(tabl.z) == "number"
end
bombulator.utils.is_vector = is_vector

-- to_vector --

--- Tries to get a vector from the provided thing.
--- Handles vectors by just returning the vector.
--- Handles strings by returning `vector.from_string(string)`.
--- Unlike `position_of`, this doesn't handle playernames, and doesn't copy if a vector is provided.
---@param thing userdata|table|string the thing to be converted into a vector
---@return vector|nil
local function to_vector(thing)
    if is_vector(thing) then return thing end
    if type(thing) == "string" then return vector.from_string(thing) end
end
bombulator.utils.to_vector = to_vector

-------------------------
-- OBJECTREF FUNCTIONS --
-------------------------

-- is_objectref --

--- Checks if userdata is an ObjectRef.
--- Note: returns false if provided a LuaEntity table or a playername.
---@param thing userdata the thing being checked
---@return boolean true if thing is ObjectRef, false otherwise
local function is_objectref(thing)
    return type(thing) == "userdata"
        -- note: you cannot use pcall(thing.get_pos, thing)
        -- since indexing userdata throws errors.
        and pcall(function() thing:get_pos() end)
end
bombulator.utils.is_objectref = is_objectref

-- to_objectref --

--- Tries to get an ObjectRef from the provided thing.
--- Handles LuaEntity tables by returning their object property.
--- Handles strings, assuming they're playernames.
--- WARNING: OBJECTREF MAY NOT BE VALID.
---@param thing userdata|table|string the thing being checked
---@return userdata|nil ObjectRef if one can be found, nil otherwise
local function to_objectref(thing)
    -- handle LuaEntity tables
    if type(thing) == "table" then thing = thing.object end
    if type(thing) == "string" then thing = get_player_by_name(thing) end
    return is_objectref(thing) and thing
end
bombulator.utils.to_objectref = to_objectref

-- to_valid_objectref --

--- Similar to to_objectref but only returns the ObjectRef if it's valid.
--- Handles LuaEntity tables by returning their object property.
--- Handles strings, assuming they're playernames.
---@param thing userdata|table|string the thing being checked
---@return userdata|nil ObjectRef if one can be found, nil otherwise
local function to_valid_objectref(thing)
    local obj = to_objectref(thing)
    return obj and obj:is_valid() and obj
end
bombulator.utils.to_valid_objectref = to_valid_objectref

-- position_of --

--- Tries to get a vector from the provided thing.
--- Handles vectors by returning a copy of the vector.
--- Handles ObjectRefs by returning `objectref:get_pos()`.
--- Handles LuaEntity tables by returning `luaentity.object:get_pos()`.
--- Handles strings by assuming they're playernames, otherwise it tries `vector.from_string(thing)`.
---@param thing userdata|table|string the thing whose position is to be found
---@return vector|nil the vector if position was found, nil otherwise.
local function position_of(thing)
    if is_vector(thing) then return vector.copy(thing) end
    local obj = to_valid_objectref(thing)
    return obj and obj:get_pos() or vector.from_string(thing)
end
bombulator.utils.position_of = position_of

-- look_at --

--- Looks at something
---@param looker userdata|table|string the thing doing the looking, see `to_valid_objectref`
---@param target userdata|table|string the thing being looked at, see `position_of`
---@return boolean true on success, false on failure
local function look_at(looker, target)
    local looker_obj = to_valid_objectref(looker)
    local tpos = position_of(target)
    
    if looker_obj then
        local tpos = position_of(target)
        local dir = vdirection(looker_obj:get_pos(), tpos)

        dir.y = 0

        looker_obj:set_rotation( vdir2rot(dir, VECTOR_UP) )

        return true
    end

    return false
end
bombulator.utils.look_at = look_at

-- nearly_kill --

--- Sets something's hp to 1, see bombulator.utils.to_valid_objectref for valid input.
--- Does not give error for invalid input.
---@param thing userdata|table|string the thing being nearly killed, see `to_valid_objectref`
---@return boolean true on success, false on failure
local function nearly_kill(thing)
    local obj = to_valid_objectref(thing)

    if obj then
        obj:set_hp(1)
        return true
    end
    
    return false
end
bombulator.utils.nearly_kill = nearly_kill

-- two_shot_kill --

--- Kills something in two shots.
--- If hp == 1, then this will kill the thing.
--- otherwise, this will set the thing's hp to 1.
---@param thing userdata|table|string the thing being two-shotted, see `to_valid_objectref`
---@return boolean true on success, false on failure
local function two_shot_kill(thing)
    local obj = to_valid_objectref(thing)

    if obj then
        if obj:get_hp() > 1 then obj:set_hp(1)
        else obj:set_hp(0) end

        return true
    end

    return false
end
bombulator.utils.two_shot_kill = nearly_kill

--------------------
-- CHAT FUNCTIONS --
--------------------

--- Sends a message tagged as coming from bombulator, passes message through string.format.
---@param message string the message format_string
---@return boolean true on success, false on failure
local function announce_fmt(message, ...)
    core.chat_send_all("<|3 () /\\/\\ |3 U |_ /\\ *|* () R> " .. fmt(message, ...))
end
bombulator.utils.announce_fmt = announce_fmt

--- Sends a dm tagged as coming from bombulator, passes message through string.format.
---@param name string the name of the recipient
---@param message string the message format_string
---@return boolean true on success, false on failure
local function dm_fmt(name, message, ...)
    core.chat_send_player(name, "DM from |3 () /\\/\\ |3 U |_ /\\ *|* () R: " .. fmt(message, ...))
end
bombulator.utils.dm_fmt = dm_fmt

----------------------
-- RANDOM FUNCTIONS --
----------------------
-- put at the bottom because it's a lot of code.
-- decoupled in case registry-specific behaviour is needed.

--- Get a random pair from an iterator.
---@param factory function an iterator factory.
---@param filter function|nil a function determining which entries should be selected from, gets key and value as arguments, returns true for each entry to be included.
---@vararg any arguments to be passed to the factory function.
---@return ...|nil a random pair returned by the next function, returns nil if next function gave no entries.
local function iterator_random(factory, filter, ...)
    if type(factory) ~= "function" then 
        errorfmt(2, "bad argument #1 to bombulatior.utils.iterator_random(): expected function, got %s instead.", type(factory))
    elseif filter and type(filter) ~= "function" then
        errorfmt(2, "bad argument #2 to bombulatior.utils.iterator_random(): expected function|nil, got %s instead.", type(filter))
    end

    local temp = {}
    local filter = filter or function() return true end
    local next, state, index = factory(...)

    repeat
        local entry = {next(state, index)}
        index = #entry ~= 0 and entry[1]
        if index and filter(unpack(entry)) then table.insert(temp, entry) end
    until (not index)

    if #temp == 0 then return end
    return unpack(temp[random(#temp)])
end
bombulator.utils.iterator_random = iterator_random

--- Get a random key-value pair from a table
---@param t table
---@param filter function|nil a function determining which entries should be selected from, gets key and value as arguments, returns true for each entry to be included.
---@return any, any a random key-value pair from the table.
local function random_pair(t, filter)
    if type(t) ~= "table" then 
        errorfmt(2, "bad argument #1 to bombulatior.utils.table_random(): expected table, got %s instead.", type(t))
    elseif filter and type(filter) ~= "function" then
        errorfmt(2, "bad argument #2 to bombulatior.utils.table_random(): expected function|nil, got %s instead.", type(filter))
    end

    return iterator_random(pairs, filter, t)
end
bombulator.utils.random_pair = random_pair

--- Get a random index-value ipair from a table
---@param t table
---@param filter function|nil a function determining which entries should be selected from, gets key and value as arguments, returns true for each entry to be included.
---@return number, any a random index-value pair from the table.
local function random_ipair(t, filter)
    if type(t) ~= "table" then 
        errorfmt(2, "bad argument #1 to bombulatior.utils.table_random(): expected table, got %s instead.", type(t))
    elseif filter and type(filter) ~= "function" then
        errorfmt(2, "bad argument #2 to bombulatior.utils.table_random(): expected function|nil, got %s instead.", type(filter))
    end

    return iterator_random(ipairs, filter, t)
end
bombulator.utils.random_ipair = random_ipair

local function chance_check(name, def)
    return def.chance and math.random() < def.chance or false
end

--- get a random bombulation
---@return table
function bombulator.random_bombulation()
    return random_pair(bombulator.registered_bombulations, chance_check)
end

--- get a random entity
---@return table
function bombulator.random_entity()
    return random_pair(bombulator.registered_entities, chance_check)
end

--- get a random item
---@return table
function bombulator.random_item()
    return random_pair(bombulator.registered_items, chance_check)
end

--- get a random node
---@return table
function bombulator.random_node()
    return random_pair(bombulator.registered_nodes, chance_check)
end

--- get a random sound
---@return table
function bombulator.random_sound()
    return random_pair(bombulator.registered_sounds, chance_check)
end

--- get a random texture
---@return table
function bombulator.random_texture()
    return random_pair(bombulator.registered_textures, chance_check)
end