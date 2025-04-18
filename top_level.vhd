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
  signal new_intensity   : INTEGER range 0 to 9;  -- Nov� sign�l pro hodnotu z intensity_control
  signal intensity_level : INTEGER range 0 to 9;  -- Zobrazovan� hodnota (p�evod z current_duty)
  type duty_array is array (0 to 7) of UNSIGNED(31 downto 0);
  signal duty_registers : duty_array := (others => to_unsigned(1000, 32));
  signal current_duty   : UNSIGNED(31 downto 0);
  constant PWM_PERIOD : UNSIGNED(31 downto 0) := to_unsigned(1000, 32); -- 10 �s (m�sto 20 ms)

begin
CH_SEL: channel_selector 
  port map (
    clk     => CLK,         -- CLK je sign�l v top-level
    reset   => RESET,       -- RESET je sign�l v top-level
    btn_up  => BTN_CH_UP,   -- BTN_CH_UP je vstup top-level
    btn_dn  => BTN_CH_DN,   -- BTN_CH_DN je vstup top-level
    channel => selected_channel -- selected_channel je intern� sign�l
  );

   -- P�evod current_duty na intenzitu (bez p�i�azen� do intensity_level)
  intensity_level <= to_integer((current_duty - 100000) / 10000) + 1;

  INT_CTRL: intensity_control port map (
    clk => CLK,
    reset => RESET,
    btn_up => BTN_DUTY_UP,
    btn_dn => BTN_DUTY_DN,
    intensity_level => new_intensity -- Toto je jedin� zdroj ��zen�!
  );

  
  PWM_GEN: for i in 0 to 7 generate
  PWM: pwm_generator
    port map (
      clk => CLK,
      reset => RESET,
      period => PWM_PERIOD, -- Pevn� perioda
      duty => duty_registers(i),
      pwm_out => PWM_OUT(i)
    );
end generate;

  SEG7: seg7disp port map (
    number => selected_channel,
    segments => SEGMENTS
  );

  BAR_SEG: bar_graph port map (
    intensity_level => intensity_level,
    bar_graph => BAR_DISP
  );

process(CLK)
begin
  if rising_edge(CLK) then
    if RESET = '1' then
      duty_registers <= (others => to_unsigned(1000, 32)); -- V�choz� 1.5ms
    else
      -- Omezen� rozsahu �rovn� (0�9 ? 100,000�190,000)
      if new_intensity >= 0 and new_intensity <= 9 then
        duty_registers(selected_channel) <= to_unsigned(100000 + new_intensity * 10000, 32);
      end if;
    end if;
  end if;
end process;
  
  --intensity_level <= to_integer((current_duty - 100000) / 10000) + 1;
  ANODE <= "11111110"; -- Aktivace prvn�ho 7-segmentu
end Structural;