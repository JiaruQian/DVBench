module dvbench_top;
  import uvm_pkg::*;
  import dvbench_test_pkg::*;

  logic clk = 1'b0;
  always #5 clk = ~clk;

  fft_if vif(clk);

  fft_wrapper dut (
    .clk(clk), .rst(vif.rst), .m_addr(vif.m_addr), .m_data(vif.m_data),
    .m_we(vif.m_we), .s_addr(vif.s_addr), .s_re(vif.s_re), .s_data(vif.dut_data)
  );

  dvbench_model reference_model (
    .clk(clk), .rst(vif.rst), .m_addr(vif.m_addr), .m_data(vif.m_data),
    .m_we(vif.m_we), .s_addr(vif.s_addr), .s_re(vif.s_re), .s_data(vif.model_data)
  );

  initial begin
    vif.rst = 1'b0;
    vif.m_addr = '0;
    vif.m_data = '0;
    vif.m_we = 1'b0;
    vif.s_addr = '0;
    vif.s_re = 1'b0;
    uvm_config_db#(virtual fft_if)::set(null, "*", "vif", vif);
    run_test("dvbench_test");
  end
endmodule
