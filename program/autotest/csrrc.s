# TAG = csrrc
    .text
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    addi x29, x29, 0x003 #Chargement de la valeur 0x003 dans le registre x29
    csrrc x28, 0x300, x29 #Chargement de 0x000 dans mstatus
    csrrc x31, 0x300, x29 #Chargement de 0x000 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrc x28, 0x304, x29 #Chargement de 0x000 dans mie
    csrrc x31, 0x304, x29 #Chargement de 0x001 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrc x28, 0x305, x29 #Chargement de 0x000 dans mtvec
    csrrc x31, 0x305, x29 #Chargement de 0x000 dans x31
    addi x31, x31, 1 #Chargement de 0x001 dans x31
    csrrc x28, 0x341, x29 #Chargement de 0x000 dans mepc
    csrrc x31, 0x341, x29 #Chargement de 0x000 dans x31

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