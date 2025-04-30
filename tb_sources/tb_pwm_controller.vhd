library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm_generator_tb is
end pwm_generator_tb;

architecture Behavioral of pwm_generator_tb is
  component pwm_generator is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      period  : in  UNSIGNED(31 downto 0);
      duty    : in  UNSIGNED(31 downto 0);
      pwm_out : out STD_LOGIC
    );
  end component;

  signal clk     : STD_LOGIC := '0';
  signal reset   : STD_LOGIC := '1';
  signal period  : UNSIGNED(31 downto 0) := (others => '0');
  signal duty    : UNSIGNED(31 downto 0) := (others => '0');
  signal pwm_out : STD_LOGIC;

  constant CLK_PERIOD : time := 10 ns; -- 100 MHz
  signal test_case    : natural := 0;
begin

  uut: pwm_generator port map (
    clk => clk,
    reset => reset,
    period => period,
    duty => duty,
    pwm_out => pwm_out
  );

  clk <= not clk after CLK_PERIOD/2;

  stim_proc: process
    procedure run_cycle(cycles: natural) is
    begin
      for i in 1 to cycles loop
        wait until rising_edge(clk);
      end loop;
    end procedure;
  begin
    -- Test 0: Reset test
    reset <= '1';
    period <= to_unsigned(4, 32);
    duty <= to_unsigned(2, 32);
    wait for 100 ns;
    assert pwm_out = '0' report "Test 0: Reset failed" severity error;
    test_case <= 1;

    -- Test 1: Basic PWM (50% duty)
    reset <= '0';
    run_cycle(4);
    assert pwm_out = '0' report "Test 1: End cycle failed" severity error;
    test_case <= 2;

    -- Test 2: 0% duty cycle
    duty <= to_unsigned(0, 32);
    run_cycle(4);
    assert pwm_out = '0' report "Test 2: 0% duty failed" severity error;
    test_case <= 3;

    -- Test 3: 100% duty cycle
    duty <= to_unsigned(4, 32);
    run_cycle(4);
    assert pwm_out = '1' report "Test 3: 100% duty failed" severity error;
    test_case <= 4;


    -- Test 4: duty change
    duty <= to_unsigned(0, 32);
    run_cycle(4);
    assert pwm_out = '1' report "Test 5: change failed" severity error;
    test_case <= 5;

    -- Test 5: Reset during operation
    reset <= '1';
    wait for CLK_PERIOD;
    assert pwm_out = '0' report "Test 6: Active reset failed" severity error;
    reset <= '0';
    test_case <= 6;

    report "Testbench end";
    std.env.stop;
    wait;
  end process;

end Behavioral;