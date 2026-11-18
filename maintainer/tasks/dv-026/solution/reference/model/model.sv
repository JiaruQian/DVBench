`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
output logic auto_int_out_0,
output logic auto_int_out_1,
output logic auto_in_a_ready,
input logic auto_in_a_valid,
input logic [2:0] auto_in_a_bits_opcode,
input logic [2:0] auto_in_a_bits_param,
input logic [1:0] auto_in_a_bits_size,
input logic [9:0] auto_in_a_bits_source,
input logic [25:0] auto_in_a_bits_address,
input logic [7:0] auto_in_a_bits_mask,
input logic [63:0] auto_in_a_bits_data,
input logic auto_in_a_bits_corrupt,
input logic auto_in_d_ready,
output logic auto_in_d_valid,
output logic [2:0] auto_in_d_bits_opcode,
output logic [1:0] auto_in_d_bits_size,
output logic [9:0] auto_in_d_bits_source,
output logic [63:0] auto_in_d_bits_data,
input logic io_rtcTick
);
logic [63:0] elapsed, deadline;
logic software_interrupt;
logic [15:0] register_offset;
logic write_transfer;
always_comb begin
  register_offset=auto_in_a_bits_address[15:0];
  write_transfer=auto_in_a_valid && auto_in_d_ready && auto_in_a_bits_opcode!=4;
  auto_in_a_ready=auto_in_d_ready;
  auto_in_d_valid=auto_in_a_valid;
  auto_in_d_bits_opcode=(auto_in_a_bits_opcode==4)?1:0;
  auto_in_d_bits_size=auto_in_a_bits_size;
  auto_in_d_bits_source=auto_in_a_bits_source;
  auto_int_out_0=software_interrupt;
  auto_int_out_1=(elapsed>=deadline);
  auto_in_d_bits_data=0;
  if(register_offset<8) auto_in_d_bits_data={63'b0,software_interrupt};
  else if(register_offset>=16'h4000 && register_offset<16'h4008) auto_in_d_bits_data=deadline;
  else if(register_offset>=16'hbff8 && register_offset<16'hc000) auto_in_d_bits_data=elapsed;
end
always @(posedge clock) begin
  if(write_transfer && register_offset>=16'h4000 && register_offset<16'h4008)
    for(integer byte_index=0;byte_index<8;byte_index=byte_index+1)
      if(auto_in_a_bits_mask[byte_index]) deadline[byte_index*8+:8]<=auto_in_a_bits_data[byte_index*8+:8];
  if(reset) begin elapsed<=0;software_interrupt<=0;end
  else begin
    if(write_transfer && register_offset>=16'hbff8 && register_offset<16'hc000 && auto_in_a_bits_mask!=0) begin
      for(integer byte_index=0;byte_index<8;byte_index=byte_index+1)
        if(auto_in_a_bits_mask[byte_index]) elapsed[byte_index*8+:8]<=auto_in_a_bits_data[byte_index*8+:8];
    end else if(io_rtcTick) elapsed<=elapsed+1;
    if(write_transfer && register_offset<8 && auto_in_a_bits_mask[0]) software_interrupt<=auto_in_a_bits_data[0];
  end
end
endmodule
