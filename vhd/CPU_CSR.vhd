library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CSR is
    generic (
        INTERRUPT_VECTOR : waddr   := w32_zero;
        mutant           : integer := 0
    );
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;

        -- Interface de et vers la PO
        cmd         : in  PO_cs_cmd;
        it          : out std_logic;
        pc          : in  w32;
        rs1         : in  w32;
        imm         : in  W32;
        csr         : out w32;
        mtvec       : out w32;
        mepc        : out w32;

        -- Interface de et vers les IP d'interruption
        irq         : in  std_logic;
        meip        : in  std_logic;
        mtip        : in  std_logic;
        mie         : out w32;
        mip         : out w32;
        mcause      : in  w32
    );
end entity;

architecture RTL of CPU_CSR is
    -- Fonction retournant la valeur à écrire dans un csr en fonction
    -- du « mode » d'écriture, qui dépend de l'instruction
    function CSR_write (CSR        : w32;
                         CSR_reg    : w32;
                         WRITE_mode : CSR_WRITE_mode_type)
        return w32 is
        variable res : w32;
    begin
        case WRITE_mode is
            when WRITE_mode_simple =>
                res := CSR;
            when WRITE_mode_set =>
                res := CSR_reg or CSR;
            when WRITE_mode_clear =>
                res := CSR_reg and (not CSR);
            when others => null;
        end case;
        return res;
    end CSR_write;
    signal mcause_d, mcause_q, mip_d, mip_q, mie_d, mie_q, mstatus_d, mstatus_q, mtvec_d, mtvec_q, mepc_d, mepc_q: w32;
    signal to_csr : w32;
begin
    process(clk)
    begin
    if clk'event and clk = '1' then
        if rst = '1' then
            mcause_q <= w32_zero;
            mip_q <= w32_zero;
            mie_q <= w32_zero;
            mstatus_q <= w32_zero;
            mtvec_q <= w32_zero;
            mepc_q <= w32_zero;
        else 
            mcause_q <= mcause_d;
            mip_q <= mip_d;
            mie_q <= mie_d;
            mstatus_q <= mstatus_d;
            mtvec_q <= mtvec_d;
            mepc_q <= mepc_d;
        end if;
    end if;
    end process;
    process(all)
    begin
    mie_d <= mie_q;
    mstatus_d <= mstatus_q;
    mtvec_d <= mtvec_q;
    mepc_d <= mepc_q;
    if cmd.CSR_we = CSR_mie then
        mie_d <= CSR_write(to_csr, mie_q, cmd.CSR_WRITE_mode);
    elsif cmd.CSR_we = CSR_mstatus then
        mstatus_d <= CSR_write(to_csr, mstatus_q, cmd.CSR_WRITE_mode);
    elsif cmd.CSR_we = CSR_mtvec then
        mtvec_d <= CSR_write(to_csr, mtvec_q, cmd.CSR_WRITE_mode)(31 downto 2) & "00";
    elsif cmd.CSR_we = CSR_mepc then
        if cmd.MEPC_sel =  MEPC_from_pc then
            mepc_d <=  CSR_write( pc, mepc_q, cmd.CSR_WRITE_mode);
        else
            mepc_d <= CSR_write(to_csr, mepc_q, cmd.CSR_WRITE_mode)(31 downto 2) & "00";
        end if;
    end if;
    if cmd.CSR_sel = CSR_from_mcause then
        csr <= mcause_q;
    elsif cmd.CSR_sel = CSR_from_mip then
        csr <= mip_q;
    elsif cmd.CSR_sel = CSR_from_mie then
        csr <= mie_q;
    elsif cmd.CSR_sel = CSR_from_mstatus then
        csr <= mstatus_q;
    elsif cmd.CSR_sel = CSR_from_mtvec then
        csr <= mtvec_q;
    elsif cmd.CSR_sel = CSR_from_mepc then
        csr <= mepc_q;
    end if;
    if cmd.MSTATUS_mie_set = '1' then
        mstatus_d(3) <= '1';
    end if;
    if cmd.MSTATUS_mie_reset = '1' then
        mstatus_d(3) <= '0';
    end if;
    end process;
    it <= irq and mstatus_q(3);
    mip_d <= mip_q(31 downto 12) & meip & mip_q(10 downto 8) & mtip & mip_q(6 downto 0);
    mip <= mip_q;
    mie <= mie_q;
    to_csr <= rs1 when cmd.TO_CSR_Sel = TO_CSR_from_rs1 else imm;
    mtvec <= mtvec_q;
    mepc <= mepc_q;
    mcause_d <= it & mcause(30 downto 0) when irq = '1' else mcause_q;
end architecture;
