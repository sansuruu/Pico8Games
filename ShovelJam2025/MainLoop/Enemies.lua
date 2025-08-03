
--instantiate what we will use to manage all the enemies
function initEnemies()
    enemies = {}
    e_sec = 0
    enemy_vel_bound = 1
    enemy_attack=10
end

--move then spawn, bnasically
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
        if (i.aggro == 51) then --beeline to the brain
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


        else -- wander
            if (distance(i.wander_x,i.wander_y,i.x,i.y) < 15) then
                i.wander_x= rndb(20,108)
                i.wander_y= rndb(20,108)
                while (distance(i.wander_x,i.wander_y,95,60) < 20) do
                    i.wander_x= rndb(20,108)
                    i.wander_y= rndb(20,108)
                end
                
                i.aggro += 1
                if (i.aggro == 51) then
                    for j=1,20 do
                        add_p(i.x+4,i.y+4)
                    end
                    sfx(14)
                end
            end

            if (i.x < i.wander_x and i.dx < enemy_vel_bound) then
                i.dx += 0.05
            elseif (i.x > i.wander_x and i.dx > -1*enemy_vel_bound) then
                i.dx -= 0.05
            end
            if (i.y < i.wander_y and i.dy < enemy_vel_bound) then
                i.dy += 0.05
            elseif (i.y > i.wander_y and i.dy > -1*enemy_vel_bound) then
                i.dy -= 0.05
            end
        end
        i.x += i.dx
        i.y += i.dy
        --consider momementum based aka dx dy
        --check for mouse movement
        if (checkEnemyCollision(i)) then 
            sfx(10) 
            for k=1,10 do
                add_p(i.x+4,i.y+4)
            end
            del(enemies,i) 
        end

        if (i.x < 99 and i.x+7 > 91 and i.y < 64 and i.y+7 > 56) then
            sfx(2)
            sfx(4)
            coin_check = false
            --check first for coin
            for k,v in all(p.inv) do
                if (k=="coin") then
                    coin_check = true
                end
            end
            local attack = flr((i.aggro-47/4)*enemy_attack * (1/(0.15*p.distract_r + 1)))
            if (coin_check) then
                if (rndb(0,1) == 0) then
                    p.attention -= enemy_attack*2
                    add_e_p(i.x,i.y,i.dx,i.dy,false)
                else
                    p.attention += enemy_attack*2
                    add_e_p(i.x,i.y,i.dx,i.dy,true)
                end
            else
                p.attention -= enemy_attack
                add_e_p(i.x,i.y,i.dx,i.dy,false)
            end
            del(enemies,i)

        end
    end
    
    -- then, if applicable, spawn an enemy if its time
    if (tick > 0 and tick % enemy_mod == 0) e_sec +=1
    if ((e_sec == enemy_mod_inc and (rndb(1,100)< p.distract_p))) then
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
            sprite = rndb(5,10),
            aggro = 48,
            wander_x= rndb(20,108),
            wander_y= rndb(20,108)
        }
        add(enemies,e)
        for i=1,5 do
            add_p(e.x+4,e.y+4)
        end
        shake += 0.065
        sfx(1)
        sfx(11)
    end
end

--helper function to help with mouse collision
function checkEnemyCollision(o)
    if (o.x+1 < p.m_x+7 and o.x+6 > p.m_x and o.y+1 < p.m_y+7 and o.y+6 > p.m_y) then
        return true
    else
        return false
    end
end

--draw the mfs :3
function drawEnemies()
    for i in all(enemies) do
        spr(i.sprite,i.x,i.y)
        spr(i.aggro,i.x,i.y)
    end
end
