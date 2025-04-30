library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debouncer_tb is
end debouncer_tb;

architecture Behavioral of debouncer_tb is
  component debouncer is
    Generic (
      CLK_FREQ    : integer := 100_000_000;
      DEBOUNCE_MS : integer := 20
    );
    Port (
      clk      : in  STD_LOGIC;
      btn_in   : in  STD_LOGIC;
      btn_out  : out STD_LOGIC
    );
  end component;

  signal clk      : STD_LOGIC := '0';
  signal btn_in   : STD_LOGIC := '0';
  signal btn_out  : STD_LOGIC;

  constant CLK_PERIOD    : time := 10 ns;  -- 100 MHz
  constant DEBOUNCE_TIME : time := 200 ns; -- Zkrácený èas pro simulaci
  
  -- Pøepoèet parametrù pro zkrácenou simulaci
  constant TB_DEBOUNCE_MS : integer := DEBOUNCE_TIME / (1 ms / 1000); -- 0.2 ms
  constant TB_CLK_FREQ    : integer := 100_000_000; -- Pùvodní frekvence

begin

  uut: debouncer
    generic map (
      CLK_FREQ    => TB_CLK_FREQ,
      DEBOUNCE_MS => TB_DEBOUNCE_MS -- Nastavíme na 0.2 ms
    )
    port map (
      clk => clk,
      btn_in => btn_in,
      btn_out => btn_out
    );

  -- Generování hodinového signálu
  clk <= not clk after CLK_PERIOD/2;

  -- Stimulaèní proces
  stim_proc: process
  begin
    -- Inicializace
    btn_in <= '0';
    wait for 100 ns;

    -- Test stisku tlaèítka s bouncingem
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; -- Stabilní stav
  --  wait for DEBOUNCE_TIME + 2*CLK_PERIOD;

    assert btn_out = '1'
      report "CHYBA: Výstup není '1' po stisku"
      severity error;

    -- Test uvolnìní tlaèítka s bouncingem
    wait for 50 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '1'; wait for 15 ns;
    btn_in <= '0'; wait for 15 ns;
    btn_in <= '0'; -- Stabilní stav
    wait for DEBOUNCE_TIME + 2*CLK_PERIOD;

    assert btn_out = '0'
      report "CHYBA: Výstup není '0' po uvolnìní"
      severity error;

    report "Testbench end" severity note;
    std.env.stop;
    wait;
  end process;

end Behavioral;