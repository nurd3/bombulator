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
        question = fmt("%i %s %i = ???", lhs, operator, rhs),
        answers = {answer}
    }
end

local trivia_questions = {
    {
        question = S"What's my password?",
        answers = {
            "123456",
            "password",
            "qwerty",
            "1234"
        }
    },
    {
        question = "OwO?",
        answers = {
            "owo",
            "uwu",
            "qwq",
            "-w-"
        }
    },
    {
        question = S"When did the 21st century begin?",
        answers = {
            "2000",
            "'00",
            "00"
        }
    },
    {
        question = S"When did the year 1999 start?",
        answers = {
            "99",
            "'99",
            "1999",
            "january 1st",
            "1st january",
            "1st of january",
            "01/01",
        }
    }
}

local function trivia()
    table.shuffle(trivia_questions)
    return trivia_questions[1]
end

local quiz_answers = {}

function bombulator.show_quiz_formspec(playername, quiz)
    quiz_answers[playername] = quiz.answers

    core.show_formspec(playername, "bombulator:quiz", [[
        formspec_version[4]
        size[8,4]
        position[0.5,0.5]
        allow_close[false]
        no_prepend[]
        field[0.25,2.25;4.0,0.5;response;Your Answer;]
        button[0.25,3.0;4.0,0.5;submit;Submit]
    ]] .. fmt("label[0.25,0.5;%s]", core.formspec_escape(quiz.question)))
end

local quiz_generators = {arithmetic, trivia}

function bombulator.random_quiz()
    table.shuffle(quiz_generators)
    local generator = quiz_generators[1]

    return generator and generator()
end

function bombulator.give_quiz_to_player(player)
    local playername = player:get_player_name()
    local quiz = bombulator.random_quiz()

    if quiz_answers[playername] then return end

    bombulator.show_quiz_formspec(playername, quiz) 
end

bombulator.register_bombulation("bombulator:quiz", {
    interval = 120.0,
    per_player = function(player)
        bombulator.give_quiz_to_player(player)
    end
})

local function is_answer(playername, response)
    if not response or not playername or not quiz_answers[playername] then return end

    local answers = quiz_answers[playername]

    for _, answer in ipairs(answers) do
        if tostring(answer) == tostring(response) then return true end
    end

    return false
end

core.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "bombulator:quiz" then return end

    local playername = player:get_player_name()
    local response = fields.response and string.lower(string.trim(fields.response))

    if is_answer(playername, response) then
        core.chat_send_player(playername, core.colorize("#00ff00", S"Correct answer! You get to keep playing!"))
        core.close_formspec(playername, "bombulator:quiz")
        quiz_answers[playername] = nil
    else
        core.chat_send_player(playername, core.colorize("#ff0000", S"Incorrect answer! Try again!"))
        quiz_answers[playername] = nil
        bombulator.give_quiz_to_player(player)
    end
end)