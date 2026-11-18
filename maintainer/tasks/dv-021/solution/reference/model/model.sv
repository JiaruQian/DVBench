`timescale 1ns/1ps
module dvbench_model #(parameter MSEC_WIDTH=7, SEC_WIDTH=6, MIN_WIDTH=6, HOUR_WIDTH=5)(
input clk,rst,btnR,btnL,btnU,btuD,input [2:0] sw,
output logic [3:0] fnd_com,output logic [7:0] fnd_data,led);
integer phase=0, elapsed=0, control=0;
integer stopwatch_phase=0,watch_phase=0;
logic reverse_direction=0,stopwatch_tick=0,watch_tick=0;
logic [7:0] histories[0:3];
logic [3:0] edge_seen=0;
wire [3:0] raw_buttons={btuD,btnU,btnL,btnR};
wire [3:0] pulses={(&histories[3]),(&histories[2]),(&histories[1]),(&histories[0])}&~edge_seen;
integer stopwatch_digits[0:3];
integer watch_digits[0:5];
integer stopwatch_radix[0:3]='{100,60,60,24};
integer watch_radix[0:5]='{100,10,6,10,6,24};
integer chosen, movement, following;
logic carry;
always @(posedge clk or posedge rst) begin
  if(rst) begin
    phase<=0; elapsed<=0; control<=0; reverse_direction<=0;
    stopwatch_phase<=0; watch_phase<=0; stopwatch_tick<=0; watch_tick<=0; edge_seen<=0;
    for(integer button=0;button<4;button++) histories[button]<=0;
    for(integer digit=0;digit<4;digit++) stopwatch_digits[digit]<=0;
    for(integer digit=0;digit<6;digit++) watch_digits[digit]<=0;
  end else begin
    elapsed<=elapsed+1;
    phase<=(phase+1)%100000;
    for(integer button=0;button<4;button++) begin
      edge_seen[button]<=&histories[button];
      if(phase==99999) histories[button]<={raw_buttons[button],histories[button][7:1]};
    end
    following=control;
    case(control)
      0: if(!sw[1]) following=1; else if(!sw[2]) following=5;
      1: if(sw[1]) following=5; else if(pulses[0]) following=2; else if(pulses[1]) following=3; else if(pulses[3]) following=4;
      2: if(sw[1]) following=5; else if(pulses[0]) following=1;
      3,4: following=1;
      5: if(!sw[1]) following=1; else if(sw[2]) following=6;
      default: if(!sw[2]) following=5; else if(pulses[1]) following=6+(control-6+1)%5; else if(pulses[0]) following=6+(control-6+4)%5;
    endcase
    control<=following;
    if(control==4) reverse_direction<=~reverse_direction;
    stopwatch_tick<=0;
    if(control==3) stopwatch_phase<=0;
    else if(control==2) begin
      stopwatch_phase<=(stopwatch_phase+1)%1000000;
      if(stopwatch_phase==999999) stopwatch_tick<=1;
    end
    watch_tick<=0;
    if(control<6) begin
      watch_phase<=(watch_phase+1)%1000000;
      if(watch_phase==999999) watch_tick<=1;
    end
    carry=stopwatch_tick;
    for(integer digit=0;digit<4;digit++) begin
      if(carry) begin
        stopwatch_digits[digit]<=(stopwatch_digits[digit]+(reverse_direction ? stopwatch_radix[digit]-1 : 1))%stopwatch_radix[digit];
        carry=reverse_direction ? stopwatch_digits[digit]==0 : stopwatch_digits[digit]==stopwatch_radix[digit]-1;
      end else if(control==3) stopwatch_digits[digit]<=0;
    end
    carry=watch_tick;
    chosen=control-5;
    movement=pulses[2] ? 1 : (pulses[3] ? -1 : 0);
    for(integer digit=0;digit<6;digit++) begin
      if(carry) begin
        watch_digits[digit]<=(watch_digits[digit]+1)%watch_radix[digit];
        carry=watch_digits[digit]==watch_radix[digit]-1;
      end else if(control>=6 && digit==chosen && movement!=0)
        watch_digits[digit]<=(watch_digits[digit]+movement+watch_radix[digit])%watch_radix[digit];
    end
  end
end
integer scan_slot, centisecond_value,second_value,minute_value,hour_value,digit_code;
always @* begin
  led={control==7,(control==6 || control==10),control==9,control==8,sw[1]&sw[2],sw[1]&~sw[2],sw[1],sw[0]};
  scan_slot=((elapsed+50000)/100000)%8;
  fnd_com=4'b1111 ^ (4'b0001<<(scan_slot%4));
  centisecond_value=sw[1] ? watch_digits[0] : stopwatch_digits[0];
  second_value=sw[1] ? watch_digits[1]+10*watch_digits[2] : stopwatch_digits[1];
  minute_value=sw[1] ? watch_digits[3]+10*watch_digits[4] : stopwatch_digits[2];
  hour_value=sw[1] ? watch_digits[5] : stopwatch_digits[3];
  case(scan_slot)
    0:digit_code=(sw[0] ? minute_value : centisecond_value)%10;
    1:digit_code=((sw[0] ? minute_value : centisecond_value)/10)%10;
    2:digit_code=(sw[0] ? hour_value : second_value)%10;
    3:digit_code=((sw[0] ? hour_value : second_value)/10)%10;
    6:digit_code=centisecond_value>50 ? 15 : 14;
    default:digit_code=15;
  endcase
  case(digit_code)
    0:fnd_data=8'hc0;1:fnd_data=8'hf9;2:fnd_data=8'ha4;3:fnd_data=8'hb0;
    4:fnd_data=8'h99;5:fnd_data=8'h92;6:fnd_data=8'h82;7:fnd_data=8'hf8;
    8:fnd_data=8'h80;9:fnd_data=8'h90;14:fnd_data=8'h7f;default:fnd_data=8'hff;
  endcase
end
endmodule
