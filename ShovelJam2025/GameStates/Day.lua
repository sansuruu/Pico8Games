--init function solely for toggling the stats screen
function dayInit()
    active_stats_s = false
end

-- within the update: basically manage all the logic for a day
-- procrastinating, stats display
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

--visually reflect where in the week you are at
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

--the thing that actually shows u items + stats
function drawStatsScreen() 
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

--when day finishes (either by hw completion or no more attent)
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

--manage the item selection when player completes homework
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

--when you finish a homework, this displays the item choices
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



