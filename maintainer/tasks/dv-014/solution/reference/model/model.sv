`timescale 1ns/1ps
// Transaction/time-table oracle, driven solely by sys_clk/reset and its own
// resolved sensor input. No DUT instance, implementation hierarchy or trace.
module dvbench_model #(
 parameter SLAVE_ADDR=7'h1e,parameter BIT_CTRL=1'b0,
 parameter CLK_FREQ=26'd50_000_000,parameter I2C_FREQ=18'd250_000
)(input sys_clk,sys_rst_n,output logic ap_scl,inout wire ap_sda,
 output logic [3:0] led,output logic [5:0] sel,output logic [7:0] seg_led);
 localparam integer HALF_TICK=((CLK_FREQ/I2C_FREQ)>>2)>>1;
 integer sys_phase=0;logic tick_clock=0;bit driving=1;logic bus_value=1;
 logic [9:0] proximity=0;logic [15:0] illuminance;
 assign ap_sda=driving ? bus_value : 1'bz;
 always @(posedge sys_clk or negedge sys_rst_n)
  if(!sys_rst_n)begin sys_phase<=0;tick_clock<=0;end
  else if(sys_phase==HALF_TICK-1)begin sys_phase<=0;tick_clock<=!tick_clock;end
  else sys_phase<=sys_phase+1;
 task automatic tick;@(posedge tick_clock);endtask
 task automatic pause_ticks(input integer n);repeat(n)tick();endtask
 // A complete byte consists of eight MSB-first bits and an ACK slot.
 // Initial/repeated START has four additional drive-clock slots.
 task automatic send_byte(input logic[7:0] value,input integer prefix);
  integer k,j,offset,total;
  offset=(prefix!=0)?4:0;total=36+offset;
  for(k=0;k<total;k++)begin
   tick();
   if(prefix!=0 && k<4)begin
    if(k==0 && prefix==2)begin driving=1;bus_value=1;end
    if(k==1)begin if(prefix==1)bus_value=0;else ap_scl=1;end
    if(k==2 && prefix==2)bus_value=0;
    if(k==3)ap_scl=0;
   end else begin
    j=k-offset;
    if(j<32)begin
     if((j%4)==0)begin driving=1;bus_value=value[7-j/4];end
     if((j%4)==1)ap_scl=1;
     if((j%4)==3)ap_scl=0;
    end else case(j)
     32:begin driving=0;bus_value=1;end
     33:ap_scl=1;
     35:ap_scl=0;
     default:;
    endcase
   end
  end
 endtask
 task automatic receive_byte(output logic[7:0] value);
  integer k;value=0;
  for(k=0;k<36;k++)begin
   tick();
   if(k<32)begin
    driving=0;
    if((k%4)==1)begin value[7-k/4]=ap_sda;ap_scl=1;end
    if((k%4)==3)ap_scl=0;
   end else case(k)
    32:begin driving=1;bus_value=1;end
    33:ap_scl=1;
    35:ap_scl=0;
    default:;
   endcase
  end
 endtask
 task automatic stop_bus;
  for(integer k=0;k<17;k++)begin
   tick();
   if(k==0)begin driving=1;bus_value=0;end
   if(k==1)ap_scl=1;
   if(k==3)bus_value=1;
  end
 endtask
 task automatic operation(input logic[7:0] reg_addr,input bit is_read,output logic[7:0] value);
  send_byte({SLAVE_ADDR,1'b0},1);
  if(BIT_CTRL)send_byte(8'h00,0);
  send_byte(reg_addr,0);
  if(is_read)begin send_byte({SLAVE_ADDR,1'b1},2);receive_byte(value);end
  else begin send_byte(8'h03,0);value=0;end
  stop_bus();
 endtask
 task automatic sensor_script;
  logic[7:0] unused,ps_low,ps_high,als_low,als_high;
  // 101 startup wait ticks, one command assertion, one acceptance tick.
  pause_ticks(103);operation(8'h00,0,unused);pause_ticks(12504);
  forever begin
   operation(8'h0e,1,ps_low);pause_ticks(6);
   operation(8'h0f,1,ps_high);
   pause_ticks(100002);proximity<={ps_high[5:0],ps_low[3:0]};pause_ticks(2);
   operation(8'h0c,1,als_low);pause_ticks(6);
   operation(8'h0d,1,als_high);tick();
   // The original 16-bit expression truncates multiplication before /100.
   illuminance<=((({als_high,als_low}*35)%65536)/100);
   pause_ticks(12503);
  end
 endtask
 initial begin
  ap_scl=1;driving=1;bus_value=1;proximity=0;
  forever begin
   wait(sys_rst_n===1'b1);
   fork
    begin sensor_script();end
    begin @(negedge sys_rst_n);end
   join_any
   disable fork;
   ap_scl=1;driving=1;bus_value=1;proximity=0;
   wait(sys_rst_n===1'b0);
  end
 end
 always @(posedge tick_clock or negedge sys_rst_n)
  if(!sys_rst_n)led<=0;
  else if(proximity<16)led<=4'b0001;
  else if(proximity<128)led<=4'b0011;
  else if(proximity<512)led<=4'b0111;
  else led<=4'b1111;
 // Display oracle: mathematical decimal digits, two display-clock pipeline
 // stages, and a position selected once per 5000 display ticks.
 integer screen_divider=0;logic screen_clock=1;
 longint unsigned screen_ticks=0;
 logic[23:0] decimal_digits=0;logic[3:0] selected_digit=0;
 integer display_position;
 function automatic logic[23:0] decimal_image(input logic[15:0] value);
  logic[23:0] result;integer v,position;
  if($isunknown(value))return 24'haaaaax;
  result=24'haaaaaa;v=value;position=0;
  do begin result[position*4+:4]=v%10;v=v/10;position++;end while(v!=0 && position<6);
  return result;
 endfunction
 function automatic logic[7:0] glyph(input logic[3:0] digit);
  case(digit)
   0:return 8'hc0;1:return 8'hf9;2:return 8'ha4;3:return 8'hb0;
   4:return 8'h99;5:return 8'h92;6:return 8'h82;7:return 8'hf8;
   8:return 8'h80;9:return 8'h90;10:return 8'hff;11:return 8'hbf;
   default:return 8'hc0;
  endcase
 endfunction
 always @(posedge sys_clk or negedge sys_rst_n)
  if(!sys_rst_n)begin screen_divider<=0;screen_clock<=1;end
  else if(screen_divider==4)begin screen_divider<=0;screen_clock<=!screen_clock;end
  else screen_divider<=screen_divider+1;
 always @(posedge screen_clock or negedge sys_rst_n)
  if(!sys_rst_n)begin screen_ticks<=0;decimal_digits<=0;selected_digit<=0;sel<=6'b111111;seg_led<=8'hc0;end
  else begin
   display_position=((screen_ticks>0 ? screen_ticks-1 : 0)/5000)%6;
   screen_ticks<=screen_ticks+1;
   decimal_digits<=decimal_image(illuminance);
   sel<=6'b111111 ^ (6'b000001 << display_position);
   selected_digit<=decimal_digits[display_position*4+:4];
   seg_led<=glyph(selected_digit);
  end
endmodule
