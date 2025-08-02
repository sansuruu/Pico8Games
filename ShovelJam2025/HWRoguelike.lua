--Main Functions
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
    enemy_mod_inc = 4 --everytime the above modulates, e_sec goes up, this is the upper limit of that
    base = {hw_length = 15, attent=30, dis_p=35, sp=2, diff = 20}
    chosen = 0
    item_desc = {
        --common
        pencil="pencil: +speed",
        glasses="glasses: +attention",
        paper="paper: -%distraction\nspawns",

        --rare
        coin="coin: distractions have a\n50/50 chance to give attent",
        star="gold star: 50% hw length,\nbut 2x difficulty",
        headphones="headphones: no distractions\n but faster attention drain"
    }

    particleInit()
    shakeInit()    
    makePlayer()
end


function _update()
    if (game_state == 0) then
        if (btnp(5)) then
            game_state = 1
            dayInit()
        end
    elseif (game_state == 1) then --day manager
        dayManager()
    elseif (game_state == 2) then --main game loop
        updateKeyInput()
        updateMouse()
        updateEnemies()
        particleUpdate()
        updateAttentionBar()
        updateTick()
    elseif (game_state == 3) then -- end of week
        updateLoopJudgement()
    elseif (game_state == 4) then --studied
        updateDayHWRewards()
    elseif (game_state == 5) then
        updateProcrastinate()
    end
end

function _draw()
    if (game_state == 0) then
        drawTitleScreen()
    elseif (game_state == 1) then
        cls(1)
        drawDayManager()
        drawStatsScreen()
        print("grade:"..p.grade.."%",88,2,6)
    elseif (game_state == 2) then
        cls(1)
        doShake()
        sspr(24,0,16,16,65,32,59,60) -- brain
        rect(91,56,99,64,5) --area where they hit
        drawHomework() --in order -> background, homework, attention bar, enemies, mouse
        drawKeyInput()
        drawWritingAnswer()
        drawAttentionBar()
        drawEnemies()
        particleDraw()
        drawMouse()
        print("grade:"..p.grade.."%",88,2,6)
    elseif (game_state == 3) then
        drawJudgementScreen()
        print("grade:"..p.grade.."%",88,2,6)
    elseif (game_state == 4) then
        drawDayHWRewards()
        print("grade:"..p.grade.."%",88,2,6)
    elseif (game_state == 5) then
        drawProcrastinate()
        print("grade:"..p.grade.."%",88,2,6)
    end
end

--Title Screen + Game State Changers

function drawTitleScreen()
    cls(1)
    circfill(64,64,50,5)
    circfill(64,64,40,1)
    circfill(64,64,30,5)
    sspr(16,8,8,8,24,48)
    sspr(8,8,8,8,96,48)
    
    print("procrasti-start",34,50,7)
    print("press ❎ to begin",32, 60, 7) 


    
    print("BY SANSURU",44,100,6)
    print("(CHECK DESC. FOR INFO/TUTORIAL)",3,115,6)
end

function dayInit()
    active_stats_s = false
end

function dayManager()
    if (btnp(4) and day < 5) then
        day +=1
        procras_luck = rndb(1,10)

        if (procras_luck <= 4) then
            item_pool = {}
            item_index = 1
            
            for i=1,3 do
                local t = rndb(1,3)
                if (t == 1) add(item_pool,"pencil")
                if (t == 2) add (item_pool,"glasses")
                if (t == 3) add (item_pool,"paper")
            end
            
        elseif (procras_luck > 8) then
            item_pool = {}
            local t = rndb(1,3)
            if (t == 1) add(item_pool,"coin")
            if (t == 2) add(item_pool,"star")
            if (t == 3) add(item_pool,"headphones")
        end
        game_state = 5
        
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
    print(" you have a test in\n    in "..5-day.." day(s)",25,15)
    print("press ❎ to study today", 20, 68,3)
    print("press [tab] to toggle stats", 10, 100, 6)
    if (day < 5) print("press 🅾️ to procrastinate", 15, 85,10)

end

function drawDayHWRewards()
    cls(1)
    if (hw_complete) then
        choose_lim = 1
        if (prev_incorrect == p.hw_incorrect) choose_lim += 1
        print(" congrats you completed\na chunk of your homework", 18, 20,6)
        print(" use arrow keys\nto choose "..choose_lim.." item(s)", 30, 40,6)
        for i=1, #item_pool do
            if (item_pool[i] == "pencil") spr(18,26+i*16,60) --consider making temporary items1
            if (item_pool[i] == "glasses") spr(16,26+i*16,60)
            if (item_pool[i] == "paper") spr(17,26+i*16,60) 
        end
        rect(25+item_index*16,59,34+item_index*16,68)

        print(item_desc[item_pool[item_index]],40,70,6)
        print("press ❎ to select the item", 10, 90,6) 

    else
        print("your mind starts to wander...",10,30,6)
        print("(you did not finish\nthe study session)",24,40,6)
        print("press ❎ to continue", 23, 90,6)
    end
end

function updateDayHWRewards()
    if (btnp(0) and item_index > 1) then item_index -= 1 sfx(3) end
    if (btnp(1) and item_index < #item_pool) then item_index += 1 sfx(3) end
    choose_lim = 1
    if (prev_incorrect == p.hw_incorrect) choose_lim += 1
    if (btnp(5)) then
        add(p.inv,item_pool[item_index])
        sfx(3)
        if (item_pool[item_index] == "pencil") p.speed += 0.5
        if (item_pool[item_index] == "glasses") p.max_attention += 5
        if (item_pool[item_index] == "paper") if(p.distract_p > 0) p.distract_p -= 5
        del(item_pool, item_pool[item_index])
        chosen += 1
        if (chosen == choose_lim) then
            chosen = 0
            game_state = 1
            item_pool = {} 
        end
    end
end

function drawStatsScreen() --update: remove current line, add more stats + inv
    if (active_stats_s) then
        rectfill(2,60,126,128,15)
        print("test length: "..p.hw_set_length,4,62,0)
        print("attention: "..p.max_attention,4,68,0)
        print("speed: "..p.speed,4,74,0)
        print("difficulty: "..p.difficulty,4,80,0)
        print("distract%: "..p.difficulty,4,86,0)

        print("hw grade: "..p.hw_grade,4,98,0)
        print("exam grade: "..p.test_grade,4,104,0)

        --display items lol
        local index = 1
        local item_count = {}
        for k in all(p.inv) do
            if (item_count[k] == nil) then
                item_count[k] = 1
            else
                item_count[k] += 1 
            end
        end

        for k,v in pairs(item_count) do
            print(k..": "..v,80,56+index*6,7)
            index += 1
        end

    end
end

function finishDay()
    submitted = false
    sub_tick = 0
    if (day < 5) then
        updateGrade()
        day+=1
        item_pool = {}
        item_pool_length = 3
        if (prev_incorrect == p.hw_incorrect) item_pool_length += 2
        item_index = 1
        if (hw_complete) then
            sfx(6)
            for i=1,item_pool_length do
                local t = rndb(1,3)
                if (t == 1) add(item_pool,"pencil")
                if (t == 2) add (item_pool,"glasses")
                if (t == 3) add (item_pool,"paper")
            end
        else
            sfx(5)
        end
        game_state = 4
    else
        local t = p.hw_set_length-(p.test_correct + p.test_incorrect)
        p.test_incorrect += t
        updateGrade()
        if (p.grade >= 70) then
            sfx(6)
        else
            sfx(5)
        end
        game_state = 3
    end
    
end

function drawProcrastinate()
    cls(1)
    if (procras_luck <=4) then
        print(" you skipped today to\n refocus your mental.", 18, 20,6)
        print(" use arrow keys\nto choose an item", 30, 40,6)
        for i=1, #item_pool do
            if (item_pool[i] == "pencil") spr(18,26+i*16,60) --consider making temporary items1
            if (item_pool[i] == "glasses") spr(16,26+i*16,60)
            if (item_pool[i] == "paper") spr(17,26+i*16,60) 
        end
        rect(25+item_index*16,59,34+item_index*16,68)

        print(item_desc[item_pool[item_index]],35,70,6)
        print("press ❎ to select the item", 10, 90,6) 

    elseif (procras_luck <= 8) then
        print("you skipped today\nand did nothing :(",25,30,6)

        print("press ❎ to continue", 24, 90,6)
    else
        print("you skipped today and\n found a rare trinket",20,30,6)
        if (item_pool[1] == "coin") spr(32,26+32,60)
        if (item_pool[1] == "star") spr(34,26+32,60)
        if (item_pool[1] == "headphones") spr(35,26+32,60) 
        print(item_desc[item_pool[1]],15,70,6)
        print(" press ❎ to grab\n🅾️ to skip the item", 30, 90,6)
    end
end

function updateProcrastinate()
    if (procras_luck <=4) then
        if (btnp(0) and item_index > 1) then item_index -= 1 sfx(3) end
        if (btnp(1) and item_index < 3) then item_index += 1 sfx(3) end
        if (btnp(5)) then
            add(p.inv,item_pool[item_index])
            if (item_pool[item_index] == "pencil") p.speed += 0.5
            if (item_pool[item_index] == "glasses") p.max_attention += 5
            if (item_pool[item_index] == "paper") if(p.distract_p > 0) p.distract_p -= 5
            item_pool = {} 
            game_state = 1
        end
    elseif (procras_luck <= 8) then
        if (btnp(5)) game_state = 1
    else
        if (btnp(5)) then
            add(p.inv,item_pool[1])
            if (item_pool[1] == "star") then
                p.difficulty *= 2
                p.hw_set_length \= 2

                if (p.hw_set_length < 1) p.hw_set_length = 1
            end
            item_pool = {} 
            game_state = 1
        elseif(btnp(4)) then
            game_state = 1
        end
    end

end









function updateLoopJudgement()
    pass = p.grade >= 70
    if (not pass and btnp(5)) _init()
    if (pass and btnp(5)) then
        week += 1
        updatePlayer(week)
        day = 1
        game_state = 1
        
    end
        
end



function drawJudgementScreen()
    
    cls(1)
    print("week "..week.." summary:",10,50,6)
    print("correct: "..p.test_correct.."   incorrect: "..p.test_incorrect, 10, 70, 6)
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

function updateGrade()
    if (p.test_correct == 0 and p.test_incorrect == 0) then
        p.hw_grade = ceil(100*(0.2 * (p.hw_correct / (p.hw_correct + p.hw_incorrect))))
    else
        p.test_grade =  ceil(100*(0.8 * (p.test_correct/(p.test_correct+p.test_incorrect))))
    end

    p.grade = p.hw_grade + p.test_grade
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
        m_sprite = 12,
        ans_input = "",
        hw_set_length = base.hw_length,    --stat: total length (of the final test, /3 for hw's)
        hw_length = 0,--used for func
        max_attention = base.attent,    --stat: max time
        attention = 0,--used for func
        distract_p = base.dis_p,       --stat: how often dudes will spawn
        speed = base.sp,
        difficulty = base.diff,
        test_correct = 0, --hold data on if its right or not
        test_incorrect = 0,
        hw_correct = 0,
        hw_incorrect = 0,
        hw_grade = 0,
        test_grade = 0,
        grade = 0,
        inv = {}
    }
    p.inv = ti
end

function updatePlayer(w)
    p.test_correct = 0
    p.test_incorrect = 0
    p.hw_correct = 0
    p.hw_incorrect = 0
    prev_incorrect = 0

    --hw scaling
    p.difficulty = w * 20
    p.hw_set_length = flr(base.hw_length + 10 * 1.75^(w-1))

    --=check for star
    for k,v in all(p.inv) do
        if (k=="star") then
            p.difficulty *= 2
            p.hw_set_length \= 2
            if (p.hw_set_length < 1) p.hw_set_length = 1
        end
    end

    -- enemy scaling
    if (p.distract_p < 100) p.distract_p += 5
    if (enemy_mod_inc > 1) then
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
    prev_incorrect = p.hw_incorrect
    hw_complete = false
    hw = {}
    hw_page_index = 1
    if (day < 5) then
        p.hw_length = p.hw_set_length \ 3
        if (p.hw_length < 1) p.hw_length = 1
    else
        p.hw_length = p.hw_set_length
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
                local temp_ans = rndb((1+(week-1)*5),p.difficulty)
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
                local temp_ans = rndb((1+(week-1)*5),p.difficulty)
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
            if (day == 5) p.test_correct += 1
            if (day < 5) p.hw_correct += 1
            sfx(9)
        else
            active_page.subm_format[active_page.index] = 8
            if (day == 5) p.test_incorrect += 1
            if (day < 5) p.hw_incorrect += 1
            sfx(8)
        end
        updateGrade()
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


    if (t == "\b" or t=="\t" and not submitted) then
        p.ans_input = sub(p.ans_input,1,#p.ans_input-1)
        sfx(3)
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
        sfx(3)
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
        if (flr((100*(sub_tick/(300/p.speed)))) % 10 == 0) sfx(0)
        rectfill(8,active_page.index*8,8+flr((sub_tick/(300/p.speed))*(#active_page.problems[active_page.index]*4+#p.ans_input*4)),active_page.index*8+4,9)
    end
end

--ATTENTION BAR
function updateAttentionBar()
    local ticker = 30
    local attent_dec = 1
    for k,v in all(p.inv) do
        if (k=="headphones") then
            ticker = 10
            attent_dec = 3
        end
    end
    if (tick > 0 and tick % ticker == 0) then
        p.attention -= attent_dec
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

    --if headphones, who cares lol dont bother
    for k,v in all(p.inv) do
        if (k=="headphones") then
            return
        end
    end

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
        if (checkEnemyCollision(i)) then 
            sfx(10) 
            for k=1,10 do
                add_p(i.x+4,i.y+4)
            end
            del(enemies,i) 

        end

        if (i.x < 99 and i.x+7 > 91 and i.y < 64 and i.y+7 > 56) then
            del(enemies,i)
            sfx(2)
            sfx(4)
            --check first for coin
            for k,v in all(p.inv) do
                if (k=="coin") then
                    if (rndb(0,1) == 0) then
                        p.attention -= 5
                    else
                        p.attention += 10
                    end
                end
            end
            p.attention -=5
        end
    end
    

    -- then, if applicable, spawn an enemy if its time
    -- coroutine: enemy spawn vfx
    if (tick > 0 and tick % enemy_mod == 0) e_sec +=1
    if ((e_sec == enemy_mod_inc and (rndb(0,100)< p.distract_p))) then
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
        for i=1,10 do
            add_p(e.x+4,e.y+4)
        end
        shake += 0.065
        sfx(1)
        sfx(11)
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

--particles?
function particleInit()
    ps={}       --empty particle table
    g=0.1       --particle gravity
    max_vel=0.5   --max initial particle velocity
    min_life=20 --particle lifetime
    max_life=60
    cols={2,13,13,9,9,8,8,8} --colors
    burst=50

    end
    function rndb(low,high)
    return flr(rnd(high-low+1)+low)
end

function particleUpdate()
    --burst
    foreach(ps,update_p)
end
function particleDraw()
    foreach(ps,draw_p)
end

function add_p(x,y)
    local p={}
    p.x,p.y=x,y
    p.dx=rnd(max_vel)*(-1)^rndb(0,1)
    p.dy=rnd(max_vel)*(-1)^rndb(0,1)
    p.life_start=rndb(min_life,max_life)
    p.life=p.life_start
    add(ps,p)
end

function update_p(p)
    if (p.life<=0) then
        del(ps,p) --kill old particles
    else
        p.x+=p.dx --update position
        p.y+=p.dy
        p.life-=1 --die a little
    end
end

function draw_p(p)
    local pcol=flr(p.life/p.life_start*#cols+1)
    pset(p.x,p.y,cols[pcol])
end

-- subtle screenshake
function shakeInit()
    shake = 0
end

function doShake()
    local shakex=8-rnd(16)
    local shakey=8-rnd(16)
    shakex*=shake
    shakey*=shake
    camera(shakex,shakey)
    shake = shake*0.95
    if (shake<0.05) shake=0
end
