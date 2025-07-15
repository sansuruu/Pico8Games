--main function

function _init()
    poke(0x5F2D, 1)
    -- title screen stuff before any of this lmfao
    game_state = 0 -- 0 => not active, 1 => active, 2=> shop
    tick = 0
    day = 1
    num_table = {1,2,3,4,5,6,7,8,9,0}

end


function _update()
    if (game_state == 0) then
        if (btn(5)) game_init()
    elseif (game_state == 1) then
        updateKeyInput()
        updateMouse()
        updateEnemies()
        updateAttentionBar()
        checkHomeworkComplete()
        updateTick()
    end
end

function _draw()
    if (game_state == 0) then
        drawTitleScreen()
    elseif (game_state == 1) then
        cls(1)
        sspr(24,0,16,16,65,32,59,60) -- brain
        drawHomework() --in order -> background, homework, attention bar, enemies, mouse
        drawAttentionBar()
        drawEnemies()
        drawMouse()
        drawKeyInput()
    end
    
end

--Title Screen + Game State Changers

function drawTitleScreen()
    cls(0)
    print("procrasti-stop",38,50,7)
    print("press ❎ to begin",32, 60, 7) 
end



function game_init()
    game_state = 1
    makePlayer()
    makeHomework()
    initEnemies()
    --explain the game briefly lmfaoo
    --add a quick inbetween scene where we basically choose a difficulty (LATER)
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
    p = {
        m_x = 0,
        m_y = 0,
        m_sprite = 1,
        ans_input = "",
        hw_length = 26,
        attention = 100,
        distract_p = 20,
        speed = 2,
        correct = 0, --hold data on if its right or not
        incorrect = 0
    }
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
                local temp_ans = rndb(1,20)
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
    local color = nil

    rectfill(2,2,60,125,6) --paper
    rectfill(4,4,58,123,7)

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
    if (t == " ") then
        active_page.problems[active_page.index] = active_page.problems[active_page.index]..p.ans_input
        if (p.ans_input == tostr(active_page.answers[active_page.index])) then
            active_page.subm_format[active_page.index] = 3
        else
            active_page.subm_format[active_page.index] = 8
        end
        active_page.index += 1

        if (#hw > 1 and active_page.index > 13 and last == 0) then
            del(hw,active_page)
        elseif (#hw == 1) then
            last = #active_page.problems
            if (active_page.index > last) del(hw,active_page)
            
        end
        if (#hw < 1) game_state = 2
        p.ans_input = ""
        return
    end
    if (t == "\b" or t=="\t") then
        p.ans_input = sub(p.ans_input,1,#p.ans_input-1)
        return
    end
    local isNum = false
    for i in all(num_table) do
        if (tostr(t) == tostr(i)) isNum = true
    end
    if (not isNum) then
        return
    else
        p.ans_input = p.ans_input..t
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


--ATTENTION BAR
function updateAttentionBar()
    if (tick ==30) then
        p.attention -= 1
    end
end

function drawAttentionBar()
    rectfill(4,115,124,124,0)
    rectfill(6,117,2+p.attention,122,11)
end


--ENEMIES

function initEnemies()
    enemies = {}
    e_sec = 0
end

function updateEnemies()
    --first check if the enemy we're looking at has made it
    --move all current enemies
    -- 96, 64 is the target
    for i in all(enemies) do

        if (i.x < 92) then
            i.x += 1
        elseif (i.x > 92) then
            i.x -= 1
        end
        if (i.y < 60) then
            i.y += 1
        elseif (i.y > 60) then
            i.y -= 1
        end
        --consider momementum based aka dx dy
        if (checkEnemyCollision(i)) del(enemies,i)

        if (i.x == 92 and i.y == 60) then
            del(enemies,i)
            p.attention -=5
        end
    end


    -- then, if applicable, spawn an enemy if its time
    if (tick > 0 and tick % 15 == 0) e_sec +=1
    if (e_sec ==2) then
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

