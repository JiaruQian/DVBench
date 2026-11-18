`timescale 1ns/1ps
module dvbench_model(
input logic nvdla_core_clk,
input logic nvdla_core_rstn,
input logic dc2cvt_dat_wr_en,
input logic [16:0] dc2cvt_dat_wr_addr,
input logic [63:0] dc2cvt_dat_wr_data,
input logic [11:0] dc2cvt_dat_wr_info_pd,
input logic img2cvt_dat_wr_en,
input logic [16:0] img2cvt_dat_wr_addr,
input logic [63:0] img2cvt_dat_wr_data,
input logic [127:0] img2cvt_mn_wr_data,
input logic [7:0] img2cvt_dat_wr_pad_mask,
input logic [11:0] img2cvt_dat_wr_info_pd,
input logic nvdla_hls_clk,
input logic nvdla_core_ng_clk,
input logic reg2dp_op_en,
input logic [1:0] reg2dp_in_precision,
input logic [1:0] reg2dp_proc_precision,
input logic reg2dp_cvt_en,
input logic [5:0] reg2dp_cvt_truncate,
input logic [15:0] reg2dp_cvt_offset,
input logic [15:0] reg2dp_cvt_scale,
input logic reg2dp_nan_to_zero,
input logic [15:0] reg2dp_pad_value,
input logic dp2reg_done,
output logic cdma2buf_dat_wr_en,
output logic [16:0] cdma2buf_dat_wr_addr,
output logic [63:0] cdma2buf_dat_wr_data,
output logic slcg_hls_en,
output logic [31:0] dp2reg_nan_data_num,
output logic [31:0] dp2reg_inf_data_num,
output logic dp2reg_dat_flush_done
);
logic active,conversion;
logic [1:0] precision;
logic [15:0] offset_value,scale_value,pad_value;
logic [5:0] shift_value;
logic [2:0] gate_history;
logic [4:0] valid_history,image_history;
logic [16:0] address_history[0:4];
logic [3:0] nonzero_history[0:4];
logic [7:0] pad_history[0:4];
logic [63:0] raw_input;
logic [127:0] mean_input;
logic use_mean,use_unsigned,input_pending,operand_valid;
logic input_cell_enable;
logic signed [16:0] operand_data[0:7];
logic signed [15:0] operand_subtrahend[0:7];
logic subtract_valid,multiply_valid;
logic signed [17:0] difference[0:7];
logic signed [33:0] product[0:7];
logic [15:0] converted[0:7];
logic [13:0] clear_index;
logic incoming;
logic [11:0] incoming_info;
logic [63:0] incoming_data;
logic [16:0] incoming_address;
logic [2:0] depth;
logic [63:0] final_data;
function automatic [15:0] finish_value(input logic signed [33:0] value,input logic [5:0] amount,input logic [1:0] mode);
longint signed quotient,remainder,divisor,rounded,limited;
begin
if(amount>=34)rounded=0;
else if(amount==0)rounded=value;
else begin
divisor=64'sd1<<amount;quotient=$signed(value)>>>amount;
remainder=$signed(value)-quotient*divisor;
rounded=quotient+((remainder*2>divisor)||(remainder*2==divisor&&value>=0));
end
if(rounded>65535)limited=65535;else if(rounded< -65536)limited=-65536;else limited=rounded;
if(mode==1)begin if(limited>32767)limited=32767;else if(limited< -32768)limited=-32768;end
else begin if(limited>127)limited=127;else if(limited< -128)limited=-128;end
finish_value=limited;
end
endfunction
always @* begin
incoming=dc2cvt_dat_wr_en||img2cvt_dat_wr_en;
incoming_info=(dc2cvt_dat_wr_en?dc2cvt_dat_wr_info_pd:0)|(img2cvt_dat_wr_en?img2cvt_dat_wr_info_pd:0);
incoming_data=(dc2cvt_dat_wr_en?dc2cvt_dat_wr_data:0)|(img2cvt_dat_wr_en?img2cvt_dat_wr_data:0);
incoming_address=(dc2cvt_dat_wr_en?dc2cvt_dat_wr_addr:0)|(img2cvt_dat_wr_en?img2cvt_dat_wr_addr:0);
depth=conversion?4:0;
for(integer lane=0;lane<8;lane++)begin
final_data[lane*8+:8]=conversion?converted[lane][7:0]:raw_input[lane*8+:8];
if(image_history[depth]&&pad_history[depth][lane])final_data[lane*8+:8]=pad_value[7:0];
end
if(!nonzero_history[depth][0])final_data=0;
slcg_hls_en=gate_history[2];
dp2reg_nan_data_num=0;dp2reg_inf_data_num=0;
dp2reg_dat_flush_done=clear_index[13];
end
always @(posedge nvdla_core_clk or negedge nvdla_core_rstn)begin
if(!nvdla_core_rstn)begin
active<=0;conversion<=0;precision<=0;offset_value<=0;scale_value<=0;pad_value<=0;shift_value<=0;gate_history<=0;
valid_history<=0;image_history<=0;use_mean<=0;use_unsigned<=0;input_pending<=0;input_cell_enable<=0;operand_valid<=0;
cdma2buf_dat_wr_data<=0;
for(integer stage=0;stage<5;stage++)begin address_history[stage]<=0;nonzero_history[stage]<=0;pad_history[stage]<=0;end
end else begin
active<=reg2dp_op_en&&!dp2reg_done;
if(reg2dp_op_en&&!dp2reg_done&&!active)begin conversion<=reg2dp_cvt_en;precision<=reg2dp_proc_precision;offset_value<=reg2dp_cvt_offset;scale_value<=reg2dp_cvt_scale;pad_value<=reg2dp_pad_value;shift_value<=reg2dp_cvt_truncate;end
gate_history<={gate_history[1:0],reg2dp_op_en&&reg2dp_cvt_en};
valid_history<={valid_history[3:0],incoming};image_history<={image_history[3:0],img2cvt_dat_wr_en};
if(incoming)begin address_history[0]<=incoming_address;nonzero_history[0]<=incoming_info[3:0];use_mean<=incoming_info[7];use_unsigned<=incoming_info[8];end
if(img2cvt_dat_wr_en)pad_history[0]<=img2cvt_dat_wr_pad_mask;
for(integer stage=1;stage<5;stage++)begin
if(valid_history[stage-1])begin address_history[stage]<=address_history[stage-1];nonzero_history[stage]<=nonzero_history[stage-1];end
if(image_history[stage-1])pad_history[stage]<=pad_history[stage-1];
end
input_pending<=incoming;
if(incoming||input_pending)input_cell_enable<=incoming&&conversion&&incoming_info[0];
if(input_pending||operand_valid)operand_valid<=input_cell_enable;
else operand_valid<=operand_valid;
cdma2buf_dat_wr_data<=final_data;
end
end
always @(posedge nvdla_core_clk)begin
if(incoming)raw_input<=incoming_data;
if(incoming&&incoming_info[7])mean_input<=img2cvt_mn_wr_data;
for(integer lane=0;lane<8;lane++)if(input_cell_enable)begin
operand_data[lane]<=use_unsigned?$signed({9'b0,raw_input[lane*8+:8]}):$signed(raw_input[lane*8+:8]);
operand_subtrahend[lane]<=use_mean?mean_input[lane*16+:16]:offset_value;
end
end
always @(posedge nvdla_hls_clk or negedge nvdla_core_rstn)begin
if(!nvdla_core_rstn)begin subtract_valid<=0;multiply_valid<=0;end
else begin subtract_valid<=operand_valid;multiply_valid<=subtract_valid;end
end
always @(posedge nvdla_hls_clk)begin
for(integer lane=0;lane<8;lane++)begin
if(operand_valid)difference[lane]<=$signed(operand_data[lane])-$signed(operand_subtrahend[lane]);
if(subtract_valid)product[lane]<=$signed(difference[lane])*$signed(scale_value);
if(multiply_valid)converted[lane]<=finish_value(product[lane],shift_value,precision);
end
end
always @(posedge nvdla_core_ng_clk or negedge nvdla_core_rstn)begin
if(!nvdla_core_rstn)begin clear_index<=0;cdma2buf_dat_wr_en<=0;cdma2buf_dat_wr_addr<=0;end
else begin
if(!clear_index[13])clear_index<=clear_index+1;
cdma2buf_dat_wr_en<=valid_history[depth]||!clear_index[13];
if(!clear_index[13])cdma2buf_dat_wr_addr<=clear_index;
else if(valid_history[depth])cdma2buf_dat_wr_addr<=address_history[depth];
end
end
endmodule
