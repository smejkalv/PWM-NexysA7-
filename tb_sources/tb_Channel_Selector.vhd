library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity channel_selector_tb is
end channel_selector_tb;

architecture Behavioral of channel_selector_tb is
  component channel_selector is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      btn_up  : in  STD_LOGIC;
      btn_dn  : in  STD_LOGIC;
      channel : buffer INTEGER range 0 to 7
    );
  end component;

  signal clk     : STD_LOGIC := '0';
  signal reset   : STD_LOGIC := '1';
  signal btn_up  : STD_LOGIC := '0';
  signal btn_dn  : STD_LOGIC := '0';
  signal channel : INTEGER range 0 to 7;

  constant CLK_PERIOD : time := 10 ns; -- 100 MHz
  signal simulation_ended : boolean := false;
begin

  uut: channel_selector
    port map (
      clk => clk,
      reset => reset,
      btn_up => btn_up,
      btn_dn => btn_dn,
      channel => channel
    );

  -- Generování hodinového signálu
  clk <= not clk after CLK_PERIOD/2 when not simulation_ended else '0';

  -- Testovací proces
  stim_proc: process
  begin
    -- Poèáteèní reset
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait for 20 ns;

    -- Test 1: Základní inkrementace
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 1
      report "Chyba 1: Channel neinkrementován" severity error;

    -- Test 2: Vícenásobná inkrementace
    for i in 1 to 5 loop
      btn_up <= '1'; wait for 20 ns;
      btn_up <= '0'; wait for 40 ns;
    end loop;
    assert channel = 6
      report "Chyba 2: Chybná inkrementace" severity error;

    -- Test 3: Maximální hodnota (7)
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 7
      report "Chyba 3: Nedosazeno maxima" severity error;

    -- Test 4: Pokus o pøekroèení maxima
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 7
      report "Chyba 4: Pøekroèeno maximum" severity error;

    -- Test 5: Základní dekrementace
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 6
      report "Chyba 5: Channel nedekrementován" severity error;

    -- Test 6: Vícenásobná dekrementace
    for i in 1 to 5 loop
      btn_dn <= '1'; wait for 20 ns;
      btn_dn <= '0'; wait for 40 ns;
    end loop;
    assert channel = 1
      report "Chyba 6: Chybná dekrementace" severity error;

    -- Test 7: Minimální hodnota (0)
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 7: Nedosazeno minima" severity error;

    -- Test 8: Pokus o pøekroèení minima
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 8: Pøekroèeno minimum" severity error;

    -- Test 9: Reset bìhem provozu
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 20 ns;
    reset <= '1'; wait for 50 ns;
    assert channel = 0
      report "Chyba 9: Reset nefunguje" severity error;
    reset <= '0';

    -- Test 10: Simultánní stisk obou tlaèítek
    btn_up <= '1';
    btn_dn <= '1'; wait for 20 ns;
    btn_up <= '0';
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 10: Neoèekávaná reakce na obì tlaèítka" severity error;

    report "Testbench end";
    simulation_ended <= true;
    wait;
  end process;

end Behavioral;