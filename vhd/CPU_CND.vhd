library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.PKG.all;

entity CPU_CND is
    generic (
        mutant      : integer := 0
    );
    port (
        rs1         : in w32;
        alu_y       : in w32;
        IR          : in w32;
        slt         : out std_logic;
        jcond       : out std_logic
    );
end entity;

architecture RTL of CPU_CND is
    signal int1:std_logic;
    signal int2: std_logic;
    signal int3: std_logic;
    signal int4: std_logic;
    signal ext: std_logic;
    signal x: signed(32 downto 0);
    signal y: signed(32 downto 0);
    signal z: std_logic;
    signal s: std_logic;
    signal res: signed(32 downto 0);
begin
    int1 <= not(IR(12)) and not(IR(6));
    int2 <= IR(6) and not(IR(13));
    ext <= int1 or int2;
    x <= signed(rs1(31) & rs1) when ext = '1' else signed('0' & rs1);
    y <= signed(alu_y(31) & alu_y) when ext = '1' else signed('0' & alu_y);
    res <= x - y;
    z <= '1' when res = 0 else '0';
    s <= res(32);
    int3 <= (z xor IR(12)) and (not(IR(14)));
    int4 <= (s xor IR(12)) and IR(14);
    jcond <= int3 or int4;
    slt <= s;
    
end architecture;

