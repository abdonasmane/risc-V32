# TAG = ADD
    .text

    add x31, x0, x0     #ajout de 0
    addi x1, x1, -1
    add x31, x31, x1    #ajout de ffffffff
    add x31, x0, x0    #remise a 0
    add x1, x0, x0
    addi x1, x1, 0x123
    add x31, x31, x1   #ajout d'une valeur qlq

    # max_cycle 50
    # pout_start
    # 00000000
    # FFFFFFFF
    # 00000000
    # 00000123
    # pout_end
