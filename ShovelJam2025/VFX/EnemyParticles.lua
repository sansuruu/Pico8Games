--general particle effects (for spawn and destroy)
function enemyParticleInit()
    e_ps={}       --empty particle table
    e_start_vel=0.5   --max initial particle velocity
    e_min_life=10 --particle lifetime
    e_max_life=15
    e_spr_pos = {45,45,29,29,13,13}
    e_spr_neg = {46,46,30,30,14,14}
    burst=50

    end
    function rndb(low,high)
    return flr(rnd(high-low+1)+low)
end

function enemyParticleUpdate()
    --burst
    foreach(e_ps,update_e_p)
end

function enemyParticleDraw()
    foreach(e_ps,draw_e_p)
end

function add_e_p(x,y,dx,dy,pos)
    local p={}
    p.x,p.y=x,y
    p.dx=-4*dx
    p.dy=-4*dy
    p.life_start=rndb(e_min_life,e_max_life)
    p.life=p.life_start
    p.pos=pos
    add(e_ps,p)
end

function update_e_p(p)
    if (p.life<=0) then
        del(e_ps,p) --kill old particles
    else
        p.x+=p.dx --update position
        p.y+=p.dy
        p.dx*=0.75
        p.dy*=0.75
        p.life-=1 --die a little
    end
end

function draw_e_p(p)
    if (not p.pos) then
        local pcol=flr(p.life/p.life_start*#e_spr_neg+1)
        spr(e_spr_neg[pcol],p.x,p.y)
    else
        local pcol=flr(p.life/p.life_start*#e_spr_pos+1)
        spr(e_spr_pos[pcol],p.x,p.y)        
    end
end