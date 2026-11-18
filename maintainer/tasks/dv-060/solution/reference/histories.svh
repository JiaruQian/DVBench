
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
 c='0;c.reset=0;
 c.dc2_message_valid=1;c.dc2_message_type=3;c.dc2_message_source=3;
 c.dc2_message_cache_hit=1;c.dc2_message_cache_valid=1;c.dc2_message_cache_state=5;
 c.dc2_message_cache_owner=3;c.dc2_message_cache_sharers_list=8;
 drive(c);
 c.dc2_message_valid=0;c.reset=1;drive_short_reset(c);
 c.reset=0;repeat(3)drive(c);
 c='0;c.reset=1;drive(c);c.reset=0;repeat(4)drive(c);
endtask
