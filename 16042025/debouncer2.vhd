library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer is
  Generic (
    CLK_FREQ    : integer := 100_000_000;  -- 100 MHz
    DEBOUNCE_MS : integer := 20            -- 20 ms
  );
  Port (
    clk      : in  STD_LOGIC;
    btn_in   : in  STD_LOGIC;
    btn_out  : out STD_LOGIC
  );
end debouncer;

architecture Behavioral of debouncer is
  constant MAX_COUNT : integer := (CLK_FREQ / 1000) * DEBOUNCE_MS;
  signal count : integer range 0 to MAX_COUNT := 0;
  signal stable: STD_LOGIC := '0';
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if btn_in /= stable then
        count <= 0;
        stable <= btn_in;
      elsif count < MAX_COUNT then
        count <= count + 1;
      else
        btn_out <= stable;
      end if;
    end if;
  end process;
end Behavioral;