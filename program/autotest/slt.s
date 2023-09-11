# TAG = slt
    .text
    addi x31, x31, 0x001
    slt x31, x31, x0
    slt x31, zero, x31
    addi x30, x30, 0x001
    addi x29, x29, 0x002
    slt x31, x30, x29
    addi x20, x20, 0x005
    sub x28, x28, x20
    slt x31, x31, x28
    addi x31, x31, 0x005
    slt x31, x31, x28
    # max_cycle 50
    # pout_start
    # 00000001
    # 00000000
    # 00000000
    # 00000001
    # 00000000
    # 00000005
    # 00000000
    # pout_end
