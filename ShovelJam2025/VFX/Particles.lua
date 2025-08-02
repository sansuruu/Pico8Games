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