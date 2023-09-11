# TAG = lb

    .text
    auipc x29, 0x0
    lb x31, 0(x29)
    auipc x29, 0x0
    addi x29, x29, 0x004
    lb x31, 0(x29)

    # max_cycle 50
    # pout_start
    # ffffff97
    # ffffff93
    # pout_end
