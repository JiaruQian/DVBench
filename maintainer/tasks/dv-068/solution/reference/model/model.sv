`timescale 1ns/1ps
module dvbench_model(
  input logic [12:0] auto_in_a_bits_address,
  input logic auto_in_a_bits_corrupt,
  input logic [63:0] auto_in_a_bits_data,
  input logic [7:0] auto_in_a_bits_mask,
  input logic [2:0] auto_in_a_bits_opcode,
  input logic [2:0] auto_in_a_bits_param,
  input logic [2:0] auto_in_a_bits_size,
  input logic [5:0] auto_in_a_bits_source,
  output logic auto_in_a_ready,
  input logic auto_in_a_valid,
  output logic [63:0] auto_in_d_bits_data,
  output logic [2:0] auto_in_d_bits_opcode,
  output logic [2:0] auto_in_d_bits_size,
  output logic [5:0] auto_in_d_bits_source,
  input logic auto_in_d_ready,
  output logic auto_in_d_valid,
  output logic [12:0] auto_out_a_bits_address,
  output logic auto_out_a_bits_corrupt,
  output logic [63:0] auto_out_a_bits_data,
  output logic [7:0] auto_out_a_bits_mask,
  output logic [2:0] auto_out_a_bits_opcode,
  output logic [2:0] auto_out_a_bits_param,
  output logic [1:0] auto_out_a_bits_size,
  output logic [9:0] auto_out_a_bits_source,
  input logic auto_out_a_ready,
  output logic auto_out_a_valid,
  input logic [63:0] auto_out_d_bits_data,
  input logic [2:0] auto_out_d_bits_opcode,
  input logic [1:0] auto_out_d_bits_size,
  input logic [9:0] auto_out_d_bits_source,
  output logic auto_out_d_ready,
  input logic auto_out_d_valid,
  input logic clock,
  input logic reset
);

  typedef struct packed {
    logic [2:0] opcode,param,size;
    logic [5:0] source;
    logic [12:0] address;
    logic [7:0] mask;
    logic corrupt;
  } request_header;
  request_header held,active;
  logic buffered,response_phase,request_phase;
  logic [2:0] request_remaining,response_remaining,response_size;
  logic [2:0] fragment,initial_remaining,first_response_size;
  logic suppress_response,repeat_request,save_request,request_valid;
  function automatic logic [2:0] reconstruct_size(input logic [2:0] number,input logic [1:0] size);
    case(number)
      0: reconstruct_size={1'b0,size};
      1: case(size) 0:reconstruct_size=4;1:reconstruct_size=5;2:reconstruct_size=6;3:reconstruct_size=4;endcase
      2: case(size) 0,1:reconstruct_size=5;2,3:reconstruct_size=7;endcase
      3: case(size) 0,1,3:reconstruct_size=5;2:reconstruct_size=7;endcase
      4,6: case(size) 0,2:reconstruct_size=6;1,3:reconstruct_size=7;endcase
      5,7: case(size) 1:reconstruct_size=7;default:reconstruct_size=6;endcase
      default: reconstruct_size=3'bx;
    endcase
  endfunction
  always_comb begin
    active=buffered ? held : {auto_in_a_bits_opcode,auto_in_a_bits_param,auto_in_a_bits_size,auto_in_a_bits_source,auto_in_a_bits_address,auto_in_a_bits_mask,auto_in_a_bits_corrupt};
    case(active.size)
      0,1,2,3:initial_remaining=0;
      4:initial_remaining=1;
      5:initial_remaining=3;
      default:initial_remaining=7;
    endcase
    fragment=request_remaining==0 ? initial_remaining : request_remaining-1'b1;
    request_valid=auto_in_a_valid|buffered;
    repeat_request=active.opcode[2] && fragment!=0;
    auto_in_a_ready=auto_out_a_ready && !buffered;
    save_request=auto_in_a_ready && auto_in_a_valid && repeat_request;
    auto_out_a_valid=request_valid;
    auto_out_a_bits_opcode=active.opcode;
    auto_out_a_bits_param=active.param;
    auto_out_a_bits_size=active.size>=4 ? 3 : active.size[1:0];
    auto_out_a_bits_source={active.source,~(request_remaining==0 ? response_phase : request_phase),fragment};
    auto_out_a_bits_address=active.address | ((initial_remaining & ~fragment)<<3);
    auto_out_a_bits_mask=buffered ? 8'hff : auto_in_a_bits_mask;
    auto_out_a_bits_data=auto_in_a_bits_data;
    auto_out_a_bits_corrupt=active.corrupt;
    suppress_response=!auto_out_d_bits_opcode[0] && auto_out_d_bits_source[2:0]!=0;
    auto_out_d_ready=auto_in_d_ready || suppress_response;
    auto_in_d_valid=auto_out_d_valid && !suppress_response;
    auto_in_d_bits_opcode=auto_out_d_bits_opcode;
    first_response_size=reconstruct_size(auto_out_d_bits_source[2:0],auto_out_d_bits_size);
    auto_in_d_bits_size=response_remaining==0 ? first_response_size : response_size;
    auto_in_d_bits_source=auto_out_d_bits_source[9:4];
    auto_in_d_bits_data=auto_out_d_bits_data;
  end
  always @(posedge clock) begin
    if(save_request) held<={auto_in_a_bits_opcode,auto_in_a_bits_param,auto_in_a_bits_size,auto_in_a_bits_source,auto_in_a_bits_address,auto_in_a_bits_mask,auto_in_a_bits_corrupt};
    if(request_remaining==0) request_phase<=response_phase;
    if(auto_out_d_valid && auto_out_d_ready && response_remaining==0) response_size<=first_response_size;
    if(reset) begin
      buffered<=0; request_remaining<=0; response_remaining<=0; response_phase<=0;
    end
    else begin
      if(auto_out_a_ready && request_valid && !repeat_request) buffered<=0;
      else if(save_request) buffered<=1;
      if(auto_out_a_ready && request_valid) request_remaining<=fragment;
      if(auto_out_d_valid && auto_out_d_ready) begin
        if(response_remaining==0) begin
          response_remaining<=auto_out_d_bits_source[2:0];
          response_phase<=auto_out_d_bits_source[3];
        end
        else if(auto_out_d_bits_opcode[0] || auto_out_d_bits_size==3) response_remaining<=response_remaining-1'b1;
      end
    end
  end
endmodule
