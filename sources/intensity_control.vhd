library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intensity_control is
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    btn_up  : in  STD_LOGIC;
    btn_dn  : in  STD_LOGIC;
    incr    : out STD_LOGIC;
    decr    : out STD_LOGIC
  );
end intensity_control;

architecture Behavioral of intensity_control is
  signal btn_up_prev, btn_dn_prev : STD_LOGIC := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        btn_up_prev <= '0';
        btn_dn_prev <= '0';
        incr <= '0';
        decr <= '0';
      else
        incr <= '0';
        decr <= '0';
        -- Detekce nábìžné hrany
        if btn_up_prev = '0' and btn_up = '1' then
          incr <= '1';
        end if;
        if btn_dn_prev = '0' and btn_dn = '1' then
          decr <= '1';
        end if;
        btn_up_prev <= btn_up;
        btn_dn_prev <= btn_dn;
      end if;
    end if;
  end process;
end Behavioral;