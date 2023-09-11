# TAG = lbu

    .text
    auipc x29, 0x0
    lbu x31, 0(x29)
    auipc x29, 0x0
    addi x29, x29, 0x004
    lbu x31, 0(x29)

    # max_cycle 50
    # pout_start
    # 00000097
    # 00000093
    # pout_end
