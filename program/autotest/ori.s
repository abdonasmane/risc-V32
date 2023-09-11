# TAG = ori
    .text

    addi x31, x31, 0x010
    ori x31, x31, 0x111
    ori x31, x31, 0x000
    ori x31, x31, -1

    # max_cycle 50
    # pout_start
    # 00000010
    # 00000111 x
    # FFFFFFFF
    # pout_end
