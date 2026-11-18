`timescale 1ns/1ps
module replay;
  logic rst_i=1, tck_i=0, tdi_i=0, capture_dr_i=0, shift_dr_i=0, update_dr_i=0;
  logic [63:0] data_register_i=0;
  logic module_select_i=0, PRESETn=0, PCLK=0, PSEL=0, PENABLE=0, PWRITE=0;
  logic [2:0] PADDR=0;
  logic [7:0] PWDATA=0;
  wire module_tdo_o, top_inhibit_o, PREADY, PSLVERR, int_o;
  wire [7:0] PRDATA;
  wire model_module_tdo_o, model_top_inhibit_o, model_PREADY, model_PSLVERR, model_int_o;
  wire [7:0] model_PRDATA;
  integer comparisons=0, mismatches=0;

  always #3 PCLK=~PCLK;
  always #5 tck_i=~tck_i;

  adbg_jsp_apb_module dut (
    .rst_i(rst_i), .tck_i(tck_i), .tdi_i(tdi_i), .capture_dr_i(capture_dr_i),
    .shift_dr_i(shift_dr_i), .update_dr_i(update_dr_i), .data_register_i(data_register_i),
    .module_select_i(module_select_i), .module_tdo_o(module_tdo_o), .top_inhibit_o(top_inhibit_o),
    .PRESETn(PRESETn), .PCLK(PCLK), .PSEL(PSEL), .PENABLE(PENABLE), .PWRITE(PWRITE),
    .PADDR(PADDR), .PWDATA(PWDATA), .PRDATA(PRDATA), .PREADY(PREADY),
    .PSLVERR(PSLVERR), .int_o(int_o)
  );

  dvbench_model model (
    .rst_i(rst_i), .tck_i(tck_i), .tdi_i(tdi_i), .capture_dr_i(capture_dr_i),
    .shift_dr_i(shift_dr_i), .update_dr_i(update_dr_i), .data_register_i(data_register_i),
    .module_select_i(module_select_i), .module_tdo_o(model_module_tdo_o),
    .top_inhibit_o(model_top_inhibit_o), .PRESETn(PRESETn), .PCLK(PCLK), .PSEL(PSEL),
    .PENABLE(PENABLE), .PWRITE(PWRITE), .PADDR(PADDR), .PWDATA(PWDATA),
    .PRDATA(model_PRDATA), .PREADY(model_PREADY), .PSLVERR(model_PSLVERR), .int_o(model_int_o)
  );

  task automatic compare_apb;
    comparisons++;
    if ({PRDATA,PREADY,PSLVERR,int_o} !== {model_PRDATA,model_PREADY,model_PSLVERR,model_int_o}) begin
      mismatches++;
      if (mismatches <= 20)
        $display("D_MISMATCH APB t=%0t addr=%0h write=%0b data=%0h actual=%h model=%h", $time, PADDR, PWRITE, PWDATA, {PRDATA,PREADY,PSLVERR,int_o}, {model_PRDATA,model_PREADY,model_PSLVERR,model_int_o});
    end
  endtask

  task automatic compare_scan;
    comparisons++;
    if ({module_tdo_o,top_inhibit_o} !== {model_module_tdo_o,model_top_inhibit_o}) begin
      mismatches++;
      if (mismatches <= 20)
        $display("D_MISMATCH SCAN t=%0t select=%0b capture=%0b shift=%0b tdi=%0b actual=%b model=%b", $time, module_select_i, capture_dr_i, shift_dr_i, tdi_i, {module_tdo_o,top_inhibit_o}, {model_module_tdo_o,model_top_inhibit_o});
    end
  endtask

  always @(posedge PCLK) begin #1; compare_apb(); end
  always @(negedge tck_i) begin #1; compare_scan(); end

  task automatic apb_write(input logic [2:0] addr, input logic [7:0] data);
    @(negedge PCLK); PSEL=1; PENABLE=0; PWRITE=1; PADDR=addr; PWDATA=data;
    @(negedge PCLK); PENABLE=1;
    @(negedge PCLK); PSEL=0; PENABLE=0; PWRITE=0;
  endtask

  task automatic apb_read(input logic [2:0] addr);
    @(negedge PCLK); PSEL=1; PENABLE=0; PWRITE=0; PADDR=addr;
    @(negedge PCLK); PENABLE=1;
    @(negedge PCLK); PSEL=0; PENABLE=0;
  endtask

  initial begin
    repeat (4) @(negedge PCLK);
    rst_i=0; PRESETn=1;
    repeat (4) @(negedge PCLK);
    apb_write(3, 8'h03);
    apb_write(1, 8'h03);
    apb_write(7, 8'hA5);
    apb_read(1); apb_read(2); apb_read(3); apb_read(5); apb_read(6); apb_read(7);
    apb_write(2, 8'h06);
    apb_read(0); apb_read(2);
    @(negedge tck_i); module_select_i=1; data_register_i=64'h0123456789abcdef;
    capture_dr_i=1;
    @(negedge tck_i); capture_dr_i=0; shift_dr_i=1;
    repeat (96) begin @(negedge tck_i); tdi_i=$urandom_range(0,1); end
    shift_dr_i=0; update_dr_i=1;
    @(negedge tck_i); update_dr_i=0; module_select_i=0;
    repeat (80) @(negedge PCLK);
    $display("D_REPLAY_COMPLETE comparisons=%0d mismatches=%0d", comparisons, mismatches);
    $finish;
  end
endmodule
