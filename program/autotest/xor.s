# TAG = xor
    .text
    addi x30, x30, 1
    xor x31, x31, x30   # avec une valeur qlq
    xor x31, x31, x0    # avec le registre 0
    xor x31, x31, x31   # xor enttre le registre et lui meme doit donner 0

    # max_cycle 50
    # pout_start
    # 00000001 x
    # 00000000
    # pout_end
