# TAG = lh

    .text
    auipc x29, 0x0
    lh x31, 0(x29)
    auipc x29, 0x0
    addi x29, x29, 0x004
    lh x31, 0(x29)

    # max_cycle 50
    # pout_start
    # 00000e97
    # ffff8e93
    # pout_end
