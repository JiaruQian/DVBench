// jsp_apb_if.sv — adbg_jsp_apb_module interface (JTAG tck domain + APB pclk domain, two self-managed asynchronous resets)
// data_register_i shifting is self-managed by the interface (emulating the 64bit data register of top-level adv_dbg_if)
`timescale 1ns/1ps

interface jsp_apb_if ();

  // Resets (self-managed by tb, tasks provided for F06 injection)
  logic rst_i    = 1'b0;   // JTAG domain, asynchronous active-high
  logic PRESETn  = 1'b0;   // APB domain, asynchronous active-low

  // Clocks: integer half-periods (real delays trigger VCS analog-style scheduling, ~300× slower)
  // tck must be slower than pclk: JTAG issues one strobe every 8·tck, CDC toggle/syncreg round trip ~4·pclk;
  // Excessively fast tck causes data_in to be overwritten by the next byte, delayed rdata relatching, and lost ren toggles (RTL protocol constraint)
  int unsigned tck_half = 5;   // tck period 10ns (strobe spacing 80ns)
  int unsigned pclk_half = 3;  // pclk period 6ns (CDC processing ~24ns)
  logic tck = 0, pclk = 0;
  initial forever #(tck_half) tck  = ~tck;
  initial forever #(pclk_half) pclk = ~pclk;

  // ---- JTAG / TAP side ----
  logic        tdi_i;
  logic        module_tdo_o;
  logic        capture_dr_i, shift_dr_i, update_dr_i;
  logic        module_select_i;
  logic [63:0] data_register_i = '0;
  logic        top_inhibit_o;

  // Top-level data register shift behavior: posedge tck samples tdi into MSB and shifts out LSB (NBA, DUT sees the pre-shift value)
  always @(posedge tck) begin
    if (shift_dr_i) data_register_i <= {tdi_i, data_register_i[63:1]};
  end

  // ---- APB side ----
  logic       PSEL, PENABLE, PWRITE;
  logic [2:0] PADDR;
  logic [7:0] PWDATA, PRDATA;
  logic       PREADY, PSLVERR;
  logic       int_o;

  // boot: must first pulse rst_i for one cycle — RTL synchronization chain (rst_n_ff/wen_tff/ren_tff/syncreg toggle)
  // No power-up initialization; without reset, the entire CDC chain is stuck at X and the FIFO remains empty forever
  initial begin
    rst_i = 1'b1;
    #20 rst_i  = 1'b0;
    #20 PRESETn = 1'b1;
  end

  task pulse_rst_jtag();   // F06: JTAG domain reset (FIFO counts and synchronizers are all cleared)
    rst_i = 1'b1;
    repeat (5) @(negedge tck);
    rst_i = 1'b0;
    repeat (2) @(negedge tck);
  endtask

  task pulse_presetn();    // F06: APB domain reset (ier/lcr/scr/FSM cleared, FIFO not cleared)
    PRESETn = 1'b0;
    repeat (5) @(negedge pclk);
    PRESETn = 1'b1;
    repeat (2) @(negedge pclk);
  endtask

  // Observation-side clocking block (for monitor use; driving uses native negedge assignments)
  clocking cb_t @(posedge tck);
    default input #1step;
    input tdi_i, module_tdo_o, shift_dr_i, capture_dr_i, update_dr_i, module_select_i;
  endclocking

  clocking cb_p @(posedge pclk);
    default input #1step;
    input PSEL, PENABLE, PWRITE, PADDR, PWDATA, PRDATA, PREADY, PSLVERR, int_o;
  endclocking


 logic e_module_tdo_o,e_top_inhibit_o,e_PREADY,e_PSLVERR,e_int_o;
 logic [7:0] e_PRDATA;
endinterface

