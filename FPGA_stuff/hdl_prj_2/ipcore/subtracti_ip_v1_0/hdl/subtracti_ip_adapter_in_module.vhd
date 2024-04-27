-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj_2\hdlsrc\ImageProcessingNoShift\subtracti_ip_adapter_in_module.vhd
-- Created: 2024-04-26 14:00:31
-- 
-- Generated by MATLAB 9.14 and HDL Coder 4.1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: subtracti_ip_adapter_in_module
-- Source Path: subtracti_ip/subtracti_ip_axi4_stream_video_slave/subtracti_ip_adapter_in/subtracti_ip_adapter_in_module
-- Hierarchy Level: 3
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY subtracti_ip_adapter_in_module IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        data_in                           :   IN    std_logic_vector(63 DOWNTO 0);  -- ufix64
        tvalid                            :   IN    std_logic;  -- ufix1
        sof                               :   IN    std_logic;  -- ufix1
        eol                               :   IN    std_logic;  -- ufix1
        image_length                      :   IN    std_logic_vector(12 DOWNTO 0);  -- ufix13
        image_height                      :   IN    std_logic_vector(12 DOWNTO 0);  -- ufix13
        hporch                            :   IN    std_logic_vector(12 DOWNTO 0);  -- ufix13
        vporch                            :   IN    std_logic_vector(12 DOWNTO 0);  -- ufix13
        data_out                          :   OUT   std_logic_vector(63 DOWNTO 0);  -- ufix64
        hstart                            :   OUT   std_logic;  -- ufix1
        hend                              :   OUT   std_logic;  -- ufix1
        vstart                            :   OUT   std_logic;  -- ufix1
        vend                              :   OUT   std_logic;  -- ufix1
        valid                             :   OUT   std_logic;  -- ufix1
        ready_out                         :   OUT   std_logic  -- ufix1
        );
END subtracti_ip_adapter_in_module;


ARCHITECTURE rtl OF subtracti_ip_adapter_in_module IS

  -- Signals
  SIGNAL cond54                           : std_logic;  -- ufix1
  SIGNAL image_height_unsigned            : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL vporch_unsigned                  : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL vlength_buf_1                    : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL vlength_1                        : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL cond41                           : std_logic;  -- ufix1
  SIGNAL image_length_unsigned            : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL hporch_unsigned                  : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL hlength_buf_1                    : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL hlength_1                        : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL numoflines_1                     : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL constant1                        : std_logic;  -- ufix1
  SIGNAL constant0                        : std_logic;  -- ufix1
  SIGNAL pixel_constant0                  : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL pixel_constant1                  : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL numofpixels_1                    : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL line_constant0                   : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL line_constant1                   : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL condition0                       : std_logic;  -- ufix1
  SIGNAL line_load_value0                 : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL line_load_value1                 : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL line_counter                     : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL larger1_relop1                   : std_logic;
  SIGNAL pixel_counter                    : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL larger_relop1                    : std_logic;
  SIGNAL less2_relop1                     : std_logic;
  SIGNAL cond51                           : std_logic;  -- ufix1
  SIGNAL less1_relop1                     : std_logic;
  SIGNAL less_relop1                      : std_logic;
  SIGNAL cond45                           : std_logic;  -- ufix1
  SIGNAL cond48                           : std_logic;  -- ufix1
  SIGNAL cond53                           : std_logic;  -- ufix1
  SIGNAL condition1                       : std_logic;  -- ufix1
  SIGNAL pixel_load_value0                : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL pixel_load_value1                : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL pixel_load_value2                : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL first_pixel_en                   : std_logic;  -- ufix1
  SIGNAL first_pixel_en_delay             : std_logic;  -- ufix1
  SIGNAL cond2                            : std_logic;  -- ufix1
  SIGNAL equal12_relop1                   : std_logic;
  SIGNAL cond1                            : std_logic;  -- ufix1
  SIGNAL equa31_relop1                    : std_logic;
  SIGNAL cond42                           : std_logic;  -- ufix1
  SIGNAL cond43                           : std_logic;  -- ufix1
  SIGNAL cond44                           : std_logic;  -- ufix1
  SIGNAL equa29_relop1                    : std_logic;
  SIGNAL equa28_relop1                    : std_logic;
  SIGNAL cond55                           : std_logic;  -- ufix1
  SIGNAL cond56                           : std_logic;  -- ufix1
  SIGNAL cond6                            : std_logic;  -- ufix1
  SIGNAL cond7                            : std_logic;  -- ufix1
  SIGNAL equal4_relop1                    : std_logic;
  SIGNAL cond9                            : std_logic;  -- ufix1
  SIGNAL hstart_reg                       : std_logic;  -- ufix1
  SIGNAL cond10                           : std_logic;  -- ufix1
  SIGNAL hstart_output                    : std_logic;  -- ufix1
  SIGNAL cond26                           : std_logic;  -- ufix1
  SIGNAL cond27                           : std_logic;  -- ufix1
  SIGNAL vstart_output_temp               : std_logic;  -- ufix1
  SIGNAL vstart_output                    : std_logic;  -- ufix1
  SIGNAL cond21                           : std_logic;  -- ufix1
  SIGNAL cond58                           : std_logic;  -- ufix1
  SIGNAL cond22                           : std_logic;  -- ufix1
  SIGNAL equa10_relop1                    : std_logic;
  SIGNAL equal14_relop1                   : std_logic;
  SIGNAL equa11_relop1                    : std_logic;
  SIGNAL equal13_relop1                   : std_logic;
  SIGNAL cond19                           : std_logic;  -- ufix1
  SIGNAL cond20                           : std_logic;  -- ufix1
  SIGNAL valid_reg                        : std_logic;  -- ufix1
  SIGNAL cond11                           : std_logic;  -- ufix1
  SIGNAL equa7_relop1                     : std_logic;
  SIGNAL cond13                           : std_logic;  -- ufix1
  SIGNAL equa8_relop1                     : std_logic;
  SIGNAL nonblank                         : std_logic;  -- ufix1
  SIGNAL cond23                           : std_logic;  -- ufix1
  SIGNAL cond57                           : std_logic;  -- ufix1
  SIGNAL cond25                           : std_logic;  -- ufix1
  SIGNAL cond59                           : std_logic;  -- ufix1
  SIGNAL valid_output                     : std_logic;  -- ufix1
  SIGNAL data_constant0                   : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_in_unsigned                 : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_reg                         : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_reg_temp                    : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_buf                         : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_buf_delay_1                 : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_buf_delay1                  : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_out_output                  : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL data_out_tmp                     : unsigned(63 DOWNTO 0);  -- ufix64
  SIGNAL hend_output_temp                 : std_logic;  -- ufix1
  SIGNAL hend_output                      : std_logic;  -- ufix1
  SIGNAL equa26_relop1                    : std_logic;
  SIGNAL vend_reg                         : std_logic;  -- ufix1
  SIGNAL vend_output                      : std_logic;  -- ufix1
  SIGNAL read_out_cond1                   : std_logic;  -- ufix1
  SIGNAL equa17_relop1                    : std_logic;
  SIGNAL pixel_counter_sub_1_sub_cast     : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL pixel_counter_1                  : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL equa19_relop1                    : std_logic;
  SIGNAL read_out_cond2                   : std_logic;  -- ufix1
  SIGNAL equa18_relop1                    : std_logic;
  SIGNAL read_out_cond3                   : std_logic;  -- ufix1
  SIGNAL equa20_relop1                    : std_logic;
  SIGNAL read_out_cond4                   : std_logic;  -- ufix1
  SIGNAL equa21_relop1                    : std_logic;
  SIGNAL equa22_relop1                    : std_logic;
  SIGNAL equa23_relop1                    : std_logic;
  SIGNAL equa24_relop1                    : std_logic;
  SIGNAL constant2                        : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL hlength_2                        : unsigned(12 DOWNTO 0);  -- ufix13
  SIGNAL read_out_cond5                   : std_logic;  -- ufix1
  SIGNAL equal25_relop1                   : std_logic;
  SIGNAL read_out_cond6                   : std_logic;  -- ufix1
  SIGNAL eol_tvalid                       : std_logic;  -- ufix1
  SIGNAL eol_buf                          : std_logic;  -- ufix1
  SIGNAL tvalid_not_1                     : std_logic;  -- ufix1
  SIGNAL equal1_relop1                    : std_logic;
  SIGNAL cond3                            : std_logic;  -- ufix1
  SIGNAL freeze                           : std_logic;  -- ufix1
  SIGNAL freeze_delay                     : std_logic;  -- ufix1
  SIGNAL cond5                            : std_logic;  -- ufix1
  SIGNAL read_out_cond8                   : std_logic;  -- ufix1
  SIGNAL read_out_output                  : std_logic;  -- ufix1

BEGIN
  cond54 <= sof AND tvalid;

  image_height_unsigned <= unsigned(image_height);

  vporch_unsigned <= unsigned(vporch);

  vlength_buf_1 <= image_height_unsigned + vporch_unsigned;

  vlength_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vlength_1 <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        vlength_1 <= vlength_buf_1;
      END IF;
    END IF;
  END PROCESS vlength_process;


  cond41 <= sof AND tvalid;

  image_length_unsigned <= unsigned(image_length);

  hporch_unsigned <= unsigned(hporch);

  hlength_buf_1 <= image_length_unsigned + hporch_unsigned;

  hlength_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hlength_1 <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        hlength_1 <= hlength_buf_1;
      END IF;
    END IF;
  END PROCESS hlength_process;


  numoflines_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        numoflines_1 <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        numoflines_1 <= image_height_unsigned;
      END IF;
    END IF;
  END PROCESS numoflines_process;


  constant1 <= '1';

  constant0 <= '0';

  pixel_constant0 <= to_unsigned(16#0000#, 13);

  pixel_constant1 <= to_unsigned(16#0001#, 13);

  numofpixels_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        numofpixels_1 <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        numofpixels_1 <= image_length_unsigned;
      END IF;
    END IF;
  END PROCESS numofpixels_process;


  line_constant0 <= to_unsigned(16#0000#, 13);

  line_constant1 <= to_unsigned(16#0001#, 13);

  
  line_load_value0 <= line_constant0 WHEN condition0 = '0' ELSE
      line_constant0;

  
  line_load_value1 <= line_load_value0 WHEN cond54 = '0' ELSE
      line_constant1;

  
  larger1_relop1 <= '1' WHEN line_counter > numoflines_1 ELSE
      '0';

  
  larger_relop1 <= '1' WHEN pixel_counter >= numofpixels_1 ELSE
      '0';

  
  less2_relop1 <= '1' WHEN pixel_counter < hlength_1 ELSE
      '0';

  cond51 <= less2_relop1 AND larger_relop1;

  
  less1_relop1 <= '1' WHEN pixel_counter < numofpixels_1 ELSE
      '0';

  
  less_relop1 <= '1' WHEN line_counter <= numoflines_1 ELSE
      '0';

  
  cond45 <= '1' WHEN pixel_counter > to_unsigned(16#0000#, 13) ELSE
      '0';

  cond48 <= tvalid AND (less1_relop1 AND (cond45 AND less_relop1));

  cond53 <= larger1_relop1 OR (cond48 OR cond51);

  
  pixel_load_value0 <= pixel_constant0 WHEN condition1 = '0' ELSE
      pixel_constant1;

  
  pixel_load_value1 <= pixel_load_value0 WHEN condition0 = '0' ELSE
      pixel_constant0;

  
  pixel_load_value2 <= pixel_load_value1 WHEN cond41 = '0' ELSE
      pixel_constant1;

  Delay8_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        first_pixel_en_delay <= '0';
      ELSIF enb = '1' THEN
        first_pixel_en_delay <= first_pixel_en;
      END IF;
    END IF;
  END PROCESS Delay8_process;


  
  cond2 <= first_pixel_en_delay WHEN tvalid = '0' ELSE
      constant1;

  
  equal12_relop1 <= '1' WHEN line_counter < numoflines_1 ELSE
      '0';

  cond1 <= equal12_relop1 AND (eol AND tvalid);

  
  first_pixel_en <= cond2 WHEN cond1 = '0' ELSE
      constant0;

  
  equa31_relop1 <= '1' WHEN pixel_counter = hlength_1 ELSE
      '0';

  condition1 <= equa31_relop1 AND first_pixel_en;

  
  cond42 <= constant0 WHEN condition1 = '0' ELSE
      constant1;

  
  cond43 <= cond42 WHEN condition0 = '0' ELSE
      constant1;

  
  cond44 <= cond43 WHEN cond41 = '0' ELSE
      constant1;

  -- Count limited, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  --  count to value  = 4096
  obj_pixel_counter_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        pixel_counter <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        IF cond44 = '1' THEN 
          pixel_counter <= pixel_load_value2;
        ELSIF cond53 = '1' THEN 
          IF pixel_counter >= to_unsigned(16#1000#, 13) THEN 
            pixel_counter <= to_unsigned(16#0000#, 13);
          ELSE 
            pixel_counter <= pixel_counter + to_unsigned(16#0001#, 13);
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS obj_pixel_counter_process;


  
  equa29_relop1 <= '1' WHEN pixel_counter = hlength_1 ELSE
      '0';

  
  equa28_relop1 <= '1' WHEN line_counter = vlength_1 ELSE
      '0';

  condition0 <= equa28_relop1 AND equa29_relop1;

  
  cond55 <= constant0 WHEN condition0 = '0' ELSE
      constant1;

  
  cond56 <= cond55 WHEN cond54 = '0' ELSE
      constant1;

  -- Count limited, Unsigned Counter
  --  initial value   = 0
  --  step value      = 1
  --  count to value  = 2160
  obj_pixel_count_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        line_counter <= to_unsigned(16#0000#, 13);
      ELSIF enb = '1' THEN
        IF cond56 = '1' THEN 
          line_counter <= line_load_value1;
        ELSIF condition1 = '1' THEN 
          IF line_counter >= to_unsigned(16#0870#, 13) THEN 
            line_counter <= to_unsigned(16#0000#, 13);
          ELSE 
            line_counter <= line_counter + to_unsigned(16#0001#, 13);
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS obj_pixel_count_process;


  
  cond6 <= '1' WHEN line_counter = to_unsigned(16#0001#, 13) ELSE
      '0';

  
  cond7 <= '1' WHEN pixel_counter = to_unsigned(16#0001#, 13) ELSE
      '0';

  
  equal4_relop1 <= '1' WHEN line_counter <= numoflines_1 ELSE
      '0';

  cond9 <= tvalid AND (cond7 AND equal4_relop1);

  hstart_reg <= sof AND tvalid;

  Delay10_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        cond10 <= '0';
      ELSIF enb = '1' THEN
        cond10 <= hstart_reg;
      END IF;
    END IF;
  END PROCESS Delay10_process;


  
  hstart_output <= cond9 WHEN cond6 = '0' ELSE
      cond10;

  
  cond26 <= '1' WHEN line_counter > to_unsigned(16#0001#, 13) ELSE
      '0';

  cond27 <= hstart_output AND cond26;

  vstart_output_temp <= sof AND tvalid;

  vstart_output_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vstart_output <= '0';
      ELSIF enb = '1' THEN
        vstart_output <= vstart_output_temp;
      END IF;
    END IF;
  END PROCESS vstart_output_delay_process;


  
  cond21 <= '1' WHEN pixel_counter = to_unsigned(16#0001#, 13) ELSE
      '0';

  
  cond58 <= '1' WHEN line_counter /= to_unsigned(16#0001#, 13) ELSE
      '0';

  cond22 <= cond58 AND (cond21 AND tvalid);

  
  equa10_relop1 <= '1' WHEN pixel_counter = hlength_1 ELSE
      '0';

  
  equal14_relop1 <= '1' WHEN vlength_1 /= numoflines_1 ELSE
      '0';

  
  equa11_relop1 <= '1' WHEN line_counter = vlength_1 ELSE
      '0';

  
  equal13_relop1 <= '1' WHEN hlength_1 /= numofpixels_1 ELSE
      '0';

  cond19 <= equal14_relop1 OR equal13_relop1;

  cond20 <= cond19 AND (equa10_relop1 AND equa11_relop1);

  valid_reg_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        valid_reg <= '0';
      ELSIF enb = '1' THEN
        valid_reg <= tvalid;
      END IF;
    END IF;
  END PROCESS valid_reg_delay_process;


  
  cond11 <= '1' WHEN pixel_counter > to_unsigned(16#0000#, 13) ELSE
      '0';

  
  equa7_relop1 <= '1' WHEN pixel_counter <= numofpixels_1 ELSE
      '0';

  
  cond13 <= '1' WHEN line_counter > to_unsigned(16#0000#, 13) ELSE
      '0';

  
  equa8_relop1 <= '1' WHEN line_counter <= numoflines_1 ELSE
      '0';

  nonblank <= equa8_relop1 AND (cond13 AND (cond11 AND equa7_relop1));

  cond23 <= valid_reg AND nonblank;

  
  cond57 <= cond23 WHEN cond21 = '0' ELSE
      constant0;

  
  cond25 <= cond57 WHEN cond20 = '0' ELSE
      valid_reg;

  
  cond59 <= cond25 WHEN cond22 = '0' ELSE
      constant1;

  
  valid_output <= cond59 WHEN vstart_output = '0' ELSE
      constant1;

  data_constant0 <= to_unsigned(0, 64);

  data_in_unsigned <= unsigned(data_in);

  input_data_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        data_reg <= to_unsigned(0, 64);
      ELSIF enb = '1' THEN
        data_reg <= data_in_unsigned;
      END IF;
    END IF;
  END PROCESS input_data_delay_process;


  
  data_reg_temp <= data_constant0 WHEN valid_output = '0' ELSE
      data_reg;

  data_buf_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        data_buf_delay_1 <= to_unsigned(0, 64);
      ELSIF enb = '1' THEN
        data_buf_delay_1 <= data_buf;
      END IF;
    END IF;
  END PROCESS data_buf_delay_process;


  
  data_buf <= data_buf_delay_1 WHEN tvalid = '0' ELSE
      data_in_unsigned;

  Delay11_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        data_buf_delay1 <= to_unsigned(0, 64);
      ELSIF enb = '1' THEN
        data_buf_delay1 <= data_buf;
      END IF;
    END IF;
  END PROCESS Delay11_process;


  
  data_out_output <= data_reg_temp WHEN cond27 = '0' ELSE
      data_buf_delay1;

  data_out_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        data_out_tmp <= to_unsigned(0, 64);
      ELSIF enb = '1' THEN
        data_out_tmp <= data_out_output;
      END IF;
    END IF;
  END PROCESS data_out_1_process;


  data_out <= std_logic_vector(data_out_tmp);

  hstart_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hstart <= '0';
      ELSIF enb = '1' THEN
        hstart <= hstart_output;
      END IF;
    END IF;
  END PROCESS hstart_1_process;


  hend_output_temp <= eol AND tvalid;

  hend_output_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hend_output <= '0';
      ELSIF enb = '1' THEN
        hend_output <= hend_output_temp;
      END IF;
    END IF;
  END PROCESS hend_output_delay_process;


  hend_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        hend <= '0';
      ELSIF enb = '1' THEN
        hend <= hend_output;
      END IF;
    END IF;
  END PROCESS hend_1_process;


  vstart_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vstart <= '0';
      ELSIF enb = '1' THEN
        vstart <= vstart_output;
      END IF;
    END IF;
  END PROCESS vstart_1_process;


  
  equa26_relop1 <= '1' WHEN line_counter = numoflines_1 ELSE
      '0';

  vend_reg <= equa26_relop1 AND (eol AND tvalid);

  vend_output_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vend_output <= '0';
      ELSIF enb = '1' THEN
        vend_output <= vend_reg;
      END IF;
    END IF;
  END PROCESS vend_output_delay_process;


  vend_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        vend <= '0';
      ELSIF enb = '1' THEN
        vend <= vend_output;
      END IF;
    END IF;
  END PROCESS vend_1_process;


  valid_1_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        valid <= '0';
      ELSIF enb = '1' THEN
        valid <= valid_output;
      END IF;
    END IF;
  END PROCESS valid_1_process;


  read_out_cond1 <= sof AND tvalid;

  
  equa17_relop1 <= '1' WHEN pixel_counter = hlength_1 ELSE
      '0';

  pixel_counter_sub_1_sub_cast <= '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & '0' & constant1;
  pixel_counter_1 <= numofpixels_1 - pixel_counter_sub_1_sub_cast;

  
  equa19_relop1 <= '1' WHEN pixel_counter < pixel_counter_1 ELSE
      '0';

  
  read_out_cond2 <= '1' WHEN pixel_counter = to_unsigned(16#0000#, 13) ELSE
      '0';

  
  equa18_relop1 <= '1' WHEN line_counter < numoflines_1 ELSE
      '0';

  read_out_cond3 <= equa17_relop1 AND equa18_relop1;

  
  equa20_relop1 <= '1' WHEN line_counter <= numoflines_1 ELSE
      '0';

  read_out_cond4 <= equa19_relop1 AND equa20_relop1;

  
  equa21_relop1 <= '1' WHEN pixel_counter = pixel_counter_1 ELSE
      '0';

  
  equa22_relop1 <= '1' WHEN line_counter < numoflines_1 ELSE
      '0';

  
  equa23_relop1 <= '1' WHEN line_counter = vlength_1 ELSE
      '0';

  
  equa24_relop1 <= '1' WHEN pixel_counter <= hlength_1 ELSE
      '0';

  constant2 <= to_unsigned(16#0002#, 13);

  hlength_2 <= hlength_1 - constant2;

  read_out_cond5 <= equa21_relop1 AND equa22_relop1;

  
  equal25_relop1 <= '1' WHEN pixel_counter > hlength_2 ELSE
      '0';

  read_out_cond6 <= equal25_relop1 AND (equa23_relop1 AND equa24_relop1);

  eol_tvalid <= eol AND tvalid;

  eol_buf_delay_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        eol_buf <= '0';
      ELSIF enb = '1' THEN
        eol_buf <= eol_tvalid;
      END IF;
    END IF;
  END PROCESS eol_buf_delay_process;


  tvalid_not_1 <=  NOT tvalid;

  
  equal1_relop1 <= '1' WHEN line_counter < numoflines_1 ELSE
      '0';

  cond3 <= equal1_relop1 AND (eol_buf AND tvalid_not_1);

  Delay9_process : PROCESS (clk)
  BEGIN
    IF clk'EVENT AND clk = '1' THEN
      IF reset = '1' THEN
        freeze_delay <= '0';
      ELSIF enb = '1' THEN
        freeze_delay <= freeze;
      END IF;
    END IF;
  END PROCESS Delay9_process;


  
  cond5 <= freeze_delay WHEN tvalid = '0' ELSE
      constant0;

  
  freeze <= cond5 WHEN cond3 = '0' ELSE
      constant1;

  read_out_cond8 <= tvalid_not_1 AND (equa21_relop1 AND equa26_relop1);

  read_out_output <= read_out_cond8 OR (freeze OR (read_out_cond6 OR (read_out_cond5 OR (read_out_cond4 OR (read_out_cond3 OR (read_out_cond1 OR read_out_cond2))))));

  ready_out <= read_out_output;

END rtl;

