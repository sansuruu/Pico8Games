--main function

function _init()
    poke(0x5F2D, 1)
    -- title screen stuff before any of this lmfao
    game_state = 0 -- 0 => title sequence, 1 => first time enable, 2=> shop, 3=>continue
    tick = 0
    day = 1 -- this acts as the blinds
    week = 1 --this acts as the "ante"
    num_table = {1,2,3,4,5,6,7,8,9,0}
    submitted = false
    sub_tick = 0
    enemy_mod = 15 --in the tick % 30, basically we go down 15->10->6->5, etc
    enemy_mod_inc = 3 --everytime the above modulates, e_sec goes up, this is the upper limit of that
    base = {hw_length = 20, attent=25, dis_p=90, sp=2, diff = 20}
    item_desc = {pencil="pencil: +speed",glasses="glasses: +attention",paper="paper: -%distraction\nspawns"}
    makePlayer()
end


function _update()
    if (game_state == 0) then
        if (btnp(5)) then
            game_state = 1
            dayInit()
        end
    elseif (game_state == 1) then
        dayManager()
    elseif (game_state == 2) then
        updateKeyInput()
        updateMouse()
        updateEnemies()
        updateAttentionBar()
        checkHomeworkComplete()
        updateTick()
    elseif (game_state == 3) then
        updateLoopJudgement()
    elseif (game_state == 4) then
        updateDayHWRewards()
    end
end

function _draw()
    if (game_state == 0) then
        drawTitleScreen()
    elseif (game_state == 1) then
        cls(1)
        drawDayManager()
        drawStatsScreen()
    elseif (game_state == 2) then
        cls(1)
        sspr(24,0,16,16,65,32,59,60) -- brain
        rect(91,56,99,64,5) --area where they hit
        drawHomework() --in order -> background, homework, attention bar, enemies, mouse
        drawKeyInput()
        drawWritingAnswer()
        drawAttentionBar()
        drawEnemies()
        drawMouse()
        
    elseif (game_state == 3) then
        drawJudgementScreen()
    elseif (game_state == 4) then
        drawDayHWRewards()
    end
    
end

--Title Screen + Game State Changers

function drawTitleScreen()
    cls(0)
    print("procrasti-stop",38,50,7)
    print("press ❎ to begin",32, 60, 7) 
end

function dayInit()
    active_stats_s = false

end

function dayManager()
    if (btnp(4) and day < 5) then
        day +=1
        --then do like shop n shit idk
    end
    if (btnp(5)) then
        game_init()
    end
    
    if (stat(31) == "\t") active_stats_s = not active_stats_s
end

function drawDayManager()
    for i=0, 4 do
        local color = 6
        if (i+1 == day) color = 8
        rect(4+i*25,35,24+i*25,55,color)
    end

    print("week "..week,2,2,6)
    print("your homework is due\n    in "..5-day.." day(s)",25,15)
    print("press ❎ to work on\n some of it today", 27, 68,3)
    if (day < 5) print("press 🅾️ to procrastinate", 15, 85,10)

end

function finishDay()
    submitted = false
    sub_tick = 0
    if (day < 5) then
        day+=1
        item_pool = {}
        item_index = 1
        if (hw_complete) then
            for i=1,3 do
                local t = rndb(1,3)
                if (t == 1) add(item_pool,"pencil")
                if (t == 2) add (item_pool,"glasses")
                if (t == 3) add (item_pool,"paper")
            end
        end
        game_state = 4
    else
        local t = p.hw_set_length-(p.correct + p.incorrect)
        p.incorrect += t
        game_state = 3
    end
    
end

function drawStatsScreen()
    if (active_stats_s) then
        rectfill(80,60,126,128,15)
        print("problems\nleft: "..p.hw_set_length-(p.correct + p.incorrect).."\n\n★: "..p.correct.."\n\nX: "..p.incorrect,84,62,0)
    end
end

function updateLoopJudgement()
    pass = p.correct >= flr(p.hw_set_length * 0.6)
    if (not pass and btnp(5)) _init()
    if (pass and btnp(5)) then
        week += 1
        day = 1
        game_state = 1
        updatePlayer(week)
    end
        
end

function drawJudgementScreen()
    
    cls(1)
    print("week "..week.." summary:",10,50,6)
    print("correct: "..p.correct.."   incorrect: "..p.incorrect, 10, 70, 6)
    if (pass) then
        print("you have passed this week\ncongrats",10,80,7)
        print("press ❎ to continue", 10, 95,3)
    else
        print("you have failed, you lose",10,80,4)
        print("press ❎ to restart the game", 10, 90,3)
    end


end


function game_init()
    game_state = 2
    makeHomework()
    initEnemies()
    p.attention = tonum(p.max_attention)
    p.ans_input = ""
    --explain the game briefly lmfaoo
    --add a quick inbetween scene where we basically choose a difficulty (LATER)
end

function drawDayHWRewards()
    cls(1)
    if (hw_complete) then
        print(" congrats you completed\na chunk of your homework", 18, 20,6)
        print(" use arrow keys\nto choose an item", 30, 40,6)
        for i=1, #item_pool do
            if (item_pool[i] == "pencil") spr(18,26+i*16,60)
            if (item_pool[i] == "glasses") spr(16,26+i*16,60)
            if (item_pool[i] == "paper") spr(17,26+i*16,60) 
        end
        rect(25+item_index*16,59,34+item_index*16,68)

        print(item_desc[item_pool[item_index]],40,70,6)
        print("press ❎ to select the item", 10, 90,6) 

    else
        print("unfortunately u did not\nfinish the small chunk",20,30,6)
        print("press ❎ to continue", 10, 90,6)
    end
end

function updateDayHWRewards()
    if (btnp(0) and item_index > 1) item_index -= 1
    if (btnp(1) and item_index < 3) item_index += 1 
    if (btnp(5)) then
        add(p.inv,item_pool[item_index])
        if (item_pool[item_index] == "pencil") p.speed += 0.5
        if (item_pool[item_index] == "glasses") p.max_attention += 5
        if (item_pool[item_index] == "paper") p.distract_p -= 5
        item_pool = {} 
        game_state = 1
    end
end



--HELPER
function rndb(low,high)
	return flr(rnd(high-low+1)+low)
end

function updateTick()
    if (tick < 31) then
        tick +=1
    else
        tick = 0
    end
end



--PLAYER
function makePlayer()
    local ti = {}
    if (p != nil) then
        ti = p.inv
    end

    p = {
        m_x = 0,
        m_y = 0,
        m_sprite = 1,
        ans_input = "",
        hw_set_length = base.hw_length,    --stat: total length
        hw_length = 0,--used for func
        max_attention = base.attent,    --stat: max time
        attention = 0,--used for func
        distract_p = base.dis_p,       --stat: how often dudes will spawn
        speed = base.sp,
        difficulty = base.diff,
        correct = 0, --hold data on if its right or not
        incorrect = 0,
        inv = {}
    }
    p.inv = ti
end

function updatePlayer(w)
    p.correct = 0
    p.incorrect = 0
    p.difficulty += w *10
    p.hw_set_length = base.hw_length + w * 10 
    p.distract_p -= 10
    if (enemy_mod_inc>1) then
        enemy_mod_inc -= 1
    elseif (enemy_mod>1) then
        enemy_mod -= 1
    end
end


--MOUSE
function updateMouse()
    p.m_x = stat(32)
    p.m_y = stat(33)
end

function drawMouse()
    spr(p.m_sprite, p.m_x, p.m_y)
end


--HOMEWORK
function makeHomework()
    hw_complete = false
    hw = {}
    hw_page_index = 1
    if (day < 5) then
        p.hw_length = p.hw_set_length \ 5
    else
        p.hw_length = p.hw_set_length - (p.correct + p.incorrect)
    end

    hw_max_page= (p.hw_length \ 14) + 1

    page_count = (p.hw_length \ 14) + 1
    local temp = p.hw_length
    for i=1, page_count do 
        hw_page = {
            problems = {},
            answers = {},
            subm_format = {}, -- 0 -> n/a, 3 -> correct, 8 -> wrong
            index = 1
        }
        if (temp > 13) then
            for i=1, 13 do
                local temp_ans = rndb(1+(week-1)*5,p.difficulty)
                add(hw_page.answers, temp_ans)
                local temp_a = rndb(1,temp_ans)
                local temp_b = temp_ans - temp_a
                add(hw_page.problems,""..temp_a.."+"..temp_b.."=")
                add(hw_page.subm_format,0)
            end
            add(hw, hw_page)
            temp -= 13
        else
            for i=1, temp do
                local temp_ans = rndb(1,20)
                add(hw_page.answers, temp_ans)
                local temp_a = rndb(1,temp_ans)
                local temp_b = temp_ans - temp_a
                add(hw_page.problems,""..temp_a.."+"..temp_b.."=")
                add(hw_page.subm_format,0)
            end
            add(hw, hw_page)            
        end
    end
end

function drawHomework()

    rectfill(2,2,60,125,6) --paper
    rectfill(4,4,58,123,7)
    rectfill(60,2,76,14,6) --paper
    rectfill(58,4,74,12,7)
    print(tostr(hw_page_index).."/"..tostr(hw_max_page), 61,6,2)
    active_page = hw[1]
    for i=1, #active_page.problems do
        print(active_page.problems[i],8,i*8,active_page.subm_format[i])
    end
    
end

function checkHomeworkComplete()
    
end


 --KEYBOARD

function updateKeyInput()
    local t = stat(31)
    local last = #active_page.problems % 13
    if (t == "\r") return
    if (t == " " and submitted) return
    if (t == " " and not submitted) submitted = not submitted
    
    if (submitted and sub_tick > (300/p.speed)) then
        active_page.problems[active_page.index] = active_page.problems[active_page.index]..p.ans_input
        if (p.ans_input == tostr(active_page.answers[active_page.index])) then
            active_page.subm_format[active_page.index] = 3
            p.correct += 1
        else
            active_page.subm_format[active_page.index] = 8
            p.incorrect += 1
        end
        active_page.index += 1

        if (#hw > 1 and active_page.index > 13 and last == 0) then --in any case where theres more than 1 page left
            del(hw,active_page)
            hw_page_index += 1
        elseif (#hw == 1) then --we only have 1 page left 
            last = #active_page.problems
            if (active_page.index > last) then
                del(hw,active_page)
                hw_complete = true
            end
        end
        if (#hw < 1) finishDay()
        p.ans_input = ""
        submitted = false
        sub_tick = 0
        return
    else
        if (submitted) then
            sub_tick += 1
        end
    end


    if (t == "\b" or t=="\t") then
        p.ans_input = sub(p.ans_input,1,#p.ans_input-1)
        sfx(2)
        return
    end
    local isNum = false
    for i in all(num_table) do
        if (tostr(t) == tostr(i)) isNum = true
    end
    if (not isNum) then
        return
    else
        if (submitted) return
        p.ans_input = p.ans_input..t
        sfx(2)
    end

end

function drawKeyInput()
    if (p.ans_input=="") then
        if (active_page.problems[active_page.index] == nil) return
        --rect(4+#hw.problems[hw.index]*4,hw.index*8,6+#hw.problems[hw.index]*4,hw.index*8 +4,0)
        spr(2,8+#active_page.problems[active_page.index]*4,active_page.index*8)
    else
        print(p.ans_input,8+#active_page.problems[active_page.index]*4,active_page.index*8,0)
    end
end

function drawWritingAnswer()
    
    if (submitted) then
        if (active_page.problems[active_page.index] == nil) return
         --convert hoiw long -> perc -> length thats consistent
        rectfill(8,active_page.index*8,8+flr((sub_tick/(300/p.speed))*(#active_page.problems[active_page.index]*4+#p.ans_input*4)),active_page.index*8+4,9)
    end
end

--ATTENTION BAR
function updateAttentionBar()
    if (tick ==30) then
        p.attention -= 1
    end
    if (p.attention <= 0) finishDay()
end

function drawAttentionBar()
    rectfill(4,115,8+p.max_attention,124,0)
    if (p.attention > -1) rectfill(6,117,6+p.attention,122,11)
end


--ENEMIES

function initEnemies()
    enemies = {}
    e_sec = 0
    enemy_vel_bound = 1
end

function updateEnemies()
    --first check if the enemy we're looking at has made it
    --move all current enemies
    -- 96, 64 is the target
    for i in all(enemies) do

        if (i.x < 95 and i.dx < enemy_vel_bound) then
            i.dx += 0.05
        elseif (i.x > 95 and i.dx > -1*enemy_vel_bound) then
            i.dx -= 0.05
        end
        if (i.y < 60 and i.dy < enemy_vel_bound) then
            i.dy += 0.05
        elseif (i.y > 60 and i.dy > -1*enemy_vel_bound) then
            i.dy -= 0.05
        end

        i.x += i.dx
        i.y += i.dy
        --consider momementum based aka dx dy
        if (checkEnemyCollision(i)) del(enemies,i)

        if (i.x < 99 and i.x+7 > 91 and i.y < 64 and i.y+7 > 56) then
            del(enemies,i)
            p.attention -=5
        end
    end
    

    -- then, if applicable, spawn an enemy if its time
    -- coroutine: enemy spawn vfx
    if (tick > 0 and tick % enemy_mod == 0) e_sec +=1
    if (e_sec == enemy_mod_inc and rndb(0,100) < p.distract_p) then
        e_sec = 0
        local temp_x = rndb(0,128)
        local temp_y = nil
        if (temp_x <64) then
            temp_y = rndb(0,128)
        else
            temp_y = rndb(0,1) * 120
        end

        local e = {
            x = temp_x,
            y = temp_y,
            dx = -1^(rndb(1,2))*rnd(0),
            dy = -1^(rndb(1,2))*rnd(0),
            sprite = rndb(5,10)
        }
        add(enemies,e)
    end
end

function checkEnemyCollision(o)
    if (o.x+1 < p.m_x+7 and o.x+6 > p.m_x and o.y+1 < p.m_y+7 and o.y+6 > p.m_y) then
        return true
    else
        return false
    end
end

function drawEnemies()
    for i in all(enemies) do
        spr(i.sprite,i.x,i.y)
    end
end

--Coroutines

