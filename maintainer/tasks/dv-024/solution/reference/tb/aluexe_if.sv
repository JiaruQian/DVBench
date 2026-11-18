`timescale 1ns/1ps
interface aluexe_if;
logic clock;
logic reset;
logic auto_in_a_ready;
logic auto_in_a_valid;
logic [2:0] auto_in_a_bits_opcode;
logic [2:0] auto_in_a_bits_param;
logic [2:0] auto_in_a_bits_size;
logic [5:0] auto_in_a_bits_source;
logic [12:0] auto_in_a_bits_address;
logic [7:0] auto_in_a_bits_mask;
logic [63:0] auto_in_a_bits_data;
logic auto_in_a_bits_corrupt;
logic auto_in_d_ready;
logic auto_in_d_valid;
logic [2:0] auto_in_d_bits_opcode;
logic [1:0] auto_in_d_bits_param;
logic [2:0] auto_in_d_bits_size;
logic [5:0] auto_in_d_bits_source;
logic auto_in_d_bits_sink;
logic auto_in_d_bits_denied;
logic [63:0] auto_in_d_bits_data;
logic auto_in_d_bits_corrupt;
logic auto_out_a_ready;
logic auto_out_a_valid;
logic [2:0] auto_out_a_bits_opcode;
logic [2:0] auto_out_a_bits_param;
logic [2:0] auto_out_a_bits_size;
logic [5:0] auto_out_a_bits_source;
logic [12:0] auto_out_a_bits_address;
logic [7:0] auto_out_a_bits_mask;
logic [63:0] auto_out_a_bits_data;
logic auto_out_a_bits_corrupt;
logic auto_out_d_ready;
logic auto_out_d_valid;
logic [2:0] auto_out_d_bits_opcode;
logic [2:0] auto_out_d_bits_size;
logic [5:0] auto_out_d_bits_source;
logic [63:0] auto_out_d_bits_data;
logic expected_auto_in_a_ready;
logic expected_auto_in_d_valid;
logic [2:0] expected_auto_in_d_bits_opcode;
logic [1:0] expected_auto_in_d_bits_param;
logic [2:0] expected_auto_in_d_bits_size;
logic [5:0] expected_auto_in_d_bits_source;
logic expected_auto_in_d_bits_sink;
logic expected_auto_in_d_bits_denied;
logic [63:0] expected_auto_in_d_bits_data;
logic expected_auto_in_d_bits_corrupt;
logic expected_auto_out_a_valid;
logic [2:0] expected_auto_out_a_bits_opcode;
logic [2:0] expected_auto_out_a_bits_param;
logic [2:0] expected_auto_out_a_bits_size;
logic [5:0] expected_auto_out_a_bits_source;
logic [12:0] expected_auto_out_a_bits_address;
logic [7:0] expected_auto_out_a_bits_mask;
logic [63:0] expected_auto_out_a_bits_data;
logic expected_auto_out_a_bits_corrupt;
logic expected_auto_out_d_ready;
logic [185:0] actual_bus,expected_bus;
assign actual_bus={auto_in_a_ready,auto_in_d_valid,auto_in_d_bits_opcode,auto_in_d_bits_param,auto_in_d_bits_size,auto_in_d_bits_source,auto_in_d_bits_sink,auto_in_d_bits_denied,auto_in_d_bits_data,auto_in_d_bits_corrupt,auto_out_a_valid,auto_out_a_bits_opcode,auto_out_a_bits_param,auto_out_a_bits_size,auto_out_a_bits_source,auto_out_a_bits_address,auto_out_a_bits_mask,auto_out_a_bits_data,auto_out_a_bits_corrupt,auto_out_d_ready};
assign expected_bus={expected_auto_in_a_ready,expected_auto_in_d_valid,expected_auto_in_d_bits_opcode,expected_auto_in_d_bits_param,expected_auto_in_d_bits_size,expected_auto_in_d_bits_source,expected_auto_in_d_bits_sink,expected_auto_in_d_bits_denied,expected_auto_in_d_bits_data,expected_auto_in_d_bits_corrupt,expected_auto_out_a_valid,expected_auto_out_a_bits_opcode,expected_auto_out_a_bits_param,expected_auto_out_a_bits_size,expected_auto_out_a_bits_source,expected_auto_out_a_bits_address,expected_auto_out_a_bits_mask,expected_auto_out_a_bits_data,expected_auto_out_a_bits_corrupt,expected_auto_out_d_ready};
task drive(input logic [181:0] value);
{reset,auto_in_a_valid,auto_in_a_bits_opcode,auto_in_a_bits_param,auto_in_a_bits_size,auto_in_a_bits_source,auto_in_a_bits_address,auto_in_a_bits_mask,auto_in_a_bits_data,auto_in_a_bits_corrupt,auto_in_d_ready,auto_out_a_ready,auto_out_d_valid,auto_out_d_bits_opcode,auto_out_d_bits_size,auto_out_d_bits_source,auto_out_d_bits_data}=value;
endtask
integer response_head=0,response_tail=0;
integer response_write_left[0:47];
integer receive_left[0:47];
logic source_busy[0:47];
logic [2:0] response_opcode[0:32767],response_size[0:32767];
logic [5:0] response_source[0:32767];
logic [63:0] response_data[0:32767];
logic request_accepted=0;
integer request_left=0;
integer request_number=0;
always @(posedge clock) begin
  request_accepted=auto_in_a_valid && auto_in_a_ready;
  if(reset) begin
    response_head=0;response_tail=0;request_accepted=0;
    for(integer source=0;source<48;source=source+1) begin
      source_busy[source]=0;response_write_left[source]=0;receive_left[source]=0;
    end
  end else begin
    if(auto_in_a_valid && auto_in_a_ready) source_busy[auto_in_a_bits_source]=1;
    if(auto_in_d_valid && auto_in_d_ready) begin
      if(receive_left[auto_in_d_bits_source]==0)
        receive_left[auto_in_d_bits_source]=(auto_in_d_bits_opcode==1 && auto_in_d_bits_size>3)?((1 << (auto_in_d_bits_size-3))-1):0;
      else receive_left[auto_in_d_bits_source]=receive_left[auto_in_d_bits_source]-1;
      if(receive_left[auto_in_d_bits_source]==0) source_busy[auto_in_d_bits_source]=0;
    end
    if(auto_out_d_valid && auto_out_d_ready) response_head=response_head+1;
    if(auto_out_a_valid && auto_out_a_ready) begin
      if(auto_out_a_bits_opcode==4) begin
        for(integer beat=0;beat<((auto_out_a_bits_size>3)?(1 << (auto_out_a_bits_size-3)):1);beat=beat+1) begin
          response_opcode[response_tail]=1;response_size[response_tail]=auto_out_a_bits_size;
          response_source[response_tail]=auto_out_a_bits_source;response_data[response_tail]={$urandom,$urandom};
          response_tail=response_tail+1;
        end
      end else begin
        if(response_write_left[auto_out_a_bits_source]==0)
          response_write_left[auto_out_a_bits_source]=(auto_out_a_bits_size>3)?(1 << (auto_out_a_bits_size-3)):1;
        response_write_left[auto_out_a_bits_source]=response_write_left[auto_out_a_bits_source]-1;
        if(response_write_left[auto_out_a_bits_source]==0) begin
          response_opcode[response_tail]=0;response_size[response_tail]=auto_out_a_bits_size;
          response_source[response_tail]=auto_out_a_bits_source;response_data[response_tail]={$urandom,$urandom};
          response_tail=response_tail+1;
        end
      end
    end
  end
end
task prepare(input int index);
  integer chosen,domain_index,lane;
  logic [7:0] lane_mask;
  reset=(index==0 || index==2048);
  auto_out_a_ready=(index%32>=6) && $urandom_range(0,3)!=0;
  auto_in_d_ready=(index%48>=12) && $urandom_range(0,3)!=0;
  if(reset) begin
    auto_in_a_valid=0;auto_out_d_valid=0;request_left=0;
  end else begin
    if(request_accepted && request_left>0) request_left=request_left-1;
    if(auto_in_a_valid && !request_accepted) begin end
    else if(request_left>0) begin
      auto_in_a_valid=1;auto_in_a_bits_data={$urandom,$urandom};
      if(auto_in_a_bits_opcode==1) auto_in_a_bits_mask=$urandom_range(0,255);
    end else begin
      chosen=-1;
      for(integer candidate=0;candidate<27;candidate=candidate+1) begin
        domain_index=(request_number+candidate)%27;
        lane=(domain_index<10)?domain_index:((domain_index==10)?16:domain_index+21);
        if(chosen<0 && !source_busy[lane]) chosen=lane;
      end
      auto_in_a_valid=(chosen>=0 && $urandom_range(0,7)!=0);
      if(auto_in_a_valid) begin
        request_number=request_number+1;
        auto_in_a_bits_source=chosen;
        auto_in_a_bits_size=(request_number%11==0)?$urandom_range(4,6):$urandom_range(0,3);
        auto_in_a_bits_opcode=(request_number%3==0)?4:((request_number%3==1)?0:1);
        auto_in_a_bits_param=0;auto_in_a_bits_corrupt=(auto_in_a_bits_opcode==4)?0:$urandom_range(0,1);
        auto_in_a_bits_address=13'h1000 | (($urandom_range(0,4095) >> auto_in_a_bits_size) << auto_in_a_bits_size);
        lane=auto_in_a_bits_address[2:0];
        lane_mask=(auto_in_a_bits_size>=3)?255:(((1 << (1 << auto_in_a_bits_size))-1) << lane);
        auto_in_a_bits_mask=(auto_in_a_bits_opcode==1)?($urandom_range(0,255)&lane_mask):lane_mask;
        auto_in_a_bits_data={$urandom,$urandom};
        request_left=(auto_in_a_bits_opcode!=4 && auto_in_a_bits_size>3)?(1 << (auto_in_a_bits_size-3)):1;
      end
    end
    auto_out_d_valid=(response_head<response_tail) && (auto_out_d_valid || $urandom_range(0,3)!=0);
    if(auto_out_d_valid) begin
      auto_out_d_bits_opcode=response_opcode[response_head];
      auto_out_d_bits_size=response_size[response_head];
      auto_out_d_bits_source=response_source[response_head];
      auto_out_d_bits_data=response_data[response_head];
    end
  end
endtask

endinterface
