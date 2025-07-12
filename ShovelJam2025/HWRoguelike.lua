function _init()
    poke(0x5F2D, 1)
    makePlayer()
    make_homework()
    game_state = 0 -- 0 => not active, 1 => active, 2=> shop
end


function _update()
    updateMouse()
end

function _draw()
    cls(1)
    drawHomework() --in order -> background, homework, attention bar, enemies, mouse
    drawMouse()
    
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
        hw_length = 5
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
function make_homework()
    hw = {
        problems = {},
        answers = {},
        index = 0
    }

    for i=1, p.hw_length do
        local temp_ans = rndb(1,20)
        add(hw.answers, temp_ans)
        local temp_a = rndb(1,temp_ans)
        local temp_b = temp_ans - temp_a
        add(hw.problems,""..temp_a.."+"..temp_b.."= ")
    end
end

function drawHomework()
    rectfill(2,2,60,125,6) --paper
    rectfill(4,4,58,123,7)

    for i=1, #hw.problems do
        print(hw.problems[i],6,i*8,0)
    end
    
end