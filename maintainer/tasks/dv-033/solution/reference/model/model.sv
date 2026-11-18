`timescale 1ns/1ps
module dvbench_model #(parameter STRLEN=0, parameter PS2DIV=100, parameter ROM_DIRECT_UPLOAD=0)(
input logic  SPI_CLK,
output logic  SPI_MISO,
input logic  SPI_MOSI,
input logic  SPI_SS_IO,
output logic [1:0] buttons,
input logic  clk_sd,
input logic  clk_sys,
output logic [9:0] conf_addr,
input logic [7:0] conf_chr,
input logic [-1:0] conf_str,
output logic [6:0] core_mod,
output logic [1:0] img_mounted,
output logic [31:0] img_size,
output logic [31:0] joystick_0,
output logic [31:0] joystick_1,
output logic [31:0] joystick_2,
output logic [31:0] joystick_3,
output logic [31:0] joystick_4,
output logic [15:0] joystick_analog_0,
output logic [15:0] joystick_analog_1,
output logic [7:0] key_code,
output logic  key_extended,
output logic  key_pressed,
output logic  key_strobe,
output logic [7:0] mouse_flags,
output logic  mouse_idx,
output logic  mouse_strobe,
output logic [8:0] mouse_x,
output logic [8:0] mouse_y,
output logic [3:0] mouse_z,
output logic  no_csync,
output logic  ps2_kbd_clk,
output logic  ps2_kbd_data,
output logic  ps2_mouse_clk,
output logic  ps2_mouse_data,
output logic [63:0] rtc,
output logic  scandoubler_disable,
output logic  sd_ack,
output logic  sd_ack_conf,
output logic [8:0] sd_buff_addr,
input logic  sd_conf,
input logic [7:0] sd_din,
output logic  sd_din_strobe,
output logic [7:0] sd_dout,
output logic  sd_dout_strobe,
input logic [31:0] sd_lba,
input logic [1:0] sd_rd,
input logic  sd_sdhc,
input logic [1:0] sd_wr,
input logic [7:0] serial_data,
input logic  serial_strobe,
output logic [31:0] status,
output logic [1:0] switches,
output logic  ypbpr
);
  logic [2:0] bit_position;
  logic [9:0] byte_position;
  logic [7:0] receiving, received_byte, command, response_byte;
  logic byte_toggle=0, transaction_end=1;
  logic [1:0] sys_toggle, sys_end, sd_toggle, sd_end;
  logic [7:0] sys_command, sys_position, sd_command, sd_position;
  logic [7:0] controls, saved_flags, saved_x, saved_y;
  logic pressed_state, extended_state;
  logic [2:0] analog_index;
  logic [31:0] requested_lba;
  logic requested_drive;
  logic [1:0] previous_sd_write;
  logic [7:0] serial_queue [0:63];
  logic [5:0] serial_read, serial_write;
  wire serial_available = serial_read != serial_write;
  assign {no_csync,ypbpr,scandoubler_disable,switches,buttons}=controls[6:0];
  assign conf_addr=byte_position;
  assign ps2_kbd_clk=1'bx;
  assign ps2_mouse_clk=1'bx;
  assign ps2_kbd_data=1'bx;
  assign ps2_mouse_data=1'bx;
  always @(posedge serial_strobe or posedge status[0]) begin
    if(status[0]===1'b1) serial_write<=0;
    else begin serial_queue[serial_write]<=serial_data; serial_write<=serial_write+1; end
  end
  always @(negedge SPI_CLK or posedge status[0]) begin
    if(status[0]===1'b1) serial_read<=0;
    else if(byte_position!=0 && command==8'h1b && bit_position==7 && !byte_position[0] && serial_available) serial_read<=serial_read+1;
  end
  always @(negedge SPI_CLK or posedge SPI_SS_IO) begin
    if(SPI_SS_IO) SPI_MISO<=1'bz;
    else SPI_MISO<=response_byte[7-bit_position];
  end
  always @(posedge SPI_CLK or posedge SPI_SS_IO) begin
    if(SPI_SS_IO) begin
      bit_position<=0;
      byte_position<=0;
      response_byte<=ROM_DIRECT_UPLOAD ? 8'hb4 : 8'ha4;
      transaction_end<=1;
    end else begin
      transaction_end<=0;
      bit_position<=bit_position+1;
      if(bit_position!=7) receiving<={receiving[6:0],SPI_MOSI};
      else begin
        received_byte<={receiving[6:0],SPI_MOSI};
        byte_toggle<=~byte_toggle;
        if(byte_position!=1023) byte_position<=byte_position+1;
        if(byte_position==0) command<={receiving[6:0],SPI_MOSI};
        response_byte<=0;
        case(byte_position==0 ? {receiving[6:0],SPI_MOSI} : command)
          8'h14: begin
            if(STRLEN==0) response_byte<=conf_chr;
            else if(byte_position<STRLEN) response_byte<=conf_str[(STRLEN-byte_position-1)*8+:8];
          end
          8'h16: begin
            if(byte_position==0) begin
              response_byte<={4'h6,sd_conf,sd_sdhc,sd_wr[sd_rd[1]|sd_wr[1]],sd_rd[sd_rd[1]|sd_wr[1]]};
              requested_lba<=sd_lba;
              requested_drive<=sd_rd[1]|sd_wr[1];
            end else if(byte_position==1) response_byte<={7'b0,requested_drive};
            else if(byte_position<6) response_byte<=requested_lba[(5-byte_position)*8+:8];
          end
          8'h18: response_byte<=sd_din;
          8'h1b: response_byte<=byte_position[0] ? {7'b1000000,serial_available} : serial_queue[serial_read];
        endcase
      end
    end
  end
  always @(posedge clk_sys) begin
    sys_toggle<={sys_toggle[0],byte_toggle};
    sys_end<={sys_end[0],transaction_end};
    key_strobe<=0;
    mouse_strobe<=0;
    if(sys_end[1]) sys_position<=0;
    else if(sys_toggle[0]^sys_toggle[1]) begin
      if(sys_position!=255) sys_position<=sys_position+1;
      if(sys_position==0) sys_command<=received_byte;
      else begin
        case(sys_command)
          8'h01: controls<=received_byte;
          8'h60: if(sys_position<5) joystick_0[(sys_position-1)*8+:8]<=received_byte;
          8'h61: if(sys_position<5) joystick_1[(sys_position-1)*8+:8]<=received_byte;
          8'h62: if(sys_position<5) joystick_2[(sys_position-1)*8+:8]<=received_byte;
          8'h63: if(sys_position<5) joystick_3[(sys_position-1)*8+:8]<=received_byte;
          8'h64: if(sys_position<5) joystick_4[(sys_position-1)*8+:8]<=received_byte;
          8'h15: status<={24'b0,received_byte};
          8'h1e: if(sys_position<5) status[(sys_position-1)*8+:8]<=received_byte;
          8'h21: core_mod<=received_byte[6:0];
          8'h22: if(sys_position<9) rtc[(sys_position-1)*8+:8]<=received_byte;
          8'h1a: begin
            if(sys_position==1) analog_index<=received_byte[2:0];
            else if(sys_position==2 || sys_position==3) begin
              if(analog_index==0) joystick_analog_0[(3-sys_position)*8+:8]<=received_byte;
              if(analog_index==1) joystick_analog_1[(3-sys_position)*8+:8]<=received_byte;
            end
          end
          8'h05: begin
            if(sys_position==1) begin extended_state<=0; pressed_state<=1; end
            if(received_byte==8'he0) extended_state<=1;
            else if(received_byte==8'hf0) pressed_state<=0;
            else begin
              key_extended<=extended_state && sys_position!=1;
              key_pressed<=pressed_state || sys_position==1;
              key_code<=received_byte;
              key_strobe<=1;
            end
          end
          8'h70,8'h71: begin
            case(sys_position)
              1: saved_flags<=received_byte;
              2: saved_x<=received_byte;
              3: saved_y<=received_byte;
              4: begin
                mouse_flags<=saved_flags;
                mouse_x<={saved_flags[4],saved_x};
                mouse_y<={saved_flags[5],saved_y};
                mouse_z<=received_byte[3:0];
                mouse_idx<=sys_command[0];
                mouse_strobe<=1;
              end
            endcase
          end
        endcase
      end
    end
  end
  always @(posedge clk_sd) begin
    sd_toggle<={sd_toggle[0],byte_toggle};
    sd_end<={sd_end[0],transaction_end};
    previous_sd_write<=sd_wr;
    if(sd_dout_strobe) begin sd_dout_strobe<=0; if(sd_buff_addr!=511) sd_buff_addr<=sd_buff_addr+1; end
    sd_din_strobe<=0;
    if(!previous_sd_write[0] && sd_wr[0]) begin sd_buff_addr<=0; sd_din_strobe<=1; end
    img_mounted<=0;
    if(sd_end[1]) begin
      sd_position<=0;
      sd_ack<=0;
      sd_ack_conf<=0;
      sd_dout_strobe<=0;
      sd_din_strobe<=0;
      sd_buff_addr<=0;
    end else if(sd_toggle[0]^sd_toggle[1]) begin
      if(sd_position!=255) sd_position<=sd_position+1;
      if(sd_position==0) begin
        sd_command<=received_byte;
        if(received_byte==8'h18) begin sd_din_strobe<=1; if(sd_buff_addr!=511) sd_buff_addr<=sd_buff_addr+1; end
        if(received_byte==8'h19) sd_ack_conf<=1;
        if(received_byte==8'h17 || received_byte==8'h18) sd_ack<=1;
      end else begin
        case(sd_command)
          8'h17,8'h19: begin sd_dout_strobe<=1; sd_dout<=received_byte; end
          8'h18: if(sd_buff_addr!=511) begin sd_din_strobe<=1; sd_buff_addr<=sd_buff_addr+1; end
          8'h1c: img_mounted[received_byte[0]]<=1;
          8'h1d: if(sd_position<5) img_size[(sd_position-1)*8+:8]<=received_byte;
        endcase
      end
    end
  end

endmodule
