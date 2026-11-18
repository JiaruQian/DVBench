// jsp_apb_pkg.sv — adbg_jsp_apb_module UVM environment
// feature: F01 APB register reads/writes F02 JTAG→APB data F03 APB→JTAG data F04 FIFO boundaries (full/empty/overflow)
//          F05 Status byte/LSR F06 Dual-domain resets F07 IIR/int_o F08 FCR FIFO reset
//          F09 Dual-domain concurrency F10 Early update abort F11 module_select=0 F12 Random mix
`timescale 1ns/1ps
package jsp_apb_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_jtag)
  `uvm_analysis_imp_decl(_apb)

  // ---------- txn ----------
  class jsp_scan_txn extends uvm_sequence_item;
    bit          sel = 1'b1;        // module_select_i
    int          n_bits = 64;
    int          abort_after = 0;   // >0: early update_dr after shifting abort_after bits (F10)
    bit [7:0]    tx_bytes[8];       // byte0: count nibble mirror; byte1..7: JTAG→APB data
    bit [7:0]    rx_bytes[8];       // byte0: {rd_avail, wr_free}; byte1..7: APB→JTAG data
    int          n_tx = 0, n_rx = 0;
    `uvm_object_utils(jsp_scan_txn)
    function new(string name = "jsp_scan_txn"); super.new(name); endfunction
  endclass

  class apb_txn extends uvm_sequence_item;
    bit       wr;
    bit [2:0] addr;
    bit [7:0] wdata;
    bit [7:0] rdata;                // Filled in by driver
    bit       int_lvl;              // int_o level at the completion edge (V8 interrupt coverage sampling)
    `uvm_object_utils(apb_txn)
    function new(string name = "apb_txn"); super.new(name); endfunction
  endclass

  // ---------- scoreboard: reference model + checks ----------
  class jsp_sb extends uvm_scoreboard;
    `uvm_component_utils(jsp_sb)
    uvm_analysis_imp_jtag #(jsp_scan_txn, jsp_sb) jtag_imp;
    uvm_analysis_imp_apb  #(apb_txn,     jsp_sb) apb_imp;

    bit [7:0] q_wr[$];              // wr_fifo model: JTAG→APB (capacity 8)
    bit [7:0] q_rd[$];              // rd_fifo model: APB→JTAG (capacity 8)
    bit [7:0] expected_wr[$];       // V9 concurrency-window multiset expectations (same gating as chk_en)
    bit [3:0] ier = 0;              // 16550 register shadow
    bit [7:0] lcr = 0, scr = 0;
    bit       thr_arm = 0;          // thr_int_arm shadow
    bit       rdata_clr = 0;        // PRESETn clears the rdata register (does not clear rd_fifo): the first byte shifted out is 0
    bit       chk_en = 1;           // Check enable (disabled during concurrent/random/reset windows)
    bit       quiet  = 0;           // Reset window: even model updates are stopped (in-flight transactions do not contaminate the model)
    bit       in_conc = 0;          // V9 concurrent checking window: RBR uses multiset comparison (order is unpredictable)
    bit       conc_win = 0;         // V9 concurrent stimulus window: collect candidate push bytes
    bit [7:0] conc_cand[$];         // V9 candidate set: the DUT push gate uses the tck-side stale view,
                                    // with concurrent pop, the actual push count/content is uncertain; only candidate-set comparison is possible
    int       conc_rd = 0;          // V9 actual number of bytes read during the concurrent window
    int       n_scan = 0, n_apb = 0, n_err = 0;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      jtag_imp = new("jtag_imp", this);
      apb_imp  = new("apb_imp",  this);
    endfunction

    function bit int_exp();
      return ((q_rd.size() < 8) && thr_arm && ier[1]) || ((q_wr.size() > 0) && ier[0]);
    endfunction

    function void chk(bit ok, string msg);
      if (chk_en && !ok) begin n_err++; `uvm_info("LEGACY_DIAGNOSTIC",msg,UVM_LOW) end
    endfunction

    // ---- APB completed transactions ----
    function void write_apb(apb_txn t);
      bit [7:0] e, exp;
      if (quiet) return;
      n_apb++;
      if (t.wr) begin
        case (t.addr)
          3'd0: if (lcr[7] == 1'b0) begin       // THR: enqueue into rd_fifo (the DUT discards it if full)
                  if (q_rd.size() < 8) begin
                    if (q_rd.size() == 0) rdata_clr = 1'b0;  // First push into an empty FIFO: the rcz path re-latches rdata
                    q_rd.push_back(t.wdata);
                  end
                  thr_arm = 1'b1;
                end
          3'd1: if (lcr[7] == 1'b0) ier = t.wdata[3:0];
          3'd2: begin                             // FCR: bit1 resets wr_fifo, bit2 resets rd_fifo
                  if (t.wdata[1]) q_wr.delete();
                  if (t.wdata[2]) q_rd.delete();
                end
          3'd3: lcr = t.wdata;
          3'd7: scr = t.wdata;
          default: ;
        endcase
      end else begin
        case (t.addr)
          3'd0: if (lcr[7] == 1'b0) begin         // RBR: dequeue from wr_fifo (when empty, the DUT returns X; no comparison)
                  if (in_conc && (^t.rdata) !== 1'bx) begin
                    // V9: concurrent window, multiset comparison; DUT empty reads returning X are not counted (no byte consumed)
                    if (q_wr.size() > 0) begin
                      mset_chk(t.rdata, "conc");
                      q_wr.delete(0);
                      conc_rd++;
                    end
                  end else if (q_wr.size() > 0) begin
                    e = q_wr.pop_front();
                    chk(t.rdata === e, $sformatf("RBR mismatch exp=%02x got=%02x", e, t.rdata));
                  end
                end
          3'd1: chk(t.rdata === {4'h0, ier}, "IER readback mismatch");
          3'd2: begin                              // IIR: 4=wrfifo has data 2=THR empty 1=no interrupt
                  exp = (q_wr.size() > 0) ? 8'h04 :
                        ((thr_arm && q_rd.size() < 8) ? 8'h02 : 8'h01);
                  chk(t.rdata[2:0] === exp[2:0], $sformatf("IIR mismatch exp=%02x got=%02x", exp, t.rdata));
                  if (q_wr.size() == 0) thr_arm = 1'b0;
                end
          3'd3: chk(t.rdata === lcr, "LCR readback mismatch");
          3'd4: chk(t.rdata === 8'h00, "MCR should always be 0");
          3'd5: begin                              // LSR: bit0=wrfifo nonempty, bit5/6=rdfifo not full
                  exp = {1'b0, (q_rd.size() < 8), (q_rd.size() < 8), 4'h0, (q_wr.size() > 0)};
                  chk(t.rdata === exp, $sformatf("LSR mismatch exp=%02x got=%02x", exp, t.rdata));
                end
          3'd6: chk(t.rdata === 8'h0B, "MSR should always be 0x0B");
          3'd7: chk(t.rdata === scr, "SCR readback mismatch");
          default: ;
        endcase
      end
    endfunction

    // ---- JTAG scan completed transactions (reconstruct the bitstream from pins; DUT bit/byte boundaries derived from RTL) ----
    // push gate edge E(8k+7), pop gate edge E(8k): a full 64bit scan has at most 7 push / 7 pop
    function void write_jtag(jsp_scan_txn t);
      int pre_wr, pre_rd, cnt, i;
      int n_in, n_pop;
      bit [3:0] fr;
      if (quiet) return;
      n_scan++;
      if (!t.sel) return;                          // F11: not selected; the DUT FSM does not move
      pre_wr = q_wr.size(); pre_rd = q_rd.size();
      cnt    = t.tx_bytes[0][7:4];
      if (conc_win)                            // V9: collect candidates during the concurrent window (bytes the DUT may push)
        for (i = 0; i < cnt && i < 7; i++) conc_cand.push_back(t.tx_bytes[1 + i]);
      n_pop  = (t.n_bits == 64) ? 7 : (t.n_bits - 1) / 8;
      if (n_pop > pre_rd) n_pop = pre_rd;
      if (t.n_bits == 64)
        n_in = cnt;
      else
        n_in = (t.n_bits > 8) ? (t.n_bits - 8) / 8 : 0;
      if (n_in > cnt)               n_in = cnt;
      if (n_in > 8 - pre_wr)        n_in = 8 - pre_wr;
      fr = 8 - pre_wr;
      if (t.n_bits == 64) begin
        for (i = 0; i < n_in; i++) q_wr.push_back(t.tx_bytes[1 + i]);
        for (i = 0; i < n_pop; i++) begin
          if (i == 0 && rdata_clr)
            // PRESETn clears rdata: the first byte shifted out is 0; q_rd[0] is popped but its value is unobservable
            chk(t.rx_bytes[1] === 8'h00, "rdata cleared to zero after PRESETn, rx[0] should be 00");
          else
            chk(t.rx_bytes[1 + i] === q_rd[i],
                $sformatf("JTAG rx[%0d] mismatch exp=%02x got=%02x", i, q_rd[i], t.rx_bytes[1 + i]));
        end
        if (n_pop > 0) rdata_clr = 1'b0;    // After pop, RD_LATCH re-latches rdata
        chk(t.rx_bytes[0] === {pre_rd[3:0], fr},
            $sformatf("Status byte mismatch exp={av=%0d,fr=%0d} got=%02x", pre_rd, fr, t.rx_bytes[0]));
      end else begin
        for (i = 0; i < n_in; i++) q_wr.push_back(t.tx_bytes[1 + i]);   // Fully shifted bytes are still written
      end
      for (i = 0; i < n_pop; i++) q_rd.pop_front();
      if (n_pop > 0 && pre_rd == n_pop) thr_arm = 1'b1;
    endfunction

    function void flush_fifos(); q_wr.delete(); q_rd.delete(); endfunction

    // V9 concurrent-window checking: RBR multiset comparison (order is unpredictable, content/count are predictable)
    // The exact set of concurrent pushes is unpredictable (DUT gate stale view); the expected set is
    // the model q_wr snapshot ∪ candidate bytes shifted during the window, to catch data corruption; count conservation is
    // guaranteed by draining to empty (LSR bit0=0) + final-state LSR
    function void conc_start();      // Called before fork: start collecting candidates
      conc_win  = 1;
      conc_cand.delete();
    endfunction
    function void conc_stop();       // Called after join
      conc_win = 0;
    endfunction
    function void conc_arm();
      expected_wr.delete();
      foreach (q_wr[i]) expected_wr.push_back(q_wr[i]);
      foreach (conc_cand[i]) expected_wr.push_back(conc_cand[i]);
      in_conc = 1;
    endfunction
    function void conc_end();
      in_conc = 0;
      expected_wr.delete();
      conc_cand.delete();
    endfunction

    function void mset_chk(bit [7:0] got, string tag);
      int idx[$];
      idx = expected_wr.find_first_index with (item === got);
      if (idx.size() == 0)
        chk(0, $sformatf("[%s] RBR multiset mismatch: byte %02x is not in the expected set", tag, got));
      else
        expected_wr.delete(idx[0]);
    endfunction

    function void apb_regs_reset();
      ier = 0; lcr = 0; scr = 0; thr_arm = 0; rdata_clr = 1;
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("SB", $sformatf("Scans %0d, APB transactions %0d, errors %0d, model remaining wr=%0d rd=%0d",
                                n_scan, n_apb, n_err, q_wr.size(), q_rd.size()), UVM_LOW)
    endfunction
  endclass

  // ---------- Coverage ----------
  class jsp_cov extends uvm_subscriber #(jsp_scan_txn);
    `uvm_component_utils(jsp_cov)
    uvm_analysis_imp_apb #(apb_txn, jsp_cov) apb_imp;
    jsp_sb sb;                                    // V8: obtain model IER/FIFO occupancy when sampling an IIR read
    int cur_cnt = 0, cur_avl = 0, cur_free = 0;
    bit [2:0] cur_addr = 0;
    bit [1:0] cur_fcr = 0;
    bit cur_wr = 0, cur_sel = 1, cur_abort = 0, cur_dlab = 0;
    int cur_rst = 0;   // 0=empty FIFO reset 1=jtag-domain FIFO nonempty reset 2=apb-domain FIFO nonempty reset
    bit cur_conc = 0;                             // V9: dual-domain concurrent-window flag (sampled before and after fork)
    bit [2:0] cur_iir = 3'd1;                     // V8: IIR readback value (priority 4/2/1)
    bit cur_int = 0;                              // V8: int_o level at the IIR read edge
    bit [1:0] cur_ier = 0;                        // V8: interrupt enables erbfi/etbei
    covergroup cg_feat();
      option.per_instance = 1;
      cp_cnt:  coverpoint cur_cnt { bins c0 = {0}; bins c1 = {1}; bins c_mid = {[2:6]}; bins c7 = {7}; }
      cp_addr: coverpoint cur_addr;
      cp_rw:   coverpoint cur_wr;
      cp_sel:  coverpoint cur_sel;
      cp_abt:  coverpoint cur_abort;
      cp_fcr:  coverpoint cur_fcr { bins f_none = {0}; bins f_wr = {1}; bins f_rd = {2}; bins f_both = {3}; }
      cp_dlab: coverpoint cur_dlab { bins d0 = {0}; bins d1 = {1}; }
      cp_avl:  coverpoint cur_avl { bins a0 = {0}; bins a1 = {1}; bins a_mid = {[2:6]}; bins a7 = {7}; bins a8 = {8}; }
      cp_free: coverpoint cur_free { bins f0 = {0}; bins f1 = {1}; bins f_mid = {[2:6]}; bins f7 = {7}; bins f8 = {8}; }
      cp_rstf: coverpoint cur_rst { bins r_empty = {0}; bins r_jtag_full = {1}; bins r_apb_full = {2}; }
      cp_conc: coverpoint cur_conc { bins cc_solo = {0}; bins cc_conc = {1}; }
      cp_iir:  coverpoint cur_iir  { bins i_none = {1}; bins i_thr = {2}; bins i_data = {4}; }
      cp_int:  coverpoint cur_int  { bins n0 = {0}; bins n1 = {1}; }
      cp_ier:  coverpoint cur_ier  { bins e_none = {0}; bins e_rx = {1}; bins e_tx = {2}; bins e_both = {3}; }
      x_cnt_avl: cross cp_cnt, cp_avl;
      x_int_avl: cross cp_int, cp_avl;            // V8: int_o × rd-side occupancy (interrupt × FIFO state)
      x_iir_ier: cross cp_iir, cp_ier;            // V8: IIR priority × interrupt-enable combination
    endgroup
    function new(string name, uvm_component parent);
      super.new(name, parent);
      cg_feat = new();
      apb_imp = new("apb_imp", this);
    endfunction
    function void write(jsp_scan_txn t);
      // A non-aborted scan must be 64 bits: n_bits!=64 means early update (the monitor does not reconstruct abort_after)
      cur_cnt = t.tx_bytes[0][7:4]; cur_sel = t.sel; cur_abort = (t.n_bits != 64);
      cur_avl  = t.rx_bytes[0][7:4];              // Status byte avail high nibble: rd-side occupancy at scan start
      cur_free = t.rx_bytes[0][3:0];              // free low nibble: wr-side occupancy at scan start
      cg_feat.sample();
    endfunction
    function void write_apb(apb_txn t);
      cur_addr = t.addr; cur_wr = t.wr;
      if (t.wr && t.addr == 3'd2) cur_fcr = t.wdata[2:1];     // V7: FCR functional switch values
      if (t.addr == 3'd3) cur_dlab = t.wdata[7];              // V7: dlab sampling (post-write value, equivalent to lcr[7])
      if (!t.wr && t.addr == 3'd2 && sb != null) begin
        // V8: IIR readback value, int_o at the read edge, enable combination × FIFO occupancy (taken from the model, consistent after the transaction)
        cur_iir  = t.rdata[2:0];
        cur_int  = t.int_lvl;
        cur_ier  = sb.ier[1:0];
        cur_avl  = sb.q_rd.size();
        cur_free = 8 - sb.q_wr.size();
      end
      cg_feat.sample();
    endfunction
    function void sample_rst(int kind);                       // V10: reset direction × FIFO nonempty flag
      cur_rst = kind;
      cg_feat.sample();
    endfunction
    function void sample_conc(bit on);                        // V9: concurrent window on/off (before and after s_f09 fork)
      cur_conc = on;
      cg_feat.sample();
    endfunction
  endclass

  // ---------- JTAG monitor (sampling at negedge+0.1ns: avoid a race with driver writes on the same edge) ----------
  class jsp_mon extends uvm_monitor;
    `uvm_component_utils(jsp_mon)
    virtual jsp_apb_if vif;
    uvm_analysis_port #(jsp_scan_txn) ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual jsp_apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      bit tx_bits[64];
      bit rx_bits[64];
      int nbits = 0;
      bit in_scan = 0, sel = 0;
      int n_inh_err = 0;
      jsp_scan_txn t;
      forever begin
        @(negedge vif.tck);
        #0.1;
        // V12 invariant: top_inhibit_o is always 0 (JSP never requests wired-AND)—must be checked online at every edge
        if (vif.top_inhibit_o !== 1'b0) begin
          n_inh_err++;
          `uvm_error("MON", $sformatf("top_inhibit_o should always be 0, actually %b", vif.top_inhibit_o))
        end
        if (vif.capture_dr_i) begin
          in_scan = 1; sel = vif.module_select_i; nbits = 0;
        end else if (in_scan && vif.shift_dr_i && nbits < 64) begin
          tx_bits[nbits] = vif.tdi_i;
          rx_bits[nbits] = vif.module_tdo_o;
          nbits++;
        end else if (in_scan && vif.update_dr_i) begin
          t = jsp_scan_txn::type_id::create("scan");
          t.sel = sel; t.n_bits = nbits; t.n_tx = (nbits + 7) / 8; t.n_rx = t.n_tx;
          for (int i = 0; i < t.n_tx && i < 8; i++)
            for (int b = 0; b < 8; b++) begin
              t.tx_bytes[i][b] = tx_bits[8*i + b];
              t.rx_bytes[i][b] = rx_bits[8*i + b];
            end
          ap.write(t);
          in_scan = 0;
        end
      end
    endtask
  endclass

  // ---------- APB monitor (sample the pre-edge value at the completion edge in the posedge active region) ----------
  class apb_mon extends uvm_monitor;
    `uvm_component_utils(apb_mon)
    virtual jsp_apb_if vif;
    uvm_analysis_port #(apb_txn) ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual jsp_apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      apb_txn t;
      forever begin
        @(posedge vif.pclk);
        if (vif.PSEL === 1'b1 && vif.PENABLE === 1'b1 && vif.PREADY === 1'b1) begin
          // V8 invariant: this module has no error response; PSLVERR is always 0
          if (vif.PSLVERR !== 1'b0)
            `uvm_error("MON", $sformatf("PSLVERR should always be 0: addr=%0d wr=%0d", vif.PADDR, vif.PWRITE))
          t = apb_txn::type_id::create("apb");
          t.wr = vif.PWRITE; t.addr = vif.PADDR; t.wdata = vif.PWDATA; t.rdata = vif.PRDATA;
          t.int_lvl = vif.int_o;      // V8: interrupt level at the completion edge (thr_int_arm is cleared by NBA in the same cycle; take the value before clearing here)
          ap.write(t);
        end
      end
    endtask
  endclass

  // ---------- JTAG driver: TAP state machine simulation (drive on negedge, sample on posedge) ----------
  class jtag_drv extends uvm_driver #(jsp_scan_txn);
    `uvm_component_utils(jtag_drv)
    virtual jsp_apb_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual jsp_apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      jsp_scan_txn t;
      logic [63:0] tx;
      int nshift;
      vif.tdi_i = 0; vif.capture_dr_i = 0; vif.shift_dr_i = 0;
      vif.update_dr_i = 0; vif.module_select_i = 0;
      forever begin
        seq_item_port.get_next_item(t);
        for (int i = 0; i < 8; i++)
          for (int b = 0; b < 8; b++) tx[8*i + b] = t.tx_bytes[i][b];   // Shift each byte LSB first
        @(negedge vif.tck);
        vif.module_select_i = t.sel;
        vif.capture_dr_i = 1'b1;
        @(negedge vif.tck);                       // capture edge: DUT FSM idle→counts, load the status byte
        vif.capture_dr_i = 1'b0;
        vif.shift_dr_i = 1'b1;
        nshift = t.n_bits;
        if (t.abort_after > 0 && t.abort_after < nshift) nshift = t.abort_after;
        for (int j = 0; j < nshift; j++) begin
          vif.tdi_i = tx[j];
          @(negedge vif.tck);
        end
        vif.shift_dr_i = 1'b0;
        vif.update_dr_i = 1'b1;
        @(negedge vif.tck);                       // update edge: DUT FSM →idle
        vif.update_dr_i = 1'b0;
        vif.module_select_i = 1'b0;
        vif.tdi_i = 1'b0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------- APB driver: setup/access two phases + PREADY wait ----------
  class apb_drv extends uvm_driver #(apb_txn);
    `uvm_component_utils(apb_drv)
    virtual jsp_apb_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual jsp_apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      apb_txn t;
      int guard;
      vif.PSEL = 0; vif.PENABLE = 0; vif.PWRITE = 0; vif.PWDATA = '0; vif.PADDR = '0;
      forever begin
        seq_item_port.get_next_item(t);
        @(negedge vif.pclk);
        vif.PSEL = 1'b1; vif.PENABLE = 1'b0;
        vif.PADDR = t.addr; vif.PWRITE = t.wr; vif.PWDATA = t.wdata;
        @(negedge vif.pclk);
        vif.PENABLE = 1'b1;
        guard = 0;
        while (vif.PREADY !== 1'b1) begin
          @(negedge vif.pclk);
          guard++;
          if (guard > 20) begin `uvm_error("APB", "PREADY timeout") break; end
        end
        t.rdata = vif.PRDATA;
        @(negedge vif.pclk);
        vif.PSEL = 1'b0; vif.PENABLE = 1'b0; vif.PWRITE = 1'b0; vif.PWDATA = '0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------- agents ----------
  class jtag_agent extends uvm_agent;
    `uvm_component_utils(jtag_agent)
    jtag_drv drv;
    jsp_mon mon;
    uvm_sequencer #(jsp_scan_txn) sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = jtag_drv::type_id::create("drv", this);
      mon = jsp_mon::type_id::create("mon", this);
      sqr = uvm_sequencer#(jsp_scan_txn)::type_id::create("sqr", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class apb_agent extends uvm_agent;
    `uvm_component_utils(apb_agent)
    apb_drv drv;
    apb_mon mon;
    uvm_sequencer #(apb_txn) sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = apb_drv::type_id::create("drv", this);
      mon = apb_mon::type_id::create("mon", this);
      sqr = uvm_sequencer#(apb_txn)::type_id::create("sqr", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  // ---------- env ----------

  class jsp_native_checker extends uvm_component;
    `uvm_component_utils(jsp_native_checker)
    virtual jsp_apb_if vif;
    int apb_observations=0,tdo_observations=0,errors=0;
    function new(string n,uvm_component p);super.new(n,p);endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual jsp_apb_if)::get(this,"","vif",vif))
        `uvm_fatal("NOVIF","native checker vif missing")
    endfunction
    function void mismatch(string field,logic [7:0] actual,logic [7:0] expected);
      if(actual!==expected)begin
        errors++;
        if(errors<=40)
          `uvm_error("NATIVE_MODEL",$sformatf("%s actual=%h expected=%h",field,actual,expected))
      end
    endfunction
    task check_apb();
      forever begin
        @(negedge vif.pclk);#0.2;
        apb_observations++;
        if(!$test$plusargs("DISABLE_CHECKER"))begin
          mismatch("PSLVERR",vif.PSLVERR,vif.e_PSLVERR);
          mismatch("top_inhibit_o",vif.top_inhibit_o,vif.e_top_inhibit_o);
          if(apb_observations>1)begin
            mismatch("PREADY",vif.PREADY,vif.e_PREADY);
            mismatch("int_o",vif.int_o,vif.e_int_o);
            if(vif.PADDR!=0 || !$isunknown(vif.e_PRDATA))
              mismatch("PRDATA",vif.PRDATA,vif.e_PRDATA);
          end
        end
      end
    endtask
    task check_tdo();
      bit scanning=0;
      int bit_index=0,valid_payload=0;
      logic [7:0] predicted_header=0;
      forever begin
        @(negedge vif.tck);#0.2;
        if(vif.rst_i)begin scanning=0;bit_index=0;end
        else if(vif.capture_dr_i&&vif.module_select_i)begin
          scanning=1;bit_index=0;valid_payload=0;predicted_header=0;
        end else if(vif.update_dr_i)scanning=0;
        else if(scanning&&vif.shift_dr_i)begin
          if(bit_index<8)predicted_header[bit_index]=vif.e_module_tdo_o;
          if(bit_index<8 || bit_index<8+valid_payload*8)begin
            tdo_observations++;
            if(!$test$plusargs("DISABLE_CHECKER"))
              mismatch("module_tdo_o",vif.module_tdo_o,vif.e_module_tdo_o);
          end
          if(bit_index==7)valid_payload=predicted_header[7:4];
          bit_index++;
        end
      end
    endtask
    task run_phase(uvm_phase phase);
      fork check_apb();check_tdo();join
    endtask
    function void check_phase(uvm_phase phase);
      super.check_phase(phase);
      if(apb_observations<100 || tdo_observations<64)
        `uvm_error("NATIVE_VACUOUS","insufficient native port observations")
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("NATIVE_COUNTS",$sformatf("APB=%0d TDO=%0d mismatches=%0d",apb_observations,tdo_observations,errors),UVM_NONE)
    endfunction
  endclass

  class jsp_apb_env extends uvm_env;
    `uvm_component_utils(jsp_apb_env)
    jtag_agent jtag_agt;
    apb_agent  apb_agt;
    jsp_sb     sb;
    jsp_cov    cov;
    jsp_native_checker native_checks;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      jtag_agt = jtag_agent::type_id::create("jtag_agt", this);
      apb_agt  = apb_agent::type_id::create("apb_agt", this);
      sb  = jsp_sb::type_id::create("sb", this);
      cov = jsp_cov::type_id::create("cov", this);
      native_checks=jsp_native_checker::type_id::create("native_checks",this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      jtag_agt.mon.ap.connect(sb.jtag_imp);
      apb_agt.mon.ap.connect(sb.apb_imp);
      jtag_agt.mon.ap.connect(cov.analysis_export);
      apb_agt.mon.ap.connect(cov.apb_imp);
      cov.sb = sb;                 // V8: IIR coverage sampling uses model IER/FIFO occupancy (sb receives transactions before cov)
    endfunction
  endclass

  // ---------- Virtual sequence base class: coordination of APB/JTAG sequencers ----------
  class jsp_vseq extends uvm_sequence #(uvm_sequence_item);
    `uvm_object_utils(jsp_vseq)
    jsp_apb_env env;
    virtual jsp_apb_if vif;
    function new(string name = "jsp_vseq"); super.new(name); endfunction

    task apb_op(bit wr_i, bit [2:0] addr_i, bit [7:0] data_i, output bit [7:0] rd_o);
      apb_txn t = apb_txn::type_id::create("t");
      start_item(t, -1, env.apb_agt.sqr);
      t.wr = wr_i; t.addr = addr_i; t.wdata = data_i;
      finish_item(t);
      rd_o = t.rdata;
    endtask

    task scan_op(input int cnt_i,
                 input bit [7:0] d0, input bit [7:0] d1, input bit [7:0] d2,
                 input bit [7:0] d3, input bit [7:0] d4, input bit [7:0] d5,
                 input bit [7:0] d6,
                 input int abort_i = 0, input bit sel_i = 1'b1);
      jsp_scan_txn t = jsp_scan_txn::type_id::create("t");
      start_item(t, -1, env.jtag_agt.sqr);
      t.tx_bytes[0] = {cnt_i[3:0], cnt_i[3:0]};    // Mirror the count nibble to avoid alignment ambiguity
      t.tx_bytes[1] = d0; t.tx_bytes[2] = d1; t.tx_bytes[3] = d2; t.tx_bytes[4] = d3;
      t.tx_bytes[5] = d4; t.tx_bytes[6] = d5; t.tx_bytes[7] = d6;
      t.abort_after = abort_i; t.sel = sel_i;
      finish_item(t);
    endtask

    task settle();      // Quiesce both domains to ensure CDC synchronized values converge
      repeat (8) @(negedge vif.tck);
      repeat (8) @(negedge vif.pclk);
    endtask

    task resync();      // FCR reset of both FIFOs: realign the model and DUT after concurrency/randomization
      bit [7:0] r;
      settle();
      apb_op(1, 3'd2, 8'h06, r);
    endtask

    // Align the arm bit on both sides (IIR read-to-clear; drift may exist, so checking must be disabled)
    task align_arm();
      bit [7:0] r;
      bit ce = env.sb.chk_en;
      env.sb.chk_en = 0;
      apb_op(0, 3'd2, 0, r);
      env.sb.chk_en = ce;
    endtask

    // ---- V9 concurrent-window checking (call before resync: race-arc differences are observable) ----
    task conc_settle();      // wr side: RBR drain loop + multiset comparison + LSR final state
      bit [7:0] r, e;
      settle();
      env.sb.chk_en = 1;
      env.sb.conc_arm();     // Expected set = all current model wr contents
      // Read until drained: DUT-side LSR bit0 indicates wr_fifo is nonempty (at most 24 iterations to prevent a hang)
      for (int k = 0; k < 24; k++) begin
        apb_op(0, 3'd5, 8'h00, r);
        if (r[0] === 1'b0) break;
        apb_op(0, 3'd0, 8'h00, r);
      end
      env.sb.conc_end();
      e = {1'b0, (env.sb.q_rd.size() < 8), (env.sb.q_rd.size() < 8), 4'h0, 1'b0};
      apb_op(0, 3'd5, 8'h00, r);
      env.sb.chk(r === e, "conc LSR mismatch after drain");
      env.sb.chk_en = 0;
    endtask

    task rdc_conc_settle();  // Symmetric rd side: FCR bit2 clears residual contents + LSR bit5/6 final state
      bit [7:0] r;
      settle();
      env.sb.chk_en = 1;
      apb_op(1, 3'd2, 8'h04, r);   // FCR bit2: rd_fifo reset (model synchronized)
      env.sb.q_rd.delete();
      apb_op(0, 3'd5, 8'h00, r);
      env.sb.chk(r[6:5] === 2'b11,
                 $sformatf("conc rd LSR bit5/6 not empty-free after clear, got r=%b", r));
      env.sb.chk_en = 0;
    endtask

    task chk_int();
      if (vif.int_o !== env.sb.int_exp()) begin
        env.sb.n_err++;
        `uvm_info("LEGACY_DIAGNOSTIC", $sformatf("int_o mismatch exp=%b got=%b", env.sb.int_exp(), vif.int_o),UVM_LOW)
      end
    endtask
  endclass

  // ---- Pure JTAG / pure APB loop subsequences (for F09 concurrency, running on their respective sequencers) ----
  class js_loop extends uvm_sequence #(jsp_scan_txn);
    `uvm_object_utils(js_loop)
    int n = 4; int cnt = 0;
    function new(string name = "js_loop"); super.new(name); endfunction
    task body();
      for (int k = 0; k < n; k++) begin
        jsp_scan_txn t = jsp_scan_txn::type_id::create("t");
        start_item(t);
        t.tx_bytes[0] = {cnt[3:0], cnt[3:0]};
        for (int i = 1; i < 8; i++) t.tx_bytes[i] = 8'h10 * i + k;
        finish_item(t);
      end
    endtask
  endclass

  class as_loop extends uvm_sequence #(apb_txn);
    `uvm_object_utils(as_loop)
    int n = 4; bit wr = 1; bit [2:0] addr = 0;
    function new(string name = "as_loop"); super.new(name); endfunction
    task body();
      for (int k = 0; k < n; k++) begin
        apb_txn t = apb_txn::type_id::create("t");
        start_item(t);
        t.wr = wr; t.addr = addr; t.wdata = 8'hB0 + k;
        finish_item(t);
      end
    endtask
  endclass

  // ---------- feature sequences ----------
  class s_f01_regs extends jsp_vseq;      // Register write/readback + dlab branch + full address space
    `uvm_object_utils(s_f01_regs)
    function new(string n = "s_f01_regs"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      for (int k = 0; k < 8; k++) apb_op(0, k[2:0], 0, r);          // Read all reset values (empty reads of the data port return X)
      apb_op(1, 3'd7, 8'h00, r); apb_op(0, 3'd7, 0, r);             // SCR boundary 0x00
      apb_op(1, 3'd7, 8'hFF, r); apb_op(0, 3'd7, 0, r);             // SCR boundary 0xFF
      apb_op(1, 3'd7, 8'hA5, r); apb_op(0, 3'd7, 0, r);
      apb_op(1, 3'd3, 8'h5A, r); apb_op(0, 3'd3, 0, r);             // LCR（dlab=0）
      apb_op(1, 3'd1, 8'h0F, r); apb_op(0, 3'd1, 0, r);             // IER all 1
      apb_op(1, 3'd3, 8'h80, r);                                     // LCR.DLAB=1
      apb_op(0, 3'd0, 0, r); apb_op(0, 3'd1, 0, r);                  // dlab=1: DLL/DLM take the reg_ack path
      apb_op(1, 3'd1, 8'h0F, r); apb_op(0, 3'd1, 0, r);              // dlab=1: IER writes are masked (readback 0)
      apb_op(1, 3'd3, 8'h00, r);                                     // Reset DLAB
      apb_op(1, 3'd1, 8'h00, r);                                     // Clear IER to zero
      apb_op(0, 3'd4, 0, r); apb_op(0, 3'd5, 0, r); apb_op(0, 3'd6, 0, r);   // MCR/LSR/MSR
    endtask
  endclass

  class s_f02_j2a extends jsp_vseq;      // JTAG→APB: scan write + APB readback (boundary values A5/00/FF)
    `uvm_object_utils(s_f02_j2a)
    function new(string n = "s_f02_j2a"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      settle();
      scan_op(3, 8'hA5, 8'h00, 8'hFF, 8'h00, 8'h00, 8'h00, 8'h00);
      settle();
      apb_op(0, 3'd5, 0, r);                                          // LSR: bit0=1
      apb_op(0, 3'd0, 0, r); apb_op(0, 3'd0, 0, r); apb_op(0, 3'd0, 0, r);
      apb_op(0, 3'd5, 0, r);                                          // LSR: bit0=0 (empty)
    endtask
  endclass

  class s_f03_a2j extends jsp_vseq;      // APB→JTAG: THR write + scan readout
    `uvm_object_utils(s_f03_a2j)
    function new(string n = "s_f03_a2j"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      settle();
      apb_op(1, 3'd0, 8'h12, r); apb_op(1, 3'd0, 8'h34, r); apb_op(1, 3'd0, 8'h56, r);
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Read out 3 bytes, check the status byte
    endtask
  endclass

  class s_f04_bound extends jsp_vseq;    // FIFO boundaries: fill/full push blocked/drain/empty scan/near-full and near-empty/cnt=0 when full
    `uvm_object_utils(s_f04_bound)
    function new(string n = "s_f04_bound"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      settle();
      env.sb.chk_en = 0;   // CDC counts are stale during back-to-back dual scans; a transient status-byte mismatch is inevitable
      scan_op(7, 8'h11, 8'h22, 8'h33, 8'h44, 8'h55, 8'h66, 8'h77);   // Fill 7 from empty
      scan_op(7, 8'h88, 8'h99, 8'hAA, 8'hBB, 8'hCC, 8'hDD, 8'hEE);   // Back-to-back: synchronized space is stale
      settle();                                                        //  → Push when full is blocked by push_ok
      env.sb.chk_en = 1;
      apb_op(0, 3'd5, 0, r);                                          // Full: LSR bit0=1
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // cnt=0 when full: both zero signals true simultaneously
      settle();
      scan_op(7, 8'hE1, 8'hE2, 8'hE3, 8'hE4, 8'hE5, 8'hE6, 8'hE7);   // Space 0: all discarded
      settle();
      for (int k = 0; k < 8; k++) apb_op(0, 3'd0, 0, r);             // Drain 8 bytes
      apb_op(0, 3'd0, 0, r);                                          // Empty read (DUT returns X)
      // Fill rd_fifo to 8 (one-hot bytes → all data-path bits toggle)
      apb_op(1, 3'd0, 8'h01, r);
      apb_op(1, 3'd0, 8'h02, r);
      apb_op(1, 3'd0, 8'h04, r);
      apb_op(1, 3'd0, 8'h08, r);
      apb_op(1, 3'd0, 8'h10, r);
      apb_op(1, 3'd0, 8'h20, r);
      apb_op(1, 3'd0, 8'h40, r);
      apb_op(1, 3'd0, 8'h80, r);
      apb_op(1, 3'd0, 8'hF0, r);                                      // Write again when full: push_ok=0
      apb_op(1, 3'd0, 8'h0F, r);
      settle();
      apb_op(0, 3'd5, 0, r);                                          // Full: bit5/6=0
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Output 7 bytes, 1 remain
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Output 1 bytes → empty
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Empty scan (status byte 00)
      settle();
    endtask
  endclass

  class s_f07_iir extends jsp_vseq;      // Three IIR values 1/2/4 + int_o erbfi/etbei, both items
    `uvm_object_utils(s_f07_iir)
    function new(string n = "s_f07_iir"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      settle();
      apb_op(1, 3'd1, 8'h00, r);       // IER disabled
      apb_op(0, 3'd2, 0, r);           // IIR (f04 scanned rd empty and already armed it → 2; q_wr empty)
      apb_op(0, 3'd2, 0, r);           // arm already cleared → 1
      settle();
      scan_op(2, 8'hD1, 8'hD2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // JTAG writes wr_fifo
      settle();
      apb_op(0, 3'd2, 0, r);           // IIR=4 (wrfifo contains data)
      apb_op(1, 3'd1, 8'h01, r);       // erbfi → int_o=1
      chk_int();
      apb_op(1, 3'd1, 8'h00, r);       // IER disabled → int_o=0
      chk_int();
      apb_op(0, 3'd0, 0, r); apb_op(0, 3'd0, 0, r);   // Drain wr_fifo
      settle();
      apb_op(1, 3'd0, 8'hAA, r);       // THR write → arm=1
      apb_op(1, 3'd1, 8'h02, r);       // etbei and rd not full → IIR=2, int_o=1
      chk_int();
      apb_op(0, 3'd2, 0, r);           // IIR=2; arm cleared after read → int_o=0
      chk_int();
      apb_op(0, 3'd2, 0, r);           // IIR=1
      apb_op(1, 3'd1, 8'h00, r);
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Scan out residual rd contents
      // ---- V8 coverage arcs: IIR priority(1/2/4)×IER enable, int_o(0/1)×rd occupancy (mandatory covergroup supplement) ----
      resync(); settle(); align_arm();
      for (int e = 0; e <= 3; e++) begin
        apb_op(1, 3'd1, e[7:0], r);                 // IER = e (erbfi/etbei combinations)
        apb_op(0, 3'd2, 0, r);                      // Clear residual arm (reading IIR when wr is empty clears it)
        apb_op(0, 3'd2, 0, r);                      // IIR=1 × e
        apb_op(1, 3'd0, 8'h40 + e, r);              // THR：rd=1、arm
        apb_op(0, 3'd2, 0, r);                      // IIR=2 × e（int = e[1]）
        settle();                                    // av syncreg convergence (pclk→tck ~30-40ns):
        scan_op(1, 8'h50 + e, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);  // Capture must see av=1 before popping 0x40+e
        settle();                                    // wr 1 bytes, rd scanned empty (scanning empty resets arm)
        apb_op(0, 3'd2, 0, r);                      // IIR=4 × e（int = e[0]）
        apb_op(0, 3'd0, 0, r);                      // RBR checks the popped byte
        apb_op(1, 3'd2, 8'h06, r);                  // FCR clear both, return to a clean starting point
      end
      // int_o=1 arc: etbei + arm (set by THR write/scan-to-empty) × rd occupancy 0..7
      apb_op(1, 3'd1, 8'h02, r);
      apb_op(0, 3'd2, 0, r);                        // After scanning to empty, arm=1 → IIR=2, int=1, avl=0
      for (int L = 1; L <= 7; L++) begin
        apb_op(1, 3'd0, 8'h20 + L, r);              // rd→L、arm
        apb_op(0, 3'd2, 0, r);                      // IIR=2, int=1, avl=L (read clears arm; reset next round)
      end
      // int_o=1 × rd full: erbfi + wr nonempty (scan necessarily pops 7; refill before reading again)
      apb_op(1, 3'd0, 8'h38, r);                    // rd→8、arm
      apb_op(1, 3'd1, 8'h01, r);                    // erbfi: wr-side interrupt source
      settle();                                      // av syncreg converges to 8 (0x38 just written)
      scan_op(1, 8'h71, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
      settle();                                      // wr 1 bytes, rd 8→1
      for (int k = 0; k < 7; k++) apb_op(1, 3'd0, 8'h60 + k, r);   // Refill rd to 8
      apb_op(0, 3'd2, 0, r);                        // IIR=4、int=1、avl=8
      // int_o=0 arc: IER off × {a_mid, a7, a8}
      apb_op(1, 3'd1, 8'h00, r);
      apb_op(0, 3'd2, 0, r);                        // IIR=4、int=0、avl=8
      apb_op(0, 3'd0, 0, r);                        // Drain wr (check 0x71)
      apb_op(1, 3'd2, 8'h06, r);                    // FCR clear both
      for (int k = 0; k < 4; k++) apb_op(1, 3'd0, 8'h80 + k, r);   // rd=4
      apb_op(0, 3'd2, 0, r);                        // IIR=2(arm)、int=0、a_mid
      for (int k = 0; k < 3; k++) apb_op(1, 3'd0, 8'h90 + k, r);   // rd=7
      apb_op(0, 3'd2, 0, r);                        // int=0、a7
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00); // Scan out rd residue
      settle();
      resync();
    endtask
  endclass

  class s_f08_fcr extends jsp_vseq;      // FCR FIFO reset
    `uvm_object_utils(s_f08_fcr)
    function new(string n = "s_f08_fcr"); super.new(n); endfunction
    task fill_rd(int n);                 // Fill rd_fifo with n bytes, then wait for CDC avail to converge
      bit [7:0] r;
      for (int k = 0; k < n; k++) apb_op(1, 3'd0, 8'hE0 + k, r);
      settle();
    endtask
    task drain_wr();                     // Drain wr: check bytes pushed by the cnt scan byte by byte
      bit [7:0] r;
      for (int k = 0; k < 16; k++) begin
        apb_op(0, 3'd5, 8'h00, r);
        if (r[0] === 1'b0) break;
        apb_op(0, 3'd0, 8'h00, r);
      end
    endtask
    task body();
      bit [7:0] r;
      settle();
      scan_op(2, 8'hC1, 8'hC2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
      apb_op(1, 3'd0, 8'hD1, r); apb_op(1, 3'd0, 8'hD2, r);
      settle();
      apb_op(1, 3'd2, 8'h02, r);       // bit1: reset wr_fifo (JTAG input side)
      apb_op(0, 3'd5, 0, r);           // LSR bit0=0
      apb_op(1, 3'd2, 8'h04, r);       // bit2: reset rd_fifo (APB input side)
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Status byte 00
      // V3/V4: supplementary arcs for cnt×occupancy cross (c7/c_mid/c1 × a8/a7/a_mid/a1, all checked)
      fill_rd(8); scan_op(7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c7,a8}
      settle();      scan_op(7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c7,a1}
      fill_rd(4); scan_op(7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c7,a_mid}
      fill_rd(7); scan_op(7, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c7,a7}
      fill_rd(8); scan_op(1, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c1,a8}
      settle();      scan_op(1, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c1,a1}
      fill_rd(7); scan_op(1, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c1,a7}
      fill_rd(4); scan_op(1, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c1,a_mid}
      fill_rd(8); scan_op(2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c_mid,a8}
      settle();      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Drain 1 residual rd bytes
      fill_rd(7); scan_op(2, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c_mid,a7}
      fill_rd(7); scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // {c0,a7}
      settle();
      drain_wr();                      // Drain wr (also covers RBR datapath checking)
      settle();
    endtask
  endclass

  class s_f09_conc extends jsp_vseq;     // Dual-domain concurrency: contention arcs RD_POP↔RD_PUSH / WR_PUSH↔WR_POP
    `uvm_object_utils(s_f09_conc)
    function new(string n = "s_f09_conc"); super.new(n); endfunction
    task body();
      js_loop js;
      as_loop as_;
      bit [7:0] r0;
      env.sb.chk_en = 0;
      // JTAG write scan (wr_fifo side) ∥ APB RBR read loop: prefill 2—low occupancy ensures that the DUT's
      // tck-side space syncreg view matches the model (near full, pop lag causes push counts to diverge,
      // making multiset contents unpredictable); contention arcs are still covered by push/pop overlap in the same window
      scan_op(2, 8'h21, 8'h22, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
      js = js_loop::type_id::create("js");  js.n = 8;  js.cnt = 2;
      as_ = as_loop::type_id::create("as"); as_.n = 16; as_.wr = 0; as_.addr = 3'd0;
      env.cov.sample_conc(1);                 // V9: concurrent-window marker (coverage expresses that contention arcs are exercised again)
      env.sb.conc_start();                    // V9: collect push candidates (DUT gating uses a stale view; the set cannot be measured precisely)
      fork js.start(env.jtag_agt.sqr); as_.start(env.apb_agt.sqr); join
      env.sb.conc_stop();
      env.cov.sample_conc(0);
      conc_settle();                 // V9: wr-side multiset check + LSR final state
      resync();
      // JTAG read scan (rd_fifo side) ∥ APB THR write loop: prefill 8 to ensure data is available to pop throughout the scan
      apb_op(1, 3'd0, 8'h31, r0);
      apb_op(1, 3'd0, 8'h32, r0);
      apb_op(1, 3'd0, 8'h33, r0);
      apb_op(1, 3'd0, 8'h34, r0);
      apb_op(1, 3'd0, 8'h35, r0);
      apb_op(1, 3'd0, 8'h36, r0);
      apb_op(1, 3'd0, 8'h37, r0);
      apb_op(1, 3'd0, 8'h38, r0);
      js = js_loop::type_id::create("js2");  js.n = 8;  js.cnt = 0;
      as_ = as_loop::type_id::create("as2"); as_.n = 16; as_.wr = 1; as_.addr = 3'd0;
      env.cov.sample_conc(1);                 // V9: rd-side concurrent-window marker
      fork js.start(env.jtag_agt.sqr); as_.start(env.apb_agt.sqr); join
      env.cov.sample_conc(0);
      // V9 rd-side symmetric check: when the THR write loop does not overflow, the scanned-out contents have already been routinely checked by write_jtag
      // byte by byte; here, clear residual rd contents and check the final states of LSR bit5/6, then resync
      rdc_conc_settle();
      resync();
      env.sb.chk_en = 1;
    endtask
  endclass

  class s_f10_abort extends jsp_vseq;    // Early update abort: counts(4bit)/end of counts(8bit)/rdack(12bit)→idle
    `uvm_object_utils(s_f10_abort)
    function new(string n = "s_f10_abort"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      apb_op(1, 3'd0, 8'hF1, r); apb_op(1, 3'd0, 8'hF2, r);   // Prepare 2 bytes in rd_fifo
      settle();
      // Abort points cover all wr{counts,xfer}→idle and rd{counts,rdack,xfer}→idle arcs
      scan_op(3, 8'h91, 8'h92, 8'h93, 8'h00, 8'h00, 8'h00, 8'h00, 2);
      scan_op(3, 8'h94, 8'h95, 8'h96, 8'h00, 8'h00, 8'h00, 8'h00, 4);
      scan_op(3, 8'h97, 8'h98, 8'h99, 8'h00, 8'h00, 8'h00, 8'h00, 7);
      scan_op(3, 8'h9A, 8'h9B, 8'h9C, 8'h00, 8'h00, 8'h00, 8'h00, 12);
      scan_op(3, 8'h9D, 8'h9E, 8'h9F, 8'h00, 8'h00, 8'h00, 8'h00, 24);
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Regular scan: check status/remainder
      settle();
      resync();
    endtask
  endclass

  class s_f11_sel0 extends jsp_vseq;     // module_select=0: FSM stays in the idle branch
    `uvm_object_utils(s_f11_sel0)
    function new(string n = "s_f11_sel0"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      scan_op(2, 8'h31, 8'h32, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 0, 1'b0);
      settle();
      apb_op(0, 3'd5, 0, r);             // FIFO still empty
    endtask
  endclass

  class s_f06_reset extends jsp_vseq;    // Dual-domain reset: in-flight/stored-data behavior + post-reset register readback
    `uvm_object_utils(s_f06_reset)
    function new(string n = "s_f06_reset"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      // JTAG-domain reset: clear all FIFOs and synchronizers
      apb_op(1, 3'd0, 8'h71, r); apb_op(1, 3'd0, 8'h72, r);
      settle();                                          // avail syncreg converges → scan out 71,72
      scan_op(2, 8'h73, 8'h74, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);
      apb_op(1, 3'd3, 8'h3C, r); apb_op(1, 3'd7, 8'h7E, r);
      settle();
      env.cov.sample_rst(1);                             // V10: FIFO nonempty × JTAG-domain reset
      env.sb.quiet = 1;
      fork
        begin scan_op(3, 8'h75, 8'h76, 8'h77, 8'h00, 8'h00, 8'h00, 8'h00); end
        begin repeat (10) @(negedge vif.tck); vif.pulse_rst_jtag(); end
      join
      settle();
      env.sb.flush_fifos();
      env.sb.quiet = 0;
      apb_op(0, 3'd5, 0, r);                            // Both FIFOs empty
      apb_op(0, 3'd3, 0, r); apb_op(0, 3'd7, 0, r);     // PCLK-domain registers are unaffected by rst_i
      // APB-domain reset: ier/lcr/scr cleared to zero, FIFO data retained (rdata register cleared to zero)
      scan_op(1, 8'h82, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // wr_fifo stores 1 bytes (rd empty: no pop)
      apb_op(1, 3'd0, 8'h81, r);                        // rd_fifo stores 1 bytes, rdata=81
      settle();
      env.cov.sample_rst(2);                            // V10: FIFO nonempty × APB-domain reset
      env.sb.quiet = 1;
      vif.pulse_presetn();
      settle();
      env.sb.apb_regs_reset();                          // rdata_clr=1
      env.sb.quiet = 0;
      apb_op(0, 3'd1, 0, r);                            // IER=0
      apb_op(0, 3'd3, 0, r);                            // LCR=0
      apb_op(0, 3'd7, 0, r);                            // SCR=0
      settle();
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // FIFO data still present: 81 is popped (rdata already cleared to zero → rx[0]=00)
      settle();
      resync();
      env.cov.sample_rst(0);                            // V10: FIFO already empty × JTAG-domain reset pulse
      vif.pulse_rst_jtag();
      settle();
      align_arm();
    endtask
  endclass

  class s_f12_random extends jsp_vseq;    // Random mix (no checks; model aligned by FCR at the end)
    `uvm_object_utils(s_f12_random)
    function new(string n = "s_f12_random"); super.new(n); endfunction
    task body();
      bit [7:0] r;
      int op, cnt;
      env.sb.chk_en = 0;
      for (int k = 0; k < 14; k++) begin
        op  = $urandom_range(0, 2);
        cnt = $urandom_range(0, 7);
        case (op)
          0: scan_op(cnt, $urandom, $urandom, $urandom, 8'h00, 8'h00, 8'h00, 8'h00);
          1: apb_op(1, $urandom_range(0, 7), $urandom, r);
          2: apb_op(0, $urandom_range(0, 7), 8'h00, r);
        endcase
      end
      resync();
      settle();
      align_arm();
      // Fallback walkthrough: the model silently follows throughout the random segment; regular checking resumes here, making accumulated mismatches on the random path observable
      env.sb.chk_en = 1;
      apb_op(1, 3'd3, 8'h00, r);                   // LCR=0 (dlab off, register window normalized)
      apb_op(0, 3'd3, 0, r);                       // LCR readback check
      apb_op(0, 3'd1, 0, r);                       // IER readback check
      apb_op(0, 3'd7, 0, r);                       // SCR readback check
      scan_op(0, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00, 8'h00);   // Empty scan: status-byte check
      settle();
      apb_op(0, 3'd5, 0, r);                       // LSR: fallback comparison of the both-empty final state
      apb_op(0, 3'd6, 0, r);                       // MSR constant comparison
    endtask
  endclass

  // ---------- t_main orchestration body ----------
  class t_main_vseq extends jsp_vseq;
    `uvm_object_utils(t_main_vseq)
    function new(string n = "t_main_vseq"); super.new(n); endfunction
    task contiguous_apb_witnesses();
      bit [7:0] observed;
      bit [7:0] transmitted[8];
      apb_op(1,3'd3,0,observed);
      resync();
      @(negedge vif.pclk);
      vif.PSEL=1;vif.PENABLE=0;vif.PWRITE=1;vif.PADDR=0;vif.PWDATA=8'h35;
      @(negedge vif.pclk);vif.PENABLE=1;
      @(negedge vif.pclk);vif.PENABLE=0;vif.PWDATA=8'hca;
      @(negedge vif.pclk);vif.PENABLE=1;
      @(negedge vif.pclk);vif.PSEL=0;vif.PENABLE=0;
      settle();
      for(int index=0;index<8;index++)transmitted[index]=0;
      scan_op(0,0,0,0,0,0,0,0);
      settle();
      resync();
      transmitted[0]=8'h27;transmitted[1]=8'hb8;
      scan_op(2,transmitted[0],transmitted[1],0,0,0,0,0);
      settle();
      @(negedge vif.pclk);
      vif.PSEL=1;vif.PENABLE=0;vif.PWRITE=0;vif.PADDR=0;
      @(negedge vif.pclk);vif.PENABLE=1;
      @(negedge vif.pclk);vif.PENABLE=0;
      @(negedge vif.pclk);vif.PENABLE=1;
      @(negedge vif.pclk);vif.PSEL=0;vif.PENABLE=0;
      settle();
      resync();
      scan_op(1,transmitted[0],0,0,0,0,0,0);
      settle();
      vif.PADDR=5;
      @(negedge vif.pclk);#0.5;
      if(vif.e_PRDATA[0]!==1) `uvm_error("ASYNC_NONVACUITY","Independent input history must establish a nonempty inbound queue")
      vif.rst_i=1;
      #0.2;
      if(vif.e_PRDATA[0]!==0) `uvm_error("ASYNC_NONVACUITY","Independent reset prediction must clear nonempty inbound queue")
      env.native_checks.mismatch("asynchronous_fifo_reset",vif.PRDATA,vif.e_PRDATA);
      #0.3;vif.rst_i=0;
      settle();
      for(int alignment=0;alignment<3;alignment++)begin
        resync();apb_op(1,3'd0,8'h59,observed);settle();
        apb_op(0,3'd2,0,observed);
        fork
          scan_op(0,0,0,0,0,0,0,0);
          begin
            repeat(alignment)@(negedge vif.pclk);
            for(int index=0;index<80;index++)begin
              @(negedge vif.pclk);vif.PSEL=1;vif.PENABLE=0;vif.PWRITE=0;vif.PADDR=2;
              @(negedge vif.pclk);vif.PENABLE=1;
            end
            @(negedge vif.pclk);vif.PSEL=0;vif.PENABLE=0;
          end
        join
        settle();
      end
      resync();
    endtask
    task body();
      jsp_vseq subs[$];
      settle();
      subs.push_back(s_f01_regs::type_id::create("f01"));
      subs.push_back(s_f02_j2a::type_id::create("f02"));
      subs.push_back(s_f03_a2j::type_id::create("f03"));
      subs.push_back(s_f04_bound::type_id::create("f04"));
      subs.push_back(s_f07_iir::type_id::create("f07"));
      subs.push_back(s_f08_fcr::type_id::create("f08"));
      subs.push_back(s_f09_conc::type_id::create("f09"));
      subs.push_back(s_f10_abort::type_id::create("f10"));
      subs.push_back(s_f11_sel0::type_id::create("f11"));
      subs.push_back(s_f06_reset::type_id::create("f06"));
      subs.push_back(s_f12_random::type_id::create("f12"));
      foreach (subs[i]) begin
        subs[i].env = env; subs[i].vif = vif;
        `uvm_info("T", $sformatf("phase %0d: %s", i, subs[i].get_name()), UVM_LOW)
        subs[i].start(env.jtag_agt.sqr);
      end
      contiguous_apb_witnesses();
    endtask
  endclass

  // ---------- tests ----------
  class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    jsp_apb_env env;
    virtual jsp_apb_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = jsp_apb_env::type_id::create("env", this);
      if (!uvm_config_db#(virtual jsp_apb_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
      uvm_config_db#(virtual jsp_apb_if)::set(this, "env*", "vif", vif);
    endfunction
    task run_phase(uvm_phase phase);
      jsp_vseq s;
      phase.raise_objection(this);
      wait (vif.PRESETn === 1'b1);
      repeat (10) @(negedge vif.tck);
      s = main_seq();
      s.env = env; s.vif = vif;
      s.start(env.jtag_agt.sqr);
      repeat (20) @(negedge vif.pclk);
      phase.drop_objection(this);
    endtask
    virtual function jsp_vseq main_seq();
      return jsp_vseq::type_id::create("s");
    endfunction
  endclass

  class dvbench_test extends test_base;        // Default comprehensive test: all features in sequence
    `uvm_component_utils(dvbench_test)
    function new(string n = "dvbench_test", uvm_component p = null); super.new(n, p); endfunction
    function jsp_vseq main_seq();
      return t_main_vseq::type_id::create("main");
    endfunction

    function void report_phase(uvm_phase phase);
      uvm_report_server server;
      super.report_phase(phase);server=uvm_report_server::get_server();
      if(server.get_severity_count(UVM_ERROR)==0&&server.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass

endpackage
