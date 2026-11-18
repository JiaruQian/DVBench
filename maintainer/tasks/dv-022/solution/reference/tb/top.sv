`timescale 1ns/1ps
module dvbench_top;
`include "uvm_macros.svh"
import uvm_pkg::*;
import dvbench_pkg::*;
dvbench_if bus();
logic  CLK;
logic [127:0] DATA;
logic [3:0] DATA_EN;
logic [2:0] DATA_EN_COUNT;
logic  DONE;
logic [127:0] ENG_DATA;
logic  ERR;
logic [4:0] EXT_TAG;
logic  EXT_TAG_VALID;
logic [5:0] INT_TAG;
logic  INT_TAG_VALID;
logic [35:0] MAIN_DATA_EN;
logic [11:0] MAIN_DONE;
logic [11:0] MAIN_ERR;
logic  RST;
logic [35:0] SG_RX_DATA_EN;
logic [11:0] SG_RX_DONE;
logic [11:0] SG_RX_ERR;
logic [35:0] SG_TX_DATA_EN;
logic [11:0] SG_TX_DONE;
logic [11:0] SG_TX_ERR;
logic [4:0] TAG;
logic  VALID;
logic [127:0] predicted_ENG_DATA;
logic [4:0] predicted_EXT_TAG;
logic  predicted_EXT_TAG_VALID;
logic [35:0] predicted_MAIN_DATA_EN;
logic [11:0] predicted_MAIN_DONE;
logic [11:0] predicted_MAIN_ERR;
logic [35:0] predicted_SG_RX_DATA_EN;
logic [11:0] predicted_SG_RX_DONE;
logic [11:0] predicted_SG_RX_ERR;
logic [35:0] predicted_SG_TX_DATA_EN;
logic [11:0] predicted_SG_TX_DONE;
logic [11:0] predicted_SG_TX_ERR;
assign {CLK, DATA, DATA_EN, DATA_EN_COUNT, DONE, ERR, INT_TAG, INT_TAG_VALID, RST, TAG, VALID} = bus.input_state;
assign bus.actual_state = {ENG_DATA, EXT_TAG, EXT_TAG_VALID, MAIN_DATA_EN, MAIN_DONE, MAIN_ERR, SG_RX_DATA_EN, SG_RX_DONE, SG_RX_ERR, SG_TX_DATA_EN, SG_TX_DONE, SG_TX_ERR};
assign bus.expected_state = {predicted_ENG_DATA, predicted_EXT_TAG, predicted_EXT_TAG_VALID, predicted_MAIN_DATA_EN, predicted_MAIN_DONE, predicted_MAIN_ERR, predicted_SG_RX_DATA_EN, predicted_SG_RX_DONE, predicted_SG_RX_ERR, predicted_SG_TX_DATA_EN, predicted_SG_TX_DONE, predicted_SG_TX_ERR};
reorder_queue  dut(.CLK(CLK),.DATA(DATA),.DATA_EN(DATA_EN),.DATA_EN_COUNT(DATA_EN_COUNT),.DONE(DONE),.ENG_DATA(ENG_DATA),.ERR(ERR),.EXT_TAG(EXT_TAG),.EXT_TAG_VALID(EXT_TAG_VALID),.INT_TAG(INT_TAG),.INT_TAG_VALID(INT_TAG_VALID),.MAIN_DATA_EN(MAIN_DATA_EN),.MAIN_DONE(MAIN_DONE),.MAIN_ERR(MAIN_ERR),.RST(RST),.SG_RX_DATA_EN(SG_RX_DATA_EN),.SG_RX_DONE(SG_RX_DONE),.SG_RX_ERR(SG_RX_ERR),.SG_TX_DATA_EN(SG_TX_DATA_EN),.SG_TX_DONE(SG_TX_DONE),.SG_TX_ERR(SG_TX_ERR),.TAG(TAG),.VALID(VALID));
dvbench_model  predictor(.CLK(CLK),.DATA(DATA),.DATA_EN(DATA_EN),.DATA_EN_COUNT(DATA_EN_COUNT),.DONE(DONE),.ENG_DATA(predicted_ENG_DATA),.ERR(ERR),.EXT_TAG(predicted_EXT_TAG),.EXT_TAG_VALID(predicted_EXT_TAG_VALID),.INT_TAG(INT_TAG),.INT_TAG_VALID(INT_TAG_VALID),.MAIN_DATA_EN(predicted_MAIN_DATA_EN),.MAIN_DONE(predicted_MAIN_DONE),.MAIN_ERR(predicted_MAIN_ERR),.RST(RST),.SG_RX_DATA_EN(predicted_SG_RX_DATA_EN),.SG_RX_DONE(predicted_SG_RX_DONE),.SG_RX_ERR(predicted_SG_RX_ERR),.SG_TX_DATA_EN(predicted_SG_TX_DATA_EN),.SG_TX_DONE(predicted_SG_TX_DONE),.SG_TX_ERR(predicted_SG_TX_ERR),.TAG(TAG),.VALID(VALID));
bit output_started=0;
integer valid_words;
integer channel;
always @(posedge CLK) begin #2; if(!$isunknown({predicted_MAIN_DATA_EN,predicted_SG_RX_DATA_EN,predicted_SG_TX_DATA_EN}) && |{predicted_MAIN_DATA_EN,predicted_SG_RX_DATA_EN,predicted_SG_TX_DATA_EN}) output_started=1; end
always_comb begin
bus.compare_mask='1;
valid_words=0;
for(channel=0;channel<12;channel++) valid_words+=predicted_MAIN_DATA_EN[channel*3+:3]+predicted_SG_RX_DATA_EN[channel*3+:3]+predicted_SG_TX_DATA_EN[channel*3+:3];
bus.compare_mask[186+:128]='0;
if(valid_words>0 && valid_words<=4) bus.compare_mask[186+:128]=128'hffffffffffffffffffffffffffffffff >> (128-32*valid_words);
if(!output_started) bus.compare_mask[186+:128]='0;
if(!output_started) bus.compare_mask[144+:36]='0;
if(!output_started) bus.compare_mask[132+:12]='0;
if(!output_started) bus.compare_mask[120+:12]='0;
if(!output_started) bus.compare_mask[84+:36]='0;
if(!output_started) bus.compare_mask[72+:12]='0;
if(!output_started) bus.compare_mask[60+:12]='0;
if(!output_started) bus.compare_mask[24+:36]='0;
if(!output_started) bus.compare_mask[12+:12]='0;
if(!output_started) bus.compare_mask[0+:12]='0;
end
always @(posedge CLK) begin #3; ->bus.sample_ready; end
initial begin
    uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
    run_test("dvbench_test");
end
initial begin #1000000; `uvm_fatal("WATCHDOG","Reference did not terminate") end
endmodule
