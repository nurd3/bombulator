local random = math.random
local fmt = string.format
local S = bombulator.get_translator

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
        question = S"Say my name.",
        answer = S"B O M B U L A T O R",
        options = {
            S"Minetest",
            S"NodeCore",
            S"Unlit",
            S"Void - An empty game",
            S"Age of Mending"
        }
    },
}

local function trivia()
    table.shuffle(trivia_questions)
    local quiz = table.copy(trivia_questions[1])
    quiz.question = fmt("label[0.25,0.5;%s]", core.formspec_escape(quiz.question))
    return quiz
end

local function guess_the_node()
    local node_name = bombulator.random_node()

    if not node_name then return end

    local options = {}

    for _ = 1, 2 do
        local option = bombulator.random_node()
        while option == node_name do option = bombulator.random_node() end
        table.insert(options, option)
    end

    return {
        question = fmt([[
            label[0.25,0.5;%s]
            item_image[0.25,0.75;1.0,1.0;%s]
        ]], core.formspec_escape(S"What is this node?"), node_name),
        answer = node_name,
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

local ongoing_quizzes = {}

function bombulator.show_quiz_formspec(playername, quiz)
    ongoing_quizzes[playername] = quiz

    local options = quiz.options

    -- shuffle options and make sure there's only 3 options
    table.shuffle(options)
    options = {options[1], options[2], quiz.answer}
    table.shuffle(options)

    core.show_formspec(playername, "bombulator:quiz", [[
        formspec_version[4]
        size[8,8]
        position[0.5,0.5]
        no_prepend[]
    ]]
    .. fmt([[
        button[0.25,3.0;4.0,0.5;response;%s]
        button[0.25,3.5;4.0,0.5;response;%s]
        button[0.25,4.0;4.0,0.5;response;%s]
    ]], options[1], options[2], options[3])
    .. quiz.question)
end

local quiz_generators = {arithmetic, trivia, coinflip, guess_the_node}

function bombulator.random_quiz()
    table.shuffle(quiz_generators)
    local generator = quiz_generators[1]

    return generator and generator()
end

function bombulator.give_quiz_to_player(player)
    local playername = player:get_player_name()
    local quiz = bombulator.random_quiz()

    while not quiz do bombulator.random_quiz() end

    -- do not show player another quiz if they already have a quiz
    if ongoing_quizzes[playername] then return end

    bombulator.show_quiz_formspec(playername, quiz) 
end

bombulator.register_bombulation("bombulator:quiz", {
    interval = 60.0,
    per_player = function(player)
        bombulator.give_quiz_to_player(player)
    end
})

local function is_answer(playername, response)
    if not response or not playername or not ongoing_quizzes[playername] then return end
    
    return tostring(response) == tostring(ongoing_quizzes[playername].answer)
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bombulator:quiz" then return end

    local playername = player:get_player_name()
    local response = fields.response

    if is_answer(playername, response) then
        core.chat_send_player(playername, core.colorize("#00ff00", S"Correct answer! You get to keep playing!"))
        core.close_formspec(playername, "bombulator:quiz")
        ongoing_quizzes[playername] = nil
    else
        core.chat_send_player(playername, core.colorize("#ff0000", S"Incorrect answer! Try again!"))
        ongoing_quizzes[playername] = nil
        bombulator.give_quiz_to_player(player)
    end
end)