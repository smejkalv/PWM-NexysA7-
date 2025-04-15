library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity channel_selector is
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    btn_up  : in  STD_LOGIC; -- Pøímý vstup z tlaèítka (bez debounce)
    btn_dn  : in  STD_LOGIC;
    channel : buffer INTEGER range 0 to 7
  );
end channel_selector;

architecture Behavioral of channel_selector is
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        channel <= 0;
      else
        -- Pozor: Bez debounce mùže reagovat na zákmit tlaèítka!
        if btn_up = '1' and channel < 7 then
          channel <= channel + 1;
        elsif btn_dn = '1' and channel > 0 then
          channel <= channel - 1;
        end if;
      end if;
    end if;
  end process;
end Behavioral;