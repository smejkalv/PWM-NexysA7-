library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity intensity_control_tb is
end intensity_control_tb;

architecture Behavioral of intensity_control_tb is
  component intensity_control is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      btn_up  : in  STD_LOGIC;
      btn_dn  : in  STD_LOGIC;
      incr    : out STD_LOGIC;
      decr    : out STD_LOGIC
    );
  end component;

  signal clk     : STD_LOGIC := '0';
  signal reset   : STD_LOGIC := '1';
  signal btn_up  : STD_LOGIC := '0';
  signal btn_dn  : STD_LOGIC := '0';
  signal incr    : STD_LOGIC;
  signal decr    : STD_LOGIC;

  constant CLK_PERIOD : time := 10 ns;
  signal incr_counter : natural := 0;
  signal decr_counter : natural := 0;
begin

  uut: intensity_control
    port map (
      clk => clk,
      reset => reset,
      btn_up => btn_up,
      btn_dn => btn_dn,
      incr => incr,
      decr => decr
    );

  -- Poèitadla pulsù
  process(clk)
  begin
    if rising_edge(clk) then
      if incr = '1' then
        incr_counter <= incr_counter + 1;
      end if;
      if decr = '1' then
        decr_counter <= decr_counter + 1;
      end if;
    end if;
  end process;

  clk <= not clk after CLK_PERIOD/2;

  stim_proc: process
    procedure pulse(signal btn : out STD_LOGIC; duration : time) is
    begin
      btn <= '1';
      wait for duration;
      btn <= '0';
    end procedure;
  begin
    -- Test 0: Reset
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    wait for 20 ns;
    assert incr = '0' and decr = '0'
      report "Chyba 0: Reset nefunguje" severity error;

    -- Test 1: Pulz btn_up
    pulse(btn_up, CLK_PERIOD*2);
    wait for CLK_PERIOD*3;
    assert incr_counter = 1 and decr_counter = 0
      report "Chyba 1: Chybný poèet incr pulsù" severity error;

    -- Test 2: Pulz btn_dn
    pulse(btn_dn, CLK_PERIOD*2);
    wait for CLK_PERIOD*3;
    assert decr_counter = 1 and incr_counter = 1
      report "Chyba 2: Chybný poèet decr pulsù" severity error;

    -- Test 3: Dlouhý pulz
    btn_up <= '1';
    wait for CLK_PERIOD*5;
    btn_up <= '0';
    wait for CLK_PERIOD*4;
    assert incr_counter = 2
      report "Chyba 3: Vícenásobné pulsy" severity error;

    -- Test 4: Simultánní stisk
    pulse(btn_up, CLK_PERIOD);
    pulse(btn_dn, CLK_PERIOD);
    wait for CLK_PERIOD*3;
    assert incr_counter = 3 and decr_counter = 2
      report "Chyba 4: Chyba pøi simultánním stisku" severity error;

    report "Testbench end";
    std.env.stop;
    wait;
  end process;

end Behavioral;