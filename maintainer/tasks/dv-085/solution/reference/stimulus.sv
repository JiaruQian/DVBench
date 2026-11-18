package dvbench_stim;
function automatic logic [31:0] prng(input integer k,seed,lane);logic [31:0] x;x=32'h9e3779b9*(k+1)^seed^(32'h85ebca6b*lane);x^=x<<13;x^=x>>17;x^=x<<5;return x;endfunction
function automatic logic [293:0] original_sample_pins(input integer k,seed);
logic rst_ni;
logic instr_req_i;
logic [31:0] instr_addr_i;
logic flush_i;
logic mem_req_ack_i;
logic mem_rsp_valid_i;
logic [255:0] mem_rsp_data_i;
logic mem_rsp_last_i;
rst_ni=!(k<4 || k%700==0);instr_req_i=(k%12==4);flush_i=(k%700==400 || k%700==490 || k%700==550);

instr_addr_i=((k/12)%7)*4096+(((k/84)%3)*64)+((k/12)%16)*4;
if(k%96>=72&&k%96<84)instr_addr_i=32'h00001000;
mem_req_ack_i=(k%12>=6);mem_rsp_valid_i=(k%12==9);mem_rsp_last_i=k[4];
mem_rsp_data_i={prng(k,seed,2),prng(k,seed,3),prng(k,seed,4),prng(k,seed,5),prng(k,seed,6),prng(k,seed,7),prng(k,seed,8),prng(k,seed,9)};


// Query uses a live index distinct from the index at request acceptance.
if(k>=700&&k%12==5)instr_addr_i+=64;if(k>=700&&k%12==6)instr_addr_i+=128;
// Alternate flush while READ and simultaneous REFILL response histories.
if(k>=700&&k%700>=240&&k%700<252&&k%12==(((k/700)%2)?5:9))flush_i=1;

return {rst_ni,instr_req_i,instr_addr_i,flush_i,mem_req_ack_i,mem_rsp_valid_i,mem_rsp_data_i,mem_rsp_last_i};endfunction
function automatic logic [293:0] inherited_sample_pins(input integer k,seed);
integer witness_group, witness_phase;
logic [31:0] witness_address;
logic [255:0] witness_data;
if(k>=4096) return original_sample_pins(k-4096,seed);
witness_group=k/16;
witness_phase=k%16;
witness_address=32'h01234000+32'((witness_group%64)*64);
if(witness_phase>=12)
  witness_address=witness_address^(32'b1<<(28+witness_group/64));
witness_data={prng(k,seed,2),prng(k,seed,3),prng(k,seed,4),prng(k,seed,5),prng(k,seed,6),prng(k,seed,7),prng(k,seed,8),prng(k,seed,9)};
return {1'(witness_phase>=2),1'(witness_phase==2 || witness_phase==8 || witness_phase==12),witness_address,1'b0,1'(witness_phase==3 || witness_phase==13),1'(witness_phase==4 || witness_phase==14),witness_data,1'b1};
endfunction
function automatic logic [293:0] sample_pins(input integer k,seed);
integer witness_set,witness_phase;
logic [31:0] address;
logic [255:0] data;
if(k<8296) return inherited_sample_pins(k,seed);
witness_set=(k-8296)/32;
witness_phase=(k-8296)%32;
address=32'h51234000+32'(witness_set*64);
data={8{32'hc35aa53c^32'(witness_set)}};
return {1'(witness_phase>=2 && witness_phase!=16),1'(witness_phase==2 || witness_phase==8 || witness_phase==16),address,1'b0,1'(witness_phase==3),1'(witness_phase==4),data,1'b1};
endfunction
endpackage
