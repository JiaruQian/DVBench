`timescale 1ns/1ps
module dvbench_model(input logic clk,input logic rst,input logic floor_0_p,input logic floor_1_p,input logic floor_2_p,input logic floor_3_p,input logic floor_4_p,input logic floor_0_d,input logic floor_1_d,input logic floor_2_d,input logic floor_3_d,input logic floor_4_d,input logic direction_1,input logic direction_2,input logic direction_3,output logic led_inside_4,output logic led_inside_3,output logic led_inside_2,output logic led_inside_1,output logic led_inside_0,output logic led_outside_4,output logic led_outside_3,output logic led_outside_2,output logic led_outside_1,output logic led_outside_0,output logic led_busy,output logic a_out,output logic b_out,output logic c_out,output logic d_out,output logic e_out,output logic f_out,output logic g_out,output logic p_out,output logic [7:0] an);
  integer source_age, display_age, display_digit, slow_age, accepted_floor;
  bit request_seen;
  logic [4:0] pending;
  function automatic logic [7:0] glyph(input integer digit, destination);
    case (digit)
      0: glyph=8'h03;
      1: glyph=8'hfd;
      2: glyph=8'he3;
      3: glyph=8'h71;
      4: glyph=(destination>0) ? 8'h31 : 8'h85;
      5: glyph=(destination>0) ? 8'h83 : 8'h9f;
      6,7: glyph=8'hfd;
      default: glyph=8'hff;
    endcase
  endfunction
  always @(posedge clk or negedge rst) begin : predict_early_history
    integer selected;
    if (!rst) begin
      source_age=0; slow_age=0; accepted_floor=0; request_seen=0;
      pending=0;
      {led_inside_4,led_inside_3,led_inside_2,led_inside_1,led_inside_0}<=0;
      {led_outside_4,led_outside_3,led_outside_2,led_outside_1,led_outside_0}<=0;
      led_busy<=0;
    end else begin
      source_age++;
      if ((source_age%2000002)==1000001) begin
        slow_age++;
        selected=-1;
        if (floor_1_d) selected=1;
        else if (floor_2_d) selected=2;
        else if (floor_3_d) selected=3;
        else if (floor_4_d) selected=4;
        else if (floor_0_d) selected=0;
        if (!request_seen && selected>=0) begin
          accepted_floor=selected; request_seen=1;
          if (selected>0) pending[selected]=1;
        end
        {led_inside_4,led_inside_3,led_inside_2,led_inside_1,led_inside_0}<=pending;
        {led_outside_4,led_outside_3,led_outside_2,led_outside_1,led_outside_0}<=pending;
        led_busy<=(accepted_floor>0 && slow_age>=3);
      end
    end
  end
  always @(posedge clk) begin : predict_scan
    if (!rst) begin
      display_age=0; display_digit=0;
      an<=8'hff; {a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out}<=8'hff;
    end else begin
      if (display_digit==0) begin
        an<=8'hff; {a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out}<=8'hff;
      end else begin
        an<=~(8'b1<<(display_digit-1));
        {a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out}<=glyph(display_digit-1,accepted_floor);
      end
      display_age++;
      if (display_age==100001) begin
        display_age=0;
        display_digit=(display_digit==8) ? 1 : display_digit+1;
      end
    end
  end
endmodule
