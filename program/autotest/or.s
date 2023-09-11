# TAG = or
    .text

    addi x31, x31, 0x00f
    or x31, x31, x0     # or avec le registre 0
    addi x30, x30, 0x0f1
    or x31, x31, x30    # or avec une valeur qlq

    # max_cycle 50
    # pout_start
    # 0000000F x
    # 000000FF
    # pout_end
