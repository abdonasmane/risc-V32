# TAG = SRAI
    .text

    addi x31, x31, 0x1f0
    srai x31, x31, 0x0  # decalage par 0
    srai x31, x31, 0x01 # decalage par 1
    # max_cycle 50
    # pout_start
    # 000001F0
    # 000001F0
    # 000000F8
    # pout_end

