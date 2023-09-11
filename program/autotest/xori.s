# TAG = xori
    .text
    addi x31, x31, 1
    xori x31, x31, 0x000    #xor avec 00000000
    xori x31, x31, -1    #xor avec ffffffff

    # max_cycle 50
    # pout_start
    # 00000001 x
    # FFFFFFFE
    # pout_end
