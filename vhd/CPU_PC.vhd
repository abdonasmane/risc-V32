library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.PKG.all;

entity CPU_PC is
    generic(
        mutant: integer := 0
    );
    Port (
        -- Clock/Reset
        clk    : in  std_logic ;
        rst    : in  std_logic ;

        -- Interface PC to PO
        cmd    : out PO_cmd ;
        status : in  PO_status
    );
end entity;

architecture RTL of CPU_PC is
    type State_type is (
        S_Error,
        S_Init,
        S_Pre_Fetch,
        S_Fetch,
        S_Decode,
        S_LUI,
        S_ADDI,
        S_ADD,
        S_SLL,
        S_AUIPC,
        S_AND,
        S_OR,
        S_XOR,
        S_ANDI,
        S_ORI,
        S_XORI,
        S_SUB,
        S_SRL,
        S_SRA,
        S_SRAI,
        S_SLLI,
        S_SRLI,
        S_BEQ,
        S_BNE,
        S_BLT,
        S_BGE,
        S_BLTU,
        S_BGEU,
        S_SLT,
        S_SLTI,
        S_SLTU,
        S_SLTIU,
        S_Pre_LOAD,
        S_LOAD,
        S_LW,
        S_Pre_STORE,
        S_SW,
        S_JAL,
        S_JALR,
        S_LB,
        S_LBU,
        S_LH,
        S_LHU,
        S_SB,
        S_SH,
        S_CSRRW,
        S_CSRRS,
        S_MRET,
        S_CSRRWI,
        S_CSRRSI,
        S_CSRRC,
        S_CSRRCI,
        S_INTERRUPTION
    );

    signal state_d, state_q : State_type;


begin

    FSM_synchrone : process(clk)
    begin
        if clk'event and clk='1' then
            if rst='1' then
                state_q <= S_Init;
            else
                state_q <= state_d;
            end if;
        end if;
    end process FSM_synchrone;

    FSM_comb : process (state_q, status)
    begin

        -- Valeurs par défaut de cmd à définir selon les préférences de chacun
        cmd.ALU_op            <= ALU_plus;
        cmd.LOGICAL_op        <= LOGICAL_and;
        cmd.ALU_Y_sel         <= ALU_Y_rf_rs2;

        cmd.SHIFTER_op        <= SHIFT_rl;
        cmd.SHIFTER_Y_sel     <= SHIFTER_Y_rs2;

        cmd.RF_we             <= '0';
        cmd.RF_SIZE_sel       <= RF_SIZE_word;
        cmd.RF_SIGN_enable    <= '0';
        cmd.DATA_sel          <= DATA_from_alu;

        cmd.PC_we             <= '0';
        cmd.PC_sel            <= PC_from_alu;

        cmd.PC_X_sel          <= PC_X_cst_x00;
        cmd.PC_Y_sel          <= PC_Y_cst_x04;

        cmd.TO_PC_Y_sel       <= TO_PC_Y_immB;

        cmd.AD_we             <= '0';
        cmd.AD_Y_sel          <= AD_Y_immI;

        cmd.IR_we             <= '0';

        cmd.ADDR_sel          <= ADDR_from_pc;
        cmd.mem_we            <= '0';
        cmd.mem_ce            <= '0';

        cmd.cs.CSR_we            <= CSR_none;

        cmd.cs.TO_CSR_sel        <= TO_CSR_from_rs1;
        cmd.cs.CSR_sel           <= CSR_from_mcause;
        cmd.cs.MEPC_sel          <= MEPC_from_pc;

        cmd.cs.MSTATUS_mie_set   <= '0';
        cmd.cs.MSTATUS_mie_reset <= '0';

        cmd.cs.CSR_WRITE_mode    <= WRITE_mode_simple;

        state_d <= state_q;

        case state_q is
            when S_Error =>
                -- Etat transitoire en cas d'instruction non reconnue 
                -- Aucune action
                state_d <= S_Init;

            when S_Init =>
                -- PC <- RESET_VECTOR
                cmd.PC_we <= '1';
                cmd.PC_sel <= PC_rstvec;
                state_d <= S_Pre_Fetch;

            when S_Pre_Fetch =>
                -- mem[PC]
                cmd.mem_we   <= '0';
                cmd.mem_ce   <= '1';
                cmd.ADDR_sel <= ADDR_from_pc;
                state_d      <= S_Fetch;

            when S_Fetch =>
                if status.it = true then
                    state_d <= S_INTERRUPTION; 
                else 
                    -- IR <- mem_datain
                    cmd.IR_we <= '1';
                    state_d <= S_Decode;
                end if;

            when S_Decode =>
                -- Décodage effectif des instructions,
                -- à compléter par vos soins
                if status.IR(6 downto 0) = "0110111" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    state_d <= S_LUI;
                elsif status.IR(6 downto 0) = "0010011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "000" then
                        state_d <= S_ADDI;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_ORI;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_ANDI;
                    elsif status.IR(14 downto 12) = "100" then
                        state_d <= S_XORI;
                    elsif status.IR(14 downto 12) = "101" then
                        if status.IR(30) = '1' then
                            state_d <= S_SRAI;
                        elsif status.IR(30) = '0' then
                            state_d <= S_SRLI;
                        end if;
                    elsif status.IR(14 downto 12) = "001" then
                        state_d <= S_SLLI;
                    elsif status.IR(14 downto 12) = "010" then
                        state_d <= S_SLTI;
                    elsif status.IR(14 downto 12) = "011" then
                        state_d <= S_SLTIU;
                    end if;
                elsif status.IR(6 downto 0) = "0110011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "000" then
                        if status.IR(30) = '0' then 
                            state_d <= S_ADD;
                        elsif status.IR(30) = '1' then
                            state_d <= S_SUB;
                        end if;
                    elsif status.IR(14 downto 12) = "001" then
                        state_d <= S_SLL;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_AND;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_OR;
                    elsif status.IR(14 downto 12) = "100" then
                        state_d <= S_XOR;
                    elsif status.IR(14 downto 12) = "101" then
                        if status.IR(30) = '0' then
                            state_d <= S_SRL;
                        elsif status.IR(30) = '1' then
                            state_d <= S_SRA;
                        end if;
                    elsif status.IR(14 downto 12) = "010" then
                        state_d <= S_SLT;
                    elsif status.IR(14 downto 12) = "011" then
                        state_d <= S_SLTU;
                    end if;
                elsif status.IR(6 downto 0) = "0010111" then
                    state_d <= S_AUIPC;
                elsif status.IR(6 downto 0) = "1100011" then
                    if status.IR(14 downto 12) = "000" then
                        state_d <= S_BEQ;
                    elsif status.IR(14 downto 12) = "001" then
                        state_d <= S_BNE;
                    elsif status.IR(14 downto 12) = "100" then
                        state_d <= S_BLT;
                    elsif status.IR(14 downto 12) = "101" then
                        state_d <= S_BGE;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_BLTU;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_BGEU;
                    end if;
                elsif status.IR(6 downto 0) = "0000011" then
                    state_d <= S_Pre_LOAD;
                elsif status.IR(6 downto 0) = "0100011" then
                    state_d <= S_Pre_STORE;
                elsif status.IR(6 downto 0) = "1101111" then
                    state_d <= S_JAL;
                elsif status.IR(6 downto 0) = "1100111" then
                    state_d <= S_JALR;
                elsif status.IR(6 downto 0) = "1110011" then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                    if status.IR(14 downto 12) = "001" then
                        state_d <= S_CSRRW;
                    elsif status.IR(14 downto 12) = "010" then
                        state_d <= S_CSRRS;
                    elsif status.IR(14 downto 12) = "000" then
                        state_d <= S_MRET;
                    elsif status.IR(14 downto 12) = "101" then
                        state_d <= S_CSRRWI;
                    elsif status.IR(14 downto 12) = "110" then
                        state_d <= S_CSRRSI;
                    elsif status.IR(14 downto 12) = "011" then
                        state_d <= S_CSRRC;
                    elsif status.IR(14 downto 12) = "111" then
                        state_d <= S_CSRRCI;
                    end if;
                else
                    state_d <= S_Error;
                end if;
---------- Instructions avec immediat de type U ----------
            when S_LUI =>
                -- rd <- ImmU + 0
                cmd.PC_X_sel <= PC_X_cst_x00;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_AUIPC =>
                -- rd <- ImmU + pc
                cmd.PC_X_sel <= PC_X_pc;
                cmd.PC_Y_sel <= PC_Y_immU;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_pc;
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
---------- Instructions arithmétiques et logiques ----------
            when S_ADDI =>
                -- rd <- rs + ImmI
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_ADD =>
                -- rd <- rs1 + rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_plus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLL =>
                -- rd <- rs1 decalé de rs2
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_AND =>
                -- rd <- rs1 and rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_OR =>
                -- rd <- rs1 or rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_XOR =>
                -- rd <- rs1 xor rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_ORI =>
                -- rd <- ImmI or rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_or;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_ANDI =>
                -- rd <- ImmI and rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_and;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_XORI =>
                -- rd <- ImmI xor rs1
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.LOGICAL_op <= LOGICAL_xor;
                cmd.DATA_sel <= DATA_from_logical;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SUB =>
                -- rd <= rs1 - rs2
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.ALU_op <= ALU_minus;
                cmd.DATA_sel <= DATA_from_alu;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SRA =>
                -- rd <- rs1 decalé à droite de rs2 et remplacement avec bit de signe
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
             when S_SRL =>
                -- rd <- rs1 decalé à droite de rs2 et remplacement avec des 0
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_rs2;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SRAI =>
                -- rd <- rs1 decalé à droite de shamt  et remplacement avec des 0
                cmd.SHIFTER_op <= SHIFT_ra;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLLI =>
                -- rd <- rs1 decalé à droite de imm  et remplacement avec des 0
                cmd.SHIFTER_op <= SHIFT_ll;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SRLI =>
                cmd.SHIFTER_op <= SHIFT_rl;
                cmd.SHIFTER_Y_sel <= SHIFTER_Y_ir_sh;
                cmd.DATA_sel <= DATA_from_shifter;
                cmd.RF_we <= '1';
                -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLT =>
                --comparaison entre rs1 et rs2 et mettre 1 dans rd si rs1 < rs2, 0 sinon
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                 -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLTI =>
                --comparaison entre rs1 et ImmI et mettre 1 dans rd si rs1 < ImmI, 0
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                 -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLTU =>
                --comparaison entre rs1 et rs2 et mettre 1 dans rd si rs1 <= rs2, 0
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                 -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
            when S_SLTIU =>
                --comparaison entre rs1 et ImmI et mettre 1 dans rd si rs1 < ImmI, 0
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.DATA_sel <= DATA_from_slt;
                cmd.RF_we <= '1';
                 -- lecture mem[PC]
                cmd.ADDR_sel <= ADDR_from_pc;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                -- next state
                state_d <= S_Fetch;
---------- Instructions de saut ----------
            when S_BEQ =>
                --rs1 = rs2 ⇒ pc ← pc + cst
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_BNE =>
                --rs1 not = rs2 ⇒ pc ← pc + cst
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_BLT =>
                --rs1 < rs2 ⇒ pc ← pc + cst
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
             when S_BGE =>
                --rs1 >= rs2 ⇒ pc ← pc + cst if jcond=1
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_BLTU =>
                --rs1 < usg rs2 ⇒ pc ← pc + cst if jcond=1
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_BGEU =>
                --rs1 >= usg rs2 ⇒ pc ← pc + cst if jcond=1
                cmd.ALU_Y_sel <= ALU_Y_rf_rs2;
                if status.JCOND = true then
                    cmd.TO_PC_Y_sel <= TO_PC_Y_immB;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                else
                    cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                    cmd.PC_sel <= PC_from_pc;
                    cmd.PC_we <= '1';
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_JAL =>
                -- rd ← pc + 4, cst = (IR1231 ∥ IR19...12 ∥ IR20 ∥ IR30...25 ∥ IR24...21 ∥ 0), pc ← pc + cst
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                cmd.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.TO_PC_Y_sel <= TO_PC_Y_immJ;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_JALR =>
                -- rd ← pc + 4, pc ← (rs1 + (IR2031 ∥ IR31...20))31...1 ∥ 0
                cmd.PC_Y_sel <= PC_Y_cst_x04;
                CMD.PC_X_sel <= PC_X_pc;
                cmd.DATA_sel <= DATA_from_pc;
                cmd.RF_we <= '1';
                cmd.ALU_Y_sel <= ALU_Y_immI;
                cmd.ALU_op <= ALU_plus;
                cmd.PC_sel <= PC_from_alu;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
---------- Instructions de chargement à partir de la mémoire ----------
            when S_Pre_LOAD =>
                cmd.AD_Y_sel <= AD_Y_immI;
                cmd.AD_we <= '1';
                state_d <= S_LOAD;
            when S_LOAD =>
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '0';
                if status.IR(14 downto 12) = "010" then
                    state_d <= S_LW;
                elsif status.IR(14 downto 12) = "000" then
                    state_d <= S_LB;
                elsif status.IR(14 downto 12) = "100" then
                    state_d <= S_LBU;
                elsif status.IR(14 downto 12) = "001" then
                    state_d <= S_LH;
                elsif status.IR(14 downto 12) = "101" then
                    state_d <= S_LHU;
                end if;
            when S_LW =>
                -- rd ← mem[(IR31_20 ∥ IR31...20) + rs1]
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.RF_we <= '1';
                cmd.DATA_sel <= DATA_from_mem;
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_LB =>
                -- rd ← mem[(IR2031 ∥ IR31...20) + rs1]247 ∥ mem[IR2031 ∥ IR31...20 + rs1]7...0
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_LBU =>
                -- rd ← 024 ∥ mem[(IR2031 ∥ IR31...20) + rs1]7...0
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_LH =>
                -- rd ← mem[(IR2031 ∥ IR31...20) + rs1]1615 ∥ mem[(IR2031 ∥ IR31...20) + rs1]15...0
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.RF_SIGN_enable <= '1';
                cmd.RF_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_LHU =>
                -- rd ← 016 ∥ mem[(IR2031 ∥ IR31...20) + rs1]15...0
                cmd.DATA_sel <= DATA_from_mem;
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.RF_SIGN_enable <= '0';
                cmd.RF_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
---------- Instructions de sauvegarde en mémoire ----------
            when S_Pre_STORE =>
                cmd.AD_Y_sel <= AD_Y_immS;
                cmd.AD_we <= '1';
                if status.IR(14 downto 12) = "010" then
                    state_d <= S_SW;
                elsif status.IR(14 downto 12) = "000" then
                    state_d <= S_SB;
                elsif status.IR(14 downto 12) = "001" then
                    state_d <= S_SH;
                end if;
            when S_SW => 
                -- cst = (IR31_20 ∥ IR31...25 ∥ IR11...7), mem[cst + rs1] ← rs2
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_word;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_SB => 
                -- cst = (IR2031 ∥ IR31...25 ∥ IR11...7), mem[cst + rs1] ← rs27...0
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_byte;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_SH => 
                -- cst = (IR2031 ∥ IR31...25 ∥ IR11...7), mem[cst + rs1] ← rs215...0
                cmd.ADDR_sel <= ADDR_from_ad;
                cmd.RF_SIZE_sel <= RF_SIZE_half;
                cmd.mem_ce <= '1';
                cmd.mem_we <= '1';
                -- incrementation de PC
                cmd.TO_PC_Y_sel <= TO_PC_Y_cst_x04;
                cmd.PC_sel <= PC_from_pc;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
---------- Instructions d'accès aux CSR ----------
            when S_INTERRUPTION =>
                cmd.cs.MEPC_sel <= MEPC_from_pc;
                cmd.cs.CSR_we <= CSR_mepc;
                cmd.cs.MSTATUS_mie_reset <= '1';
                cmd.PC_sel <= PC_mtvec;
                cmd.PC_we <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRW =>
                -- rd ← csr, csr ← rs1
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRS =>
                -- rd ← csr, csr ← csr or rs1
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_MRET =>
                -- pc ← mepc, mstatus3 ← 1
                cmd.PC_sel <= PC_from_mepc;
                cmd.PC_we <= '1';
                cmd.cs.MSTATUS_mie_set <= '1';
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRWI =>
                -- rd ← csr, csr ← 0(27) || zimm
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_simple;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRSI =>
                -- rd ← csr, csr ← csr or (0(27) || zimm)
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_set;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRC =>
                -- rd ← csr, csr ← csr and not(rs1)
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_rs1;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when S_CSRRCI =>
                -- rd ← csr,  csr ← csr and not(0(27) || zimm)
                cmd.DATA_sel <= DATA_from_csr;
                cmd.RF_we <= '1';
                cmd.cs.TO_CSR_sel <= TO_CSR_from_imm;
                cmd.cs.CSR_WRITE_mode <= WRITE_mode_clear;
                if status.IR(31 downto 20) = "001100000000" then
                    cmd.cs.CSR_sel <= CSR_from_mstatus;
                    cmd.cs.CSR_we <= CSR_mstatus;
                elsif status.IR(31 downto 20) = "001100000100" then
                    cmd.cs.CSR_sel <= CSR_from_mie;
                    cmd.cs.CSR_we <= CSR_mie;
                elsif status.IR(31 downto 20) = "001100000101" then
                    cmd.cs.CSR_sel <= CSR_from_mtvec;
                    cmd.cs.CSR_we <= CSR_mtvec;
                elsif status.IR(31 downto 20) = "001101000001" then
                    cmd.cs.CSR_sel <= CSR_from_mepc;
                    cmd.cs.CSR_we <= CSR_mepc;
                    cmd.cs.MEPC_sel <= MEPC_from_csr;
                elsif status.IR(31 downto 20) = "001101000010" then
                    cmd.cs.CSR_sel <= CSR_from_mcause;
                    cmd.cs.CSR_we <= CSR_none;
                elsif status.IR(31 downto 20) = "001101000100" then
                    cmd.cs.CSR_sel <= CSR_from_mip;
                    cmd.cs.CSR_we <= CSR_none;
                end if;
                -- next state
                state_d <= S_Pre_Fetch;
            when others => null;
        end case;

    end process FSM_comb;

end architecture;
