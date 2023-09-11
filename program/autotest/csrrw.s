# TAG = csrrw
    .text
    
    addi x29, x29, 0x00e #Chargement de la valeur 0x00e dans le registre x29
    csrrw x28, 0x300, x29 #Chargement de 0x00e dans mstatus
    csrrw x31, 0x300, x29 #Chargement de 0x00e dans x31
    addi x29, x29, -1 #Décrementation de x29
    csrrw x28, 0x304, x29 #Chargement de 0x00d dans mie
    csrrw x31, 0x304, x29 #Chargement de 0x00d dans x31
    addi x29, x29, -1 #Décrementation de x29
    csrrw x28, 0x305, x29 #Chargement de 0x00c dans mtvec
    csrrw x31, 0x305, x29 #Chargement de 0x00c dans x31
    addi x29, x29, -1 #Décrementation de x29
    csrrw x28, 0x341, x29 #Chargement de 0x008 dans mepc
    csrrw x31, 0x341, x29 #Chargement de 0x008 dans x31

    # max_cycle 50
    # pout_start
    # 0000000e
    # 0000000d
    # 0000000c
    # 00000008
    # pout_end