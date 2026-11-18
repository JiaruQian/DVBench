`timescale 1ns/1ps
module dvbench_model (
input logic  CLOCK_50Mhz,
output logic [6:0] HEX0,
input logic  KEY_0,
output logic  LCD_BLON,
output logic [7:0] LCD_DATA,
output logic  LCD_EN,
output logic  LCD_ON,
output logic  LCD_RS,
output logic  LCD_RW,
input logic  key_valid,
input logic [3:0] keypad_input,
output logic  lock,
output logic  lock_c
);

integer source_phase=0;
logic slow_level=0;
integer mode=0;
integer idle_age=0;
integer open_age=0;
integer bad_age=0;
integer block_age=0;
integer failures=0;
integer position=0;
logic [15:0] password=16'h1122;
logic [15:0] entered=0;
logic [15:0] replacement=0;
logic [3:0] shown;
logic accepted;
integer display_class;
assign LCD_ON=1;
assign LCD_BLON=1;
assign LCD_RW=0;
always @(posedge CLOCK_50Mhz) begin
  if(source_phase==24999999) begin source_phase<=0; slow_level<=!slow_level; end
  else source_phase<=source_phase+1;
end
always @* begin
  accepted=key_valid && keypad_input<10;
  shown=(key_valid && mode!=6) ? keypad_input : 15;
  if(!KEY_0) HEX0=7'b1111111;
  else case(shown)
    0:HEX0=7'b1000000; 1:HEX0=7'b1111001; 2:HEX0=7'b0100100;
    3:HEX0=7'b0110000; 4:HEX0=7'b0011001; 5:HEX0=7'b0010010;
    6:HEX0=7'b0000010; 7:HEX0=7'b1111000; 8:HEX0=7'b0000000;
    9:HEX0=7'b0010000; 10:HEX0=7'b1000110; default:HEX0=7'b1111111;
  endcase
  display_class=0;
  if(mode==1) display_class=1;
  else if(mode==2 || mode==3 || mode==4) display_class=4;
  else if(mode==5) display_class=2;
  else if(mode==6) display_class=5;
  else if(idle_age>=4) display_class=3;
end
always @(posedge slow_level or negedge KEY_0) begin
  if(!KEY_0) begin
    mode<=0; idle_age<=0; open_age<=0; bad_age<=0; block_age<=0;
    failures<=0; position<=0; password<=16'h1122; entered<=0;
    lock<=0; lock_c<=0;
  end else begin
    case(mode)
      0: begin
        if(position==0) begin lock<=0; lock_c<=0; end
        if(position==0 && failures>=3) begin mode<=6; block_age<=0; end
        else if(accepted) begin
          entered<={entered[11:0],keypad_input}; idle_age<=0;
          if(position==3) begin
            position<=0;
            if({entered[11:0],keypad_input}==password) begin mode<=1; open_age<=0; failures<=0; end
            else begin mode<=5; failures<=failures+1; bad_age<=0; end
          end else position<=position+1;
        end else if(position!=0 && idle_age>=4) begin position<=0; lock_c<=0; end
        else if(idle_age<4) idle_age<=idle_age+1;
      end
      1: begin
        lock<=1; lock_c<=0;
        if(key_valid && keypad_input==10) begin mode<=2; position<=0; open_age<=0; end
        else if(open_age>=10) begin mode<=0; lock<=0; open_age<=0; end
        else open_age<=open_age+1;
      end
      2: begin
        lock_c<=0;
        if(accepted) begin
          entered<={entered[11:0],keypad_input}; idle_age<=0;
          if(position==3) begin mode<=3; position<=0; end
          else position<=position+1;
        end else if(idle_age>=4) begin mode<=0; position<=0; lock<=0; lock_c<=0; end
        else idle_age<=idle_age+1;
      end
      3: begin
        if(entered==password) begin lock_c<=1; mode<=4; position<=0; end
        else begin lock_c<=0; mode<=5; failures<=failures+1; bad_age<=0; idle_age<=0; end
      end
      4: begin
        if(accepted) begin
          replacement<={replacement[11:0],keypad_input}; idle_age<=0;
          if(position==3) begin
            password<={replacement[11:0],keypad_input}; mode<=0; position<=0; lock<=0; lock_c<=0;
          end else position<=position+1;
        end else if(idle_age>=4) begin mode<=0; position<=0; lock<=0; lock_c<=0; end
        else idle_age<=idle_age+1;
      end
      5: begin
        lock<=0; lock_c<=0; idle_age<=0;
        if(failures>=3) begin mode<=6; block_age<=0; bad_age<=0; end
        else if(bad_age>=4) begin mode<=0; position<=0; bad_age<=0; end
        else bad_age<=bad_age+1;
      end
      6: begin
        lock<=0; lock_c<=0;
        if(block_age>=100) begin mode<=0; position<=0; failures<=0; block_age<=0; end
        else block_age<=block_age+1;
      end
    endcase
  end
end
integer lcd_phase;
logic lcd_clock;
integer lcd_action;
integer lcd_index;
logic [7:0] initialization[8]='{8'h38,8'h38,8'h38,8'h38,8'h08,8'h01,8'h06,8'h0c};
string first_line;
string second_line;
always @* begin
  first_line="ENTER PASSWORD  "; second_line="                ";
  case(display_class)
    1:begin first_line="DOOR UNLOCKED   "; second_line="AUTO Lock Soon.."; end
    2:begin first_line="WRONG PASSWORD! "; second_line="Try Again       "; end
    3:begin first_line="TIMEOUT ERROR   "; second_line="Start Again     "; end
    4:begin first_line="CHANGE PASSWORD "; second_line="Enter New Code  "; end
    5:begin first_line="    BLOCKED     "; second_line="                "; end
  endcase
end
always @(posedge CLOCK_50Mhz) begin
  if(lcd_phase<50000) lcd_phase<=lcd_phase+1;
  else lcd_phase<=0;
  if(lcd_phase<25000) lcd_clock<=0;
  else lcd_clock<=1;
end
always @(posedge lcd_clock or negedge KEY_0) begin
  if(!KEY_0) begin lcd_action<=0; lcd_index<=0; LCD_RS<=0; LCD_EN<=0; LCD_DATA<=8'h38; end
  else begin
    case(lcd_action)
      0:begin LCD_EN<=1;LCD_RS<=0;LCD_DATA<=initialization[lcd_index];lcd_action<=1;end
      1:begin LCD_EN<=0;lcd_index<=lcd_index+1;lcd_action<=lcd_index<7 ? 0:2;end
      2:begin LCD_EN<=1;LCD_RS<=0;LCD_DATA<=8'h80;lcd_action<=3;end
      3:begin LCD_EN<=0;lcd_index<=0;lcd_action<=4;end
      4:begin LCD_EN<=1;LCD_RS<=1;LCD_DATA<=first_line.getc(lcd_index);lcd_action<=5;end
      5:begin LCD_EN<=0;lcd_index<=lcd_index+1;lcd_action<=lcd_index<15 ? 4:6;end
      6:begin LCD_EN<=1;LCD_RS<=0;LCD_DATA<=8'hc0;lcd_action<=7;end
      7:begin LCD_EN<=0;lcd_index<=0;lcd_action<=8;end
      8:begin LCD_EN<=1;LCD_RS<=1;LCD_DATA<=second_line.getc(lcd_index);lcd_action<=9;end
      9:begin LCD_EN<=0;lcd_index<=lcd_index+1;lcd_action<=lcd_index<15 ? 8:2;end
      default:begin lcd_action<=0;lcd_index<=0;end
    endcase
  end
end

endmodule
