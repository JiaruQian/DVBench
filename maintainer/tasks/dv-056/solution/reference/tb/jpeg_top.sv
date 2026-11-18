`timescale 1ns/1ps
module dvbench_top;import uvm_pkg::*;import jpeg_native_pkg::*;reg clk=0;always #5 clk=~clk;jpeg_native_if vif(clk);
decoder_top dut(.clk(clk),.rst_n(vif.rst_n),.dec_start(vif.start),.bs_Y(vif.bs[0]),.bs_len_Y(vif.len[0]),.bs_Cb(vif.bs[1]),.bs_len_Cb(vif.len[1]),.bs_Cr(vif.bs[2]),.bs_len_Cr(vif.len[2]),.block_num(vif.block_num),.R_out(vif.R),.G_out(vif.G),.B_out(vif.B),.dec_done(vif.done),.trigger_dec(vif.trig),.total_bits_consumed(vif.bits));
dvbench_model predictor(.clk(clk),.rst_n(vif.rst_n),.dec_start(vif.start),.bs_Y(vif.bs[0]),.bs_len_Y(vif.len[0]),.bs_Cb(vif.bs[1]),.bs_len_Cb(vif.len[1]),.bs_Cr(vif.bs[2]),.bs_len_Cr(vif.len[2]),.block_num(vif.block_num),.R_out(vif.eR),.G_out(vif.eG),.B_out(vif.eB),.dec_done(vif.edone),.trigger_dec(vif.etrig),.total_bits_consumed(vif.ebits));
always @(negedge vif.rst_n)begin #1;if(vif.done!==0 || vif.trig!==0 || vif.bits!==0 || vif.R!==0 || vif.G!==0 || vif.B!==0)`uvm_error("ASYNC_RESET","outputs not reset between edges") end
initial begin uvm_config_db#(virtual jpeg_native_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
