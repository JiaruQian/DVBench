`timescale 1ns/1ps
module dvbench_model(input logic clk,rst,input logic [31:0] addr,wdata,
  input logic we,rd,output logic [31:0] rdata);
  logic [63:0] words[0:16], retained[0:16];
  logic [255:0] digest_value,pending_digest;
  bit done_value, delayed_start, running;
  integer count_value, bytes_value, remaining;
  function automatic logic [63:0] rotate_lane(input logic [63:0] value,input integer amount);
    return (value<<amount)|(value>>((64-amount)%64));
  endfunction
  function automatic logic [63:0] reverse_bytes(input logic [63:0] value);
    logic [63:0] result;
    for(integer byte_index=0;byte_index<8;byte_index++) result[byte_index*8+:8]=value[56-byte_index*8+:8];
    return result;
  endfunction
  function automatic logic [255:0] permutation(input logic [1087:0] block_value);
    logic [63:0] lanes[0:24], columns[0:4], corrections[0:4], shuffled[0:24];
    logic [63:0] constant_value;
    logic [7:0] polynomial;
    integer position_x,position_y,offset_value;
    for(integer lane_index=0;lane_index<25;lane_index++)
      lanes[lane_index]=(lane_index<17)?block_value[lane_index*64+:64]:64'd0;
    polynomial=1;
    for(integer round_index=0;round_index<24;round_index++) begin
      for(integer column_index=0;column_index<5;column_index++)
        columns[column_index]=lanes[column_index]^lanes[column_index+5]^lanes[column_index+10]^lanes[column_index+15]^lanes[column_index+20];
      for(integer column_index=0;column_index<5;column_index++)
        corrections[column_index]=columns[(column_index+4)%5]^rotate_lane(columns[(column_index+1)%5],1);
      for(integer lane_index=0;lane_index<25;lane_index++) lanes[lane_index]^=corrections[lane_index%5];
      shuffled[0]=lanes[0]; position_x=1; position_y=0;
      for(integer walk_index=0;walk_index<24;walk_index++) begin
        offset_value=((walk_index+1)*(walk_index+2)/2)%64;
        shuffled[position_y+5*((2*position_x+3*position_y)%5)]=rotate_lane(lanes[position_x+5*position_y],offset_value);
        offset_value=position_x; position_x=position_y; position_y=(2*offset_value+3*position_y)%5;
      end
      for(integer row_index=0;row_index<5;row_index++)
        for(integer column_index=0;column_index<5;column_index++)
          lanes[column_index+5*row_index]=shuffled[column_index+5*row_index]^((~shuffled[(column_index+1)%5+5*row_index])&shuffled[(column_index+2)%5+5*row_index]);
      constant_value=0;
      for(integer bit_index=0;bit_index<7;bit_index++) begin
        if(polynomial[0]) constant_value[(1<<bit_index)-1]=1;
        polynomial=polynomial[7]?((polynomial<<1)^8'h71):(polynomial<<1);
      end
      lanes[0]^=constant_value;
    end
    return {reverse_bytes(lanes[0]),reverse_bytes(lanes[1]),reverse_bytes(lanes[2]),reverse_bytes(lanes[3])};
  endfunction
  always @(posedge clk or posedge rst) begin : predict
    logic [1087:0] padded_value;
    logic [63:0] final_lane;
    integer valid_bytes;
    if(rst) begin
      for(integer lane_index=0;lane_index<17;lane_index++) begin words[lane_index]=0;retained[lane_index]=0;end
      digest_value=0; pending_digest=0;done_value=0;delayed_start=0;running=0;
      count_value=1;bytes_value=8;remaining=0;
    end else begin
      if(running) begin
        remaining--;
        if(remaining==0) begin running=0;done_value=1;digest_value=pending_digest;end
      end else if(delayed_start) begin
        done_value=0;running=1;remaining=count_value+30;
        for(integer lane_index=0;lane_index<count_value;lane_index++) begin
          valid_bytes=(lane_index==count_value-1)?bytes_value:8;
          final_lane=0;
          for(integer byte_index=0;byte_index<valid_bytes;byte_index++)
            final_lane[byte_index*8+:8]=words[lane_index][56-byte_index*8+:8];
          if(lane_index==count_value-1 && valid_bytes<8) final_lane[valid_bytes*8+:8]=8'h06;
          retained[lane_index]=final_lane;
        end
        if(count_value<17) retained[16]=64'h8000000000000000;
        else retained[16]|=64'h8000000000000000;
        for(integer lane_index=0;lane_index<17;lane_index++) padded_value[lane_index*64+:64]=retained[lane_index];
        pending_digest=permutation(padded_value);
      end
      delayed_start=we && addr[7:0]==8'h90 && wdata[0];
      if(we) begin
        if(addr[7:0]==8'h88) count_value=wdata[4:0];
        else if(addr[7:0]==8'h8c) bytes_value=wdata[3:0];
        else if(addr[7:0]<=8'h87) words[addr[7:3]][32*addr[2]+:32]=wdata;
      end
    end
  end
  always_comb begin
    rdata=0;
    if(rd) begin
      if(addr[7:0]==8'h94) rdata={31'd0,done_value};
      else if(addr[7:0]>=8'ha0 && addr[7:0]<=8'hbc && addr[1:0]==0)
        rdata=digest_value[8*(addr[7:0]-8'ha0)+:32];
    end
  end
endmodule
