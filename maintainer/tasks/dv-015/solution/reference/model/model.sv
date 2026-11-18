`timescale 1ns/1ps
module dvbench_model  (
output logic scl,
output logic [15:0] o_data,
output logic s_busy,
output logic s_done,
output logic sda_en,
inout wire sda,
input logic clk,
input logic rst_n,
input logic [6:0] addr,
input logic [7:0] cmd,
input logic [7:0] data,
input logic rd_wr,
input logic init,
input logic wr
);
integer segment, quarter_tick, byte_slot, bit_slot;
logic active, acknowledge_seen;
logic [7:0] transmitted, received;
logic [15:0] result;
logic serial_value, clock_value, ack_drive;
logic [7:0] live_byte;
wire receiving = rd_wr && byte_slot>0;
wire more_bytes = rd_wr ? (byte_slot==0 || (byte_slot==1 && (cmd[1:0]==0 || cmd[1:0]==3))) : (byte_slot<1 || (byte_slot==1 && wr));
wire read_response = active && rd_wr && byte_slot>0 &&
  ((segment==2 && quarter_tick>0) || (segment==1 && byte_slot==2 && quarter_tick==0 && bit_slot==7) || (segment==3 && quarter_tick==0));
always @(*) begin
  live_byte=0;
  if(active && !receiving) begin
    if(segment==0 || (segment==1 && (byte_slot==0 || quarter_tick>0 || bit_slot!=7)) || (segment==2 && quarter_tick==0)) begin
      case(byte_slot)
        0: live_byte={addr,rd_wr};
        1: live_byte=cmd;
        2: live_byte=data;
        default: live_byte=0;
      endcase
    end
  end
end
always @(posedge clk) begin
  if(!rst_n) begin
    active<=0; segment<=0; quarter_tick<=0; byte_slot<=0; bit_slot<=7;
    acknowledge_seen<=0; transmitted<=0; received<=0; result<=0;
  end else begin
    transmitted<=live_byte;
    if(!active) begin
      quarter_tick<=0;
      if(init) begin active<=1; segment<=0; byte_slot<=0; bit_slot<=7; end
    end else begin
      quarter_tick<=(quarter_tick+1)%16;
      case(segment)
        0: if(quarter_tick==15) begin segment<=1; bit_slot<=7; end
        1: begin
          if(receiving) received[bit_slot]<=sda;
          if(quarter_tick==15) begin
            if(bit_slot==0) begin segment<=2; bit_slot<=7; acknowledge_seen<=0; end
            else bit_slot<=bit_slot-1;
          end
        end
        2: begin
          if(receiving && quarter_tick==0) begin
            if(byte_slot==1) result[15:8]<=received;
            else result[7:0]<=received;
          end
          if(!receiving && quarter_tick>=8 && quarter_tick<12 && !sda) acknowledge_seen<=1;
          if(quarter_tick==15 && (receiving || acknowledge_seen)) begin
            acknowledge_seen<=0;
            if(more_bytes) begin segment<=1; byte_slot<=byte_slot+1; end
            else segment<=3;
          end
        end
        3: if(quarter_tick==15) begin active<=0; segment<=0; end
      endcase
    end
  end
end
always @(*) begin
  clock_value=1; serial_value=1;
  s_busy=0; s_done=0; sda_en=read_response;
  ack_drive=(byte_slot==1 && (cmd[1:0]==0 || cmd[1:0]==3)) || (segment==1 && byte_slot==2 && quarter_tick==0);
  if(active) begin
    case(segment)
      0: begin clock_value=quarter_tick<8; serial_value=quarter_tick<=4; s_busy=1; end
      1: begin
        clock_value=quarter_tick>=4 && quarter_tick<12;
        s_busy=1;
        if(!receiving) serial_value=transmitted[bit_slot];
      end
      2: begin
        clock_value=quarter_tick>=4 && quarter_tick<12;
        if(receiving) serial_value=quarter_tick==0 ? 1'bz : !ack_drive;
      end
      3: begin
        s_done=quarter_tick<=5;
        clock_value=quarter_tick>=6;
        serial_value=quarter_tick>=9;
      end
    endcase
  end
end
assign sda = sda_en ? !ack_drive : (serial_value ? 1'bz : serial_value);
assign scl = clock_value ? 1'bz : 1'b0;
assign o_data=result;
endmodule
