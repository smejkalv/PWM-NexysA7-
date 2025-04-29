library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seg7disp is
  Port (
    number   : in  INTEGER range 0 to 7;
    segments : out STD_LOGIC_VECTOR(6 downto 0)
  );
end seg7disp;

architecture Behavioral of seg7disp is
begin
  process(number)
  begin
    case number is
      when 0 => segments <= "1001111"; -- 1
      when 1 => segments <= "0010010"; -- 2
      when 2 => segments <= "0000110"; -- 3
      when 3 => segments <= "1001100"; -- 4
      when 4 => segments <= "0100100"; -- 5
      when 5 => segments <= "0100000"; -- 6
      when 6 => segments <= "0001111"; -- 7
      when 7 => segments <= "0000000"; -- 8
      when others => segments <= "0111000";
    end case;
  end process;
end Behavioral;