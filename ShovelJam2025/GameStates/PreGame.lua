--PreInit: "setup everything before the game begins"
function preInit()
    poke(0x5F2D, 1)
    -- title screen stuff before any of this lmfao
    game_state = 0 -- 0 => title sequence, 1 => first time enable, 2=> shop, 3=>continue
    tick = 0
    day = 1 -- this acts as the blinds
    week = 1 --this acts as the "ante"
    num_table = {1,2,3,4,5,6,7,8,9,0}
    submitted = false
    sub_tick = 0
    enemy_mod = 15 --in the tick % 30, basically we go down 15->10->6->5, etc
    enemy_mod_inc = 4 --everytime the above modulates, e_sec goes up, this is the upper limit of that
    base = {hw_length = 15, attent=30, dis_p=35, sp=2, diff = 20}
    chosen = 0
    item_desc = {
        --common
        pencil="pencil: +speed",
        glasses="glasses: +attention",
        paper="paper: -%distraction\nspawns",

        --rare
        coin="coin: distractions have a\n50/50 chance to give attent",
        star="gold star: 50% hw length,\nbut 2x difficulty",
        headphones="headphones: no distractions\n but faster attention drain"
    }
end

--do i have to describe this one lol
function drawTitleScreen()
    cls(1)
    circfill(64,64,50,5)
    circfill(64,64,40,1)
    circfill(64,64,30,5)
    sspr(16,8,8,8,24,48)
    sspr(8,8,8,8,96,48)
    
    print("procrasti-start",34,50,7)
    print("press ❎ to begin",32, 60, 7) 


    
    print("BY SANSURU",44,100,6)
    print("(CHECK DESC. FOR INFO/TUTORIAL)",3,115,6)
end