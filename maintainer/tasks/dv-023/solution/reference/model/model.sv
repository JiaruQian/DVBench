`timescale 1ns/1ps
// Input-history behavioral oracle. Logical positions are unbounded event counts;
// only address selection/equality projects them modulo the fixed depth.
module dvbench_model #(parameter ADDR=16, parameter BIT_WIDTH=8)(
 input w_clk,r_clk,rst,we,re,
 input [BIT_WIDTH-1:0] wdata,
 output wire [BIT_WIDTH-1:0] rdata,
 output logic full,empty
);
 longint unsigned put_position, get_position;
 logic [BIT_WIDTH-1:0] slots[0:ADDR-1];
 wire accept_put=we && !full;
 wire accept_get=re && !empty;
 assign rdata=slots[get_position % ADDR];
 // Storage is not reset, including writes requested while reset is asserted.
 always @(posedge w_clk)
   if(accept_put) slots[put_position % ADDR] <= wdata;
 always @(posedge r_clk or posedge rst)
   if(rst) get_position<=0;
   else if(accept_get) get_position<=get_position+1;
 always @(posedge w_clk or posedge rst) begin
   if(rst) begin put_position<=0; full<=0; empty<=1; end
   else begin
     if(accept_put) put_position<=put_position+1;
     // Status is evaluated in the write-clock domain, using the prospective
     // read position selected by the current enables (not a synchronized count).
     if(we && re) begin
       if(full) full<=0;
       else if(empty) empty<=0;
     end else if(we) begin
       if(accept_put) empty<=0;
       if(((put_position+(accept_put ? 1 : 0)) % ADDR)==(get_position % ADDR)) full<=1;
     end else if(re) begin
       if(accept_get) full<=0;
       if((put_position % ADDR)==((get_position+(accept_get ? 1 : 0)) % ADDR)) empty<=1;
     end
   end
 end
endmodule
