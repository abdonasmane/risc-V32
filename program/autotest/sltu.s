# TAG = sltu
    .text
    addi x31, x31, 0x001
    slt x31, x31, zero
    slt x31, zero, x31
    addi x30, x30, 0x001
    addi x29, x29, 0x002
    slt x31, x30, x29
    # max_cycle 50
    # pout_start
    # 00000001
    # 00000000
    # 00000000
    # 00000001
    # pout_end