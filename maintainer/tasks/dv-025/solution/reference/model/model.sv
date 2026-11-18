`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
output logic auto_in_a_ready,
input logic auto_in_a_valid,
input logic [2:0] auto_in_a_bits_opcode,
input logic [2:0] auto_in_a_bits_param,
input logic [1:0] auto_in_a_bits_size,
input logic [9:0] auto_in_a_bits_source,
input logic [27:0] auto_in_a_bits_address,
input logic [7:0] auto_in_a_bits_mask,
input logic [63:0] auto_in_a_bits_data,
input logic auto_in_a_bits_corrupt,
input logic auto_in_d_ready,
output logic auto_in_d_valid,
output logic [2:0] auto_in_d_bits_opcode,
output logic [1:0] auto_in_d_bits_size,
output logic [9:0] auto_in_d_bits_source,
output logic [63:0] auto_in_d_bits_data
);
logic occupied;
logic response_read;
logic [9:0] response_source;
logic [1:0] response_size;
assign auto_in_a_ready=!occupied;
assign auto_in_d_valid=occupied;
assign auto_in_d_bits_opcode={2'b00,response_read};
assign auto_in_d_bits_source=response_source;
assign auto_in_d_bits_size=response_size;
assign auto_in_d_bits_data=64'b0;
always @(posedge clock) begin
  if(occupied===1'b0 && auto_in_a_valid) begin
    response_read<=auto_in_a_bits_opcode==4;
    response_source<=auto_in_a_bits_source;
    response_size<=auto_in_a_bits_size;
  end
  if(reset) occupied<=0;
  else case(occupied)
    1'b0:if(auto_in_a_valid) occupied<=1;
    1'b1:if(auto_in_d_ready) occupied<=0;
    default:occupied<=occupied;
  endcase
end

endmodule
