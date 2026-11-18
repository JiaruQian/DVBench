`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;
  import sigmoid_pkg::*;
  sigmoid_if uif0();
  sigmoid_if uif1();
  fp32_sigmoid_pipeline #(.FTZ(1'b0)) dut0 (
    .clk_i(uif0.clk),.rst_i(uif0.rst),.clear_i(uif0.clear),
    .valid_i(uif0.valid),.data_i(uif0.data),.invalid_i(uif0.invalid),
    .valid_o(uif0.valid_o),.result_o(uif0.result_o),.invalid_o(uif0.invalid_o));
  fp32_sigmoid_pipeline #(.FTZ(1'b1)) dut1 (
    .clk_i(uif1.clk),.rst_i(uif1.rst),.clear_i(uif1.clear),
    .valid_i(uif1.valid),.data_i(uif1.data),.invalid_i(uif1.invalid),
    .valid_o(uif1.valid_o),.result_o(uif1.result_o),.invalid_o(uif1.invalid_o));
  dvbench_model #(.FTZ(1'b0)) expected0 (
    .clk_i(uif0.clk),.rst_i(uif0.rst),.clear_i(uif0.clear),
    .valid_i(uif0.valid),.data_i(uif0.data),.invalid_i(uif0.invalid),
    .valid_o(uif0.expected_valid),.result_o(uif0.expected_result),.invalid_o(uif0.expected_invalid));
  dvbench_model #(.FTZ(1'b1)) expected1 (
    .clk_i(uif1.clk),.rst_i(uif1.rst),.clear_i(uif1.clear),
    .valid_i(uif1.valid),.data_i(uif1.data),.invalid_i(uif1.invalid),
    .valid_o(uif1.expected_valid),.result_o(uif1.expected_result),.invalid_o(uif1.expected_invalid));
  initial begin
    uvm_config_db#(virtual sigmoid_if)::set(null,"uvm_test_top.env.agn0.*","vif",uif0);
    uvm_config_db#(virtual sigmoid_if)::set(null,"uvm_test_top.env.agn1.*","vif",uif1);
    run_test("dvbench_test");
  end
  initial begin
    #20000;
    $fatal(1,"Reference watchdog expired before UVM normal completion");
  end
endmodule
