`timescale 1ns/1ps
module dvbench_model #(parameter associativity=1, sets=512, bytes_per_line=16, base_address=0, limit=0)
(input clk_i,rst_i,stall_a,stall_x,stall_m,input [31:0] address_x,address_m,input load_q_m,store_q_m,
 input [31:0] store_data,input [3:0] store_byte_select,input refill_ready,input [31:0] refill_data,input dflush,
 output stall_request,output reg restart_request,refill_request,output reg [31:0] refill_address,output reg refilling,output [31:0] load_data);
 localparam SW=$clog2(sets), TW=24-SW;
 reg [31:0] words[0:sets*4-1];reg [TW-1:0] tags[0:sets-1];reg valids[0:sets-1];
 integer read_word,read_set,flush_cursor,word_cursor;
 typedef enum {INVALIDATING,LOOKUP,FILLING} phase_t;phase_t phase;
 wire hit=(valids[read_set] && tags[read_set]==address_m[27:SW+4]);
 wire request_miss=load_q_m && !stall_m && !hit;
 assign stall_request=(phase!=LOOKUP);assign load_data=words[read_word];
 always @(posedge clk_i) begin : memory_operations
  integer w,ss,j;reg [31:0] nextword;
  if(!stall_x)begin read_word<=#1 address_x[SW+3:2];read_set<=#1 address_x[SW+3:4];end
  if(phase==INVALIDATING)begin tags[flush_cursor]<=#1 refill_address[27:SW+4];valids[flush_cursor]<=#1 0;end
  else if(refill_ready)begin ss=refill_address[SW+3:4];tags[ss]<=#1 refill_address[27:SW+4];valids[ss]<=#1 ((word_cursor==3)||(store_q_m && phase==LOOKUP));end
  if(refill_ready || (store_q_m && phase==LOOKUP && hit && !stall_m))begin
   w=(phase==FILLING)?((refill_address[SW+3:4]*4)+word_cursor):address_m[SW+3:2];
   if(phase==FILLING)words[w]<=#1 refill_data;
   else begin nextword=(sets<512)?load_data:words[w];for(j=0;j<4;j=j+1)if(store_byte_select[j])nextword[j*8+:8]=store_data[j*8+:8];words[w]<=#1 nextword;end
  end
 end
 always @(posedge clk_i or posedge rst_i)begin
  if(rst_i)begin phase<=#1 INVALIDATING;flush_cursor<=#1 sets-1;word_cursor<=#1 0;restart_request<=#1 0;refill_request<=#1 0;refill_address<=#1 32'bx;refilling<=#1 0;end
  else begin refilling<=#1 (phase==FILLING);
   case(phase)
    INVALIDATING:begin flush_cursor<=#1 ((flush_cursor+sets-1)%sets);if(flush_cursor==0)phase<=#1 LOOKUP;end
    LOOKUP:begin if(!stall_a)restart_request<=#1 0;if(request_miss)begin phase<=#1 FILLING;refill_address<=#1 address_m;refill_request<=#1 1;word_cursor<=#1 0;end else if(dflush)phase<=#1 INVALIDATING;end
    FILLING:begin refill_request<=#1 0;if(refill_ready)begin word_cursor<=#1 ((word_cursor+1)%4);if(word_cursor==3)begin phase<=#1 LOOKUP;restart_request<=#1 1;end end end
   endcase
  end
 end
endmodule
