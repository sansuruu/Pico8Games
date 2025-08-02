
--basically manage what state the procrastination landed in 
function updateProcrastinate()
    if (procras_luck <=4) then
        if (btnp(0) and item_index > 1) then item_index -= 1 sfx(3) end
        if (btnp(1) and item_index < 3) then item_index += 1 sfx(3) end
        if (btnp(5)) then
            add(p.inv,item_pool[item_index])
            if (item_pool[item_index] == "pencil") p.speed += 0.5
            if (item_pool[item_index] == "glasses") p.max_attention += 5
            if (item_pool[item_index] == "paper") if(p.distract_p > 0) p.distract_p -= 5
            item_pool = {} 
            game_state = 1
        end
    elseif (procras_luck <= 8) then
        if (btnp(5)) game_state = 1
    else
        if (btnp(5)) then
            add(p.inv,item_pool[1])
            if (item_pool[1] == "star") then
                p.difficulty *= 2
                p.hw_set_length \= 2

                if (p.hw_set_length < 1) p.hw_set_length = 1
            end
            item_pool = {} 
            game_state = 1
        elseif(btnp(4)) then
            game_state = 1
        end
    end
end

--draw the procrastination screen
function drawProcrastinate()
    cls(1)
    if (procras_luck <=4) then
        print(" you skipped today to\n refocus your mental.", 18, 20,6)
        print(" use arrow keys\nto choose an item", 30, 40,6)
        for i=1, #item_pool do
            if (item_pool[i] == "pencil") spr(18,26+i*16,60) --consider making temporary items1
            if (item_pool[i] == "glasses") spr(16,26+i*16,60)
            if (item_pool[i] == "paper") spr(17,26+i*16,60) 
        end
        rect(25+item_index*16,59,34+item_index*16,68)

        print(item_desc[item_pool[item_index]],35,70,6)
        print("press ❎ to select the item", 10, 90,6) 

    elseif (procras_luck <= 8) then
        print("you skipped today\nand did nothing :(",25,30,6)

        print("press ❎ to continue", 24, 90,6)
    else
        print("you skipped today and\n found a rare trinket",20,30,6)
        if (item_pool[1] == "coin") spr(32,26+32,60)
        if (item_pool[1] == "star") spr(34,26+32,60)
        if (item_pool[1] == "headphones") spr(35,26+32,60) 
        print(item_desc[item_pool[1]],15,70,6)
        print(" press ❎ to grab\n🅾️ to skip the item", 30, 90,6)
    end
end