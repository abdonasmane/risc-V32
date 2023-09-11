# TAG = addi
    .text

    addi x31, x31, 0x000    #Ajout de 0
    addi x31, x31, -1    #ajout de la valeur max sur 12 bits
    addi x31, x0, 0x000
    addi x31, x31, 0x123    #ajout d'une valeur qlq


    # max_cycle 50
    # pout_start
    # 00000000
    # FFFFFFFF
    # 00000000
    # 00000123
    # pout_end

