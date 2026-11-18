`timescale 1ns/1ps
module native_replay;
wire  SPI_MISO;
wire [1:0] buttons;
wire [9:0] conf_addr;
wire [6:0] core_mod;
wire [1:0] img_mounted;
wire [31:0] img_size;
wire [31:0] joystick_0;
wire [31:0] joystick_1;
wire [31:0] joystick_2;
wire [31:0] joystick_3;
wire [31:0] joystick_4;
wire [15:0] joystick_analog_0;
wire [15:0] joystick_analog_1;
wire [7:0] key_code;
wire  key_extended;
wire  key_pressed;
wire  key_strobe;
wire [7:0] mouse_flags;
wire  mouse_idx;
wire  mouse_strobe;
wire [8:0] mouse_x;
wire [8:0] mouse_y;
wire [3:0] mouse_z;
wire  no_csync;
wire  ps2_kbd_clk;
wire  ps2_kbd_data;
wire  ps2_mouse_clk;
wire  ps2_mouse_data;
wire [63:0] rtc;
wire  scandoubler_disable;
wire  sd_ack;
wire  sd_ack_conf;
wire [8:0] sd_buff_addr;
wire  sd_din_strobe;
wire [7:0] sd_dout;
wire  sd_dout_strobe;
wire [31:0] status;
wire [1:0] switches;
wire  ypbpr;
integer time_index=0, scenario=0, seed=1, pixel_count;
logic  SPI_CLK;
logic  SPI_MOSI;
logic  SPI_SS_IO;
logic  clk_sd;
logic  clk_sys;
logic [7:0] conf_chr;
logic [-1:0] conf_str;
logic  sd_conf;
logic [7:0] sd_din;
logic [31:0] sd_lba;
logic [1:0] sd_rd;
logic  sd_sdhc;
logic [1:0] sd_wr;
logic [7:0] serial_data;
logic  serial_strobe;
task advance(integer duration);
  repeat(duration) begin
    time_index++;
    if (time_index%5==0) clk_sys=~clk_sys; if (time_index%7==0) clk_sd=~clk_sd;
    send_event();
  end
endtask
task spi_byte(input logic [7:0] value);
  for(integer bit_index=7;bit_index>=0;bit_index--) begin
    SPI_CLK=0; SPI_MOSI=value[bit_index]; advance(50);
    SPI_CLK=1; advance(50);
  end
endtask
`ifdef REPLAY_MODEL
dvbench_model
`else
user_io
`endif
 unit(.SPI_CLK(SPI_CLK),.SPI_MISO(SPI_MISO),.SPI_MOSI(SPI_MOSI),.SPI_SS_IO(SPI_SS_IO),.buttons(buttons),.clk_sd(clk_sd),.clk_sys(clk_sys),.conf_addr(conf_addr),.conf_chr(conf_chr),.conf_str(conf_str),.core_mod(core_mod),.img_mounted(img_mounted),.img_size(img_size),.joystick_0(joystick_0),.joystick_1(joystick_1),.joystick_2(joystick_2),.joystick_3(joystick_3),.joystick_4(joystick_4),.joystick_analog_0(joystick_analog_0),.joystick_analog_1(joystick_analog_1),.key_code(key_code),.key_extended(key_extended),.key_pressed(key_pressed),.key_strobe(key_strobe),.mouse_flags(mouse_flags),.mouse_idx(mouse_idx),.mouse_strobe(mouse_strobe),.mouse_x(mouse_x),.mouse_y(mouse_y),.mouse_z(mouse_z),.no_csync(no_csync),.ps2_kbd_clk(ps2_kbd_clk),.ps2_kbd_data(ps2_kbd_data),.ps2_mouse_clk(ps2_mouse_clk),.ps2_mouse_data(ps2_mouse_data),.rtc(rtc),.scandoubler_disable(scandoubler_disable),.sd_ack(sd_ack),.sd_ack_conf(sd_ack_conf),.sd_buff_addr(sd_buff_addr),.sd_conf(sd_conf),.sd_din(sd_din),.sd_din_strobe(sd_din_strobe),.sd_dout(sd_dout),.sd_dout_strobe(sd_dout_strobe),.sd_lba(sd_lba),.sd_rd(sd_rd),.sd_sdhc(sd_sdhc),.sd_wr(sd_wr),.serial_data(serial_data),.serial_strobe(serial_strobe),.status(status),.switches(switches),.ypbpr(ypbpr));
logic [69:0] previous_inputs; bit started=0;
task send_event(); #0.1; if(!started || {SPI_CLK,SPI_MOSI,SPI_SS_IO,clk_sd,clk_sys,conf_chr,conf_str,sd_conf,sd_din,sd_lba,sd_rd,sd_sdhc,sd_wr,serial_data,serial_strobe} !== previous_inputs) $display("TRACE %h %h",{SPI_CLK,SPI_MOSI,SPI_SS_IO,clk_sd,clk_sys,conf_chr,conf_str,sd_conf,sd_din,sd_lba,sd_rd,sd_sdhc,sd_wr,serial_data,serial_strobe},{SPI_MISO,buttons,conf_addr,core_mod,img_mounted,img_size,joystick_0,joystick_1,joystick_2,joystick_3,joystick_4,joystick_analog_0,joystick_analog_1,key_code,key_extended,key_pressed,key_strobe,mouse_flags,mouse_idx,mouse_strobe,mouse_x,mouse_y,mouse_z,no_csync,ps2_kbd_clk,ps2_kbd_data,ps2_mouse_clk,ps2_mouse_data,rtc,scandoubler_disable,sd_ack,sd_ack_conf,sd_buff_addr,sd_din_strobe,sd_dout,sd_dout_strobe,status,switches,ypbpr}); previous_inputs={SPI_CLK,SPI_MOSI,SPI_SS_IO,clk_sd,clk_sys,conf_chr,conf_str,sd_conf,sd_din,sd_lba,sd_rd,sd_sdhc,sd_wr,serial_data,serial_strobe}; started=1; #0.9; endtask
initial begin
SPI_CLK='0;
SPI_MOSI='0;
SPI_SS_IO='0;
clk_sd='0;
clk_sys='0;
conf_chr='0;
conf_str='0;
sd_conf='0;
sd_din='0;
sd_lba='0;
sd_rd='0;
sd_sdhc='0;
sd_wr='0;
serial_data='0;
serial_strobe='0;
if($value$plusargs("ntb_random_seed=%d",seed)) begin end
      SPI_CLK=1; SPI_SS_IO=1; conf_chr=8'h9d; sd_conf=1; sd_sdhc=1; sd_din=8'hc7;
      advance(400);
      for(integer run_index=0;run_index<12;run_index++) begin
        scenario=run_index;
        for(integer joy_index=0;joy_index<5;joy_index++) begin
          SPI_SS_IO=0; advance(100); spi_byte(8'h60+joy_index);
          for(integer octet=0;octet<6;octet++) spi_byte(run_index*17+octet*29+seed);
          SPI_SS_IO=1; advance(400);
        end
        SPI_SS_IO=0; advance(100); spi_byte(8'h01); spi_byte(seed+run_index*19); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1a); spi_byte(run_index); spi_byte(8'ha3^seed); spi_byte(8'h75^run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h15); spi_byte(1); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h15); spi_byte(0); SPI_SS_IO=1; advance(400);
        for(integer octet=0;octet<run_index+1;octet++) begin
          serial_data=octet*13+seed; serial_strobe=1; advance(20); serial_strobe=0; advance(20);
        end
        SPI_SS_IO=0; advance(100); spi_byte(8'h1b); for(integer octet=0;octet<30;octet++) spi_byte(0); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1e); for(integer octet=0;octet<6;octet++) spi_byte((seed+octet*31+run_index)&8'hfe); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h22); for(integer octet=0;octet<10;octet++) spi_byte(seed+octet+run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h21); spi_byte(8'hff-run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h05); spi_byte(8'he0); spi_byte(8'hf0); spi_byte(8'h75^run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h05); spi_byte(8'h1c+run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h70+(run_index%2)); spi_byte(8'h38^run_index); spi_byte(8'h80^seed); spi_byte(8'hfe-run_index); spi_byte(8'hfa); SPI_SS_IO=1; advance(400);
        sd_lba=32'h12345678^(seed*run_index); sd_rd=run_index%4; sd_wr=(run_index+1)%4;
        SPI_SS_IO=0; advance(100); spi_byte(8'h16); sd_lba=32'habcdef12; for(integer octet=0;octet<8;octet++) spi_byte(0); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h14); for(integer octet=0;octet<8;octet++) begin conf_chr=octet*11+seed; spi_byte(0); end SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1c); spi_byte(run_index); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h1d); for(integer octet=0;octet<6;octet++) spi_byte(octet*53+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h17); for(integer octet=0;octet<(run_index==11 ? 1030 : 7);octet++) spi_byte(octet+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h19); for(integer octet=0;octet<8;octet++) spi_byte(octet*7+seed); SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'h18); for(integer octet=0;octet<(run_index==11 ? 520 : 7);octet++) begin sd_din=octet+seed; spi_byte(0); end SPI_SS_IO=1; advance(400);
        SPI_SS_IO=0; advance(100); spi_byte(8'hff); spi_byte(8'h5a); SPI_SS_IO=1; advance(400);
      end


      for(integer length_index=0;length_index<5;length_index++) begin
        scenario=12+length_index;
        SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(1);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h15);spi_byte(0);SPI_SS_IO=1;advance(400);
        pixel_count=length_index==0 ? 0 : length_index==1 ? 1 : length_index==2 ? 63 : length_index==3 ? 64 : 65;
        for(integer octet=0;octet<pixel_count;octet++) begin
          serial_data=octet*19+seed;serial_strobe=1;advance(20);serial_strobe=0;advance(20);
        end
        SPI_SS_IO=0;advance(100);spi_byte(8'h1b);for(integer octet=0;octet<140;octet++) spi_byte(0);SPI_SS_IO=1;advance(400);
      end
      for(integer index=0;index<16;index++) begin
        scenario=17;
        SPI_SS_IO=0;advance(100);spi_byte(8'h1a);spi_byte(index);spi_byte(seed^index);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h1a);spi_byte(index);spi_byte(seed+index);spi_byte(8'h80^index);spi_byte(0);SPI_SS_IO=1;advance(400);
      end
      for(integer joy_index=0;joy_index<5;joy_index++) begin
        scenario=18;
        for(integer length=1;length<5;length++) begin
          SPI_SS_IO=0;advance(100);spi_byte(8'h60+joy_index);for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*47);SPI_SS_IO=1;advance(400);
        end
      end
      for(integer length=0;length<6;length++) begin
        scenario=19;
        SPI_SS_IO=0;advance(100);spi_byte(8'h70+(length%2));for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*31);SPI_SS_IO=1;advance(400);
        SPI_SS_IO=0;advance(100);spi_byte(8'h1d);for(integer octet=0;octet<length;octet++) spi_byte(seed+octet*41);SPI_SS_IO=1;advance(400);
      end
      scenario=20;
      SPI_SS_IO=0;advance(100);spi_byte(8'h05);spi_byte(8'he0);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h05);spi_byte(8'h1c);spi_byte(8'hf0);spi_byte(8'hf0);spi_byte(8'h75);SPI_SS_IO=1;advance(400);
      for(integer drive=0;drive<2;drive++) begin
        sd_wr=0;advance(100);sd_wr=1<<drive;advance(100);sd_wr=0;advance(100);
      end
      scenario=21;
      SPI_SS_IO=0;advance(100);spi_byte(8'h17);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'h19);SPI_SS_IO=1;advance(400);
      SPI_SS_IO=0;advance(100);spi_byte(8'hff);SPI_CLK=0;SPI_MOSI=1;advance(50);SPI_CLK=1;advance(50);SPI_SS_IO=1;advance(400);
      scenario=22;
      for(integer identity=0;identity<2;identity++) begin
        for(integer polarity=0;polarity<2;polarity++) begin
          SPI_SS_IO=0;advance(100);spi_byte(8'h70+identity);
          spi_byte(polarity ? 8'h28 : 8'h18);
          spi_byte(8'h83^seed);spi_byte(8'h46+seed);spi_byte(8'h0a);
          SPI_SS_IO=1;advance(400);
        end
      end
$display("NATIVE_PROBE_COMPLETED"); $finish; end
endmodule
