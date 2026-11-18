`timescale 1ns/1ps
module native_top;
aluexe_if vif();
TLPLIC dut(
.clock(vif.clock),
.reset(vif.reset),
.auto_in_a_ready(vif.auto_in_a_ready),
.auto_in_a_valid(vif.auto_in_a_valid),
.auto_in_a_bits_opcode(vif.auto_in_a_bits_opcode),
.auto_in_a_bits_param(vif.auto_in_a_bits_param),
.auto_in_a_bits_size(vif.auto_in_a_bits_size),
.auto_in_a_bits_source(vif.auto_in_a_bits_source),
.auto_in_a_bits_address(vif.auto_in_a_bits_address),
.auto_in_a_bits_mask(vif.auto_in_a_bits_mask),
.auto_in_a_bits_data(vif.auto_in_a_bits_data),
.auto_in_a_bits_corrupt(vif.auto_in_a_bits_corrupt),
.auto_in_d_ready(vif.auto_in_d_ready),
.auto_in_d_valid(vif.auto_in_d_valid),
.auto_in_d_bits_opcode(vif.auto_in_d_bits_opcode),
.auto_in_d_bits_size(vif.auto_in_d_bits_size),
.auto_in_d_bits_source(vif.auto_in_d_bits_source),
.auto_in_d_bits_data(vif.auto_in_d_bits_data)
);
dvbench_model predictor(
.clock(vif.clock),
.reset(vif.reset),
.auto_in_a_ready(vif.expected_auto_in_a_ready),
.auto_in_a_valid(vif.auto_in_a_valid),
.auto_in_a_bits_opcode(vif.auto_in_a_bits_opcode),
.auto_in_a_bits_param(vif.auto_in_a_bits_param),
.auto_in_a_bits_size(vif.auto_in_a_bits_size),
.auto_in_a_bits_source(vif.auto_in_a_bits_source),
.auto_in_a_bits_address(vif.auto_in_a_bits_address),
.auto_in_a_bits_mask(vif.auto_in_a_bits_mask),
.auto_in_a_bits_data(vif.auto_in_a_bits_data),
.auto_in_a_bits_corrupt(vif.auto_in_a_bits_corrupt),
.auto_in_d_ready(vif.auto_in_d_ready),
.auto_in_d_valid(vif.expected_auto_in_d_valid),
.auto_in_d_bits_opcode(vif.expected_auto_in_d_bits_opcode),
.auto_in_d_bits_size(vif.expected_auto_in_d_bits_size),
.auto_in_d_bits_source(vif.expected_auto_in_d_bits_source),
.auto_in_d_bits_data(vif.expected_auto_in_d_bits_data)
);
initial begin vif.clock=0;forever #5 vif.clock=~vif.clock;end
integer index, seed, ignored, mismatches;
initial begin
 seed=1; ignored=$value$plusargs("SEED=%d",seed); ignored=$urandom(seed); mismatches=0; vif.drive('0);
 for(index=0;index<4096;index=index+1) begin
 @(negedge vif.clock); vif.prepare(index); #2;
 if(vif.actual_bus !== vif.expected_bus) begin
  mismatches=mismatches+1; if(mismatches<5) $display("MISMATCH sample=%0d actual=%h expected=%h",index,vif.actual_bus,vif.expected_bus);
 end
 end
 $display("OBSERVATIONS=4096 MISMATCHES=%0d",mismatches);
 if(mismatches) $fatal(1,"MODEL_MISMATCH");
 $display("BASELINE_PASS"); $finish;
end
endmodule
