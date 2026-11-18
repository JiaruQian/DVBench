module dvbench_model(
input logic dbg_halt_st,
input logic exec_cycle,
input logic [11:0] inst_alu,
input logic inst_bw,
input logic [7:0] inst_jmp,
input logic [7:0] inst_so,
input logic [15:0] op_dst,
input logic [15:0] op_src,
input logic [3:0] status,
output logic [15:0] alu_out,
output logic [15:0] alu_out_add,
output logic [3:0] alu_stat,
output logic [3:0] alu_stat_wr
);
integer source_value, destination_value, addition, decimal_value, carry_value, digit_value, selected, short_value, shift_value, sign_index;
logic jump_ok, fill_bit, negative_flag, zero_flag, carry_flag, overflow_flag;
integer digit_index;
always @* begin
source_value=op_src;
destination_value=op_dst;
if(exec_cycle && inst_alu[0]) source_value=65535-source_value;
if(exec_cycle && inst_bw) begin source_value=source_value%256; destination_value=destination_value%256; end
jump_ok=1;
if(inst_jmp[0] && status[1]) jump_ok=0;
if(inst_jmp[1] && !status[1]) jump_ok=0;
if(inst_jmp[2] && status[0]) jump_ok=0;
if(inst_jmp[3] && !status[0]) jump_ok=0;
if(inst_jmp[4] && !status[2]) jump_ok=0;
if(inst_jmp[5] && (status[3]!=status[2])) jump_ok=0;
if(inst_jmp[6] && (status[3]==status[2])) jump_ok=0;
addition=destination_value;
if(jump_ok) addition=addition+source_value;
alu_out_add=addition%65536;
decimal_value=0;
carry_value=status[0];
for(digit_index=0;digit_index<4;digit_index=digit_index+1) begin
digit_value=((source_value>>(4*digit_index))&15)+((destination_value>>(4*digit_index))&15)+carry_value;
if(digit_value>=10) digit_value=(digit_value+6)%32;
carry_value=digit_value/16;
decimal_value=decimal_value+((digit_value%16)<<(4*digit_index));
end
decimal_value=decimal_value+(carry_value<<16);
short_value=0;
shift_value=0;
if(inst_alu[4]) short_value=short_value|(source_value&destination_value);
if(inst_alu[5]) short_value=short_value|(source_value|destination_value);
if(inst_alu[6]) short_value=short_value|(source_value^destination_value);
fill_bit=inst_so[0]?status[0]:(inst_bw?op_src[7]:op_src[15]);
if(inst_alu[10]) begin
shift_value=(op_src>>1)&32767;
if(inst_bw) shift_value=(shift_value & ~128) | (fill_bit?128:0);
shift_value=shift_value|(fill_bit?32768:0);
short_value=short_value|shift_value;
end
if(inst_so[1]) short_value=short_value|((op_src%256)*256+op_src/256);
if(inst_so[3]) short_value=short_value|((op_src%256)+(op_src[7]?65280:0));
if(!(inst_alu[4]||inst_alu[5]||inst_alu[6]||inst_alu[10]||inst_so[1]||inst_so[3])) short_value=source_value;
selected=short_value;
if(inst_alu[7]) selected=decimal_value;
if(inst_so[7]||dbg_halt_st||inst_alu[3]) selected=addition+((exec_cycle&&(inst_alu[1]||(inst_alu[2]&&status[0])))?1:0);
alu_out=selected%65536;
sign_index=inst_bw?7:15;
negative_flag=alu_out[sign_index];
zero_flag=inst_bw?(alu_out[7:0]==0):(alu_out==0);
carry_flag=inst_bw?alu_out[8]:((selected>>16)&1);
overflow_flag=(((source_value>>sign_index)&1)==((destination_value>>sign_index)&1)) && (((source_value>>sign_index)&1)!=negative_flag);
if(inst_alu[6]) begin overflow_flag=((source_value>>sign_index)&1)&&((destination_value>>sign_index)&1); carry_flag=!zero_flag; end
if(inst_alu[8]) begin overflow_flag=0; carry_flag=!zero_flag; end
if(inst_alu[10]) begin overflow_flag=0; carry_flag=source_value%2; end
alu_stat={overflow_flag,negative_flag,zero_flag,carry_flag};
alu_stat_wr=(exec_cycle&&inst_alu[9])?4'b1111:4'b0000;
end
endmodule
