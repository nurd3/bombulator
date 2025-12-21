-- ALIASES --
local random, fmt, S,
    vlength =
        math.random, string.format, bombulator.get_translator,
        vector.length
-------------

----------
-- MATH --
----------

local arithmetic_min = 0
local arithmetic_max = 10
local arithmetic_operations = {"+", "-"}

local function arithmetic()
    local lhs, rhs = random(arithmetic_min, arithmetic_max), random(arithmetic_min, arithmetic_max)
    local operator = arithmetic_operations[random(1, 2)]
    local answer

    if operator == "+" then answer = lhs + rhs
    elseif operator == "-" then answer = lhs - rhs end
    
    return {
        question = fmt("label[0.25,0.5;%i %s %i = ???]", lhs, operator, rhs),
        answer = tostring(answer),
        options = {
            answer + random(arithmetic_min, arithmetic_max) + 1,
            answer - random(arithmetic_min, arithmetic_max) - 1,
            answer + random(arithmetic_min, arithmetic_max) + 1,
            answer - random(arithmetic_min, arithmetic_max) - 1
        }
    }
end

local select_minmax_minimum = -99
local select_minmax_maximum = 99

local function select_minmax()
    local minimum =
        random(select_minmax_minimum, select_minmax_maximum - 1)
    local maximum
        = random(minimum + 1, select_minmax_maximum)
    if math.random(2) == 1 then
        local irrelevant = random(minimum + 1, select_minmax_maximum)
        return {
            question = fmt("label[0.25,0.5;%s]", core.formspec_escape(S"Which of the 3 numbers below is the lowest?")),
            answer = minimum,
            options = { maximum, irrelevant }
        }
    else 
        local irrelevant = random(select_minmax_minimum, maximum - 1)
        return {
            question = fmt("label[0.25,0.5;%s]", core.formspec_escape(S"Which of the 3 numbers below is the highest?")),
            answer = maximum,
            options = { minimum, irrelevant }
        }
    end
end

------------
-- TRIVIA --
------------

local trivia_questions = {
    {
        question = S"What's the password?",
        answer = "password",
        options = {
            "M49m7,,['N1n",
            "7Xog_i085$Xx",
            "I/Inw{41-6+?",
            "V5m2!1`V-h+I",
            "2TkYG2\"O\\y9$",
            "+@1[Wu57MdTV",
            "46A)a-82b~Z)",
            "U9w>YI9k#4+h",
        }
    },
    {
        question = S"When did the 21st century begin?",
        answer = "2000",
        options = {
            "1900",
            "2100"
        }
    },
    {
        question = S"What day started the year 1999?",
        answer = S"January 1st",
        options = {
            S"1999",
            S"'99",
            S"Februralarry 29nd"
        }
    },
    {
        question = S"When did the Mayan calendar end?",
        answer = S"2012 December 21st",
        options = {
            S"1927 April 12th",
            S"1967 June 7th",
            S"1966 October 15th",
            S"1917 November 7th",
            S"1848 February 21st",
            S"3013 Septuary 42th",
            S"3001 Marchember 39nd"
        }
    },
    {
        question = S"What's my name?",
        answer = S"B O M B U L A T O R",
        options = {
            S"Minetest",
            S"NodeCore",
            S"Unlit",
            S"Void - An empty game",
            S"Age of Mending"
        }
    },
    {
        question = S"Say something.",
        answer = S"Something",
        options = {
            S"Hi",
            S"No",
            S"Okay",
            S"What?",
            S"This isn't a question"
        }
    },
    {
        question = S"Remember this question.",
        answer = S"Okay",
        options = {
            S"Hi",
            S"No",
            S"What?",
            S"This isn't a question"
        }
    },
}

local function trivia()
    table.shuffle(trivia_questions)
    local quiz = table.copy(trivia_questions[1])
    quiz.question = fmt("label[0.25,0.5;%s]", core.formspec_escape(quiz.question))
    return quiz
end

--------------------
-- GUESS THE NODE --
--------------------

local function guess_the_node()
    -- quiz doesn't work if there aren't at least 2 options to pick from
    if #bombulator.registered_nodes < 2 then return end
    local options = { bombulator.random_node(), bombulator.random_node(), bombulator.random_node() }
    local node_name = options[1]

    for index, option in ipairs(options) do
        local node_def = core.registered_nodes[option]

        while index ~= 1 and option == node_name do
            options[index] = bombulator.random_node()
        end

        options[index] = node_def and (node_def.short_description or node_def.description) or option
    end

    local answer = table.remove(options, 1)

    return {
        question = fmt([[
            label[0.25,0.5;%s]
            item_image[0.25,0.75;1.0,1.0;%s]
        ]], core.formspec_escape(S"What is this node?"), node_name),
        answer = answer,
        options = options
    }
end

local function coinflip()
    local answer = "tails"

    if random(2) == 1 then answer = "heads" end

    return {
        question = "label[0.25,0.5;heads or tails?]",
        answer = answer,
        options = { "neither", "both" }
    }
end

-----------------
-- BOMBULATION --
-----------------

local ongoing_quizzes = {}

function bombulator.show_quiz_formspec(playername, quiz)
    ongoing_quizzes[playername] = quiz

    local options = quiz.options

    -- shuffle options and make sure there's only 3 options
    table.shuffle(options)
    options = {options[1], options[2], quiz.answer}
    table.shuffle(options)

    local answer_index

    for index, option in ipairs(options) do
        if option == quiz.answer then answer_index = index end
    end

    ongoing_quizzes[playername].answer_index = answer_index

    core.show_formspec(playername, "bombulator:quiz", [[
        formspec_version[4]
        size[8,8]
        position[0.5,0.5]
        no_prepend[]
    ]]
    .. fmt([[
        button[0.25,3.0;4.0,0.5;submit_1;%s]
        button[0.25,3.5;4.0,0.5;submit_2;%s]
        button[0.25,4.0;4.0,0.5;submit_3;%s]
    ]], options[1], options[2], options[3])
    .. quiz.question)
end

local quiz_generators = {arithmetic, select_minmax, trivia, coinflip, guess_the_node}

function bombulator.random_quiz()
    table.shuffle(quiz_generators)
    local generator = quiz_generators[1]

    return generator and generator()
end

function bombulator.give_quiz_to_player(player)
    local playername = player:get_player_name()

    -- do not show player another quiz if they already have a quiz
    if ongoing_quizzes[playername] then return end

    local quiz = bombulator.random_quiz()
    local tries_left = 128

    while not quiz and tries_left > 0 do
        bombulator.random_quiz()
        tries_left = tries_left - 1
    end

    if not quiz then return end

    bombulator.show_quiz_formspec(playername, quiz) 
end

bombulator.register_bombulation("bombulator:quiz", {
    interval = 5.0,
    per_player = function(player)
        -- do not override respawn formspec
        if player:get_hp() < 0 then return end
        if vlength(player:get_velocity()) < 0.1 then return end
        bombulator.give_quiz_to_player(player)
    end
})

---------------------
-- ANSWER HANDLING --
---------------------

local function is_answer(playername, fields)
    if not fields or not playername or not ongoing_quizzes[playername] then return end
    
    return fields["submit_" .. tostring(ongoing_quizzes[playername].answer_index)]
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bombulator:quiz" then return end

    local playername = player:get_player_name()

    if is_answer(playername, fields) then
        core.chat_send_player(playername, core.colorize("#00ff00", S"Correct answer! You get to keep playing!"))
        core.close_formspec(playername, "bombulator:quiz")
        ongoing_quizzes[playername] = nil
    else
        core.chat_send_player(playername, core.colorize("#ff0000", S"Incorrect answer! Try again!"))
        ongoing_quizzes[playername] = nil
        bombulator.give_quiz_to_player(player)
    end
end)