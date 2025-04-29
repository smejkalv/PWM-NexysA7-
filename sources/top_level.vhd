library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_level is
  Port (
    CLK         : in  STD_LOGIC;
    RESET       : in  STD_LOGIC;
    BTN_CH_UP   : in  STD_LOGIC;
    BTN_CH_DN   : in  STD_LOGIC;
    BTN_DUTY_UP : in  STD_LOGIC;
    BTN_DUTY_DN : in  STD_LOGIC;
    PWM_OUT     : out STD_LOGIC_VECTOR(7 downto 0);
    SEGMENTS    : out STD_LOGIC_VECTOR(6 downto 0);
    ANODE       : out STD_LOGIC_VECTOR(7 downto 0);
    BAR_DISP    : out STD_LOGIC_VECTOR(9 downto 0)
  );
end top_level;

architecture Structural of top_level is
  signal deb_ch_up, deb_ch_dn, deb_duty_up, deb_duty_dn : STD_LOGIC;
  signal selected_channel : INTEGER range 0 to 7 := 0;
  signal incr, decr : STD_LOGIC;
  signal current_intensity : INTEGER range 0 to 10;
  
  type intensity_array is array (0 to 7) of INTEGER range 0 to 10;
  signal intensity_memory : intensity_array := (others => 5);
  
  component channel_selector is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      btn_up  : in  STD_LOGIC;
      btn_dn  : in  STD_LOGIC;
      channel : buffer INTEGER range 0 to 7
    );
  end component;

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

  component pwm_generator is
    Port (
      clk     : in  STD_LOGIC;
      reset   : in  STD_LOGIC;
      period  : in  UNSIGNED(31 downto 0);
      duty    : in  UNSIGNED(31 downto 0);
      pwm_out : out STD_LOGIC
    );
  end component;

  component seg7disp is
    Port (
      number   : in  INTEGER range 0 to 7;
      segments : out STD_LOGIC_VECTOR(6 downto 0)
    );
  end component;

  component bar_graph is
    Port (
      intensity_level : in  INTEGER range 0 to 10;
      bar_graph       : out STD_LOGIC_VECTOR(9 downto 0)
    );
  end component;

  type duty_array is array (0 to 7) of UNSIGNED(31 downto 0);
  signal duty_registers : duty_array;
  constant PWM_PERIOD : UNSIGNED(31 downto 0) := to_unsigned(100_000, 32); -- 1 kHz PWM
begin

  -- Debouncery
  DEB_CH_UP2: entity work.debouncer
    generic map (CLK_FREQ => 100_000_000, DEBOUNCE_MS => 20)
    port map (clk => CLK, btn_in => BTN_CH_UP, btn_out => deb_ch_up);

  DEB_CH_DN2: entity work.debouncer
    generic map (CLK_FREQ => 100_000_000, DEBOUNCE_MS => 20)
    port map (clk => CLK, btn_in => BTN_CH_DN, btn_out => deb_ch_dn);

  DEB_DUTY_UP2: entity work.debouncer
    generic map (CLK_FREQ => 100_000_000, DEBOUNCE_MS => 20)
    port map (clk => CLK, btn_in => BTN_DUTY_UP, btn_out => deb_duty_up);

  DEB_DUTY_DN2: entity work.debouncer
    generic map (CLK_FREQ => 100_000_000, DEBOUNCE_MS => 20)
    port map (clk => CLK, btn_in => BTN_DUTY_DN, btn_out => deb_duty_dn);

  -- Øízení kanálù
  CH_SEL: channel_selector
    port map (
      clk => CLK,
      reset => RESET,
      btn_up => deb_ch_up,
      btn_dn => deb_ch_dn,
      channel => selected_channel
    );

  -- Ovládání intenzity
  INT_CTRL: intensity_control
    port map (
      clk => CLK,
      reset => RESET,
      btn_up => deb_duty_up,
      btn_dn => deb_duty_dn,
      incr => incr,
      decr => decr
    );

  -- Generátory PWM pro každý kanál
  PWM_GEN: for i in 0 to 7 generate
    PWM: pwm_generator
      port map (
        clk => CLK,
        reset => RESET,
        period => PWM_PERIOD,
        duty => duty_registers(i),
        pwm_out => PWM_OUT(i)
      );
  end generate;

  -- Zobrazení èísla kanálu
  SEG7: seg7disp port map (
    number => selected_channel,
    segments => SEGMENTS
  );

  -- Zobrazení intenzity
  BAR_SEG: bar_graph port map (
    intensity_level => current_intensity,
    bar_graph => BAR_DISP
  );

  -- Aktualizace intenzity
  process(CLK)
  begin
    if rising_edge(CLK) then
      if RESET = '1' then
        intensity_memory <= (others => 5);
        current_intensity <= 5;
      else
        -- Aktualizace pamìti intenzit
        if incr = '1' and intensity_memory(selected_channel) < 10 then
          intensity_memory(selected_channel) <= intensity_memory(selected_channel) + 1;
        elsif decr = '1' and intensity_memory(selected_channel) > 0 then
          intensity_memory(selected_channel) <= intensity_memory(selected_channel) - 1;
        end if;
        
        -- Aktualizace zobrazované intenzity
        current_intensity <= intensity_memory(selected_channel);
      end if;
    end if;
  end process;

  -- Pøevod intenzity na duty cycle
  process(intensity_memory)
  begin
    for i in 0 to 7 loop
      duty_registers(i) <= to_unsigned(
        (to_integer(PWM_PERIOD) * intensity_memory(i)) / 10, 
        32
      );
    end loop;
  end process;

  ANODE <= "11111110"; -- Aktivní první 7-segment
end Structural;