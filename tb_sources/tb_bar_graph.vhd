library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bar_graph_tb is
end bar_graph_tb;

architecture Behavioral of bar_graph_tb is
  component bar_graph is
    Port (
      intensity_level : in  INTEGER range 0 to 10;
      bar_graph       : out STD_LOGIC_VECTOR(9 downto 0)
    );
  end component;

  signal intensity_level : INTEGER range 0 to 10 := 0;
  signal bar_output      : STD_LOGIC_VECTOR(9 downto 0);

  function vec_to_str(vec: STD_LOGIC_VECTOR) return string is
    variable result: string(1 to vec'length);
  begin
    for i in vec'range loop
      result(vec'length - i) := std_logic'image(vec(i))(2);
    end loop;
    return result;
  end function;

begin

  uut: bar_graph port map (
    intensity_level => intensity_level,
    bar_graph => bar_output
  );

  stim_proc: process
    variable expected : STD_LOGIC_VECTOR(9 downto 0);
  begin
    for level in 0 to 10 loop
      intensity_level <= level;
      wait for 10 ns;
      
      -- Generování oèekávané hodnoty
      expected := (others => '0');
      if level > 0 then
        expected(level-1 downto 0) := (others => '1');
      end if;
      
      -- Kontrola výstupu
      assert bar_output = expected
        report "Chyba u úrovnì " & integer'image(level) & 
               ": Oèekáváno " & vec_to_str(expected) & 
               ", Obdrzeno " & vec_to_str(bar_output)
        severity error;
    end loop;
    
    report "Testbench dokonèen. Chyba u úrovnì 10 je oèekávaná kvùli chybì v pùvodním kódu." severity note;
    wait;
  end process;

end Behavioral;