# TAG = andi
    .text

    addi x31, x31, 0x010
    andi x31, x31, 0x111    # avec valeur qlq
    andi x31, x31, -1    # avec valeur extreme
    andi x31, x31, 0x000    # avec valeur extreme

    # max_cycle 50
    # pout_start
    # 00000010 x
    # 00000000
    # pout_end
