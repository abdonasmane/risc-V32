# TAG = mret
    .text

    
    
    addi x29, x29, 0x7c1
    csrrw x28, 0x305, x29
    csrrw x31, 0x305, x29
    mret

    # max_cycle 50
    # pout_start
    # 000007c1
    # pout_end