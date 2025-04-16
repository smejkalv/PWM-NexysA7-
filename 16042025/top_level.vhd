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
    BAR_DISP   : out STD_LOGIC_VECTOR(9 downto 0)
  );
end top_level;

architecture Structural of top_level is
signal deb_ch_up, deb_ch_dn, deb_duty_up, deb_duty_dn : STD_LOGIC;
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
      clk             : in  STD_LOGIC;
      reset           : in  STD_LOGIC;
      btn_up          : in  STD_LOGIC;
      btn_dn          : in  STD_LOGIC;
      intensity_level : out INTEGER range 1 to 10
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
      intensity_level : in  INTEGER range 1 to 10;
      bar_graph       : out STD_LOGIC_VECTOR(9 downto 0)
    );
  end component;


  signal selected_channel : INTEGER range 0 to 7 := 0;
  signal new_intensity   : INTEGER range 0 to 9;  -- Nový signál pro hodnotu z intensity_control
  signal intensity_level : INTEGER range 0 to 9;  -- Zobrazovaná hodnota (pøevod z current_duty)
  type duty_array is array (0 to 7) of UNSIGNED(31 downto 0);
  signal duty_registers : duty_array := (others => to_unsigned(1000, 32));
  signal current_duty   : UNSIGNED(31 downto 0);
  constant PWM_PERIOD : UNSIGNED(31 downto 0) := to_unsigned(1000, 32); -- 10 µs (místo 20 ms)
begin
  -- Debouncery pro všechna tlaèítka
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

  -- Instance komponent s debounced signály
  CH_SEL: entity work.channel_selector
    port map (
      clk => CLK,
      reset => RESET,
      btn_up => deb_ch_up,
      btn_dn => deb_ch_dn,
      channel => selected_channel
    );

  INT_CTRL: entity work.intensity_control
    port map (
      clk => CLK,
      reset => RESET,
      btn_up => deb_duty_up,
      btn_dn => deb_duty_dn,
      intensity_level => new_intensity
    );


  
  PWM_GEN: for i in 0 to 7 generate
  PWM: pwm_generator
    port map (
      clk => CLK,
      reset => RESET,
      period => PWM_PERIOD, -- Pevná perioda
      duty => duty_registers(i),
      pwm_out => PWM_OUT(i)
    );
end generate;

  SEG7: seg7disp port map (
    number => selected_channel,
    segments => SEGMENTS
  );

  BAR_SEG: bar_graph port map (
    intensity_level => new_intensity,
    bar_graph => BAR_DISP
  );

process(CLK)
begin
  if rising_edge(CLK) then
    if RESET = '1' then
      duty_registers <= (others => to_unsigned(1000, 32)); -- Výchozí 1.5ms
    else
      -- Omezení rozsahu úrovnì (0–9 ? 100,000–190,000)
      if new_intensity >= 0 and new_intensity <= 9 then
        duty_registers(selected_channel) <= to_unsigned(100000 + new_intensity * 10000, 32);
      end if;
    end if;
  end if;
end process;
  
  --intensity_level <= to_integer((current_duty - 100000) / 10000) + 1;
  ANODE <= "11111110"; -- Aktivace prvního 7-segmentu
end Structural;