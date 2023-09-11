# TAG = SRA
    .text

    addi x31, x31, 0x1f0
    sra x31, x31, x0    # decalage par 0
    addi x30, x30, 0x001
    sra x31, x31, x30   # decalage par 1
    # max_cycle 50
    # pout_start
    # 000001F0
    # 000001F0
    # 000000F8
    # pout_end

