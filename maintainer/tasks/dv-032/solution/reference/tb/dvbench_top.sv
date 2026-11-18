// tb_top.sv — adbg_jsp_apb_module UVM top level (dual clocks: JTAG tck domain + APB pclk domain)
`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;
  import jsp_apb_pkg::*;
  `include "uvm_macros.svh"

  jsp_apb_if ifc ();

  adbg_jsp_apb_module dut (
    .rst_i          (ifc.rst_i),
    .tck_i          (ifc.tck),
    .tdi_i          (ifc.tdi_i),
    .module_tdo_o   (ifc.module_tdo_o),
    .capture_dr_i   (ifc.capture_dr_i),
    .shift_dr_i     (ifc.shift_dr_i),
    .update_dr_i    (ifc.update_dr_i),
    .data_register_i(ifc.data_register_i),
    .module_select_i(ifc.module_select_i),
    .top_inhibit_o  (ifc.top_inhibit_o),
    .PRESETn        (ifc.PRESETn),
    .PCLK           (ifc.pclk),
    .PSEL           (ifc.PSEL),
    .PENABLE        (ifc.PENABLE),
    .PWRITE         (ifc.PWRITE),
    .PADDR          (ifc.PADDR),
    .PWDATA         (ifc.PWDATA),
    .PRDATA         (ifc.PRDATA),
    .PREADY         (ifc.PREADY),
    .PSLVERR        (ifc.PSLVERR),
    .int_o          (ifc.int_o)
  );

  dvbench_model predictor(
 .rst_i(ifc.rst_i),
 .tck_i(ifc.tck),
 .tdi_i(ifc.tdi_i),
 .capture_dr_i(ifc.capture_dr_i),
 .shift_dr_i(ifc.shift_dr_i),
 .update_dr_i(ifc.update_dr_i),
 .data_register_i(ifc.data_register_i),
 .module_select_i(ifc.module_select_i),
 .PRESETn(ifc.PRESETn),
 .PCLK(ifc.pclk),
 .PSEL(ifc.PSEL),
 .PENABLE(ifc.PENABLE),
 .PWRITE(ifc.PWRITE),
 .PADDR(ifc.PADDR),
 .PWDATA(ifc.PWDATA),
 .module_tdo_o(ifc.e_module_tdo_o),
 .top_inhibit_o(ifc.e_top_inhibit_o),
 .PRDATA(ifc.e_PRDATA),
 .PREADY(ifc.e_PREADY),
 .PSLVERR(ifc.e_PSLVERR),
 .int_o(ifc.e_int_o)
  );

  initial begin
    uvm_config_db#(virtual jsp_apb_if)::set(null, "uvm_test_top", "vif", ifc);
    run_test("dvbench_test");   // Default comprehensive test (overridable with +UVM_TESTNAME)
  end

endmodule
