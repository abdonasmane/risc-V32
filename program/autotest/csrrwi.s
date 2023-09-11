# TAG = csrrwi
    .text

    csrrwi x28, 0x300, 0x00e #Chargement de 0x00e dans mstatus
    csrrwi x31, 0x300, 0x00e #Chargement de 0x00e dans x31
    csrrwi x28, 0x304, 0x00d #Chargement de 0x00d dans mie
    csrrwi x31, 0x304, 0x00d #Chargement de 0x00d dans x31
    csrrwi x28, 0x305, 0x00c #Chargement de 0x00c dans mtvec
    csrrwi x31, 0x305, 0x00c #Chargement de 0x00c dans x31
    csrrwi x28, 0x341, 0x00b #Chargement de 0x008 dans mepc
    csrrwi x31, 0x341, 0x00b #Chargement de 0x008 dans x31

    # max_cycle 50
    # pout_start
    # 0000000e
    # 0000000d
    # 0000000c
    # 00000008
    # pout_end