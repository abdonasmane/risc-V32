# TAG = csrrci
    .text

    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrci x31, 0x300, 0x001 #Chargement de 0x000 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrci x31, 0x304, 0x001 #Chargement de 0x000 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrci x31, 0x305, 0x001 #Chargement de 0x000 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrci x31, 0x341, 0x001 #Chargement de 0x000 dans x31

    # max_cycle 50
    # pout_start
    # 00000001
    # 00000000
    # 00000001
    # 00000000
    # 00000001
    # 00000000
    # 00000001
    # 00000000
    # pout_end