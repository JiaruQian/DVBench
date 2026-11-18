package port_types;
typedef struct packed {
logic reset;
logic ni_forwarded_request_network_available;
logic instr_request_pending;
logic [31:0] instr_request_address;
logic dc2_message_valid;
logic [4:0] dc2_message_type;
logic [31:0] dc2_message_address;
logic [511:0] dc2_message_data;
logic [3:0] dc2_message_source;
logic [2:0] dc2_replacement_state;
logic [15:0] dc2_replacement_sharers_list;
logic [3:0] dc2_replacement_owner;
logic dc2_message_tshr_hit;
logic [3:0] dc2_message_tshr_index;
logic [55:0] dc2_message_tshr_entry_info;
logic dc2_message_cache_hit;
logic dc2_message_cache_valid;
logic [2:0] dc2_message_cache_state;
logic [15:0] dc2_message_cache_sharers_list;
logic [3:0] dc2_message_cache_owner;
logic [18:0] dc2_message_cache_tag;
logic [511:0] dc2_message_cache_data;
logic [2:0] dc2_message_cache_way;
logic [3:0] tshr_empty_index;
} command_t;
typedef struct packed {
logic dc3_instr_request_dequeue;
logic dc3_pending;
logic [31:0] dc3_pending_address;
logic dc3_update_cache_enable;
logic dc3_update_cache_validity_bit;
logic [6:0] dc3_update_cache_set;
logic [2:0] dc3_update_cache_way;
logic [18:0] dc3_update_cache_tag;
logic [2:0] dc3_update_cache_state;
logic [15:0] dc3_update_cache_sharers_list;
logic [3:0] dc3_update_cache_owner;
logic [511:0] dc3_update_cache_data;
logic dc3_update_plru_en;
logic [6:0] dc3_update_plru_set;
logic [2:0] dc3_update_plru_way;
logic dc3_update_tshr_enable;
logic [3:0] dc3_update_tshr_index;
logic [55:0] dc3_update_tshr_entry_info;
logic dc3_replacement_enqueue;
logic [570:0] dc3_replacement_request;
logic dc3_wb_enable;
logic [511:0] dc3_wb_data;
logic [31:0] dc3_wb_addr;
logic [42:0] dc3_forwarded_request;
logic dc3_forwarded_request_valid;
logic [15:0] dc3_forwarded_request_destinations;
logic [623:0] dc3_response;
logic dc3_response_valid;
logic dc3_response_has_data;
logic [15:0] dc3_response_destinations;
} response_t;
endpackage
module native_d_tb;import port_types::*;logic clk=0;always #5 clk=~clk;command_t c;response_t actual,expected;int points=0,mismatches=0,seed;
directory_controller_stage3 dut(.clk(clk),.reset(c.reset),.ni_forwarded_request_network_available(c.ni_forwarded_request_network_available),.instr_request_pending(c.instr_request_pending),.instr_request_address(c.instr_request_address),.dc2_message_valid(c.dc2_message_valid),.dc2_message_type(c.dc2_message_type),.dc2_message_address(c.dc2_message_address),.dc2_message_data(c.dc2_message_data),.dc2_message_source(c.dc2_message_source),.dc2_replacement_state(c.dc2_replacement_state),.dc2_replacement_sharers_list(c.dc2_replacement_sharers_list),.dc2_replacement_owner(c.dc2_replacement_owner),.dc2_message_tshr_hit(c.dc2_message_tshr_hit),.dc2_message_tshr_index(c.dc2_message_tshr_index),.dc2_message_tshr_entry_info(c.dc2_message_tshr_entry_info),.dc2_message_cache_hit(c.dc2_message_cache_hit),.dc2_message_cache_valid(c.dc2_message_cache_valid),.dc2_message_cache_state(c.dc2_message_cache_state),.dc2_message_cache_sharers_list(c.dc2_message_cache_sharers_list),.dc2_message_cache_owner(c.dc2_message_cache_owner),.dc2_message_cache_tag(c.dc2_message_cache_tag),.dc2_message_cache_data(c.dc2_message_cache_data),.dc2_message_cache_way(c.dc2_message_cache_way),.tshr_empty_index(c.tshr_empty_index),.dc3_instr_request_dequeue(actual.dc3_instr_request_dequeue),.dc3_pending(actual.dc3_pending),.dc3_pending_address(actual.dc3_pending_address),.dc3_update_cache_enable(actual.dc3_update_cache_enable),.dc3_update_cache_validity_bit(actual.dc3_update_cache_validity_bit),.dc3_update_cache_set(actual.dc3_update_cache_set),.dc3_update_cache_way(actual.dc3_update_cache_way),.dc3_update_cache_tag(actual.dc3_update_cache_tag),.dc3_update_cache_state(actual.dc3_update_cache_state),.dc3_update_cache_sharers_list(actual.dc3_update_cache_sharers_list),.dc3_update_cache_owner(actual.dc3_update_cache_owner),.dc3_update_cache_data(actual.dc3_update_cache_data),.dc3_update_plru_en(actual.dc3_update_plru_en),.dc3_update_plru_set(actual.dc3_update_plru_set),.dc3_update_plru_way(actual.dc3_update_plru_way),.dc3_update_tshr_enable(actual.dc3_update_tshr_enable),.dc3_update_tshr_index(actual.dc3_update_tshr_index),.dc3_update_tshr_entry_info(actual.dc3_update_tshr_entry_info),.dc3_replacement_enqueue(actual.dc3_replacement_enqueue),.dc3_replacement_request(actual.dc3_replacement_request),.dc3_wb_enable(actual.dc3_wb_enable),.dc3_wb_data(actual.dc3_wb_data),.dc3_wb_addr(actual.dc3_wb_addr),.dc3_forwarded_request(actual.dc3_forwarded_request),.dc3_forwarded_request_valid(actual.dc3_forwarded_request_valid),.dc3_forwarded_request_destinations(actual.dc3_forwarded_request_destinations),.dc3_response(actual.dc3_response),.dc3_response_valid(actual.dc3_response_valid),.dc3_response_has_data(actual.dc3_response_has_data),.dc3_response_destinations(actual.dc3_response_destinations));
dvbench_model model(.clk(clk),.reset(c.reset),.ni_forwarded_request_network_available(c.ni_forwarded_request_network_available),.instr_request_pending(c.instr_request_pending),.instr_request_address(c.instr_request_address),.dc2_message_valid(c.dc2_message_valid),.dc2_message_type(c.dc2_message_type),.dc2_message_address(c.dc2_message_address),.dc2_message_data(c.dc2_message_data),.dc2_message_source(c.dc2_message_source),.dc2_replacement_state(c.dc2_replacement_state),.dc2_replacement_sharers_list(c.dc2_replacement_sharers_list),.dc2_replacement_owner(c.dc2_replacement_owner),.dc2_message_tshr_hit(c.dc2_message_tshr_hit),.dc2_message_tshr_index(c.dc2_message_tshr_index),.dc2_message_tshr_entry_info(c.dc2_message_tshr_entry_info),.dc2_message_cache_hit(c.dc2_message_cache_hit),.dc2_message_cache_valid(c.dc2_message_cache_valid),.dc2_message_cache_state(c.dc2_message_cache_state),.dc2_message_cache_sharers_list(c.dc2_message_cache_sharers_list),.dc2_message_cache_owner(c.dc2_message_cache_owner),.dc2_message_cache_tag(c.dc2_message_cache_tag),.dc2_message_cache_data(c.dc2_message_cache_data),.dc2_message_cache_way(c.dc2_message_cache_way),.tshr_empty_index(c.tshr_empty_index),.dc3_instr_request_dequeue(expected.dc3_instr_request_dequeue),.dc3_pending(expected.dc3_pending),.dc3_pending_address(expected.dc3_pending_address),.dc3_update_cache_enable(expected.dc3_update_cache_enable),.dc3_update_cache_validity_bit(expected.dc3_update_cache_validity_bit),.dc3_update_cache_set(expected.dc3_update_cache_set),.dc3_update_cache_way(expected.dc3_update_cache_way),.dc3_update_cache_tag(expected.dc3_update_cache_tag),.dc3_update_cache_state(expected.dc3_update_cache_state),.dc3_update_cache_sharers_list(expected.dc3_update_cache_sharers_list),.dc3_update_cache_owner(expected.dc3_update_cache_owner),.dc3_update_cache_data(expected.dc3_update_cache_data),.dc3_update_plru_en(expected.dc3_update_plru_en),.dc3_update_plru_set(expected.dc3_update_plru_set),.dc3_update_plru_way(expected.dc3_update_plru_way),.dc3_update_tshr_enable(expected.dc3_update_tshr_enable),.dc3_update_tshr_index(expected.dc3_update_tshr_index),.dc3_update_tshr_entry_info(expected.dc3_update_tshr_entry_info),.dc3_replacement_enqueue(expected.dc3_replacement_enqueue),.dc3_replacement_request(expected.dc3_replacement_request),.dc3_wb_enable(expected.dc3_wb_enable),.dc3_wb_data(expected.dc3_wb_data),.dc3_wb_addr(expected.dc3_wb_addr),.dc3_forwarded_request(expected.dc3_forwarded_request),.dc3_forwarded_request_valid(expected.dc3_forwarded_request_valid),.dc3_forwarded_request_destinations(expected.dc3_forwarded_request_destinations),.dc3_response(expected.dc3_response),.dc3_response_valid(expected.dc3_response_valid),.dc3_response_has_data(expected.dc3_response_has_data),.dc3_response_destinations(expected.dc3_response_destinations));

task drive(input command_t value);
 @(negedge clk);c=value;#1;points++;
 if(actual!==expected)begin mismatches++;if(mismatches<=12)$display("D_MISMATCH point=%0d phase=comb actual=%h expected=%h",points,actual,expected);end
 @(posedge clk);#1;points++;
 if(actual!==expected)begin mismatches++;if(mismatches<=12)$display("D_MISMATCH point=%0d phase=clock actual=%h expected=%h",points,actual,expected);end
endtask

task histories();
 command_t c;
 c='0;c.reset=1;repeat(3)drive(c);c.reset=0;
 // Exhaust all external metadata states and message encodings; both source/owner relations,
 // hit-selection precedence, message-valid and network availability.
 for(int st=0;st<8;st++)for(int msg=0;msg<32;msg++)for(int flags=0;flags<64;flags++)begin
  c='0;
  c.dc2_message_valid=flags[0];c.dc2_message_tshr_hit=flags[1];c.dc2_message_cache_hit=flags[2];c.dc2_message_cache_valid=flags[3];
  c.ni_forwarded_request_network_available=flags[4];c.instr_request_pending=flags[5];
  c.dc2_message_type=msg;c.dc2_message_source=(flags%2)?4'd3:4'd7;
  c.dc2_message_cache_state=st;c.dc2_replacement_state=st;
  c.dc2_message_cache_owner=3;c.dc2_replacement_owner=3;
  c.dc2_message_cache_sharers_list=(flags%3==0)?16'hffff:((flags%3==1)?16'h8:16'h8080);
  c.dc2_replacement_sharers_list=c.dc2_message_cache_sharers_list;
  c.dc2_message_address=$urandom;c.instr_request_address=$urandom;
  c.dc2_message_tshr_entry_info={1'b1,3'(st),32'($urandom),c.dc2_message_cache_sharers_list,4'd3};
  c.dc2_message_tshr_index=$urandom;c.tshr_empty_index=$urandom;c.dc2_message_cache_way=$urandom;c.dc2_message_cache_tag=$urandom;
  for(int k=0;k<16;k++)begin c.dc2_message_data[k*32+:32]=$urandom;c.dc2_message_cache_data[k*32+:32]=$urandom;end
  drive(c);
 end
 for(int n=0;n<1000;n++)begin
  for(int k=0;k<$bits(command_t);k+=1)c[k]=$urandom_range(0,1);
  c.reset=n%71==0;
  drive(c);
 end
 c='0;c.reset=1;drive(c);c.reset=0;repeat(4)drive(c);
endtask

initial begin
 c='0;c.reset=1;if(!$value$plusargs("SEED=%d",seed))seed=1;seed=$urandom(seed);
 histories();$display("D_RESULT checks=%0d mismatches=%0d",points,mismatches);$finish;
end
endmodule
