`timescale 1ns/1ps
module dvbench_model(
input logic gray0_src_clk,
input logic [3:0] gray0_src_in_bin,
input logic gray0_dest_clk,
output logic [3:0] gray0_dest_out_bin,
input logic gray1_src_clk,
input logic [3:0] gray1_src_in_bin,
input logic gray1_dest_clk,
output logic [3:0] gray1_dest_out_bin,
input logic gray2_src_clk,
input logic [1:0] gray2_src_in_bin,
input logic gray2_dest_clk,
output logic [1:0] gray2_dest_out_bin,
input logic gray3_src_clk,
input logic gray3_src_in_bin,
input logic gray3_dest_clk,
output logic gray3_dest_out_bin,
input logic [3:0] b2g_A,
output logic [3:0] b2g_Z,
input logic [3:0] g2b_A,
output logic [3:0] g2b_Z,
input logic hclk,
input logic hrstn,
input logic sync_serial_i,
output logic sync_serial_o,
input logic spill_valid_i,
input logic [7:0] spill_data_i,
input logic spill_ready_i,
output logic spill_ready_o,
output logic spill_valid_o,
output logic [7:0] spill_data_o,
input logic flush_valid_i,
input logic [7:0] flush_data_i,
input logic flush_ready_i,
input logic flush_flush_i,
output logic flush_ready_o,
output logic flush_valid_o,
output logic [7:0] flush_data_o,
input logic bypass_valid_i,
input logic [7:0] bypass_data_i,
input logic bypass_ready_i,
output logic bypass_ready_o,
output logic bypass_valid_o,
output logic [7:0] bypass_data_o,
input logic hrst,
input logic [1:0] debug_mode,
input logic [31:0] debug_debug_wb_pc,
input logic [31:0] debug_debug_wb_instr,
input logic [31:0] debug_debug_wb_rf_wdata,
output logic [3:0] debug_data,
input logic single0_src_in,
input logic hclk2,
output logic single0_dest_out,
input logic single1_src_in,
output logic single1_dest_out,
input logic sync_reset_src_rst,
output logic sync_reset_dest_rst,
input logic [3:0] array0_src_in,
output logic [3:0] array0_dest_out,
input logic [1:0] array1_src_in,
output logic [1:0] array1_dest_out,
input logic pulse0_src_pulse,
input logic pulse0_src_rst,
input logic pulse0_dest_rst,
output logic pulse0_dest_pulse,
input logic pulse1_src_pulse,
output logic pulse1_dest_pulse,
input logic async_reset0_src_arst,
output logic async_reset0_dest_arst,
input logic async_reset1_src_arst,
output logic async_reset1_dest_arst
);
logic [3:0] gray0_history[0:2];
logic [3:0] gray0_capture;
always @(posedge gray0_src_clk) gray0_capture <= gray0_src_in_bin;
always @(posedge gray0_dest_clk) begin
for(integer stage=2;stage>0;stage--) gray0_history[stage]<=gray0_history[stage-1];
gray0_history[0]<=gray0_capture;
end
assign gray0_dest_out_bin=gray0_history[2];
logic [3:0] gray1_history[0:3];
logic [3:0] gray1_capture;
always @(posedge gray1_src_clk) gray1_capture <= gray1_src_in_bin;
always @(posedge gray1_dest_clk) begin
for(integer stage=3;stage>0;stage--) gray1_history[stage]<=gray1_history[stage-1];
gray1_history[0]<=gray1_capture;
end
assign gray1_dest_out_bin=gray1_history[3];
logic [1:0] gray2_history[0:3];
logic [1:0] gray2_capture;
always @(posedge gray2_src_clk) gray2_capture <= gray2_src_in_bin;
always @(posedge gray2_dest_clk) begin
for(integer stage=3;stage>0;stage--) gray2_history[stage]<=gray2_history[stage-1];
gray2_history[0]<=gray2_capture;
end
assign gray2_dest_out_bin=gray2_history[3];
logic [0:0] gray3_history[0:1];
logic [0:0] gray3_capture;
always @(posedge gray3_src_clk) gray3_capture <= gray3_src_in_bin;
always @(posedge gray3_dest_clk) begin
for(integer stage=1;stage>0;stage--) gray3_history[stage]<=gray3_history[stage-1];
gray3_history[0]<=gray3_capture;
end
assign gray3_dest_out_bin=gray3_history[1];
assign b2g_Z=b2g_A ^ (b2g_A >> 1);
always @* begin for(integer bit_index=0;bit_index<4;bit_index++) g2b_Z[bit_index]=^(g2b_A >> bit_index); end
logic [0:0] sync_history[0:1];
always @(posedge hclk or negedge hrstn) begin
if(!hrstn) begin for(integer stage=0;stage<2;stage++) sync_history[stage]<=0; end else begin
for(integer stage=1;stage>0;stage--) sync_history[stage]<=sync_history[stage-1];
sync_history[0]<=sync_serial_i;
end
end
assign sync_serial_o=sync_history[1];
logic [7:0] spill_queue[0:1];
integer spill_count;
assign spill_ready_o=spill_count<2;
assign spill_valid_o=spill_count!=0;
assign spill_data_o=spill_queue[0];
always @(posedge hclk or negedge hrstn) begin
if(!hrstn) begin spill_count<=0;spill_queue[0]<=0;spill_queue[1]<=0;end
else if(1'b0) spill_count<=0;
else case({spill_valid_i && spill_count<2,spill_ready_i && spill_count>0})
2'b10:begin spill_queue[spill_count]<=spill_data_i;spill_count<=spill_count+1;end
2'b01:begin spill_queue[0]<=spill_queue[1];spill_count<=spill_count-1;end
2'b11:spill_queue[0]<=spill_data_i;
default:begin end
endcase
end
logic [7:0] flush_queue[0:1];
integer flush_count;
assign flush_ready_o=flush_count<2;
assign flush_valid_o=flush_count!=0;
assign flush_data_o=flush_queue[0];
always @(posedge hclk or negedge hrstn) begin
if(!hrstn) begin flush_count<=0;flush_queue[0]<=0;flush_queue[1]<=0;end
else if(flush_flush_i) flush_count<=0;
else case({flush_valid_i && flush_count<2,flush_ready_i && flush_count>0})
2'b10:begin flush_queue[flush_count]<=flush_data_i;flush_count<=flush_count+1;end
2'b01:begin flush_queue[0]<=flush_queue[1];flush_count<=flush_count-1;end
2'b11:flush_queue[0]<=flush_data_i;
default:begin end
endcase
end
assign bypass_ready_o=bypass_ready_i;
assign bypass_valid_o=bypass_valid_i;
assign bypass_data_o=bypass_data_i;
logic [95:0] debug_packet;
logic [31:0] debug_last_pc;
logic [1:0] debug_packet_mode;
logic debug_busy, debug_pending;
logic [4:0] debug_index;
logic debug_finish,debug_next_pending;
always @* begin
debug_finish=debug_busy && ((debug_packet_mode==0 && debug_index==7)||(debug_packet_mode==1 && debug_index==15)||(debug_packet_mode==2 && debug_index==23));
debug_next_pending=debug_pending ? !debug_finish : (debug_debug_wb_pc!=debug_last_pc);
debug_data=0;
debug_data=debug_busy ? (((debug_packet_mode==0 || debug_packet_mode==3) && debug_index>=8) ? 4'hx : 4'(debug_packet >> (debug_index*4))) : 4'b0;
end
always @(posedge hclk) begin
if(hrst) begin debug_packet<=0;debug_last_pc<=0;debug_packet_mode<=1;debug_busy<=0;debug_pending<=0;debug_index<=0;end
else begin
debug_pending<=debug_next_pending;
debug_busy<=debug_busy ? !debug_finish : (debug_next_pending && debug_debug_wb_pc!=0);
if(!debug_busy && debug_next_pending) begin
debug_packet<={debug_debug_wb_rf_wdata,debug_debug_wb_instr,debug_debug_wb_pc};
debug_last_pc<=debug_debug_wb_pc;debug_packet_mode<=debug_mode;debug_index<=0;
end else if(debug_busy) debug_index<=debug_index+1;
end
end
logic [0:0] single0_history[0:3];
logic [0:0] single0_capture;
always @(posedge hclk) single0_capture <= single0_src_in;
always @(posedge hclk2) begin
for(integer stage=3;stage>0;stage--) single0_history[stage]<=single0_history[stage-1];
single0_history[0]<=single0_capture;
end
assign single0_dest_out=single0_history[3];
logic [0:0] single1_history[0:1];
always @(posedge hclk2) begin
for(integer stage=1;stage>0;stage--) single1_history[stage]<=single1_history[stage-1];
single1_history[0]<=single1_src_in;
end
assign single1_dest_out=single1_history[1];
logic [0:0] sync_reset_history[0:3];
always @(posedge hclk2) begin
for(integer stage=3;stage>0;stage--) sync_reset_history[stage]<=sync_reset_history[stage-1];
sync_reset_history[0]<=sync_reset_src_rst;
end
assign sync_reset_dest_rst=sync_reset_history[3];
logic [3:0] array0_history[0:3];
logic [3:0] array0_capture;
always @(posedge hclk) array0_capture <= array0_src_in;
always @(posedge hclk2) begin
for(integer stage=3;stage>0;stage--) array0_history[stage]<=array0_history[stage-1];
array0_history[0]<=array0_capture;
end
assign array0_dest_out=array0_history[3];
logic [1:0] array1_history[0:1];
always @(posedge hclk2) begin
for(integer stage=1;stage>0;stage--) array1_history[stage]<=array1_history[stage-1];
array1_history[0]<=array1_src_in;
end
assign array1_dest_out=array1_history[1];
logic pulse0_serial=0,pulse0_previous,pulse0_ack,pulse0_output;
logic pulse0_events[0:3];
wire pulse0_qualified=pulse0_events[3] & ~(pulse0_dest_rst);
always @(posedge hclk) begin
if(pulse0_src_rst) begin pulse0_previous<=0;pulse0_serial<=0;end
else begin pulse0_previous<=pulse0_src_pulse; pulse0_serial<=pulse0_serial ^ (pulse0_src_pulse & ~pulse0_previous); end
end
always @(posedge hclk2) begin
pulse0_events[0]<=pulse0_serial;
for(integer age=1;age<4;age++) pulse0_events[age]<=pulse0_events[age-1];
if(pulse0_dest_rst) begin pulse0_ack<=0;pulse0_output<=0;end
else begin pulse0_ack<=pulse0_qualified;pulse0_output<=pulse0_qualified ^ pulse0_ack;end
end
assign pulse0_dest_pulse=pulse0_qualified ^ pulse0_ack;
logic pulse1_serial=0,pulse1_previous,pulse1_ack,pulse1_output;
logic pulse1_events[0:1];
wire pulse1_qualified=pulse1_events[1] & ~(1'b0);
always @(posedge hclk) begin
if(1'b0) begin pulse1_previous<=0;pulse1_serial<=0;end
else begin pulse1_previous<=pulse1_src_pulse; pulse1_serial<=pulse1_serial ^ (pulse1_src_pulse & ~pulse1_previous); end
end
always @(posedge hclk2) begin
pulse1_events[0]<=pulse1_serial;
for(integer age=1;age<2;age++) pulse1_events[age]<=pulse1_events[age-1];
if(1'b0) begin pulse1_ack<=0;pulse1_output<=0;end
else begin pulse1_ack<=pulse1_qualified;pulse1_output<=pulse1_qualified ^ pulse1_ack;end
end
assign pulse1_dest_pulse=pulse1_output;
integer async_reset0_remaining=0;
always @(posedge hclk2 or posedge async_reset0_src_arst) begin
if(async_reset0_src_arst==1'b1) async_reset0_remaining<=4;
else if(async_reset0_remaining>0) async_reset0_remaining<=async_reset0_remaining-1;
end
assign async_reset0_dest_arst=async_reset0_remaining>0 ? 1'b1 : 1'b0;
integer async_reset1_remaining=0;
always @(posedge hclk2 or negedge async_reset1_src_arst) begin
if(async_reset1_src_arst==1'b0) async_reset1_remaining<=3;
else if(async_reset1_remaining>0) async_reset1_remaining<=async_reset1_remaining-1;
end
assign async_reset1_dest_arst=async_reset1_remaining>0 ? 1'b0 : 1'b1;
endmodule
