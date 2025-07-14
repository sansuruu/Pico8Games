function _init()
    poke(0x5F2D, 1)
    makePlayer()
    makeHomework()
    game_state = 0 -- 0 => not active, 1 => active, 2=> shop
    tick = 0
end


function _update()
    updateMouse()
    updateKeyInput()
    updateAttentionBar()
end

function _draw()
    cls(1)
    sspr(24,0,16,16,65,32,59,60)
    drawHomework() --in order -> background, homework, attention bar, enemies, mouse
    drawAttentionBar()
    drawMouse()
    drawKeyInput()
    
end

--HELPER
function rndb(low,high)
	return flr(rnd(high-low+1)+low)
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
    if (t == "\t") then
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
    if (t == "\b") then
        p.ans_input = sub(p.ans_input,1,#p.ans_input-1)
        --p.ans_input = p.ans_input.."backspace"
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
    if (tick >=30) then
        p.attention -= 1
        tick = 0
    else
        tick += 1
    end
end

function drawAttentionBar()
    rectfill(2,115,2+p.attention,120,11)
end