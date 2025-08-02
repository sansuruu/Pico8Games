--this doesnt have to be its own file but for the sake of splitting it up
--it is lol

--utilize the background ticker in comparison with a local variable
--ticker changes which affect drain speed
function updateAttentionBar()
    local ticker = 30
    local attent_dec = 1
    for k,v in all(p.inv) do
        if (k=="headphones") then
            ticker = 10
            attent_dec = 3
        end
    end
    if (tick > 0 and tick % ticker == 0) then
        p.attention -= attent_dec
    end
    if (p.attention <= 0) finishDay()
end

function drawAttentionBar()
    rectfill(4,115,8+p.max_attention,124,0)
    if (p.attention > -1) rectfill(6,117,6+p.attention,122,11)
end