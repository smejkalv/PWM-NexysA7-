library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bar_graph is
  Port (
    intensity_level : in  INTEGER range 0 to 9;
    bar_graph       : out STD_LOGIC_VECTOR(9 downto 0)
  );
end bar_graph;

architecture Behavioral of bar_graph is
begin
  process(intensity_level)
  begin
    bar_graph <= (others => '0');
    for i in 0 to 9 loop
      if i < intensity_level then
        bar_graph(i) <= '1';
      end if;
    end loop;
  end process;
end Behavioral;