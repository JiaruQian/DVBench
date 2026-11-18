module dvbench_model #(parameter TILE_ID=0,TILE_MEMORY_ID=0)(input logic clk,
input logic reset,
input logic ni_forwarded_request_network_available,
input logic instr_request_pending,
input logic [31:0] instr_request_address,
input logic dc2_message_valid,
input logic [4:0] dc2_message_type,
input logic [31:0] dc2_message_address,
input logic [511:0] dc2_message_data,
input logic [3:0] dc2_message_source,
input logic [2:0] dc2_replacement_state,
input logic [15:0] dc2_replacement_sharers_list,
input logic [3:0] dc2_replacement_owner,
input logic dc2_message_tshr_hit,
input logic [3:0] dc2_message_tshr_index,
input logic [55:0] dc2_message_tshr_entry_info,
input logic dc2_message_cache_hit,
input logic dc2_message_cache_valid,
input logic [2:0] dc2_message_cache_state,
input logic [15:0] dc2_message_cache_sharers_list,
input logic [3:0] dc2_message_cache_owner,
input logic [18:0] dc2_message_cache_tag,
input logic [511:0] dc2_message_cache_data,
input logic [2:0] dc2_message_cache_way,
input logic [3:0] tshr_empty_index,
output logic dc3_instr_request_dequeue,
output logic dc3_pending,
output logic [31:0] dc3_pending_address,
output logic dc3_update_cache_enable,
output logic dc3_update_cache_validity_bit,
output logic [6:0] dc3_update_cache_set,
output logic [2:0] dc3_update_cache_way,
output logic [18:0] dc3_update_cache_tag,
output logic [2:0] dc3_update_cache_state,
output logic [15:0] dc3_update_cache_sharers_list,
output logic [3:0] dc3_update_cache_owner,
output logic [511:0] dc3_update_cache_data,
output logic dc3_update_plru_en,
output logic [6:0] dc3_update_plru_set,
output logic [2:0] dc3_update_plru_way,
output logic dc3_update_tshr_enable,
output logic [3:0] dc3_update_tshr_index,
output logic [55:0] dc3_update_tshr_entry_info,
output logic dc3_replacement_enqueue,
output logic [570:0] dc3_replacement_request,
output logic dc3_wb_enable,
output logic [511:0] dc3_wb_data,
output logic [31:0] dc3_wb_addr,
output logic [42:0] dc3_forwarded_request,
output logic dc3_forwarded_request_valid,
output logic [15:0] dc3_forwarded_request_destinations,
output logic [623:0] dc3_response,
output logic dc3_response_valid,
output logic dc3_response_has_data,
output logic [15:0] dc3_response_destinations);

localparam N=0,M=1,S=2,I=3,SD=4,MA=5,ND=6,SA=7;
typedef enum logic[2:0] {NONE,CACHE,ALLOC,EDIT,RETIRE,DISCARD} storage_t;
storage_t store;
logic[2:0] state,next_state;
logic[15:0] sharers,new_sharers,requester,owner_bit,memory_bit;
logic[3:0] owner,new_owner,count;
logic[511:0] new_data;
logic[3:0] response_type,forward_type;
logic[15:0] response_dest,forward_dest;
logic invalidate,recycle,is_owner;
always_comb begin
 state=N;sharers=0;owner=TILE_MEMORY_ID;
 if(dc2_message_tshr_hit)begin
  state=dc2_message_tshr_entry_info[54:52];sharers=dc2_message_tshr_entry_info[19:4];owner=dc2_message_tshr_entry_info[3:0];
 end else if(dc2_message_cache_hit)begin
  state=dc2_message_cache_state;sharers=dc2_message_cache_sharers_list;owner=dc2_message_cache_owner;
 end else if(dc2_message_type==12)begin
  state=dc2_replacement_state;sharers=dc2_replacement_sharers_list;owner=dc2_replacement_owner;
 end
 requester=16'h1<<dc2_message_source;owner_bit=16'h1<<owner;memory_bit=16'h1<<TILE_MEMORY_ID;
 count=$countones(sharers);is_owner=owner==dc2_message_source;
 next_state=state;new_sharers=sharers;new_owner=owner;new_data=dc2_message_cache_data;
 store=NONE;response_type=0;forward_type=0;response_dest=sharers;forward_dest=sharers;invalidate=0;recycle=0;
 case(dc2_message_type)
 0:case(state)
  N:begin next_state=ND;new_sharers=sharers|requester;store=ALLOC;forward_type=4;forward_dest=memory_bit;end
  M:begin next_state=SD;new_sharers=sharers|requester|owner_bit;new_owner=TILE_ID;store=ALLOC;invalidate=1;forward_type=4;forward_dest=owner_bit;end
  S,I:begin next_state=S;new_sharers=sharers|requester;store=CACHE;response_type=9;response_dest=requester;end
  default:begin end
 endcase
 1:case(state)
  N:begin next_state=M;new_owner=dc2_message_source;store=CACHE;forward_type=5;forward_dest=memory_bit;end
  M:begin new_owner=dc2_message_source;store=CACHE;forward_type=5;forward_dest=owner_bit;end
  S:begin next_state=M;new_owner=dc2_message_source;new_sharers=0;store=CACHE;response_type=9;response_dest=requester;forward_type=6;forward_dest=sharers;end
  I:begin next_state=M;new_owner=dc2_message_source;store=CACHE;response_type=9;response_dest=requester;end
  default:begin end
 endcase
 2:case(state)
  N,M,I,ND:begin response_type=7;response_dest=requester;end
  S:begin response_type=7;response_dest=requester;new_sharers=sharers&~requester;if(count==1)next_state=I;store=CACHE;end
  SD,SA:begin response_type=7;response_dest=requester;new_sharers=sharers&~requester;store=EDIT;end
  default:begin end
 endcase
 3:case(state)
  N,I,ND:begin response_type=7;response_dest=requester;end
  M:begin response_type=7;response_dest=requester;if(is_owner)begin next_state=I;new_owner=TILE_ID;new_data=dc2_message_data;store=CACHE;end end
  S:if(!is_owner)begin response_type=7;response_dest=requester;new_sharers=sharers&~requester;store=CACHE;end
  SD:begin response_type=7;response_dest=requester;if(!is_owner)begin new_sharers=sharers&~requester;store=RETIRE;end end
  MA:begin response_type=7;response_dest=requester;recycle=is_owner;end
  default:begin end
 endcase
 9:if(state==SD||state==ND)begin next_state=S;new_data=dc2_message_data;store=RETIRE;end
 12:case(state)
  I:begin next_state=MA;store=ALLOC;response_type=11;response_dest=memory_bit;end
  S:begin next_state=SA;store=ALLOC;response_type=11;response_dest=memory_bit;forward_type=8;forward_dest=sharers;end
  M:begin next_state=MA;store=ALLOC;forward_type=8;forward_dest=owner_bit;end
  default:begin end
 endcase
 13:case(state)
  I:begin response_type=11;response_dest=memory_bit;end
  S:begin next_state=I;store=CACHE;response_type=11;response_dest=memory_bit;end
  M:begin forward_type=15;forward_dest=owner_bit;end
  default:begin end
 endcase
 14:if(state==MA||state==SA)begin next_state=N;store=DISCARD;invalidate=1;end
 16:begin response_type=11;response_dest=memory_bit;end
 default:begin end
 endcase
end
always_comb begin
 dc3_pending=dc2_message_valid||instr_request_pending;
 dc3_pending_address=dc2_message_valid?dc2_message_address:instr_request_address;
 dc3_update_cache_enable=0;dc3_update_tshr_enable=0;dc3_update_tshr_index=dc2_message_tshr_index;dc3_replacement_enqueue=0;
 case(store)
 CACHE,RETIRE:begin
  dc3_update_cache_enable=dc2_message_valid&&(dc2_message_type!=12);
  dc3_replacement_enqueue=dc3_update_cache_enable&&!dc2_message_cache_hit&&dc2_message_cache_valid;
  if(store==RETIRE)dc3_update_tshr_enable=dc2_message_valid;
 end
 ALLOC:begin
  dc3_update_tshr_enable=dc2_message_valid;dc3_update_tshr_index=tshr_empty_index;
  dc3_update_cache_enable=dc2_message_valid&&(dc2_message_type!=12)&&dc2_message_cache_hit;
 end
 EDIT,DISCARD:dc3_update_tshr_enable=dc2_message_valid;
 default:begin end
 endcase
 dc3_update_tshr_entry_info={(store==ALLOC||store==EDIT),next_state,dc2_message_address,new_sharers,new_owner};
 dc3_update_cache_validity_bit=!invalidate;
 dc3_update_cache_set=dc2_message_address[12:6];dc3_update_cache_way=dc2_message_cache_way;dc3_update_cache_tag=dc2_message_address[31:13];
 dc3_update_cache_state=next_state;dc3_update_cache_sharers_list=new_sharers;dc3_update_cache_owner=new_owner;dc3_update_cache_data=new_data;
 dc3_update_plru_en=dc2_message_valid;dc3_update_plru_set=dc2_message_address[12:6];dc3_update_plru_way=dc2_message_cache_way;
 dc3_replacement_request={dc2_message_cache_data,dc2_message_source,dc2_message_cache_tag,dc2_message_address[12:6],6'b0,dc2_message_cache_state,dc2_message_cache_sharers_list,dc2_message_cache_owner};
 dc3_forwarded_request=0;dc3_forwarded_request_valid=0;dc3_forwarded_request_destinations=0;dc3_instr_request_dequeue=0;
 if(dc2_message_valid&&forward_type!=0)begin
  dc3_forwarded_request_valid=1;dc3_forwarded_request={dc2_message_source,forward_type,dc2_message_address,1'b0,2'b0};dc3_forwarded_request_destinations=forward_dest;
 end else if(instr_request_pending&&ni_forwarded_request_network_available)begin
  dc3_forwarded_request_valid=1;dc3_forwarded_request={4'(TILE_ID),4'd4,instr_request_address,1'b1,2'd1};dc3_forwarded_request_destinations=memory_bit;dc3_instr_request_dequeue=1;
 end
 dc3_response_valid=dc2_message_valid&&(response_type!=0);dc3_response_has_data=response_type==9||response_type==11;
 dc3_response={(dc2_message_cache_hit&&dc2_message_type!=12)?dc2_message_cache_data:dc2_message_data,64'hffffffffffffffff,dc2_message_source,response_type,dc2_message_address,count,1'b1,1'b0,2'b0};
 dc3_response_destinations=response_dest;
end
always @(posedge clk or posedge reset)begin
 if(reset)dc3_wb_enable<=0;else dc3_wb_enable<=recycle;
end
always @(posedge clk)begin dc3_wb_data<=dc2_message_data;dc3_wb_addr<=dc2_message_address;end
endmodule
