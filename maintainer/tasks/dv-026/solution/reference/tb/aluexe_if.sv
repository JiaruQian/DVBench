`timescale 1ns/1ps
interface aluexe_if;
logic clock;
logic reset;
logic auto_int_out_0;
logic auto_int_out_1;
logic auto_in_a_ready;
logic auto_in_a_valid;
logic [2:0] auto_in_a_bits_opcode;
logic [2:0] auto_in_a_bits_param;
logic [1:0] auto_in_a_bits_size;
logic [9:0] auto_in_a_bits_source;
logic [25:0] auto_in_a_bits_address;
logic [7:0] auto_in_a_bits_mask;
logic [63:0] auto_in_a_bits_data;
logic auto_in_a_bits_corrupt;
logic auto_in_d_ready;
logic auto_in_d_valid;
logic [2:0] auto_in_d_bits_opcode;
logic [1:0] auto_in_d_bits_size;
logic [9:0] auto_in_d_bits_source;
logic [63:0] auto_in_d_bits_data;
logic io_rtcTick;
logic expected_auto_int_out_0;
logic expected_auto_int_out_1;
logic expected_auto_in_a_ready;
logic expected_auto_in_d_valid;
logic [2:0] expected_auto_in_d_bits_opcode;
logic [1:0] expected_auto_in_d_bits_size;
logic [9:0] expected_auto_in_d_bits_source;
logic [63:0] expected_auto_in_d_bits_data;
logic [82:0] actual_bus,expected_bus;
assign actual_bus={auto_int_out_0,auto_int_out_1,auto_in_a_ready,auto_in_d_valid,auto_in_d_bits_opcode,auto_in_d_bits_size,auto_in_d_bits_source,auto_in_d_bits_data};
assign expected_bus={expected_auto_int_out_0,expected_auto_int_out_1,expected_auto_in_a_ready,expected_auto_in_d_valid,expected_auto_in_d_bits_opcode,expected_auto_in_d_bits_size,expected_auto_in_d_bits_source,expected_auto_in_d_bits_data};
task drive(input logic [120:0] value);
{reset,auto_in_a_valid,auto_in_a_bits_opcode,auto_in_a_bits_param,auto_in_a_bits_size,auto_in_a_bits_source,auto_in_a_bits_address,auto_in_a_bits_mask,auto_in_a_bits_data,auto_in_a_bits_corrupt,auto_in_d_ready,io_rtcTick}=value;
endtask
task prepare_carry_write(input int index);
  int group_index,phase_index,mask_index,upper_index;
  logic [31:0] upper_value,lower_value;
  logic tick_value;
  drive('0);
  auto_in_d_ready=1;
  auto_in_a_valid=1;
  auto_in_a_bits_opcode=1;
  auto_in_a_bits_size=3;
  auto_in_a_bits_address=26'h200bff8;
  auto_in_a_bits_mask=8'hff;
  if(index<4098) begin
    reset=1;
    auto_in_a_bits_opcode=0;
    auto_in_a_bits_address=26'h2004000;
    auto_in_a_bits_data=64'hffffffffffffffff;
    return;
  end
  group_index=(index-4098)/4;
  phase_index=(index-4098)%4;
  mask_index=group_index%18;
  upper_index=(group_index/18)%4;
  tick_value=(group_index/72)%2;
  lower_value=(group_index/144)%2 ? 32'hfffffffe : 32'hffffffff;
  case(upper_index)
    0:upper_value=0;
    1:upper_value=1;
    2:upper_value=32'h7fffffff;
    3:upper_value=32'hffffffff;
  endcase
  case(phase_index)
    0:begin
      auto_in_a_bits_opcode=0;
      auto_in_a_bits_data={upper_value,lower_value};
    end
    1:begin
      auto_in_a_bits_mask=mask_index<16 ? mask_index : mask_index==16 ? 8'hf0 : 8'hff;
      auto_in_a_bits_data=64'h0123456789abcdef;
      io_rtcTick=tick_value;
    end
    2:auto_in_a_bits_opcode=4;
    3:begin auto_in_a_bits_opcode=4;auto_in_a_valid=0;end
  endcase
endtask
task prepare(input int index);
  logic was_stalled;
  logic [7:0] lane_mask;
  integer lane;
  if(index>=4096) begin prepare_carry_write(index);return;end
  was_stalled=auto_in_a_valid && !auto_in_d_ready && !reset;
  io_rtcTick=$urandom_range(0,1);
  auto_in_d_ready=$urandom_range(0,1);
  reset=(index==0 || index==2048);
  if(!was_stalled || reset) begin
    auto_in_a_valid=$urandom_range(0,1);
    auto_in_a_bits_param=0;auto_in_a_bits_corrupt=0;
    auto_in_a_bits_source=$urandom_range(0,767);
    auto_in_a_bits_size=$urandom_range(0,3);
    case(index%3)
      0:auto_in_a_bits_opcode=4;
      1:auto_in_a_bits_opcode=0;
      2:auto_in_a_bits_opcode=1;
    endcase
    auto_in_a_bits_data={$urandom,$urandom};
    case((index/3)%6)
      0:auto_in_a_bits_address=26'h2000000;
      1:auto_in_a_bits_address=26'h2004000;
      2:auto_in_a_bits_address=26'h200bff8;
      3:auto_in_a_bits_address=26'h200c000;
      4:auto_in_a_bits_address=26'h2000100;
      5:auto_in_a_bits_address=26'h2004010;
    endcase
    lane=$urandom_range(0,7) & (7 << auto_in_a_bits_size);
    auto_in_a_bits_address=auto_in_a_bits_address+lane;
    lane_mask=((1 << (1 << auto_in_a_bits_size))-1) << lane;
    auto_in_a_bits_mask=(auto_in_a_bits_opcode==1)?($urandom_range(0,255)&lane_mask):lane_mask;
    if(index<1024) begin
      auto_in_a_valid=1;auto_in_a_bits_opcode=(index%4==0)?4:1;
      auto_in_a_bits_size=3;auto_in_a_bits_address=auto_in_a_bits_address & 26'h3fffff8;
      auto_in_a_bits_data=64'hfedcba9876543201;
      auto_in_a_bits_mask=(auto_in_a_bits_opcode==4)?255:(8'b1 << ((index/4)%8));
      auto_in_d_ready=(index%2==1);
    end
  end
  if(index==0 || index==2048) begin
    auto_in_a_valid=1;auto_in_d_ready=1;auto_in_a_bits_opcode=0;
    auto_in_a_bits_address=26'h2004000;auto_in_a_bits_size=3;auto_in_a_bits_mask=255;
    auto_in_a_bits_source=0;auto_in_a_bits_param=0;auto_in_a_bits_corrupt=0;auto_in_a_bits_data=64'hffffffffffffffff;
  end
  if(index>0 && index<16) begin
    auto_in_a_valid=1;auto_in_d_ready=1;auto_in_a_bits_opcode=1;auto_in_a_bits_size=3;
    auto_in_a_bits_source=0;auto_in_a_bits_param=0;auto_in_a_bits_corrupt=0;
    auto_in_a_bits_mask=255;auto_in_a_bits_data=0;reset=0;io_rtcTick=0;
    auto_in_a_bits_address=26'h200bff8;
    case(index)
      1:begin auto_in_a_bits_data=0;io_rtcTick=1;end
      2:begin auto_in_a_bits_address=26'h2004000;auto_in_a_bits_data=1;end
      3:begin auto_in_a_bits_opcode=4;io_rtcTick=1;end
      4:begin auto_in_a_bits_address=26'h2004000;auto_in_a_bits_opcode=4;end
      5:begin auto_in_a_bits_data=64'hffffffffffffffff;io_rtcTick=1;end
      6:begin auto_in_a_bits_opcode=4;io_rtcTick=1;end
      7:begin auto_in_a_bits_address=26'h2004000;auto_in_a_bits_opcode=4;end
      8:begin reset=1;auto_in_a_bits_address=26'h2004000;end
      9:begin reset=1;auto_in_a_valid=0;end
      10:begin auto_in_a_bits_address=26'h2000000;auto_in_a_bits_data=1;auto_in_a_bits_mask=1;end
      11:begin auto_in_a_bits_address=26'h2000000;auto_in_a_bits_opcode=4;end
      12:begin auto_in_a_bits_address=26'h2000000;auto_in_a_bits_mask=2;end
      13:begin auto_in_a_bits_address=26'h2000000;auto_in_a_bits_opcode=4;end
      14:begin auto_in_a_bits_mask=0;io_rtcTick=1;end
      15:begin auto_in_a_bits_opcode=4;end
    endcase
  end
endtask
endinterface
