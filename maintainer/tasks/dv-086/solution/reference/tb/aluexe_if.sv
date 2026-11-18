`timescale 1ns/1ps
interface aluexe_if;
logic clk;
logic rst_n;
logic invalid_i;
logic core_req_valid_i;
logic [31:0] core_req_addr_i;
logic [1:0] core_req_mask_i;
logic [2:0] core_req_wid_i;
logic flush_pipe_valid_i;
logic [2:0] flush_pipe_wid_i;
logic core_rsp_valid_o;
logic [31:0] core_rsp_addr_o;
logic [63:0] core_rsp_data_o;
logic [1:0] core_rsp_mask_o;
logic [2:0] core_rsp_wid_o;
logic core_rsp_status_o;
logic mem_rsp_ready_o;
logic mem_rsp_valid_i;
logic [2:0] mem_rsp_d_source_i;
logic [31:0] mem_rsp_d_addr_i;
logic [63:0] mem_rsp_d_data_i;
logic mem_req_ready_i;
logic mem_req_valid_o;
logic [2:0] mem_req_a_source_o;
logic [31:0] mem_req_a_addr_o;
logic expected_core_rsp_valid_o;
logic [31:0] expected_core_rsp_addr_o;
logic [63:0] expected_core_rsp_data_o;
logic [1:0] expected_core_rsp_mask_o;
logic [2:0] expected_core_rsp_wid_o;
logic expected_core_rsp_status_o;
logic expected_mem_rsp_ready_o;
logic expected_mem_req_valid_o;
logic [2:0] expected_mem_req_a_source_o;
logic [31:0] expected_mem_req_a_addr_o;
logic [139:0] actual_bus,expected_bus;
assign actual_bus={core_rsp_valid_o,core_rsp_addr_o,core_rsp_data_o,core_rsp_mask_o,core_rsp_wid_o,core_rsp_status_o,mem_rsp_ready_o,mem_req_valid_o,mem_req_a_source_o,mem_req_a_addr_o};
assign expected_bus={expected_core_rsp_valid_o,expected_core_rsp_addr_o,expected_core_rsp_data_o,expected_core_rsp_mask_o,expected_core_rsp_wid_o,expected_core_rsp_status_o,expected_mem_rsp_ready_o,expected_mem_req_valid_o,expected_mem_req_a_source_o,expected_mem_req_a_addr_o};
task drive(input logic [144:0] value);
{rst_n,invalid_i,core_req_valid_i,core_req_addr_i,core_req_mask_i,core_req_wid_i,flush_pipe_valid_i,flush_pipe_wid_i,mem_rsp_valid_i,mem_rsp_d_source_i,mem_rsp_d_addr_i,mem_rsp_d_data_i,mem_req_ready_i}=value;
endtask

logic [31:0] random_state;
integer seed_value,group_index,phase_index;
logic [31:0] request_address;
function automatic logic [31:0] next_random(input logic [31:0] value);
  next_random={value[30:0],value[31]^value[21]^value[1]^value[0]};
endfunction
task original_prepare(input integer index);
  if(index==0) begin
    if(!$value$plusargs("SEED=%d",seed_value))
      if(!$value$plusargs("ntb_random_seed=%d",seed_value)) seed_value=1;
    random_state=32'h91f2e5b7^seed_value;
  end
  random_state=next_random(random_state);
  rst_n=!(index<2 || index==2048 || index==3072);
  invalid_i=0;
  core_req_valid_i=0;
  core_req_addr_i=0;
  core_req_mask_i=random_state[1:0];
  core_req_wid_i=random_state[4:2];
  flush_pipe_valid_i=0;
  flush_pipe_wid_i=random_state[7:5];
  mem_rsp_valid_i=0;
  mem_rsp_d_source_i=random_state[10:8];
  mem_rsp_d_addr_i=0;
  mem_rsp_d_data_i={random_state,~random_state};
  mem_req_ready_i=1;
  group_index=(index-2)/16;
  phase_index=(index-2)%16;
  request_address={8'h9a,16'(group_index/32),5'(group_index%32),3'b000};
  if(index>=2 && index<2048) begin
    core_req_addr_i=request_address|32'(phase_index%8);
    core_req_valid_i=phase_index<4 || phase_index>=9;
    mem_req_ready_i=phase_index>=5;
    mem_rsp_valid_i=phase_index==7;
    mem_rsp_d_addr_i=request_address;
    mem_rsp_d_data_i={request_address^32'hc3a597e1,request_address^32'h37fd028a};
    flush_pipe_valid_i=group_index%13==7 && (phase_index==0 || phase_index==1);
    flush_pipe_wid_i=(phase_index==0) ? core_req_wid_i : 3'(group_index%8);
    invalid_i=group_index%17==11 && phase_index==13;
  end else if(index>=2048) begin
    core_req_valid_i=|random_state[1:0];
    core_req_addr_i={random_state[31:24],16'h0123,random_state[15:8]};
    mem_rsp_valid_i=random_state[3];
    mem_rsp_d_addr_i={random_state[31:24],16'h0123,random_state[23:16]};
    mem_req_ready_i=random_state[5];
    flush_pipe_valid_i=random_state[7:6]==2'b11;
    invalid_i=random_state[11:8]==4'hd;
  end
endtask

task inherited_prepare(input integer index);
  integer witness_group, witness_phase;
  logic [31:0] witness_address;
  if(index>=8192) begin
    original_prepare(index-8192);
  end else begin
    witness_group=index/32;
    witness_phase=index%32;
    witness_address=32'h81234000+32'((witness_group%32)*8);
    rst_n=witness_phase>=2;
    invalid_i=0;
    core_req_valid_i=witness_phase==2 || witness_phase==12 || witness_phase==16;
    core_req_addr_i=witness_address;
    if(witness_phase>=16)
      core_req_addr_i=witness_address^(32'b1<<(24+witness_group/32));
    core_req_mask_i=3;
    core_req_wid_i=witness_group%8;
    flush_pipe_valid_i=0;
    flush_pipe_wid_i=0;
    mem_rsp_valid_i=witness_phase==8;
    mem_rsp_d_source_i=0;
    mem_rsp_d_addr_i=witness_address;
    mem_rsp_d_data_i=64'h123456789abcdef0^64'(witness_group);
    mem_req_ready_i=1;
  end
endtask

task prepare(input integer index);
  integer witness_set, witness_phase;
  logic [31:0] witness_address;
  logic [63:0] witness_data;
  if(index<12288) inherited_prepare(index);
  else begin
    witness_set=(index-12288)/32;
    witness_phase=(index-12288)%32;
    witness_address=32'h81234000+32'(witness_set*8);
    witness_data=64'hc35aa53c17e8e817 ^ (64'(witness_set)*64'h0101010101010101);
    invalid_i=0;
    flush_pipe_valid_i=0;
    flush_pipe_wid_i=0;
    mem_rsp_d_source_i=0;
    rst_n=witness_phase>=2;
    core_req_addr_i=witness_address;
    core_req_mask_i=witness_set%4;
    core_req_wid_i=witness_set%8;
    core_req_valid_i=witness_phase==2 || witness_phase==10 || witness_phase==18;
    mem_req_ready_i=1;
    mem_rsp_valid_i=witness_phase==6;
    mem_rsp_d_addr_i=witness_address;
    mem_rsp_d_data_i=witness_data;
  end
endtask

endinterface
