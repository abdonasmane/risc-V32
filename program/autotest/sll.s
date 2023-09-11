# TAG = sll
    .text
    addi x31, x31, 0x001
    sll x31, x31, x0    # decalage par 0
    addi x20, x20, 0x001
    sll x31, x31, x20   # decalage par 1
    sll x31, x31, x20   # decalage par 1 encore une fois

    # max_cycle 50
    # pout_start
    # 00000001
    # 00000001
    # 00000002
    # 00000004
    # pout_end
