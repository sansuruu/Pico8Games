--create a new homework assignment based off the set length
function makeHomework()
    prev_incorrect = p.hw_incorrect
    hw_complete = false
    hw = {}
    hw_page_index = 1
    if (day < 5) then
        p.hw_length = p.hw_set_length \ 3
        if (p.hw_length < 1) p.hw_length = 1
    else
        p.hw_length = p.hw_set_length
    end

    hw_max_page= (p.hw_length \ 14) + 1

    page_count = (p.hw_length \ 14) + 1
    local temp = p.hw_length
    for i=1, page_count do 
        hw_page = {
            problems = {},
            answers = {},
            subm_format = {}, -- 0 -> n/a, 3 -> correct, 8 -> wrong
            index = 1
        }
        if (temp > 13) then
            for i=1, 13 do
                local temp_ans = rndb((1+(week-1)*5),p.difficulty)
                add(hw_page.answers, temp_ans)
                local temp_a = rndb(1,temp_ans)
                local temp_b = temp_ans - temp_a
                add(hw_page.problems,""..temp_a.."+"..temp_b.."=")
                add(hw_page.subm_format,0)
            end
            add(hw, hw_page)
            temp -= 13
        else
            for i=1, temp do
                local temp_ans = rndb((1+(week-1)*5),p.difficulty)
                add(hw_page.answers, temp_ans)
                local temp_a = rndb(1,temp_ans)
                local temp_b = temp_ans - temp_a
                add(hw_page.problems,""..temp_a.."+"..temp_b.."=")
                add(hw_page.subm_format,0)
            end
            add(hw, hw_page)            
        end
    end
end

--now draw it lol
function drawHomework()
    rectfill(2,2,60,125,6) --paper
    rectfill(4,4,58,123,7)
    rectfill(60,2,76,14,6) --paper
    rectfill(58,4,74,12,7)
    print(tostr(hw_page_index).."/"..tostr(hw_max_page), 61,6,2)
    active_page = hw[1]
    for i=1, #active_page.problems do
        print(active_page.problems[i],8,i*8,active_page.subm_format[i])
    end
    
end


--this acts as both the keyboard input manager
--but also the submission manager + what the fuck you entered
function updateKeyInput()
    local t = stat(31)
    local last = #active_page.problems % 13
    if (t == "\r") return
    if (t == " " and submitted) return
    if (t == " " and not submitted) submitted = not submitted
    
    if (submitted and sub_tick > (300/p.speed)) then
        active_page.problems[active_page.index] = active_page.problems[active_page.index]..p.ans_input
        if (p.ans_input == tostr(active_page.answers[active_page.index])) then
            active_page.subm_format[active_page.index] = 3
            if (day == 5) p.test_correct += 1
            if (day < 5) p.hw_correct += 1
            sfx(9)
        else
            active_page.subm_format[active_page.index] = 8
            if (day == 5) p.test_incorrect += 1
            if (day < 5) p.hw_incorrect += 1
            sfx(8)
        end
        updateGrade()
        active_page.index += 1

        if (#hw > 1 and active_page.index > 13 and last == 0) then --in any case where theres more than 1 page left
            del(hw,active_page)
            hw_page_index += 1
        elseif (#hw == 1) then --we only have 1 page left 
            last = #active_page.problems
            if (active_page.index > last) then
                del(hw,active_page)
                hw_complete = true
            end
        end
        if (#hw < 1) finishDay()
        p.ans_input = ""
        submitted = false
        sub_tick = 0
        return
    else
        if (submitted) then
            sub_tick += 1
        end
    end


    if (t == "\b" or t=="\t" and not submitted) then
        p.ans_input = sub(p.ans_input,1,#p.ans_input-1)
        sfx(3)
        return
    end
    local isNum = false
    for i in all(num_table) do
        if (tostr(t) == tostr(i)) isNum = true
    end
    if (not isNum) then
        return
    else
        if (submitted) return
        p.ans_input = p.ans_input..t
        sfx(3)
    end

end

--draw ur answer
function drawKeyInput()
    if (p.ans_input=="") then
        if (active_page.problems[active_page.index] == nil) return
        --rect(4+#hw.problems[hw.index]*4,hw.index*8,6+#hw.problems[hw.index]*4,hw.index*8 +4,0)
        spr(2,8+#active_page.problems[active_page.index]*4,active_page.index*8)
    else
        print(p.ans_input,8+#active_page.problems[active_page.index]*4,active_page.index*8,0)
    end
end

--when we submit, we wanna draw the animation of answer loading up
function drawWritingAnswer()
    if (submitted) then
        if (active_page.problems[active_page.index] == nil) return
         --convert hoiw long -> perc -> length thats consistent
        if ((sub_tick/(300/p.speed)) > ten_ticker) then
            sfx(0)
            ten_ticker += 0.1
        end
        if (ten_ticker > 1) ten_ticker = 0

        rectfill(8,active_page.index*8,8+flr((sub_tick/(300/p.speed))*(#active_page.problems[active_page.index]*4+#p.ans_input*4)),active_page.index*8+4,9)
    end
end