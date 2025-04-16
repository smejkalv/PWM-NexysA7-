library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity channel_selector is
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    btn_up  : in  STD_LOGIC; -- Debounced signal
    btn_dn  : in  STD_LOGIC; -- Debounced signal
    channel : buffer INTEGER range 0 to 7
  );
end channel_selector;

architecture Behavioral of channel_selector is
  signal btn_up_prev, btn_dn_prev : STD_LOGIC := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        channel <= 0;
        btn_up_prev <= '0';
        btn_dn_prev <= '0';
      else
        -- Detekce vzestupné hrany pro btn_up
        if btn_up = '1' and btn_up_prev = '0' and channel < 7 then
          channel <= channel + 1;
        end if;
        
        -- Detekce vzestupné hrany pro btn_dn
        if btn_dn = '1' and btn_dn_prev = '0' and channel > 0 then
          channel <= channel - 1;
        end if;
        
        btn_up_prev <= btn_up;
        btn_dn_prev <= btn_dn;
      end if;
    end if;
  end process;
end Behavioral;