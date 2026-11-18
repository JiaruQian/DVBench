package dvbench_stim;
function automatic logic [31:0] prng(input integer k,seed,lane);logic [31:0] x;x=32'h9e3779b9*(k+1)^seed^(32'h85ebca6b*lane);x^=x<<13;x^=x>>17;x^=x<<5;return x;endfunction
function automatic logic [386:0] original_sample_pins(input integer k,seed);
logic rst;
logic load;
logic start;
logic [127:0] key;
logic [127:0] iv;
logic [127:0] iBlock;
rst=(k<4 || k%350==0);load=(k%350==5 || k%350==180);start=(k%25==20 && k%350>20);
if(k%350>=250&&k%350<280)start=1;
if(k%350==180)start=1;
key={prng(k,seed,1),prng(k,seed,2),prng(k,seed,3),prng(k,seed,4)};
iv=(k%700<350)?128'hfffffffffffffffffffffffffffffffe:128'h80000000000000000000000000000001;
iBlock={prng(k,seed,5),prng(k,seed,6),prng(k,seed,7),prng(k,seed,8)};

return {rst,load,start,key,iv,iBlock};endfunction
function automatic logic [386:0] inherited_sample_pins(input integer k,seed);
logic rst,load,start;
logic [127:0] key,iv,iBlock;
if(k>=120)return original_sample_pins(k-120,seed);
rst=(k<4 || k>=116);
load=(k==4 || k==40 || k==76);
start=(k==20 || k==56 || k==92);
key=128'h000102030405060708090a0b0c0d0e0f;
iv=(k<40)?128'h0:(k<76)?128'h100:128'h80000000000000000000000000000000;
iBlock=128'h00112233445566778899aabbccddeeff;
return {rst,load,start,key,iv,iBlock};
endfunction
function automatic logic [386:0] sample_pins(input integer index,seed);
logic reset_value,load_value,start_value;
logic [127:0] key_value,iv_value,data_value;
integer case_index,phase_index;
if(index>=320)return inherited_sample_pins(index-320,seed);
case_index=index/80;
phase_index=index%80;
reset_value=(phase_index<4 || phase_index>=76);
load_value=(phase_index==4 || phase_index==40);
start_value=(phase_index==20 || phase_index==56);
iv_value=(case_index==0)?128'd0:(case_index==1)?128'd1:(case_index==2)?128'hffffffffffffffffffffffffffffffff:128'h80000000000000000000000000000000;
key_value=(phase_index<40)?128'h000102030405060708090a0b0c0d0e0f:(128'hf0e0d0c0b0a090807060504030201000 ^ (128'd1<<case_index));
data_value=128'h00112233445566778899aabbccddeeff;
return {reset_value,load_value,start_value,key_value,iv_value,data_value};
endfunction
endpackage
