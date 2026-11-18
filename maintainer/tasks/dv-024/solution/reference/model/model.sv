`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
output logic auto_in_a_ready,
input logic auto_in_a_valid,
input logic [2:0] auto_in_a_bits_opcode,
input logic [2:0] auto_in_a_bits_param,
input logic [2:0] auto_in_a_bits_size,
input logic [5:0] auto_in_a_bits_source,
input logic [12:0] auto_in_a_bits_address,
input logic [7:0] auto_in_a_bits_mask,
input logic [63:0] auto_in_a_bits_data,
input logic auto_in_a_bits_corrupt,
input logic auto_in_d_ready,
output logic auto_in_d_valid,
output logic [2:0] auto_in_d_bits_opcode,
output logic [1:0] auto_in_d_bits_param,
output logic [2:0] auto_in_d_bits_size,
output logic [5:0] auto_in_d_bits_source,
output logic auto_in_d_bits_sink,
output logic auto_in_d_bits_denied,
output logic [63:0] auto_in_d_bits_data,
output logic auto_in_d_bits_corrupt,
input logic auto_out_a_ready,
output logic auto_out_a_valid,
output logic [2:0] auto_out_a_bits_opcode,
output logic [2:0] auto_out_a_bits_param,
output logic [2:0] auto_out_a_bits_size,
output logic [5:0] auto_out_a_bits_source,
output logic [12:0] auto_out_a_bits_address,
output logic [7:0] auto_out_a_bits_mask,
output logic [63:0] auto_out_a_bits_data,
output logic auto_out_a_bits_corrupt,
output logic auto_out_d_ready,
input logic auto_out_d_valid,
input logic [2:0] auto_out_d_bits_opcode,
input logic [2:0] auto_out_d_bits_size,
input logic [5:0] auto_out_d_bits_source,
input logic [63:0] auto_out_d_bits_data
);
logic [1:0] request_count,response_count;
integer request_read,request_write,response_read,response_write;
logic [2:0] request_opcode[0:1];
assign auto_out_a_bits_opcode=request_opcode[request_read];
logic [2:0] request_param[0:1];
assign auto_out_a_bits_param=request_param[request_read];
logic [2:0] request_size[0:1];
assign auto_out_a_bits_size=request_size[request_read];
logic [5:0] request_source[0:1];
assign auto_out_a_bits_source=request_source[request_read];
logic [12:0] request_address[0:1];
assign auto_out_a_bits_address=request_address[request_read];
logic [7:0] request_mask[0:1];
assign auto_out_a_bits_mask=request_mask[request_read];
logic [63:0] request_data[0:1];
assign auto_out_a_bits_data=request_data[request_read];
logic request_corrupt[0:1];
assign auto_out_a_bits_corrupt=request_corrupt[request_read];
logic [2:0] response_opcode[0:1];
assign auto_in_d_bits_opcode=response_opcode[response_read];
logic [1:0] response_param[0:1];
assign auto_in_d_bits_param=response_param[response_read];
logic [2:0] response_size[0:1];
assign auto_in_d_bits_size=response_size[response_read];
logic [5:0] response_source[0:1];
assign auto_in_d_bits_source=response_source[response_read];
logic response_sink[0:1];
assign auto_in_d_bits_sink=response_sink[response_read];
logic response_denied[0:1];
assign auto_in_d_bits_denied=response_denied[response_read];
logic [63:0] response_data[0:1];
assign auto_in_d_bits_data=response_data[response_read];
logic response_corrupt[0:1];
assign auto_in_d_bits_corrupt=response_corrupt[response_read];
assign auto_in_a_ready=request_count<2;
assign auto_out_a_valid=request_count!=0;
assign auto_out_d_ready=response_count<2;
assign auto_in_d_valid=response_count!=0;
always @(posedge clock) begin
  if(request_count<2 && auto_in_a_valid) begin
    request_opcode[request_write]<=auto_in_a_bits_opcode;
    request_param[request_write]<=auto_in_a_bits_param;
    request_size[request_write]<=auto_in_a_bits_size;
    request_source[request_write]<=auto_in_a_bits_source;
    request_address[request_write]<=auto_in_a_bits_address;
    request_mask[request_write]<=auto_in_a_bits_mask;
    request_data[request_write]<=auto_in_a_bits_data;
    request_corrupt[request_write]<=auto_in_a_bits_corrupt;
  end
  if(reset) begin request_count<=0;request_read<=0;request_write<=0;end
  else begin
    if(request_count<2 && auto_in_a_valid) request_write<=(request_write+1)%2;
    if(request_count!=0 && auto_out_a_ready) request_read<=(request_read+1)%2;
    case({(request_count<2 && auto_in_a_valid),(request_count!=0 && auto_out_a_ready)})
      2'b10:request_count<=request_count+1;
      2'b01:request_count<=request_count-1;
      default:request_count<=request_count;
    endcase
  end
  if(response_count<2 && auto_out_d_valid) begin
    response_opcode[response_write]<=auto_out_d_bits_opcode;
    response_param[response_write]<='0;
    response_size[response_write]<=auto_out_d_bits_size;
    response_source[response_write]<=auto_out_d_bits_source;
    response_sink[response_write]<='0;
    response_denied[response_write]<='0;
    response_data[response_write]<=auto_out_d_bits_data;
    response_corrupt[response_write]<='0;
  end
  if(reset) begin response_count<=0;response_read<=0;response_write<=0;end
  else begin
    if(response_count<2 && auto_out_d_valid) response_write<=(response_write+1)%2;
    if(response_count!=0 && auto_in_d_ready) response_read<=(response_read+1)%2;
    case({(response_count<2 && auto_out_d_valid),(response_count!=0 && auto_in_d_ready)})
      2'b10:response_count<=response_count+1;
      2'b01:response_count<=response_count-1;
      default:response_count<=response_count;
    endcase
  end
end

endmodule
