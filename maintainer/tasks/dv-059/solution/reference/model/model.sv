`timescale 1ns/1ps
module dvbench_model(input logic[0:4][63:0]state_i,input logic[127:0]key_i,input logic[63:0]data_i,input logic resetb_i,start_i,clock_i,data_valid_i,output logic end_o,cipher_valid_o,output logic[63:0]cipher_o,output logic[127:0]tag_o);
typedef logic[0:4][63:0] image_t;
// Mathematical bitsliced ASCON S-box, independent of source RTL's 32-entry table.
function automatic logic[63:0]rr(input logic[63:0]x,input int n);return(x>>n)|(x<<(64-n));endfunction
function automatic image_t round_math(input image_t s,input int n);
 image_t x,t,y;
 if(n<0||n>11)return 'x;
 x=s;x[2]^=((15-n)<<4)|n;
 x[0]^=x[4];x[4]^=x[3];x[2]^=x[1];
 for(int j=0;j<5;j++)t[j]=~x[j]&x[(j+1)%5];
 for(int j=0;j<5;j++)y[j]=x[j]^t[(j+1)%5];
 y[1]^=y[0];y[0]^=y[4];y[3]^=y[2];y[2]=~y[2];
 y[0]^=rr(y[0],19)^rr(y[0],28);y[1]^=rr(y[1],61)^rr(y[1],39);y[2]^=rr(y[2],1)^rr(y[2],6);y[3]^=rr(y[3],10)^rr(y[3],17);y[4]^=rr(y[4],7)^rr(y[4],41);return y;
endfunction
// Abstract input-history interpreter: idle, setup, initial permutation, AD, message, final permutation.
int phase=0,round_number=0,blocks=0,next_round;bit counter_started=0;logic init6,init12,external_select;image_t image;
logic sticky_end,sticky_cipher;image_t before_round,after_round;
always_comb begin
 before_round=external_select?state_i:image;
 if((phase==4||phase==6)&&round_number==6)before_round[0]^=data_i;
 if(phase==8&&round_number==0)begin before_round[0]^=data_i;before_round[1]^=key_i[127:64];before_round[2]^=key_i[63:0];end
 after_round=round_math(before_round,round_number);
 if((phase==2||phase==8)&&round_number==11)begin after_round[3]^=key_i[127:64];after_round[4]^=key_i[63:0];end
 if(phase==4&&round_number==11)after_round[4]^=64'd1;
 cipher_o=before_round[0];end_o=sticky_end;cipher_valid_o=sticky_cipher;
 if(sticky_end===1'b1)tag_o={image[3],image[4]};
end
always @(posedge clock_i or negedge resetb_i)begin
 if(!resetb_i)begin
  if(phase inside {1,2,4,6,8})image<=after_round;else image<=0;
  phase=0;round_number=0;blocks=0;
 end else begin
  next_round=counter_started?(init6===1?6:init12===1?0:(round_number+1)%16):round_number;
  if(phase inside {1,2,4,6,8})image<=after_round;
  if(phase==4&&round_number==11)blocks=0;
  else if(phase==5)blocks=(blocks+1)%4;
  case(phase)
   0:if(start_i)begin phase=1;counter_started=1;init12=1;end
   1:begin phase=2;external_select=1;init12=0;end
   2:if(round_number==11)begin phase=3;init6=1;end else if(round_number==0)external_select=0;
   3:if(data_valid_i)begin phase=4;init6=0;end
   4:if(round_number==11)begin phase=5;init6=1;end
   5:if(data_valid_i)begin phase=6;init6=0;sticky_cipher=1;end
   6:if(round_number==11)begin if(blocks==3)begin phase=7;init12=1;end else begin phase=5;init6=1;end end else if(round_number==6)sticky_cipher=0;
   7:if(data_valid_i)begin phase=8;init12=0;sticky_cipher=1;end
   8:if(round_number==11)begin phase=9;sticky_end=1;end else if(round_number==0)sticky_cipher=0;
   9:phase=0;
  endcase
  round_number=next_round;
 end
end
endmodule
