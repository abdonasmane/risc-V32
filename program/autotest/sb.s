# TAG = sb

    .text
    addi x29, x29, 1
    slli x29, x29, 12
    addi x29, x29, 0x024
    addi x28, x28, 0x001
    sb x28, 0(x29)
    lw x31, 0(x29)
    # max_cycle 50
    # pout_start
    # 00000001
    # pout_end
