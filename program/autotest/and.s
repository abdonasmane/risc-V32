# TAG = and
    .text

    addi x31, x31, -1
    and x31, x31, x0    #and avec le registre 0
    addi x31, x31, 0x123
    addi x30, x30, 0x100    # and avec un regostre qui contient une valeur qlq
    and x31, x31, x30

    # max_cycle 50
    # pout_start
    # FFFFFFFF
    # 00000000
    # 00000123
    # 00000100
    # pout_end
