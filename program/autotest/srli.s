# TAG = SRLI
    .text

    addi x31, x31, 0x1f0
    srli x31, x31, 0x0
    srli x31, x31, 0x1

    # max_cycle 50
    # pout_start
    # 000001F0
    # 000001F0
    # 000000F8
    # pout_end



