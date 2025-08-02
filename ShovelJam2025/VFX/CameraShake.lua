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