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

  -- Generov�n� hodinov�ho sign�lu
  clk <= not clk after CLK_PERIOD/2 when not simulation_ended else '0';

  -- Testovac� proces
  stim_proc: process
  begin
    -- Po��te�n� reset
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait for 20 ns;

    -- Test 1: Z�kladn� inkrementace
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 1
      report "Chyba 1: Channel neinkrementov�n" severity error;

    -- Test 2: V�cen�sobn� inkrementace
    for i in 1 to 5 loop
      btn_up <= '1'; wait for 20 ns;
      btn_up <= '0'; wait for 40 ns;
    end loop;
    assert channel = 6
      report "Chyba 2: Chybn� inkrementace" severity error;

    -- Test 3: Maxim�ln� hodnota (7)
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 7
      report "Chyba 3: Nedosazeno maxima" severity error;

    -- Test 4: Pokus o p�ekro�en� maxima
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 40 ns;
    assert channel = 7
      report "Chyba 4: P�ekro�eno maximum" severity error;

    -- Test 5: Z�kladn� dekrementace
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 6
      report "Chyba 5: Channel nedekrementov�n" severity error;

    -- Test 6: V�cen�sobn� dekrementace
    for i in 1 to 5 loop
      btn_dn <= '1'; wait for 20 ns;
      btn_dn <= '0'; wait for 40 ns;
    end loop;
    assert channel = 1
      report "Chyba 6: Chybn� dekrementace" severity error;

    -- Test 7: Minim�ln� hodnota (0)
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 7: Nedosazeno minima" severity error;

    -- Test 8: Pokus o p�ekro�en� minima
    btn_dn <= '1'; wait for 20 ns;
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 8: P�ekro�eno minimum" severity error;

    -- Test 9: Reset b�hem provozu
    btn_up <= '1'; wait for 20 ns;
    btn_up <= '0'; wait for 20 ns;
    reset <= '1'; wait for 50 ns;
    assert channel = 0
      report "Chyba 9: Reset nefunguje" severity error;
    reset <= '0';

    -- Test 10: Simult�nn� stisk obou tla��tek
    btn_up <= '1';
    btn_dn <= '1'; wait for 20 ns;
    btn_up <= '0';
    btn_dn <= '0'; wait for 40 ns;
    assert channel = 0
      report "Chyba 10: Neo�ek�van� reakce na ob� tla��tka" severity error;

    report "Testbench end";
    simulation_ended <= true;
    wait;
  end process;

end Behavioral;