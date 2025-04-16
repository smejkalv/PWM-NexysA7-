library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intensity_control is
  Port (
    clk             : in  STD_LOGIC;
    reset           : in  STD_LOGIC;
    btn_up          : in  STD_LOGIC; -- Debounced signal
    btn_dn          : in  STD_LOGIC; -- Debounced signal
    intensity_level : out INTEGER range 0 to 9
  );
end intensity_control;

architecture Behavioral of intensity_control is
  signal level : INTEGER range 0 to 9 := 5;
  signal btn_up_prev, btn_dn_prev : STD_LOGIC := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        level <= 5;
        btn_up_prev <= '0';
        btn_dn_prev <= '0';
      else
        -- Detekce vzestupné hrany pro btn_up
        if btn_up = '1' and btn_up_prev = '0' and level < 9 then
          level <= level + 1;
        end if;
        
        -- Detekce vzestupné hrany pro btn_dn
        if btn_dn = '1' and btn_dn_prev = '0' and level > 0 then
          level <= level - 1;
        end if;
        
        btn_up_prev <= btn_up;
        btn_dn_prev <= btn_dn;
      end if;
    end if;
  end process;
  
  intensity_level <= level;
end Behavioral;