# TAG = sltiu
    .text
    addi x31, x31, 0x001
    slti x31, x31, 0x000
    slti x31, zero, 0x000
    addi x30, x30, 0x001
    slt x31, x30, 0x002
    # max_cycle 50
    # pout_start
    # 00000001
    # 00000000
    # 00000000
    # 00000001
    # pout_end