# TAG = SUB
    .text

    addi x31, x31, 0x111
    sub x31, x31, x31   #soustraction entre le registre et lui meme
    addi x30, x30, 0x001
    sub x31, x31, x30   #soustraction pour arriver a un nb negative

    # max_cycle 50
    # pout_start
    # 00000111
    # 00000000
    # FFFFFFFF
    # pout_end
