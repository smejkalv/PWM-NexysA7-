library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_generator is
  Port (
    clk     : in  STD_LOGIC;
    reset   : in  STD_LOGIC;
    period  : in  UNSIGNED(31 downto 0);
    duty    : in  UNSIGNED(31 downto 0);
    pwm_out : out STD_LOGIC
  );
end pwm_generator;

architecture Behavioral of pwm_generator is
  signal counter : UNSIGNED(31 downto 0) := (others => '0');
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        counter <= (others => '0');
        pwm_out <= '0';
      else
        -- Inkrementace èítaèe
        if counter < period - 1 then
          counter <= counter + 1;
        else
          counter <= (others => '0');
        end if;

        -- Generování PWM
        if counter < duty then
          pwm_out <= '1';
        else
          pwm_out <= '0';
        end if;
      end if;
    end if;
  end process;
end Behavioral;