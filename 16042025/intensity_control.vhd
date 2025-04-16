library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intensity_control is
  Port (
    clk             : in  STD_LOGIC;
    reset           : in  STD_LOGIC;
    btn_up          : in  STD_LOGIC; -- Pøímý vstup z tlaèítka
    btn_dn          : in  STD_LOGIC;
    intensity_level : out INTEGER range 1 to 10
  );
end intensity_control;

architecture Behavioral of intensity_control is
  signal level : INTEGER range 1 to 10 := 5;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        level <= 5;
      else
        -- Pozor: Bez debounce mùže zmìnit úroveò vícekrát na jeden stisk!
        if btn_up = '1' and level < 10 then
          level <= level + 1;
        elsif btn_dn = '1' and level > 1 then
          level <= level - 1;
        end if;
      end if;
    end if;
  end process;
  
  intensity_level <= level;
end Behavioral;