# TAG = bgeu
    .text
imhere1:
    addi x31, x31, 0x005
    addi x30, x30, 0x004
    bgeu x31, x30, imhere2
    addi x31, x31, 0x001
imhere2:
    addi x31, x31, 0x00a
    bgeu x0, x31, imhere3
    addi x31, x31, 0x001
imhere3:
    addi x31, x31, 0x005

    # max_cycle 50
    # pout_start
    # 00000005
    # 0000000f
    # 00000010
    # 00000015
    # pout_end