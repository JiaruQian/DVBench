`timescale 1ns/1ps
// Native-pin AP3216C sensor stimulus. The same parameter/seed/profile is used
// independently on the actual and predictor buses; no DUT-internal access.
module ap_sensor_slave #(parameter SLAVE_ADDR=7'h1e)(
 input rst_n,scl,inout wire sda,output integer stops,output integer read_bytes);
 bit pull_low=0,active=0,addressed=0,ack_clocked=0,send_after_ack=0,read_transfer=0;
 integer phase=0,bit_count=0,byte_index=0,send_count=0,round_index=0;
 logic[7:0] shift=0,pointer=0,send_value=0;
 integer seed=1;
 assign sda=pull_low ? 1'b0 : 1'bz;
 initial begin stops=0;read_bytes=0;if(!$value$plusargs("SEED=%d",seed))begin if(!$value$plusargs("ntb_random_seed=%d",seed))seed=1;end end
 function automatic logic[7:0] sensor_register(input logic[7:0] addr);
  integer proximity_value,als_value,profile;
  profile=(round_index+(seed^(seed>>2)))%3;
  case(profile)
   0:begin proximity_value=15;als_value=65535;end
   1:begin proximity_value=16;als_value=10000;end
   default:begin proximity_value=128;als_value=12345;end
  endcase
  case(addr)
   8'h0e:return proximity_value & 15;
   8'h0f:return (proximity_value>>4)&63;
   8'h0c:return als_value & 255;
   8'h0d:return (als_value>>8)&255;
   default:return 0;
  endcase
 endfunction
 always @(negedge rst_n)begin
  pull_low=0;active=0;addressed=0;phase=0;bit_count=0;byte_index=0;
  round_index=0;pointer=0;read_transfer=0;stops=0;read_bytes=0;
 end
 always @(negedge sda)if(rst_n && scl===1'b1)begin
  active=1;addressed=0;phase=0;bit_count=0;byte_index=0;shift=0;pull_low=0;read_transfer=0;
 end
 always @(posedge sda)if(rst_n && scl===1'b1 && active)begin
  active=0;pull_low=0;stops++;
  if(read_transfer && pointer==8'h0d)round_index++;
 end
 always @(posedge scl)if(rst_n && active)begin
  if(phase==0)begin
   shift={shift[6:0],sda};bit_count++;
   if(bit_count==8)begin
    if(byte_index==0)begin addressed=(shift[7:1]==SLAVE_ADDR);send_after_ack=addressed && shift[0];read_transfer=send_after_ack;end
    else begin send_after_ack=0;if(byte_index==1 && addressed)pointer=shift;end
    byte_index++;phase=1;ack_clocked=0;
   end
  end else if(phase==1)ack_clocked=1;
  else if(phase==2)begin send_count++;if(send_count==8)read_bytes++;end
  else if(phase==3)phase=4;
 end
 always @(negedge scl)if(rst_n && active)begin
  case(phase)
   1:if(!ack_clocked)pull_low=addressed;
     else begin
      pull_low=0;
      if(send_after_ack)begin phase=2;send_count=0;send_value=sensor_register(pointer);pull_low=!send_value[7];end
      else begin phase=0;bit_count=0;shift=0;end
     end
   2:if(send_count<8)pull_low=!send_value[7-send_count];else begin pull_low=0;phase=3;end
   default:pull_low=0;
  endcase
 end
endmodule
