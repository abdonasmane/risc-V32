# TAG = SLLI
    .text

    addi x31, x31, 0x1f1
    slli x31, x31, 0x0  # decalage par 0
    slli x31, x31, 0x1  # decalage par 1

    # max_cycle 50
    # pout_start
    # 000001F1
    # 000001F1
    # 000003E2
    # pout_end


