module dvbench_model (
input logic clk,rst_n,
output logic [31:0] imem_addr_o,
input logic [31:0] imem_rdata_i,
output logic [31:0] dmem_addr_o,dmem_wdata_o,
output logic [3:0] dmem_be_o,
output logic dmem_we_o,dmem_re_o,
input logic [31:0] dmem_rdata_i
);
logic [31:0] registers[32];
logic [31:0] program_counter, following_pc, destination_value;
logic [31:0] left_value,right_value,immediate,calculated,loaded;
logic [6:0] operation;
logic [2:0] function_code;
integer destination,source_left,source_right;
logic write_destination,taken;
logic [31:0] shifted_word;
always_comb begin
operation=imem_rdata_i[6:0];
function_code=imem_rdata_i[14:12];
destination=int'(imem_rdata_i[11:7]);
source_left=int'(imem_rdata_i[19:15]);
source_right=int'(imem_rdata_i[24:20]);
left_value=source_left==0 ? 0 : registers[source_left];
right_value=source_right==0 ? 0 : registers[source_right];
immediate={{20{imem_rdata_i[31]}},imem_rdata_i[31:20]};
following_pc=program_counter+4;
write_destination=0;
calculated=left_value+right_value;
destination_value=0;
loaded=dmem_rdata_i;
shifted_word=0;
taken=0;
dmem_we_o=operation==7'h23;
dmem_re_o=operation==7'h03;
dmem_wdata_o=right_value;
dmem_be_o=4'b1111;
case(operation)
7'h33,7'h13: begin
write_destination=1;
if(operation==7'h13) right_value=immediate;
case(function_code)
0: calculated=(operation==7'h33 && imem_rdata_i[31:25]==7'h20) ? left_value-right_value : left_value+right_value;
1: calculated=left_value << right_value[4:0];
2: calculated={31'b0,($signed(left_value)<$signed(right_value))};
3: calculated={31'b0,(left_value<right_value)};
4: calculated=left_value ^ right_value;
5: begin
if(imem_rdata_i[31:25]==7'h20) calculated=$signed(left_value) >>> right_value[4:0];
else calculated=left_value >> right_value[4:0];
end
6: calculated=left_value | right_value;
7: calculated=left_value & right_value;
endcase
destination_value=calculated;
end
7'h03: begin
write_destination=1;
calculated=left_value+immediate;
shifted_word=dmem_rdata_i >> (calculated[1:0]*8);
case(function_code)
0: loaded={{24{shifted_word[7]}},shifted_word[7:0]};
4: loaded={24'b0,shifted_word[7:0]};
1,5: begin
shifted_word=dmem_rdata_i >> (calculated[1]*16);
loaded=function_code==1 ? {{16{shifted_word[15]}},shifted_word[15:0]} : {16'b0,shifted_word[15:0]};
end
default: loaded=dmem_rdata_i;
endcase
destination_value=loaded;
end
7'h23: begin
immediate={{20{imem_rdata_i[31]}},imem_rdata_i[31:25],imem_rdata_i[11:7]};
calculated=left_value+immediate;
case(function_code)
0: begin dmem_wdata_o={24'b0,right_value[7:0]} << (calculated[1:0]*8); dmem_be_o=4'b0001 << calculated[1:0]; end
1: begin dmem_wdata_o={16'b0,right_value[15:0]} << (calculated[1]*16); dmem_be_o=4'b0011 << (calculated[1]*2); end
default: begin dmem_wdata_o=right_value; dmem_be_o=4'b1111; end
endcase
end
7'h63: begin
immediate={{19{imem_rdata_i[31]}},imem_rdata_i[31],imem_rdata_i[7],imem_rdata_i[30:25],imem_rdata_i[11:8],1'b0};
calculated=left_value-right_value;
case(function_code)
0: taken=left_value==right_value;
1: taken=left_value!=right_value;
4: taken=$signed(left_value)<$signed(right_value);
5: taken=$signed(left_value)>=$signed(right_value);
6: taken=left_value<right_value;
7: taken=left_value>=right_value;
default: taken=0;
endcase
if(taken) following_pc=program_counter+immediate;
end
7'h6f: begin
immediate={{11{imem_rdata_i[31]}},imem_rdata_i[31],imem_rdata_i[19:12],imem_rdata_i[20],imem_rdata_i[30:21],1'b0};
calculated=program_counter+immediate;
following_pc=calculated;
destination_value=program_counter+4;
write_destination=1;
end
7'h67: begin
calculated=left_value+immediate;
following_pc=calculated & 32'hfffffffe;
destination_value=program_counter+4;
write_destination=1;
end
7'h37: begin calculated={imem_rdata_i[31:12],12'b0}; destination_value=calculated; write_destination=1; end
7'h17: begin calculated=program_counter+{imem_rdata_i[31:12],12'b0}; destination_value=calculated; write_destination=1; end
default: begin end
endcase
imem_addr_o=program_counter;
dmem_addr_o=calculated;
end
always @(posedge clk) begin
if(!rst_n) begin
program_counter<=0;
for(integer register_index=0;register_index<32;register_index++) registers[register_index]<=0;
end else begin
program_counter<=following_pc;
if(write_destination && destination!=0) registers[destination]<=destination_value;
registers[0]<=0;
end
end
endmodule
