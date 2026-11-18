`timescale 1ns/1ps
interface aluexe_if;
logic clock;
logic reset;
logic auto_in_a_ready;
logic auto_in_a_valid;
logic [2:0] auto_in_a_bits_opcode;
logic [2:0] auto_in_a_bits_param;
logic [1:0] auto_in_a_bits_size;
logic [9:0] auto_in_a_bits_source;
logic [27:0] auto_in_a_bits_address;
logic [7:0] auto_in_a_bits_mask;
logic [63:0] auto_in_a_bits_data;
logic auto_in_a_bits_corrupt;
logic auto_in_d_ready;
logic auto_in_d_valid;
logic [2:0] auto_in_d_bits_opcode;
logic [1:0] auto_in_d_bits_size;
logic [9:0] auto_in_d_bits_source;
logic [63:0] auto_in_d_bits_data;
logic expected_auto_in_a_ready;
logic expected_auto_in_d_valid;
logic [2:0] expected_auto_in_d_bits_opcode;
logic [1:0] expected_auto_in_d_bits_size;
logic [9:0] expected_auto_in_d_bits_source;
logic [63:0] expected_auto_in_d_bits_data;
logic [80:0] actual_bus,expected_bus;
assign actual_bus={auto_in_a_ready,auto_in_d_valid,auto_in_d_bits_opcode,auto_in_d_bits_size,auto_in_d_bits_source,auto_in_d_bits_data};
assign expected_bus={expected_auto_in_a_ready,expected_auto_in_d_valid,expected_auto_in_d_bits_opcode,expected_auto_in_d_bits_size,expected_auto_in_d_bits_source,expected_auto_in_d_bits_data};
task drive(input logic [121:0] value);
{reset,auto_in_a_valid,auto_in_a_bits_opcode,auto_in_a_bits_param,auto_in_a_bits_size,auto_in_a_bits_source,auto_in_a_bits_address,auto_in_a_bits_mask,auto_in_a_bits_data,auto_in_a_bits_corrupt,auto_in_d_ready}=value;
endtask
task prepare(input int index);
  integer lane;
  logic [7:0] lane_mask;
  reset=(index==0 || index==1028 || index==2048);
  auto_in_d_ready=(index%8==0 || index%8==4 || index%8>=6);
  auto_in_a_valid=(index%8==1 || index%8==3 || index%8==4 || index%8==5);
  if(index%8!=4 && index%8!=5) begin
    auto_in_a_bits_source=(index/2)%768;
    auto_in_a_bits_size=$urandom_range(0,3);
    auto_in_a_bits_opcode=(index%3==0)?4:((index%3==1)?0:1);
    auto_in_a_bits_param=0;
    auto_in_a_bits_corrupt=0;
    lane=$urandom_range(0,7) & (7 << auto_in_a_bits_size);
    auto_in_a_bits_address=(28'hc000000 | ($urandom & 28'h3fffff8))+lane;
    if(index<256) auto_in_a_bits_address=28'hc200000+lane;
    lane_mask=((1 << (1 << auto_in_a_bits_size))-1) << lane;
    auto_in_a_bits_mask=(auto_in_a_bits_opcode==1)?($urandom_range(0,255)&lane_mask):lane_mask;
    auto_in_a_bits_data={$urandom,$urandom};
  end
  if(index==0 || index==2048) begin
    auto_in_a_valid=1;auto_in_a_bits_opcode=4;
    auto_in_a_bits_source=0;auto_in_a_bits_size=3;auto_in_a_bits_address=28'hc000000;
    auto_in_a_bits_mask=255;auto_in_a_bits_param=0;auto_in_a_bits_corrupt=0;
  end
endtask

endinterface
