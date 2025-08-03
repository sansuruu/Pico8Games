
--referenced in dayManager, this starts each homework loop
function game_init()
    game_state = 2
    makeHomework()
    initEnemies()
    p.attention = tonum(p.max_attention)
    p.ans_input = ""
    --explain the game briefly lmfaoo
    --add a quick inbetween scene where we basically choose a difficulty (LATER)
end

--referenced throughout, just routinely called
function updateGrade()
    if (p.test_correct == 0 and p.test_incorrect == 0) then
        p.hw_grade = ceil(100*(0.2 * (p.hw_correct / (p.hw_correct + p.hw_incorrect))))
    else
        p.test_grade =  ceil(100*(0.8 * (p.test_correct/(p.test_correct+p.test_incorrect))))
    end

    p.grade = p.hw_grade + p.test_grade
end    

--inclusive random number with specific range
function rndb(low,high)
	return flr(rnd(high-low+1)+low)
end

--background tick function, aka make it so every frame is a second in the loop lol
function updateTick()
    if (tick < 31) then
        tick +=1
    else
        tick = 0
    end
end

--to help with text 	
function p1(s,x,y,c) -- 42 tokens, 5.6 seconds
?'\f0\-f'..s..'\^g\-h'..s..'\^g\|f'..s..'\^g\|h'..s..'\^g\f'..chr(c+(c>9 and 87 or 48))..s,x,y
end

function changeState(s)
    game_state = s    

end

function distance(x1,y1,x2,y2)
    return sqrt((x2-x1)^2+(y2-y1)^2)
end