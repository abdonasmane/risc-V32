# TAG = SRL
    .text
    addi x31, x31, 0x1f0
    srl x31, x31, x0    # decalage par 0
    addi x20, x20, 0x001
    srl x31, x31, x20   # decalage par 1

    # max_cycle 50
    # pout_start
    # 000001F0
    # 000001F0
    # 000000F8
    # pout_end

