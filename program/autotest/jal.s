# TAG = jal
    .text

    jal x30, initialisation
incrementation:
    addi x31, x31, 0x001
    jal x30, fin
initialisation:
    addi x31, x31, 0x00f
    jal x30, incrementation
fin:
    addi x31, x31, 0x002

    # max_cycle 50
    # pout_start
    # 0000000F
    # 00000010
    # 00000012
    # pout_end
