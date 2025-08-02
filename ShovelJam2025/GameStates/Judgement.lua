function updateLoopJudgement()
    pass = p.grade >= 70
    if (not pass and btnp(5)) _init()
    if (pass and btnp(5)) then
        week += 1
        updatePlayer(week)
        day = 1
        game_state = 1
        
    end
        
end


function drawJudgementScreen()
    
    cls(1)
    print("week "..week.." summary:",10,50,6)
    print("correct: "..p.test_correct.."   incorrect: "..p.test_incorrect, 10, 70, 6)
    if (pass) then
        print("you have passed this week\ncongrats",10,80,7)
        print("press ❎ to continue", 10, 95,3)
    else
        print("you have failed, you lose",10,80,4)
        print("press ❎ to restart the game", 10, 90,3)
    end


end