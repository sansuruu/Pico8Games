-- ran during preInit (i think)
-- set all the appropriate variables
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
        distract_r = base.dis_r,
        speed = base.sp,  --stat: how fast answers pend
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

--this runs at the end of every week, reset player stats
-- and update with difficulty scaling
function updatePlayer(w)
    p.test_correct = 0
    p.test_incorrect = 0
    p.hw_correct = 0
    p.hw_incorrect = 0
    prev_incorrect = 0

    --hw scaling
    p.difficulty = w * base.diff
    p.hw_set_length = flr(base.hw_length + 5 * 1.25^(w-1))

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
    if (p.distract_p > 100) p.distract_p = 100
    if (enemy_mod_inc > 1) then
        enemy_mod_inc -= 1
    elseif (enemy_mod>1) then
        enemy_mod -= 1
    end

    enemy_attack +=10
end


--MOUSE
--its literally just drawing a mouse i dont have to describe ts
function updateMouse()
    p.m_x = stat(32)
    p.m_y = stat(33)
end

function drawMouse()
    spr(p.m_sprite, p.m_x, p.m_y)
end
