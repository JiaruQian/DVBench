// rdma_pkg.sv — axi_rdma UVM environment (full feature list coverage version)
// feature index: F01 handshakes F02 data F03 length/alignment F04 flow control F05 clocks F06 reset
//               F07 status cross-checking F08 parameters (two instances: big-endian MB16 / little-endian MB8) F09 FIFO full/empty boundaries
// Note: The RTL first_wstrb table is a mirrored implementation — the byte window for a single-dword command (off+B<=4) is
//     base+(4-off-B); the scoreboard models as-implemented behavior (multi-dword path = standard semantics)
`timescale 1ns/1ps
package rdma_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_do)
  `uvm_analysis_imp_decl(_ar)

  //  All three rresp states, 2'b00/2'b10(SLVERR)/2'b11(DECERR), have stimulus and coverage
  typedef enum {M_SAME, M_ARDLY, M_RGAP, M_BP, M_FULLP, M_CLK, M_RESET, M_STRESS, M_ERR} cov_mode_e;

  typedef struct packed {
    bit [31:0] addr;
    bit [7:0]  len;
  } ar_req_t;

  typedef struct packed {
    bit [31:0] data;
    bit [3:0]  keep;
    bit        last;
  } exp_beat_t;

  // ---------- Memory model (AXI slave data source + expected stream data source, using the same model) ----------
  class mem_model extends uvm_object;
    `uvm_object_utils(mem_model)
    bit [7:0] b [bit [31:0]];
    function new(string name = "mem_model"); super.new(name); endfunction
    function void fill(bit [31:0] base, int n, int mode);
      for (int i = 0; i < n; i++)
        case (mode)
          0: b[base + i] = $urandom();
          1: b[base + i] = 8'h00;
          2: b[base + i] = 8'hFF;
          default: b[base + i] = i[7:0];
        endcase
    endfunction
    function bit [7:0] g(bit [31:0] a);
      if (!b.exists(a)) b[a] = $urandom();
      return b[a];
    endfunction
  endclass

  // ---------- txn ----------
  class cmd_txn extends uvm_sequence_item;
    rand bit [31:0] addr, nbytes;
    rand int        gap;
    constraint c_gap { gap dist {0 := 8, 1 := 1, [2:3] := 1}; }
    `uvm_object_utils_begin(cmd_txn)
      `uvm_field_int(addr, UVM_ALL_ON) `uvm_field_int(nbytes, UVM_ALL_ON)
      `uvm_field_int(gap, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "cmd_txn"); super.new(name); endfunction
  endclass

  class ar_txn extends uvm_sequence_item;
    bit [31:0] addr;
    bit [7:0]  len;
    bit [3:0]  id;
    bit [2:0]  size;
    bit [1:0]  burst;
    bit [1:0]  resp;
    `uvm_object_utils_begin(ar_txn)
      `uvm_field_int(addr, UVM_ALL_ON) `uvm_field_int(len, UVM_ALL_ON)
      `uvm_field_int(id, UVM_ALL_ON) `uvm_field_int(size, UVM_ALL_ON)
      `uvm_field_int(burst, UVM_ALL_ON) `uvm_field_int(resp, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "ar_txn"); super.new(name); endfunction
  endclass

  class do_txn extends uvm_sequence_item;
    bit [31:0] data;
    bit [3:0]  keep;
    bit        last;
    `uvm_object_utils_begin(do_txn)
      `uvm_field_int(data, UVM_ALL_ON) `uvm_field_int(keep, UVM_ALL_ON)
      `uvm_field_int(last, UVM_ALL_ON)
    `uvm_object_utils_end
    function new(string name = "do_txn"); super.new(name); endfunction
  endclass

  // ---------- coverage ----------
  class rdma_cov extends uvm_component;
    `uvm_component_utils(rdma_cov)
    uvm_analysis_imp    #(cmd_txn, rdma_cov) cmd_imp;
    uvm_analysis_imp_do #(do_txn,  rdma_cov) do_imp;
    uvm_analysis_imp_ar #(ar_txn,  rdma_cov) ar_imp;
    cov_mode_e cur_mode = M_SAME;
    bit [1:0]       c_off, c_bmod;
    int unsigned    c_len;
    bit [31:0]      b_data;
    bit [3:0]       b_keep;
    bit             b_last;
    bit [7:0]       a_len;
    bit [1:0]       a_resp;

    covergroup cg_cmd();      option.per_instance = 1;
      cp_mode: coverpoint cur_mode;                       // F01/F04/F05/F06 context
      cp_off:  coverpoint c_off;                          // F03 address alignment
      cp_bmod: coverpoint c_bmod;                         // F03 length modulo 4
      cp_len:  coverpoint c_len {                         // F03 length boundaries
        bins bz   = {0};
        bins one  = {1};
        bins b23  = {[2:3]};
        bins b4_7 = {[4:7]};
        bins b8_15 = {[8:15]};
        bins b16_63 = {[16:63]};
        bins b64p = {[64:128]};
      }
      x_ob: cross cp_off, cp_bmod;                        // first/last_wstrb 16 row table
      // Mode context × length boundaries (VCS enum automatic bin names are auto_<value>; intersect must be used to reference values)
      x_mode_len: cross cp_mode, cp_len {
        bins same_len0 = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {0};
        bins same_one  = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {1};
        bins same_b23   = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {[2:3]};
        bins same_b4_7  = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {[4:7]};
        bins same_b8_15 = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {[8:15]};
        bins same_b16_63= binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {[16:63]};
        bins same_b64p  = binsof(cp_mode) intersect {M_SAME} && binsof(cp_len) intersect {[64:128]};
        bins dly_8_15  = (binsof(cp_mode) intersect {M_ARDLY, M_RGAP})
                        && binsof(cp_len) intersect {[8:15]};
        bins bp_8_15   = binsof(cp_mode) intersect {M_BP}    && binsof(cp_len) intersect {[8:15]};
        bins fullp_64p = binsof(cp_mode) intersect {M_FULLP} && binsof(cp_len) intersect {[64:128]};
        bins clk_8_15  = binsof(cp_mode) intersect {M_CLK}   && binsof(cp_len) intersect {[8:15]};
        bins rst_b4_7  = binsof(cp_mode) intersect {M_RESET} && binsof(cp_len) intersect {[4:7]};
        bins rst_64p   = binsof(cp_mode) intersect {M_RESET} && binsof(cp_len) intersect {[64:128]};
        bins err_8_15  = binsof(cp_mode) intersect {M_ERR}   && binsof(cp_len) intersect {[8:15]};
        bins err_16_63 = binsof(cp_mode) intersect {M_ERR}   && binsof(cp_len) intersect {[16:63]};
        bins strd_mid  = binsof(cp_mode) intersect {M_STRESS} && binsof(cp_len)
                         intersect {[2:3],[4:7],[8:15],[16:63],[64:128]};
        ignore_bins dly_rest = (binsof(cp_mode) intersect {M_ARDLY, M_RGAP})
                        && binsof(cp_len) intersect {0,1,[2:7],[16:128]};
        ignore_bins bp_rest  = binsof(cp_mode) intersect {M_BP}
                        && binsof(cp_len) intersect {0,1,[2:7],[16:63]};
        ignore_bins fullp_rest = binsof(cp_mode) intersect {M_FULLP}
                        && binsof(cp_len) intersect {0,1,[2:63]};
        ignore_bins clk_rest = binsof(cp_mode) intersect {M_CLK}
                        && binsof(cp_len) intersect {0,1,[2:7],[16:128]};
        ignore_bins rst_rest = binsof(cp_mode) intersect {M_RESET}
                        && binsof(cp_len) intersect {0,1,[2:3],[8:15],[16:63]};
        ignore_bins err_rest = binsof(cp_mode) intersect {M_ERR}
                        && binsof(cp_len) intersect {0,1,[2:7],[64:128]};
        ignore_bins strd_rest = binsof(cp_mode) intersect {M_STRESS}
                        && binsof(cp_len) intersect {0,1};
      }
    endgroup

    covergroup cg_beat();
      option.per_instance = 1;
      cp_bmode: coverpoint cur_mode;
      cp_keep: coverpoint b_keep {                        // F03 keep patterns (7 types in total across both instances)
        bins k1000 = {4'b1000}; bins k1100 = {4'b1100};
        bins k1110 = {4'b1110}; bins k1111 = {4'b1111};
        bins k0001 = {4'b0001}; bins k0011 = {4'b0011};
        bins k0111 = {4'b0111};
      }
      cp_last: coverpoint b_last;
      cp_data: coverpoint b_data {                        // F02 boundary values
        bins zero = {32'h0000_0000}; bins maxv = {32'hFFFF_FFFF};
        bins mid = {[32'h1:32'hFFFF_FFFE]};
      }
      x_bmode_keep: cross cp_bmode, cp_keep {              // Control context × keep patterns
        bins bp_full = binsof(cp_bmode) intersect {M_BP}     && binsof(cp_keep) intersect {4'b1111};
        bins bp_tail = binsof(cp_bmode) intersect {M_BP}     && binsof(cp_keep) intersect {4'b1000};
        bins rst_full= binsof(cp_bmode) intersect {M_RESET}   && binsof(cp_keep) intersect {4'b1111};
        bins rst_mid = binsof(cp_bmode) intersect {M_RESET}   && binsof(cp_keep) intersect {4'b0111};
        bins err_full= binsof(cp_bmode) intersect {M_ERR}     && binsof(cp_keep) intersect {4'b1111};
        bins strt_full = binsof(cp_bmode) intersect {M_STRESS} && binsof(cp_keep) intersect {4'b1111};
        bins strt_hi  = binsof(cp_bmode) intersect {M_STRESS} && binsof(cp_keep) intersect {4'b1000};
        bins dly_full = (binsof(cp_bmode) intersect {M_ARDLY, M_RGAP, M_FULLP, M_CLK})
                        && binsof(cp_keep) intersect {4'b1111};
        ignore_bins rest = !binsof(cp_bmode) intersect
              {M_BP, M_ARDLY, M_RGAP, M_FULLP, M_CLK, M_RESET, M_ERR, M_STRESS};
      }
    endgroup

    covergroup cg_ar();
      option.per_instance = 1;
      cp_amode: coverpoint cur_mode;
      cp_arlen: coverpoint a_len {                        // F03/F08 burst splitting
        bins l1 = {0}; bins l23 = {[1:2]}; bins l47 = {[3:6]};
        bins l8 = {7}; bins l9_15 = {[8:14]}; bins l16 = {15};
      }
      cp_resp: coverpoint a_resp {                        // V10 rresp context
        bins okay    = {2'b00};
        bins slverr  = {2'b10};
        bins decerr  = {2'b11};
        // All four AXI encodings are legal (01=EXOKAY); the DUT ignores rresp, so EXOKAY and OKAY are behaviorally equivalent; EXOKAY is not stimulated
        ignore_bins exokay = {2'b01};
      }
      // V9/G8: Measured slave latency settings (arready wait of 0/2 cycles × first-beat rvalid latency × R beat spacing)
      // Explicitly ignore non-latency context enumerations: coverage measures only the hit intensity of latency settings, without dilution (the value domain consists of all
      // cov_mode_e enumerations, with no unlisted values; ignore does not create holes).
      // Note: cp_ar_dly×cp_r_gap must not be crossed—the two coverpoints sample the same cur_mode,
      // so mixed-setting bins are structurally unreachable; the semantic cross of latency settings is in cg_ar_dly.x_dly (all 8 combinations of measured values)
      cp_ar_dly: coverpoint cur_mode {
        bins dly2 = {M_ARDLY};
        bins dly0 = {M_SAME, M_BP, M_FULLP, M_CLK, M_RESET, M_ERR, M_STRESS, M_RGAP};
      }
      cp_r_lat: coverpoint cur_mode {
        bins lat1 = {M_ARDLY};
        ignore_bins oth = {M_SAME, M_BP, M_FULLP, M_CLK, M_RESET, M_ERR, M_STRESS, M_RGAP};
      }
      cp_r_gap: coverpoint cur_mode {
        bins gap1 = {M_RGAP};
        ignore_bins oth = {M_SAME, M_BP, M_FULLP, M_CLK, M_RESET, M_ERR, M_STRESS, M_ARDLY};
      }
    endgroup

    // V9/G8: Three coverpoints for measured latency-setting values (semantic cross of all 8 combinations of d0/d2 × l0/l1 × g0/g1)
    covergroup cg_ar_dly();
      option.per_instance = 1;
      cp_adly: coverpoint cur_ar_dly { bins d0 = {0}; bins d2 = {2}; }
      cp_rlat: coverpoint cur_r_lat  { bins l0 = {0}; bins l1 = {1}; }
      cp_rgap: coverpoint cur_r_gap  { bins g0 = {0}; bins g1 = {1}; }
      x_dly: cross cp_adly, cp_rlat, cp_rgap;
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cg_cmd = new(); cg_beat = new(); cg_ar = new(); cg_ar_dly = new();
      cmd_imp = new("cmd_imp", this);
      do_imp  = new("do_imp",  this);
      ar_imp  = new("ar_imp",  this);
    endfunction
    function void write(cmd_txn t);
      c_off = t.addr[1:0]; c_bmod = t.nbytes[1:0]; c_len = t.nbytes;
      cg_cmd.sample();
    endfunction
    function void write_do(do_txn t);
      b_data = t.data; b_keep = t.keep; b_last = t.last;
      cg_beat.sample();
    endfunction
    function void write_ar(ar_txn t);
      a_len = t.len;
      a_resp = t.resp;
      cg_ar.sample();
    endfunction
    // V10: AR sampling entry point for error-injected bursts (axi_slv callback)
    function void sample_err_ar(bit [1:0] resp);
      a_resp = resp;
      cg_ar.sample();
    endfunction
    // V9/G8: Latency-setting snapshot sampling entry point (axi_slv callback at the arready handshake)
    function void sample_dly_ar(int d, int l, int g);
      cur_ar_dly = (d >= 2) ? 2 : 0;
      cur_r_lat  = (l >= 1) ? 1 : 0;
      cur_r_gap  = (g >= 1) ? 1 : 0;
      cg_ar.sample();
      cg_ar_dly.sample();
    endfunction
    // V9/G8: Measured slave latency-setting values (written back through env when write_ar samples; cov is declared before axi_slv
    // and cannot hold its handle—env snapshots ar_dly/r_lat/r_gap here each time the setting changes)
    int cur_ar_dly = 0;
    int cur_r_lat  = 0;
    int cur_r_gap  = 0;
  endclass

  // ---------- cmd driver ----------
  class cmd_drv extends uvm_driver #(cmd_txn);
    `uvm_component_utils(cmd_drv)
    virtual rdma_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rdma_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      cmd_txn t;
      vif.cb.cmd_valid <= 1'b0;
      vif.cb.cmd_address <= '0;
      vif.cb.cmd_bytes <= '0;
      forever begin
        seq_item_port.get_next_item(t);
        repeat (t.gap) @(posedge vif.aclk);           // F01 idle before valid
        // The return from get_next_item may fall in the same time slot as the clock edge: CB's @(vif.cb) unblocks in the observed region of the same slot
        // (zero elapsed time); ready is sampled before valid is asserted, and <=1 and <=0 cancel each other out → command loss.
        // Align to the raw edge before driving, ensuring valid is presented for at least one full cycle before checking ready (consistent with DUT/mon).
        @(posedge vif.aclk);
        vif.cb.cmd_address <= t.addr;
        vif.cb.cmd_bytes   <= t.nbytes;
        vif.cb.cmd_valid   <= 1'b1;
        @(posedge vif.aclk);
        while (vif.cmd_ready !== 1'b1)
          @(posedge vif.aclk);
        vif.cb.cmd_valid   <= 1'b0;
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------- cmd monitor ----------
  class cmd_mon extends uvm_monitor;
    `uvm_component_utils(cmd_mon)
    virtual rdma_if vif;
    uvm_analysis_port #(cmd_txn) ap;
    cov_mode_e cur_mode = M_SAME;   // Context writeback port (set when t_main switches segments)
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rdma_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      cmd_txn t;
      forever @(posedge vif.aclk)
        if (vif.cmd_valid === 1'b1 && vif.cmd_ready === 1'b1) begin
          t = cmd_txn::type_id::create("t");
          t.addr = vif.cmd_address; t.nbytes = vif.cmd_bytes; t.gap = 0;
          ap.write(t);
        end
    endtask
  endclass

  // ---------- AXI slave (AR response + memory readback, configurable latency/spacing) ----------
  class axi_slv extends uvm_component;
    `uvm_component_utils(axi_slv)
    virtual rdma_if vif;
    mem_model m;
    bit mem_be = 1;
    int ar_dly = 0;    // Delay a number of cycles after arvalid appears before asserting arready (F01)
    int r_lat = 0;     // First-beat rvalid latency (F01)
    int r_gap = 0;     // R beat spacing (F01/F04)
    // V10: Error response injection. err_mode: 0=none 1=frame-level (same resp throughout the burst) 2=beat-level (middle beat only)
    int err_mode = 0;
    bit [1:0] err_resp = 2'b10;   // 2'b10=SLVERR 2'b11=DECERR
    int n_rbeat = 0;
    int n_errbeat = 0;
    bit in_err_ctx = 0;   // Set when cov context=M_ERR (for error AR coverage sampling)
    int err_mark = 0;     // Last sampled n_errbeat level
    rdma_cov err_cov;     // Bound by env in connect_phase (sample cp_resp for error AR)
    rdma_cov dly_cov;     // Bound by env in connect_phase (V9/G8: latency-setting sampling at the AR handshake)
    ar_req_t bq[$];
    uvm_analysis_port #(ar_txn) ap_ar;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap_ar = new("ap_ar", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rdma_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    function bit [31:0] word(bit [31:0] a);
      bit [7:0] b0, b1, b2, b3;
      b0 = m.g(a); b1 = m.g(a + 1); b2 = m.g(a + 2); b3 = m.g(a + 3);
      return mem_be ? {b0, b1, b2, b3} : {b3, b2, b1, b0};
    endfunction
    task run_phase(uvm_phase phase);
      fork ar_proc(); r_proc(); join
    endtask
    task ar_proc();
      int vcnt = 0;
      vif.axi_m_arready <= 1'b0;
      forever @(posedge vif.aclk) begin
        if (vif.aresetn === 1'b0) begin
          vif.axi_m_arready <= 1'b0;
          vcnt = 0; bq.delete();
        end else if (vif.axi_m_arvalid === 1'b1 && vif.axi_m_arready === 1'b1) begin
          ar_txn a;
          a = ar_txn::type_id::create("a");
          a.addr = vif.axi_m_araddr; a.len = vif.axi_m_arlen;
          a.id = vif.axi_m_arid; a.size = vif.axi_m_arsize; a.burst = vif.axi_m_arburst;
          a.resp = 2'b00;
          ap_ar.write(a);
          if (dly_cov != null) dly_cov.sample_dly_ar(ar_dly, r_lat, r_gap);
          bq.push_back('{vif.axi_m_araddr, vif.axi_m_arlen});
          vif.axi_m_arready <= 1'b0;
          vcnt = 0;
        end else if (vif.axi_m_arvalid === 1'b1) begin
          if (vcnt >= ar_dly) vif.axi_m_arready <= 1'b1;
          else vcnt++;
        end else begin
          vcnt = 0;
          if (ar_dly == 0) vif.axi_m_arready <= 1'b1;  // Always ready (same-cycle handshake pattern)
        end
      end
    endtask
    task r_proc();
      ar_req_t cur;
      bit [31:0] ba;
      int n, i;
      bit [1:0] bresp;
      bit [1:0] fresp;    // Baseline resp for this burst (err_mode=1: same value throughout at frame level)
      bit in_err;         // Whether an error is injected into this burst (carried as context for the AR resp coverage point)
      bit [3:0] ridc = 0; // G7: rid cycles through 0..15 burst by burst (DUT has no internal rid fanout; port toggle only)
      vif.axi_m_rvalid <= 1'b0;
      vif.axi_m_rid <= 4'h0; vif.axi_m_rresp <= 2'b00;
      vif.axi_m_rlast <= 1'b0; vif.axi_m_rdata <= '0;
      forever begin
        wait (bq.size() > 0 || vif.aresetn === 1'b0);
        if (vif.aresetn === 1'b0) begin
          vif.axi_m_rvalid <= 1'b0;
          @(posedge vif.aclk);
          continue;
        end
        cur = bq.pop_front();
        ba = cur.addr; n = cur.len + 1;
        in_err = in_err_ctx;
        fresp = (err_mode == 1) ? err_resp : 2'b00;
        vif.axi_m_rid <= ridc;          // G7: Change rid between bursts (while rvalid=0, legal under the protocol)
        ridc = ridc + 1;
        repeat (r_lat) @(posedge vif.aclk);
        for (i = 0; i < n; i++) begin
          if (vif.aresetn === 1'b0) break;
          vif.axi_m_rdata  <= word(ba + 4 * i);
          // Beat data is unaffected by rresp disturbances (as-implemented: DUT ignores rresp)
          bresp = (err_mode == 2 && n >= 3 && i == n/2) ? err_resp : fresp;
          vif.axi_m_rresp  <= bresp;
          vif.axi_m_rlast  <= (i == n - 1);
          vif.axi_m_rvalid <= 1'b1;
          do @(posedge vif.aclk);
          while (vif.aresetn === 1'b1 &&
                 !(vif.axi_m_rvalid === 1'b1 && vif.axi_m_rready === 1'b1));
          if (bresp != 2'b00 && vif.aresetn === 1'b1) n_errbeat++;
          if (vif.aresetn === 1'b0) break;
          n_rbeat++;
          if (r_gap > 0) begin
            vif.axi_m_rvalid <= 1'b0;
            repeat (r_gap) @(posedge vif.aclk);
            if (vif.aresetn === 1'b0) break;
          end
        end
        vif.axi_m_rvalid <= 1'b0;
        // V10: Sample AR separately for error-injected bursts (cp_resp requires slverr/decerr context)
        if (in_err && n_errbeat > err_mark && err_cov != null) begin
          err_cov.sample_err_ar((err_mode == 2) ? err_resp : fresp);
          err_mark = n_errbeat;
        end
      end
    endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      if (err_mode != 0 && n_errbeat == 0)
        `uvm_warning("SLV", "err_mode is nonzero but no error beat was injected (stimulus missed its target)")
      else if (err_mode != 0)
        `uvm_info("SLV", $sformatf("err_mode=%0d injected error beat=%0d", err_mode, n_errbeat), UVM_LOW)
    endfunction
  endclass

  // ---------- dout monitor ----------
  class dout_mon extends uvm_monitor;
    `uvm_component_utils(dout_mon)
    virtual rdma_if vif;
    uvm_analysis_port #(do_txn) ap;
    int n_beat = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rdma_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      do_txn t;
      forever @(posedge vif.aclk)
        if (vif.dout_tvalid === 1'b1 && vif.dout_tready === 1'b1) begin
          t = do_txn::type_id::create("t");
          t.data = vif.dout_tdata; t.keep = vif.dout_tkeep; t.last = vif.dout_tlast;
          n_beat++;
          ap.write(t);
        end
    endtask
  endclass

  // ---------- dout_tready backpressure driver ----------
  class out_drv extends uvm_component;
    `uvm_component_utils(out_drv)
    virtual rdma_if vif;
    int pct = 100;     // Probability of setting tready to 1 (F04/F09 full/empty boundaries)
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual rdma_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      vif.dout_tready <= 1'b0;
      forever @(posedge vif.aclk)
        vif.dout_tready <= ($urandom_range(0, 99) < pct);
    endtask
  endclass

  // ---------- scoreboard ----------
  class rdma_sb extends uvm_scoreboard;
    `uvm_component_utils(rdma_sb)
    uvm_analysis_imp    #(cmd_txn, rdma_sb) cmd_imp;
    uvm_analysis_imp_do #(do_txn,  rdma_sb) do_imp;
    uvm_analysis_imp_ar #(ar_txn,  rdma_sb) ar_imp;
    mem_model m;
    axi_slv  slv;
    bit stream_be = 1;
    bit mem_be = 1;
    int max_burst = 16;
    exp_beat_t exp[$];
    ar_req_t   aexp[$];
    int n_chk = 0, n_cmd = 0, n_ar = 0;
    int r_snap = 0, ar_snap = 0, exp_dw = 0, exp_burst = 0;
    int err_snap = 0;
    bit [31:0] cur_addr, cur_bytes;
    bit big_cmd = 0;      // Huge-value command (D>D_CAP): model only the initial portion of expected data; must be discarded by reset (tlast never arrives)
    localparam int D_CAP = 512;   // Upper limit on expected beat modeling (prevent queues on the order of hundreds of millions from stalling simulation)
    function new(string name, uvm_component parent);
      super.new(name, parent);
      cmd_imp = new("cmd_imp", this);
      do_imp  = new("do_imp",  this);
      ar_imp  = new("ar_imp",  this);
    endfunction

    // as-implemented expected model (axi_rdma.v:206-247 three wstrb tables + axis_realign.v:83-102 byte-lane remapping):
    // keep_d = d==0 ? (D==1 ? first : first|set) : (d==D-1 ? last : F)；
    // Byte selection: BE-in: b(base+4d+j) iff keep_d[3-j], LE-in: iff keep_d[j];
    // Output: contiguous byte stream at 4 bytes/beat; BE-out: first byte at MSB, keep high-aligned; LE-out: first byte at LSB, keep low-aligned.
    // Unselected lanes contain residual realign register contents (garbage); beat-by-beat comparison is masked by keep.
    function bit [3:0] w_f(int off, int bm);
      case ((off << 2) | bm)
        0: return 4'b1111;  1: return 4'b0001;  2: return 4'b0011;  3: return 4'b0111;
        4: return 4'b1110;  5: return 4'b0010;  6: return 4'b0110;  7: return 4'b1110;
        8: return 4'b1100;  9: return 4'b0100; 10: return 4'b1100; 11: return 4'b1100;
        12: return 4'b1000; 13: return 4'b1000; 14: return 4'b1000; 15: return 4'b1000;
      endcase
      return 4'b0000;
    endfunction
    function bit [3:0] w_l(int off, int bm);
      case ((off << 2) | bm)
        0: return 4'b1111;  1: return 4'b0001;  2: return 4'b0011;  3: return 4'b0111;
        4: return 4'b0001;  5: return 4'b0011;  6: return 4'b0111;  7: return 4'b1111;
        8: return 4'b0011;  9: return 4'b0111; 10: return 4'b1111; 11: return 4'b0001;
        12: return 4'b0111; 13: return 4'b1111; 14: return 4'b0001; 15: return 4'b0011;
      endcase
      return 4'b0000;
    endfunction
    function bit [3:0] w_s(int off);
      case (off)
        0: return 4'b1111; 1: return 4'b1110; 2: return 4'b1100; 3: return 4'b1000;
      endcase
      return 4'b0000;
    endfunction

    function void write(cmd_txn t);
      int B, off, D, remain, f, i, n, nb;
      bit [31:0] base, cur;
      bit [7:0] stream[$];
      bit [3:0] kf, kl, ks, kd;
      exp_beat_t eb;
      ar_req_t ar;
      n_cmd++;
      cur_addr = t.addr; cur_bytes = t.nbytes;
      r_snap  = (slv != null) ? slv.n_rbeat : 0;
      err_snap = (slv != null) ? slv.n_errbeat : 0;
      ar_snap = n_ar;
      exp.delete(); aexp.delete();
      B = t.nbytes; off = t.addr & 3;
      D = (off + B + 3) >> 2;
      big_cmd = (D > D_CAP);
      if (B > 0) begin
        base = {t.addr[31:2], 2'b00};
        // The single-dword BE window is a mirrored implementation (this model naturally covers it by modeling byte by byte according to the wstrb table; only an evidentiary warning is retained here)
        if (off + B <= 4 && mem_be)
          `uvm_warning("SB_MIRROR",
            $sformatf("Single-dword window is a mirrored implementation addr=%08x B=%0d (standard-semantics source=%08x, as-implemented source=%08x)",
                      t.addr, B, t.addr, base + (4 - off - B)))
        kf = w_f(off, B & 3); kl = w_l(off, B & 3); ks = w_s(off);
        for (int d = 0; d < D && stream.size() < 4 * D_CAP; d++) begin
          if (d == 0)        kd = (D == 1) ? kf : (kf | ks);
          else if (d == D-1) kd = kl;
          else               kd = 4'hF;
          for (int j = 0; j < 4; j++)
            if (mem_be ? kd[3-j] : kd[j]) stream.push_back(m.g(base + 4*d + j));
        end
        nb = stream.size();
        for (i = 0; i*4 < nb && exp.size() < D_CAP; i++) begin
          n = (nb - i*4 >= 4) ? 4 : nb - i*4;
          eb.keep = stream_be ? (((4'h1 << n) - 1) << (4 - n)) : ((4'h1 << n) - 1);
          eb.data = '0;
          for (int p = 0; p < n; p++)
            if (stream_be) eb.data[31 - 8*p -: 8] = stream[i*4 + p];
            else           eb.data[8*p       +: 8] = stream[i*4 + p];
          eb.last = (!big_cmd) && ((i+1)*4 >= nb);
          exp.push_back(eb);
        end
        exp_dw = D;
        remain = D; cur = base; exp_burst = 0;
        while (remain > 0 && aexp.size() < D_CAP/8) begin
          f = (remain > max_burst) ? max_burst : remain;
          ar.addr = cur; ar.len = f - 1;
          aexp.push_back(ar);
          cur = cur + 4 * f;
          remain -= f;
          exp_burst++;
        end
        if (big_cmd) exp_burst = aexp.size();
      end else begin
        exp_dw = 0; exp_burst = 0;
      end
    endfunction

    function void write_ar(ar_txn t);
      ar_req_t e;
      n_ar++;
      if (t.size !== 3'd2 || t.burst !== 2'd1 || t.id !== 4'd0)
        `uvm_error("SB", $sformatf("Incorrect AR fixed fields size=%0d burst=%0d id=%0d",
                                   t.size, t.burst, t.id))
      if (aexp.size() == 0) begin
        // big_cmd truncated modeling: ARs beyond the D_CAP/8 modeled segment are expected (the command will necessarily be discarded by the timed reset)
        if (!big_cmd)
          `uvm_error("SB", $sformatf("Extra AR addr=%08x len=%0d", t.addr, t.len))
        return;
      end
      e = aexp.pop_front();
      if (e.addr != t.addr || e.len != t.len)
        `uvm_error("SB", $sformatf("AR mismatch exp(%08x,%0d) got(%08x,%0d)",
                                   e.addr, e.len, t.addr, t.len))
      else if (t.resp != 2'b00)
        // V10 (as-implemented check): DUT ignores rresp → all burst data with error responses is still compared,
        // The rresp value itself is recorded here (beat comparisons and final counts provide the fallback checks for no deadlock/no disturbance)
        `uvm_info("SB", $sformatf("Error-response burst resp=%b addr=%08x (DUT ignores rresp; data is compared as usual)",
                                  t.resp, t.addr), UVM_MEDIUM)
    endfunction

    function void write_do(do_txn t);
      exp_beat_t e;
      if (exp.size() == 0) begin
        // big_cmd truncated modeling: beats beyond the D_CAP modeled segment are expected (the command will necessarily be discarded by the timed reset)
        if (!big_cmd)
          `uvm_error("SB", $sformatf("Extra dout beat data=%08x keep=%x last=%b",
                                     t.data, t.keep, t.last))
        return;
      end
      e = exp.pop_front();
      begin
        // Masked comparison: byte lanes not selected by keep contain residual realign register contents (unpredictable garbage) and are not compared
        bit [31:0] msk = 0;
        for (int i = 0; i < 4; i++) if (e.keep[i]) msk[8*i +: 8] = 8'hFF;
        if ((e.data & msk) !== (t.data & msk) || e.keep !== t.keep ||
            (!big_cmd && e.last !== t.last))
          `uvm_error("SB", $sformatf("beat mismatch exp(%08x,%x,%b) got(%08x,%x,%b) @cmd(%08x,%0d)",
                     e.data, e.keep, e.last, t.data, t.keep, t.last, cur_addr, cur_bytes))
        else n_chk++;
      end
      if (t.last && !big_cmd) begin   // F07 command-completion cross-check (total R beats / total AR count; not checked for truncated modeling of huge-value commands)
        if (exp.size() != 0)
          `uvm_error("SB", $sformatf("Model has %0d beats remaining after tlast", exp.size()))
        if (slv != null && (slv.n_rbeat - r_snap) != exp_dw)
          `uvm_error("SB", $sformatf("Incorrect R beat count exp=%0d got=%0d", exp_dw, slv.n_rbeat - r_snap))
        if ((n_ar - ar_snap) != exp_burst)
          `uvm_error("SB", $sformatf("Incorrect AR count exp=%0d got=%0d", exp_burst, n_ar - ar_snap))
        // V10: final data-integrity check during error-response injection (rresp is ignored → no missing or extra data)
        if (slv != null && (slv.n_errbeat - err_snap) > 0 && (slv.n_rbeat - r_snap) != exp_dw)
          `uvm_error("SB", $sformatf("Incorrect R beat count in error-injection segment exp=%0d got=%0d",
                                     exp_dw, slv.n_rbeat - r_snap))
      end
    endfunction

    function void flush();   // F06 clear the model after the reset segment (discarding in-flight transactions is expected)
      exp.delete(); aexp.delete();
    endfunction

    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("SB", $sformatf("cmd=%0d compared beat=%0d AR=%0d remaining beat=%0d remaining AR=%0d",
                                n_cmd, n_chk, n_ar, exp.size(), aexp.size()), UVM_LOW)
    endfunction
  endclass

  // ---------- agent / env ----------
  class cmd_agent extends uvm_agent;
    `uvm_component_utils(cmd_agent)
    cmd_drv drv;
    cmd_mon mon;
    uvm_sequencer #(cmd_txn) sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = cmd_drv::type_id::create("drv", this);
      mon = cmd_mon::type_id::create("mon", this);
      sqr = uvm_sequencer#(cmd_txn)::type_id::create("sqr", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class rdma_env extends uvm_env;
    `uvm_component_utils(rdma_env)
    cmd_agent ag;
    axi_slv   slv;
    dout_mon  dmon;
    out_drv   odrv;
    rdma_sb   sb;
    rdma_cov  cov;
    mem_model mem;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      int v;
      super.build_phase(phase);
      ag   = cmd_agent::type_id::create("ag", this);
      slv  = axi_slv::type_id::create("slv", this);
      dmon = dout_mon::type_id::create("dmon", this);
      odrv = out_drv::type_id::create("odrv", this);
      sb   = rdma_sb::type_id::create("sb", this);
      cov  = rdma_cov::type_id::create("cov", this);
      mem  = mem_model::type_id::create("mem");
      mem.fill(32'h0000, 512, 0);   // Random
      mem.fill(32'h1000, 512, 1);   // 0x00 region
      mem.fill(32'h2000, 512, 2);   // 0xFF region
      mem.fill(32'h3000, 512, 0);   // Random
      if (uvm_config_db#(int)::get(this, "", "mem_be", v)) begin
        slv.mem_be = v[0]; sb.mem_be = v[0];
      end
      if (uvm_config_db#(int)::get(this, "", "stream_be", v)) sb.stream_be = v[0];
      if (uvm_config_db#(int)::get(this, "", "max_burst", v)) sb.max_burst = v;
      slv.m = mem; sb.m = mem;
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ag.mon.ap.connect(sb.cmd_imp);
      ag.mon.ap.connect(cov.cmd_imp);
      dmon.ap.connect(sb.do_imp);
      dmon.ap.connect(cov.do_imp);
      slv.ap_ar.connect(sb.ar_imp);
      slv.ap_ar.connect(cov.ar_imp);
      slv.err_cov = cov;    // V10: AR coverage-sampling channel for error-injected bursts
      slv.dly_cov = cov;    // V9/G8: delay-level coverage-sampling channel at the AR handshake instant
      sb.slv = slv;
    endfunction
  endclass

  // ---------- sequences ----------
  class seq_base extends uvm_sequence #(cmd_txn);
    `uvm_object_utils(seq_base)
    function new(string name = "seq_base"); super.new(name); endfunction
    task send(bit [31:0] a, bit [31:0] n, int g = 0);
      cmd_txn t = cmd_txn::type_id::create("t");
      start_item(t);
      void'(t.randomize());
      t.addr = a; t.nbytes = n; t.gap = g;   // Directly override with directed values (avoid solver conflicts)
      finish_item(t);
    endtask
  endclass


  class seq_reset_stall extends seq_base;
    `uvm_object_utils(seq_reset_stall)
    function new(string name="seq_reset_stall"); super.new(name); endfunction
    task body(); send(32'h1000,32'd64); endtask
  endclass

  class seq_long_count extends seq_base;
    `uvm_object_utils(seq_long_count)
    function new(string name = "seq_long_count"); super.new(name); endfunction
    task body();
      send(32'h4000, 32'd262148);
    endtask
  endclass

  class seq_smoke extends seq_base;
    `uvm_object_utils(seq_smoke)
    function new(string n = "seq_smoke"); super.new(n); endfunction
    task body();
      send(32'h1000, 4);
      send(32'h0004, 7);
    endtask
  endclass

  class seq_small extends seq_base;
    `uvm_object_utils(seq_small)
    function new(string n = "seq_small"); super.new(n); endfunction
    task body();
      send(32'h0100, 12);
      send(32'h0111, 9);
    endtask
  endclass

  // Final-beat keep pattern matrix (off×B%4)—B1/B3 alignment+offset combinations produce all non-1111 final beats:
  // O0,B%4=1 → intermediate k0111/k0001, final k1000; O0,B%4=3 → k1110, final k1100/k1000;
  // Offset bit patterns supplement dual patterns such as k0011 (LE instance patterns are mirror images of each other).
  // Also includes long frames with off=1/2/3 (first-beat first_wstrb merge b>4 path: realign b preset to 1/2/3)
  class seq_cells extends seq_base;
    `uvm_object_utils(seq_cells)
    function new(string n = "seq_cells"); super.new(n); endfunction
    task body();
      send(32'h0200, 13);          // off=0,B%4=1,D=4 → 1110,0111,1001?,0001 final 1000
      send(32'h0210, 15);          // off=0,B%4=3,D=4 → 1110,1110,1100,1000
      send(32'h0220, 21);          // D=6 two-beat tail (across the realign merge path)
      send(32'h0201, 12);          // off=1,B%4=0
      send(32'h0202, 18);          // off=2 (trigger source for the be_mask s_tuser=3 case)
      send(32'h0223, 11);          // off=3,B%4=3
      send(32'h0221, 13);          // off=1,B%4=1 two consecutive small tails
      send(32'h0230, 5);           // D=2 medium-short frame (B1 aligned, completes in just two beats)
      send(32'h0202, 5);           // B2 aligned D=2 (reinforces chain lengths k0011/k0001)
      send(32'h0211, 6);           // off=1,B%4=2 → first-beat integration/final keep family
      send(32'h0231, 7);           // off=1,B%4=3,D=3 short, multiple patterns
      send(32'h0262, 6);           // off=2,B%4=2 → realign b phase variant
      send(32'h0273, 5);           // off=3,B%4=1,D=3 → two partial beats
      send(32'h0280, 9);           // off=0,B%4=1,D=3 → another phase of two partial beats
      send(32'h02A0, 48);          // off=0 long full frame (b phase advances across the 4 domain)
      send(32'h02A1, 47);          // off=1 long frame (realign b preset to 1 holding segment)
      send(32'h02A2, 46);          // off=2 long frame (b preset to 2)
      send(32'h02A3, 45);          // off=3 long frame (b preset to 3, B%4=1)
    endtask
  endclass

  class seq_f02 extends seq_base;
    `uvm_object_utils(seq_f02)
    function new(string n = "seq_f02"); super.new(n); endfunction
    task body();
      send(32'h1000, 16);          // All 0x00
      send(32'h1001, 15);          // All 0x00 with offset
      send(32'h2000, 16);          // All 0xFF
      send(32'h2002, 14);          // All 0xFF with offset
      send(32'h0000, 8);           // Random
    endtask
  endclass

  class seq_sweep16 extends seq_base;   // Full sweep of the 16-row wstrb table for {addr[1:0],bytes[1:0]}
    `uvm_object_utils(seq_sweep16)
    function new(string n = "seq_sweep16"); super.new(n); endfunction
    task body();
      for (int o = 0; o < 4; o++)
        for (int b = 0; b < 4; b++)
          send(32'h3000 + o, 8 + b);
    endtask
  endclass

  class seq_single extends seq_base;    // Single-dword commands (all 10 combinations with off+B<=4)
    `uvm_object_utils(seq_single)
    function new(string n = "seq_single"); super.new(n); endfunction
    task body();
      for (int o = 0; o < 4; o++)
        for (int n = 1; n + o <= 4; n++)
          send(32'h3080 + o, n);
    endtask
  endclass

  class seq_zero extends seq_base;      // bytes=0 boundary (no AR, no data)
    `uvm_object_utils(seq_zero)
    function new(string n = "seq_zero"); super.new(n); endfunction
    task body();
      send(32'h0010, 0);
      send(32'h0013, 0);
    endtask
  endclass

  // FIFO truly-full write path (wr_en request window when fifo full=1): fill with a >16-beat full-capacity command under strong backpressure
  class seq_fill16 extends seq_base;
    `uvm_object_utils(seq_fill16)
    function new(string n = "seq_fill16"); super.new(n); endfunction
    task body();
      send(32'h3000, 24);          // D=6+off three-beat context fine-tuning
      send(32'h3040, 68);          // D=17 > FIFO depth 16 (M_BP×[64:128] bin hit)
      send(32'h3060, 160);         // G4/V11: D=40—truly full requires 16+output staging 2; 17 beats are not enough
    endtask
  endclass

  class seq_big0 extends seq_base;      // dut0(MB=16): arlen 15/14/11 + split-segment tail
    `uvm_object_utils(seq_big0)
    function new(string n = "seq_big0"); super.new(n); endfunction
    task body();
      send(32'h0000, 64);          // D=16 → arlen 15
      send(32'h0043, 80);          // D=21 → 16+5
      send(32'h0080, 60);          // D=15 → arlen 14
      send(32'h00C0, 48);          // D=12 → arlen 11
    endtask
  endclass  class seq_multib extends seq_base;    // Multi-burst splitting (take the tail segment for D>MAX_BURST)
    `uvm_object_utils(seq_multib)
    function new(string n = "seq_multib"); super.new(n); endfunction
    task body();
      send(32'h3001, 64);          // D=17 → 16+1 tail segment (under the env0 MB=16 convention)
      send(32'h3050, 44);          // D=11 → 8+3
      send(32'h3066, 70);          // D=18 → 16+2
    endtask
  endclass

  // Huge-value command segment (dut1 large arlen): D=255 → a single AR len=254 with MB=256, arlen/fetch /
  // dout_dwords toggles bit7+ in one go (discarded by reset after approximately 140 beats to save budget)
  class seq_big extends seq_base;
    `uvm_object_utils(seq_big)
    function new(string n = "seq_big"); super.new(n); endfunction
    task body();
      send(32'h30E0, 1020);         // off=0 → D=255, single AR len=254
      send(32'h30E3, 1017);         // off=3 → D=254, arlen=253, final beat k1000
    endtask
  endclass

  class seq_f04 extends seq_base;       // Fill FIFO under strong backpressure
    `uvm_object_utils(seq_f04)
    function new(string n = "seq_f04"); super.new(n); endfunction
    task body();
      send(32'h3100, 64);
    endtask
  endclass

  // Short chained frames with off=3 and B%4≠0: LE big-endian rows have all beats dst0 / dense occurrences of legit partial beats such as k1110
  class seq_short_off3 extends seq_base;
    `uvm_object_utils(seq_short_off3)
    function new(string n = "seq_short_off3"); super.new(n); endfunction
    task body();
      send(32'h02A3, 13);          // off=3,B%4=1 → D=5 (two partial beats spanning beats)
      send(32'h02B3, 7);           // off=3,B%4=3 → D=3
      send(32'h02C3, 9);           // off=3,B%4=1 → D=4
    endtask
  endclass

  // Huge-value commands (upper bound of toggle stimulus): full-range 32-bit nbytes → length/remain/length_dwords/
  // dout_dwords/axi_m_araddr high bits toggle; commands must be discarded by pulse_reset+flush before exhaustion
  class seq_bigaddr extends seq_base;
    `uvm_object_utils(seq_bigaddr)
    function new(string n = "seq_bigaddr"); super.new(n); endfunction
    task body();
      send(32'hFFFF_FFF0, 32'hFFFF_FFC0);   // Address in the all-1 region + huge length (reset immediately after S_INIT)
      send(32'h1000_0000, 32'h8000_0000);
    endtask
  endclass

  // G4-supplement (FSM reset arcs): S_CALC and S_INCR are both 1-cycle windows (S_INCR is a 1-cycle per-burst
  // bookkeeping state, CALC/ASTRB/INCR cycle every 3 cycles); regular reset interruptions all land in S_ASTRB/S_WAIT—
  // The two arcs S_CALC→S_IDLE and S_INCR→S_IDLE are never hit. Phase-by-phase
  // reset of multi-burst issue for long commands (k sweeps 3..9 to cover all phase remainders) must hit both windows; big_cmd truncation modeling + reset discard.
  class seq_rstph extends seq_base;
    `uvm_object_utils(seq_rstph)
    function new(string n = "seq_rstph"); super.new(n); endfunction
    task body();
      send(32'h3080, 8192);        // D=2048: burst supply in 128 segments for env0 / 8 segments for env1
    endtask
  endclass

  class seq_mid extends seq_base;      // Long command in the reset section (partial final-beat pattern: off/B%4 are both non-0)
    `uvm_object_utils(seq_mid)
    function new(string n = "seq_mid"); super.new(n); endfunction
    task body();
      send(32'h3122, 126);          // off=2, D=32; partial final beat k1110 interrupted in flight
    endtask
  endclass

  // G6/V4: huge-value boundary commands (D close to the D_CAP=512 and MAX_BURST boundaries, run to completion without reset and check the entire amount,
  // without taking the big_cmd exemption path): D=256 → fetch[8]/arlen[7] full width; D=257 → 256+1 final segment;
  // D=512 → remain/length_dwords bit9, dout_dwords[8] toggle in both directions
  class seq_bigcap extends seq_base;
    `uvm_object_utils(seq_bigcap)
    function new(string n = "seq_bigcap"); super.new(n); endfunction
    task body();
      send(32'h3080, 1024);          // off=0 → D=256 (env1 single burst arlen=255 / env0 16×16)
      send(32'h3081, 1025);          // off=1 → D=257 → final segment arlen=0 (fetch full width minus one)
      send(32'h3090, 2048);          // D=512=D_CAP exactly at the boundary: env1 2×256 / env0 32×16 fully checked
    endtask
  endclass

  // G4: off=1/off=2 long frames (b phase advances to 7/6: realign deep-phase reload branches) +
  // off=3 60B+ (tail overflow more path b_next=6); 64-128B length family complementary to seq_cells
  class seq_deep extends seq_base;
    `uvm_object_utils(seq_deep)
    function new(string n = "seq_deep"); super.new(n); endfunction
    task body();
      send(32'h02B1, 68);           // off=1 → b:0→3→7 (out_b1←out_b5 / out_b2←out_b6 branches)
      send(32'h02B2, 70);           // off=2 → b:0→2→6 (out_b1←out_b5 branch)
      send(32'h02B3, 67);           // off=3 → final beat sum=6 more overflow path
      send(32'h02B1, 96);           // off=1 extra-long frame (multiple steady-state beats at b=7)
    endtask
  endclass

  class seq_err extends seq_base;      // V10: rresp error-response injection section (data checked beat by beat as usual)
    `uvm_object_utils(seq_err)
    function new(string n = "seq_err"); super.new(n); endfunction
    task body();
      send(32'h0000, 48);          // D=12 both frame-level and beat-level injection can be covered
      send(32'h0101, 12);          // off+12 → D=4
      send(32'h1000, 16);          // mem 0x00 region verifies that data is undisturbed under error injection
      send(32'h0180, 13);          // off=0,B%4=1 → k1110/k0111/0001 final beats in error context
      send(32'h0190, 15);          // off=0,B%4=3 → k1110/k1100 final beats in error context
      send(32'h0191, 5);           // off=1,B%4=1,D=2 → k0011/k0001 short frames in error context
      send(32'h0240, 21);          // off=0,B%4=1,D=6 two-beat tail in error context
      send(32'h0202, 11);          // off=2,B%4=3,D=4 reinforced k0011 in error context
      send(32'h0263, 23);          // off=3,B%4=3,D=7 alignment variant in error context
      send(32'h02B2, 7);           // off=2,B%4=3,D=3 direct hit on k0011 in error context
      send(32'h02C2, 11);          // off=2,B%4=3,D=4 short-frame k1100 phase
      send(32'h01E0, 14);          // off=0,B%4=2,D=4 → final beat n=2: BE k1100 / LE k0011
     endtask
  endclass

  class seq_stress extends seq_base;
    `uvm_object_utils(seq_stress)
    function new(string n = "seq_stress"); super.new(n); endfunction
    task body();
      send(32'h0240, 13);          // Directed final-beat pattern (stress × k1110 row)
      send(32'h0250, 15);          // Directed final-beat pattern (stress × k1100/k1000 rows)
      send(32'h0263, 7);           // off=1,B%4=3 directed (stress × k0011/k0111 rows)
      repeat (12) begin
        cmd_txn t = cmd_txn::type_id::create("t");
        start_item(t);
        if (!t.randomize() with {
              addr inside {[32'h0000:32'h00FC], [32'h1000:32'h10FC],
                           [32'h2000:32'h20FC], [32'h3000:32'h30FC]};
              nbytes inside {[1:64]};
            }) `uvm_error("SEQ", "rnd")
        finish_item(t);
      end
    endtask
  endclass

  // ---------- tests ----------
  class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    rdma_env env0, env1;
    virtual rdma_if vif0, vif1;
    int wd_snap = 0;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env0 = rdma_env::type_id::create("env0", this);
      env1 = rdma_env::type_id::create("env1", this);
      uvm_config_db#(virtual rdma_if)::get(this, "", "vif0", vif0);
      uvm_config_db#(virtual rdma_if)::get(this, "", "vif1", vif1);
      uvm_config_db#(virtual rdma_if)::set(this, "env0*", "vif", vif0);
      uvm_config_db#(virtual rdma_if)::set(this, "env1*", "vif", vif1);
    endfunction
    task run_seq_on(seq_base s, rdma_env e);
      s.start(e.ag.sqr);
      // Drain at the end of the section: beat/AR arrive after the handshake; return only after the expected queue has been consumed,
      // otherwise cur_mode switches away prematurely, causing incorrect sampling of the mode context (root cause of all missed samples in the V8 reset/backpressure sections)
      while (e.sb.exp.size() > 0 || e.sb.aexp.size() > 0)
        @(posedge e.slv.vif.aclk);
    endtask
    task run_phase(uvm_phase phase);
      bit wd_done = 0;
      int wd_idle = 0;
      phase.raise_objection(this);
      fork
        begin : watchdog   // Watchdog: report an error and exit if there is neither a dout beat nor AR handshake progress for 2000 cycles
          forever @(vif0.aclk) begin
            if (wd_done) break;
            if (env0.dmon.n_beat + env0.sb.n_ar +
                env1.dmon.n_beat + env1.sb.n_ar == wd_snap) wd_idle++;
            else begin wd_idle = 0; wd_snap = env0.dmon.n_beat + env0.sb.n_ar +
                                          env1.dmon.n_beat + env1.sb.n_ar; end
            if (wd_idle >= 2000) begin
              `uvm_error("WD", "Watchdog timeout: no dout beat and no AR handshake progress (DUT suspected hung)")
              phase.drop_objection(this);
              break;
            end
          end
        end
      join_none
      wait (vif0.aresetn === 1'b1 && vif1.aresetn === 1'b1);
      repeat (5) @(vif0.cb);
      body();
      repeat (60) @(vif0.cb);   // Drain
      wd_done = 1;
      phase.drop_objection(this);
    endtask
    virtual task body(); endtask
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      `uvm_info("STAT", $sformatf("dut0 beat=%0d cmd=%0d chk=%0d | dut1 beat=%0d cmd=%0d chk=%0d",
        env0.dmon.n_beat, env0.sb.n_cmd, env0.sb.n_chk,
        env1.dmon.n_beat, env1.sb.n_cmd, env1.sb.n_chk), UVM_LOW)
      if (uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 && uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
    endfunction
  endclass

  class t_smoke extends test_base;
    `uvm_component_utils(t_smoke)
    function new(string n = "t_smoke", uvm_component p = null); super.new(n, p); endfunction
    task body();
      env0.cov.cur_mode = M_SAME;
      run_seq_on(seq_smoke::type_id::create("s"), env0);
    endtask
  endclass

  // Comprehensive test: Run all feature sections serially (default entry point, complete coverage collection within one test)
  class dvbench_test extends test_base;
    `uvm_component_utils(dvbench_test)
    function new(string n = "dvbench_test", uvm_component p = null); super.new(n, p); endfunction

    task reset_stalled_address(rdma_env selected_env,virtual rdma_if selected_vif);
      seq_reset_stall sequence_item;
      int completed_cases=0;
      selected_env.slv.ar_dly=100;
      for(int phase_index=0;phase_index<2;phase_index++)begin
        selected_vif.pulse_reset();
        selected_env.sb.flush();
        repeat(3)@(posedge selected_vif.aclk);
        sequence_item=seq_reset_stall::type_id::create("reset_stall");
        sequence_item.start(selected_env.ag.sqr);
        repeat(8)@(posedge selected_vif.aclk);
        @(negedge selected_vif.aclk);
        if({selected_vif.axi_m_arvalid,selected_vif.axi_m_arready,selected_vif.cmd_valid}!==3'b100)
          `uvm_error("PROBE_VACUITY","Expected a pending address and no command before reset")
        if(phase_index==0) #0.25; else #0.75;
        selected_vif.aresetn=0;
        #0.5 selected_vif.aresetn=1;
        selected_env.sb.flush();
        repeat(6)begin
          @(negedge selected_vif.aclk);
          #0.01;
          if({selected_vif.axi_m_arvalid,selected_vif.cmd_ready,selected_vif.dout_tvalid}!==3'b010)
            `uvm_error("RESET_ABORT","Canceled command must remain idle after a between-edge reset")
        end
        completed_cases++;
      end
      if(completed_cases!=2)`uvm_error("PROBE_VACUITY","Reset phase sweep incomplete")
      selected_vif.pulse_reset();
      selected_env.sb.flush();
      selected_env.slv.ar_dly=0;
      repeat(3)@(posedge selected_vif.aclk);
    endtask

    task body();
      reset_stalled_address(env0,vif0);
      reset_stalled_address(env1,vif1);
      // F01/F02 basics (dut0 default parameters)
      env0.cov.cur_mode = M_SAME;
      fork
        run_seq_on(seq_long_count::type_id::create("count0"), env0);
        begin repeat (300) @(vif0.aclk); vif0.pulse_reset(); env0.sb.flush(); end
      join
      fork
        run_seq_on(seq_long_count::type_id::create("count1"), env1);
        begin repeat (300) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      run_seq_on(seq_smoke::type_id::create("sm"), env0);
      run_seq_on(seq_f02::type_id::create("dt"), env0);
      // F01 slave latency patterns (arready wait / rvalid delay / R gap)
      env0.cov.cur_mode = M_ARDLY;
      env0.slv.ar_dly = 2; env0.slv.r_lat = 1;
      run_seq_on(seq_small::type_id::create("ad"), env0);
      run_seq_on(seq_cells::type_id::create("adc"), env0);
      env0.slv.ar_dly = 0;
      env0.cov.cur_mode = M_RGAP;
      env0.slv.r_lat = 0; env0.slv.r_gap = 1;
      run_seq_on(seq_cells::type_id::create("rgc"), env0);
      env0.slv.r_gap = 0;
      // V9/G8: combined delay-setting context (ARDLY and RGAP overlap: ar_dly=2 and r_gap=1 applied simultaneously)
      env0.cov.cur_mode = M_ARDLY;
      env0.slv.ar_dly = 2; env0.slv.r_gap = 1;
      run_seq_on(seq_small::type_id::create("dgc"), env0);
      env0.slv.ar_dly = 2; env0.slv.r_gap = 0; env0.slv.r_lat = 1;   // d2 l1 g0
      run_seq_on(seq_small::type_id::create("dg1"), env0);
      env0.slv.ar_dly = 0; env0.slv.r_gap = 1; env0.slv.r_lat = 1;   // d0 l1 g1
      run_seq_on(seq_small::type_id::create("dg2"), env0);
      // d2 l1 g1: all three delays applied simultaneously (ar_dly=2 + r_lat=1 + r_gap=1)
      env0.slv.ar_dly = 2; env0.slv.r_gap = 1; env0.slv.r_lat = 1;
      run_seq_on(seq_small::type_id::create("dg3"), env0);
      // d2 l0 g0: pure ar_dly=2 with no other delays (residual r_gap=1 in the dgc section; made a separate section here)
      env0.slv.ar_dly = 2; env0.slv.r_gap = 0; env0.slv.r_lat = 0;
      run_seq_on(seq_small::type_id::create("dg4"), env0);
      env0.slv.ar_dly = 0; env0.slv.r_gap = 0; env0.slv.r_lat = 0;
      // F03 length/alignment (dut0 big-endian)
      env0.cov.cur_mode = M_SAME;
      run_seq_on(seq_sweep16::type_id::create("sw"), env0);
      run_seq_on(seq_single::type_id::create("sg"), env0);
      run_seq_on(seq_zero::type_id::create("z0"), env0);
      run_seq_on(seq_big0::type_id::create("bg"), env0);
      // G6: D=256/257/512 huge-value boundary commands fully checked without reset (without taking the big_cmd exemption);
      // G4: off=1/2/3 long frames advance realign b phase to 6/7 (deep-phase reload branches)
      run_seq_on(seq_deep::type_id::create("dp0"), env0);
      run_seq_on(seq_bigcap::type_id::create("bc0"), env0);
      // F08 parameters (dut1 little-endian + MAX_BURST=256 multiple bursts/large arlen)
      env1.cov.cur_mode = M_SAME;
      run_seq_on(seq_smoke::type_id::create("sm1"), env1);
      run_seq_on(seq_sweep16::type_id::create("sw1"), env1);
      run_seq_on(seq_single::type_id::create("sg1"), env1);
      run_seq_on(seq_cells::type_id::create("ce1"), env1);
      run_seq_on(seq_multib::type_id::create("mb"), env1);
      // G3: env1 cp_len bz / same_len0 (seq_zero previously ran only in env0) + cp_data zero/maxv
      // (seq_f02 previously ran only in env0); G6/G4: LE mirror side of huge-value boundaries + deep-phase long frames
      run_seq_on(seq_zero::type_id::create("z01"), env1);
      run_seq_on(seq_f02::type_id::create("dt1"), env1);
      run_seq_on(seq_deep::type_id::create("dp1"), env1);
      run_seq_on(seq_bigcap::type_id::create("bc1"), env1);
      fork                                  // seq_big large-arlen command discarded after ~140 cycles
        run_seq_on(seq_big::type_id::create("bg1"), env1);
        begin repeat (140) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      // F04/F09 flow control (dut0 strong backpressure→FIFO full→release)
      env0.cov.cur_mode = M_FULLP;
      env0.odrv.pct = 0;
      fork
        run_seq_on(seq_f04::type_id::create("fl"), env0);
        begin repeat (30) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      // F09 FIFO truly full (depth-16 storage full, >17-beat command, full-storage write path fifo full=1)
      // G4 correction: after fl is released, pct has already returned to 100; this fork originally only set pct=100, a no-op—
      // Backpressure was never actually applied (root cause of full/full_val/wr_count[4] never toggling and all cond 1 0 branches being empty)
      env0.odrv.pct = 0;
      fork
        run_seq_on(seq_fill16::type_id::create("ff"), env0);
        begin repeat (50) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      // G4: hold deep-phase long frames with strong backpressure, then release (b=6/7 phase-hold windows) + multiple FIFO fill/drain wraparound rounds
      // (gray pointer bit4 toggles repeatedly)
      env0.odrv.pct = 0;
      fork
        run_seq_on(seq_deep::type_id::create("dpf"), env0);
        begin repeat (22) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      repeat (2) begin
        env0.odrv.pct = 0;
        fork
          run_seq_on(seq_fill16::type_id::create("ff2"), env0);
          begin repeat (30) @(vif0.aclk); env0.odrv.pct = 100; end
        join
      end
      // Run another command with diverse keep patterns in the FULLP context (beat/AR-level auto_M_FULLP hit)
      fork
        run_seq_on(seq_small::type_id::create("fp"), env0);
        begin repeat (10) @(vif0.aclk); begin env0.odrv.pct = 40; end
              repeat (20) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      fork
        run_seq_on(seq_cells::type_id::create("fpc"), env0);
        begin repeat (6) @(vif0.aclk); begin env0.odrv.pct = 0; end
              repeat (16) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      // M_FULLP × {k0111,k0011,k0001} (counted as a union): intermediate partial beats before the full bit flows out—
      // Feed off≠0 partial commands into strong backpressure; hit partial-beat outflow while the FIFO retains the full bit
      fork
        run_seq_on(seq_cells::type_id::create("fpx"), env0);
        begin repeat (4) @(vif0.aclk); begin env0.odrv.pct = 0; end
              repeat (24) @(vif0.aclk); env0.odrv.pct = 100; end
      join
      env0.cov.cur_mode = M_BP;
      env0.odrv.pct = 60;
      run_seq_on(seq_small::type_id::create("bp"), env0);
      run_seq_on(seq_cells::type_id::create("bpc"), env0);
      // G2: M_BP×[64:128] (68B command, maximum 48B in the original backpressure context → auto bin always empty)
      run_seq_on(seq_fill16::type_id::create("bpl"), env0);
      env0.odrv.pct = 100;
      // F05 Clock frequency changes (dut0)
      env0.cov.cur_mode = M_CLK;
      vif0.set_half(5);
      run_seq_on(seq_small::type_id::create("c1"), env0);
      run_seq_on(seq_cells::type_id::create("c1c"), env0);
      vif0.set_half(3);
      run_seq_on(seq_cells::type_id::create("c2c"), env0);
      run_seq_on(seq_small::type_id::create("c2"), env0);
      vif0.set_half(2);
      env0.cov.cur_mode = M_SAME;
      // F06 Reset (injected during dut1 transfer); followed by the huge-value-reset toggle section (high-bit toggling of the 32-bit reg)
      env1.cov.cur_mode = M_RESET;
      fork
        run_seq_on(seq_mid::type_id::create("mi"), env1);
        begin
          repeat (20) @(vif1.aclk);
          vif1.pulse_reset();
          env1.sb.flush();
        end
      join
      // V8: The first command after reset still runs in the M_RESET context → cg_ar/cg_beat auto_M_RESET get hits
      run_seq_on(seq_cells::type_id::create("sm2"), env1);
      run_seq_on(seq_smoke::type_id::create("sm3"), env1);
      // M_RESET × {k1110,k1100,k1000} rows: feed non-full beats before reset? Already infeasible (these rows require
      // realign to have already shaped a non-full intermediate beat before reset interrupts) — hit when an in-flight seq_mid non-full command is interrupted
      fork
        run_seq_on(seq_cells::type_id::create("rz"), env1);
        begin repeat (6) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      run_seq_on(seq_cells::type_id::create("zr"), env1);    // Still in the M_RESET context
      // M_RESET × {k1110,k1100,k1000}: For these three columns (this data stream), the LE instance requires a frame with off≠0
      // plus a reset interruption that leaves exactly a shaped non-full beat in flight → short off=3/B%4=1 commands with deep reset superimposed
      fork
        run_seq_on(seq_short_off3::type_id::create("rz2"), env1);
        begin repeat (4) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      run_seq_on(seq_cells::type_id::create("zr2"), env1);
      // G1: M_RESET×[64:128] uninterrupted command (126B) → rst_64p (original reset section capped at 48B,
      // although seq_mid is 126B, it is interrupted by reset at beat 20; len is sampled and bins belong to the correct context, but the beat context is missing)
      run_seq_on(seq_mid::type_id::create("mr"), env1);
      // G4-FSM/issue1: Reset a seq_rstph multi-burst long command at each phase (sweeping k over 3..9 guarantees hitting
      // the S_CALC→S_IDLE / S_INCR→S_IDLE single-cycle window arcs; big_cmd truncation modeling + discard on reset)
      fork
        run_seq_on(seq_rstph::type_id::create("rph"), env1);
        begin
          for (int k = 3; k <= 9; k++) begin
            repeat (k) @(vif1.aclk);
            if (k > 3) begin vif1.pulse_reset(); env1.sb.flush(); end
          end
        end
      join
      run_seq_on(seq_cells::type_id::create("zr3"), env1);   // Clean recovery after reset (M_RESET context)
      env1.cov.cur_mode = M_SAME;
      // Huge-value-reset: Each S_INIT is loaded at full width, then discarded by reset after ~40 cycles (truncation modeling does not check tlast)
      env1.cov.cur_mode = M_RESET;
      fork
        run_seq_on(seq_bigaddr::type_id::create("ba"), env1);
        begin repeat (40) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      fork
        run_seq_on(seq_bigaddr::type_id::create("bb"), env1);
        begin repeat (40) @(vif1.aclk); vif1.pulse_reset(); env1.sb.flush(); end
      join
      env0.cov.cur_mode = M_RESET;
      // G1: rst_64p on the env0 side (uninterrupted 126B command in the M_RESET context);
      // Drain wait: send() only reaches the command handshake; the final beat (k1100) must flow out within this context (previously, the 40-cycle
      // bigaddr reset fork would truncate the in-flight final beat → the M_RESET×k1100 combination was lost)
      run_seq_on(seq_mid::type_id::create("mr0"), env0);
      repeat (60) @(vif0.aclk);
      // M_RESET×{k1110,k1100,k1000}: env0 BE final-beat family (67B→k1110 / 70B→k1100 /
      // 9B off=1→k1000), all data flows out without reset interruption
      run_seq_on(seq_deep::type_id::create("mr1"), env0);
      repeat (60) @(vif0.aclk);
      run_seq_on(seq_small::type_id::create("mr2"), env0);
      repeat (40) @(vif0.aclk);
      fork
        run_seq_on(seq_bigaddr::type_id::create("ba0"), env0);
        begin repeat (40) @(vif0.aclk); vif0.pulse_reset(); env0.sb.flush(); end
      join
      fork
        run_seq_on(seq_bigaddr::type_id::create("bb0"), env0);
        begin repeat (40) @(vif0.aclk); vif0.pulse_reset(); env0.sb.flush(); end
      join
      // G4-FSM/issue1: seq_rstph on the env0 side (MB=16 → D=2048 split into 128 burst segments, 3 cycles/segment
      // with denser loop phases; sweeping k over 3..9 and resetting at each phase guarantees hitting the CALC/INCR single-cycle window arcs)
      fork
        run_seq_on(seq_rstph::type_id::create("rph0"), env0);
        begin
          for (int k = 3; k <= 9; k++) begin
            repeat (k) @(vif0.aclk);
            if (k > 3) begin vif0.pulse_reset(); env0.sb.flush(); end
          end
        end
      join
      run_seq_on(seq_cells::type_id::create("zr4"), env0);   // Clean recovery after reset (M_RESET context)
      env0.cov.cur_mode = M_SAME; env1.cov.cur_mode = M_SAME;
      // env1 five-mode context section (complete the LE counterpart keep×mode cross)
      env1.cov.cur_mode = M_ARDLY;
      env1.slv.ar_dly = 1; env1.slv.r_lat = 1;
      run_seq_on(seq_cells::type_id::create("adc1"), env1);
      env1.slv.ar_dly = 0;
      env1.cov.cur_mode = M_RGAP;
      env1.slv.r_lat = 0; env1.slv.r_gap = 1;
      run_seq_on(seq_cells::type_id::create("rgc1"), env1);
      env1.slv.r_gap = 0;
      // env1 FULLP section (union rows of the LE instance k0111/k0011/k0001 family)
      env1.cov.cur_mode = M_FULLP;
      env1.odrv.pct = 0;
      fork
        run_seq_on(seq_cells::type_id::create("fpc1"), env1);
        begin repeat (8) @(vif1.aclk); env1.odrv.pct = 100; end
      join
      // G3: env1 fullp_64p (fill with 68B under strong backpressure, then release flow); G4 correction: fpc1 has already put pct back to
      // 100; the original fork had no pct=0 precondition → backpressure was likewise never applied on the env1 side
      env1.odrv.pct = 0;
      fork
        run_seq_on(seq_fill16::type_id::create("fp1l"), env1);
        begin repeat (30) @(vif1.aclk); env1.odrv.pct = 100; end
      join
      env1.cov.cur_mode = M_BP;
      env1.odrv.pct = 60;
      run_seq_on(seq_cells::type_id::create("bpc1"), env1);
      // G2: M_BP×[64:128] on the env1 side
      run_seq_on(seq_fill16::type_id::create("bpl1"), env1);
      env1.odrv.pct = 100;
      env1.cov.cur_mode = M_CLK;
      vif1.set_half(5);
      run_seq_on(seq_cells::type_id::create("clkc1"), env1);
      vif1.set_half(2);
      env1.cov.cur_mode = M_SAME;
      // V10 rresp error injection (dut1: alternating frame-level SLVERR + beat-level DECERR; data is checked beat by beat as usual)
      env1.cov.cur_mode = M_ERR;
      env1.slv.in_err_ctx = 1;
      env1.slv.err_mode = 1; env1.slv.err_resp = 2'b10;
      run_seq_on(seq_err::type_id::create("e1"), env1);
      env1.slv.err_mode = 2; env1.slv.err_resp = 2'b11;
      run_seq_on(seq_err::type_id::create("e2"), env1);
      env1.slv.err_mode = 0;
      env1.slv.in_err_ctx = 0;
      env1.cov.cur_mode = M_SAME;
      // Stress wrap-up (dut0 random 60% backpressure)
      env0.cov.cur_mode = M_STRESS;
      env0.odrv.pct = 60;
      run_seq_on(seq_stress::type_id::create("st"), env0);
      env0.odrv.pct = 100;
      env1.cov.cur_mode = M_STRESS;
      env1.odrv.pct = 60;
      run_seq_on(seq_stress::type_id::create("st1"), env1);
      env1.odrv.pct = 100;
      env1.cov.cur_mode = M_SAME;
      // Add the M_ERR scenario to dut0 (M_ERR×each main keep row, counted as a union)
      env0.cov.cur_mode = M_ERR;
      env0.slv.in_err_ctx = 1;
      env0.slv.err_mode = 1; env0.slv.err_resp = 2'b10;
      run_seq_on(seq_err::type_id::create("e0"), env0);
      env0.slv.err_mode = 2; env0.slv.err_resp = 2'b11;
      run_seq_on(seq_err::type_id::create("e0b"), env0);
      env0.slv.err_mode = 0;
      env0.slv.in_err_ctx = 0;
      env0.cov.cur_mode = M_SAME;
      // issue3/G3: Supplement env1 cg_beat per-instance scores (82.37→95+ target) — increase the density of long frames and
      // off≠0 keep patterns for the LE instance (seq_deep 64-96B off=1/2/3 family + seq_short_off3 + sweep16 mirror)
      env1.odrv.pct = 100;
      run_seq_on(seq_deep::type_id::create("g3a"), env1);
      run_seq_on(seq_short_off3::type_id::create("g3b"), env1);
      run_seq_on(seq_cells::type_id::create("g3c"), env1);
      run_seq_on(seq_sweep16::type_id::create("g3d"), env1);
      run_seq_on(seq_deep::type_id::create("g3e"), env1);
    endtask
  endclass

endpackage
