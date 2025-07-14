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
        updateMouse()
        updateKeyInput()
        updateEnemies()
        updateAttentionBar()
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
        hw_length = 10,
        attention = 100,
        distract_p = 20,
        speed = 2

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
    hw = {
        problems = {},
        answers = {},
        subm_format = {}, -- 0 -> n/a, 3 -> correct, 8 -> wrong
        index = 1
    }

    for i=1, p.hw_length do
        local temp_ans = rndb(1,20)
        add(hw.answers, temp_ans)
        local temp_a = rndb(1,temp_ans)
        local temp_b = temp_ans - temp_a
        add(hw.problems,""..temp_a.."+"..temp_b.."=")
        add(hw.subm_format,0)
    end
end

function drawHomework()
    rectfill(2,2,60,125,6) --paper
    rectfill(4,4,58,123,7)

    for i=1, #hw.problems do
        print(hw.problems[i],8,i*8,hw.subm_format[i])
    end
    
end


 --KEYBOARD

function updateKeyInput()
    local t = stat(31)
    if (t == "\r") return
    if (t == " ") then
        hw.problems[hw.index] = hw.problems[hw.index]..p.ans_input
        if (p.ans_input == tostr(hw.answers[hw.index])) then
            hw.subm_format[hw.index] = 3
        else
            hw.subm_format[hw.index] = 8
        end
        hw.index += 1
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
        --rect(4+#hw.problems[hw.index]*4,hw.index*8,6+#hw.problems[hw.index]*4,hw.index*8 +4,0)
        spr(2,8+#hw.problems[hw.index]*4,hw.index*8)
    else
        print(p.ans_input,8+#hw.problems[hw.index]*4,hw.index*8,0)
    end
end


--ATTENTION BAR
function updateAttentionBar()
    if (tick ==30) then
        p.attention -= 1
    end
end

function drawAttentionBar()
    rectfill(2,115,2+p.attention,120,11)
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

        if (checkEnemyCollision(i)) del(enemies,i)

        if (i.x == 92 and i.y == 60) then
            del(enemies,i)
            p.attention -=5
        end
    end


    -- then, if applicable, spawn an enemy if its time
    if (tick > 0 and tick % 15 == 0) e_sec +=1
    if (e_sec == 1) then
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

