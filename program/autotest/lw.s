# TAG = lw

    .text
    auipc x29, 0x0
    lw x31, 0(x29)
    auipc x29, 0x0
    addi x29, x29, 0x004
    lw x31, 0(x29)

    # max_cycle 50
    # pout_start
    # 00000e97
    # 004e8e93
    # pout_end
