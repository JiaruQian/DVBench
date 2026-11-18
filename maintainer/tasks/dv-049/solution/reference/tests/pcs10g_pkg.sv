// pcs10g_pkg.sv -- full UVM env for xgmii_pcs_10g_tx (XGMII 64b -> 64b/66b PCS TX)
//
// Feature list (nine dimensions, F01..F09):
//  F01 reset        : power-on reset, mid-stream pulse_reset (scrambler s_q / gearbox seq_q reset arcs)
//  F02 idle stream  : txc=FF idle blocks (ctrl block BT=0x1e, data_ctrl zeroing mux)
//  F03 data stream  : txc=00 pure data blocks incl. all-zero/all-one/walking-one words (toggle)
//  F04 frame        : start@lane0 + data + terminate at lanes 0/6/7 (term_v path, safe term_block_type)
//  F05 start variants: FB at byte0 only / byte4 only / both / FB inside pure data word
//  F06 keep sweep   : txc low-mask patterns 00,01,03,07,0F,1F,3F -> term_block_type case TERM_0..TERM_6
//                     (TERM_7 structurally unreachable: keep[7:6] are always 0)
//  F07 gearbox FSM  : seq_q 0..32 full walk, stall (ready_o=0) every 33rd cycle, mid-round reset
//  F08 param variant: N/A -- XGMII_DATA_W!=64 breaks pcs_tx lane math (enc_intf txc stays 8b);
//                     substituted by gearbox full-period walk + boundary words
//  F09 backpressure : ready_o semantics mirrored per cycle; strict driver holds word while ready_o=0
//  extra: X-term words (term lanes 1..5 hit default case -> X block type) placed late,
//         cleared by a reset pulse (scrambler re-inits to all-ones), then clean random tail.
//
// Scoreboard: cycle-exact bit-level mirror of the whole datapath
//   enc_intf (incl. the ~txc+1 highest-set-bit lsb_ctrl selection and txc[5:0] keep truncation)
//   -> pcs_enc_lite (block_type case with X default) -> 64b66b scrambler (s_q 58b)
//   -> gearbox (vector-valued mask selects the complete FIFO word, not per-bit lanes).
//   X bits on the expected side are skipped; ready_o is compared exactly.

`include "uvm_macros.svh"
package pcs10g_pkg;
  import uvm_pkg::*;

  typedef enum int { M_BOOT, M_IDLE, M_DATA, M_STRM, M_FRAME, M_ERR,
                     M_MIDRST, M_RAND, M_XTERM } pcs_mode_e;

  // ---------------------------------------------------------------- txn
  class pcs10g_txn extends uvm_sequence_item;
    rand bit [63:0] txd;
    rand bit [7:0]  txc;
    int unsigned    reps     = 1;
    bit             strict   = 1'b0;   // F09: hold word until ready_o==1
    bit             do_reset = 1'b0;   // F01/F07: mid-stream reset
    // monitor observation fields
    logic           nreset;
    logic           ready;
    logic [63:0]    data;
    longint unsigned cyc;

    `uvm_object_utils_begin(pcs10g_txn)
      `uvm_field_int(txd,      UVM_ALL_ON)
      `uvm_field_int(txc,      UVM_ALL_ON)
      `uvm_field_int(reps,     UVM_ALL_ON | UVM_DEC)
      `uvm_field_int(strict,   UVM_ALL_ON)
      `uvm_field_int(do_reset, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "pcs10g_txn");
      super.new(name);
    endfunction
  endclass

  // ---------------------------------------------------------------- driver
  class pcs10g_driver extends uvm_driver #(pcs10g_txn);
    virtual pcs10g_if vif;
    `uvm_component_utils(pcs10g_driver)

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual pcs10g_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "pcs10g_driver has no vif")
    endfunction

    task run_phase(uvm_phase phase);
      pcs10g_txn t;
      wait (vif.nreset === 1'b1);          // never drive before reset release
      forever begin
        seq_item_port.get_next_item(t);
        if (t.do_reset) begin
          vif.pulse_reset();
          seq_item_port.item_done();
          continue;
        end
        repeat (t.reps) begin
          vif.drv_cb.txd <= t.txd;
          vif.drv_cb.txc <= t.txc;
          @(vif.drv_cb);
          if (t.strict)                    // word consumed only on a ready cycle
            while (vif.drv_cb.ready_o === 1'b0) @(vif.drv_cb);
        end
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------------------------------------------------------------- monitor
  class pcs10g_monitor extends uvm_monitor;
    virtual pcs10g_if vif;
    uvm_analysis_port #(pcs10g_txn) ap;
    longint unsigned cyc = 0;
    `uvm_component_utils(pcs10g_monitor)

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db #(virtual pcs10g_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "pcs10g_monitor has no vif")
    endfunction

    task run_phase(uvm_phase phase);
      pcs10g_txn t;
      forever begin
        @(vif.mon_cb);
        t = pcs10g_txn::type_id::create("mt");
        t.txd    = vif.mon_cb.txd;
        t.txc    = vif.mon_cb.txc;
        t.nreset = vif.mon_cb.nreset;
        t.ready  = vif.mon_cb.ready_o;
        t.data   = vif.mon_cb.data_o;
        t.cyc    = cyc++;
        ap.write(t);
      end
    endtask
  endclass

  // ---------------------------------------------------------------- scoreboard
  class pcs10g_sb extends uvm_component;
    `uvm_component_utils(pcs10g_sb)
    uvm_analysis_imp #(pcs10g_txn, pcs10g_sb) imp;

    virtual pcs10g_if vif;
    longint unsigned n_chk=0,n_bit=0,n_skipx=0;
    function new(string name,uvm_component parent);
      super.new(name,parent);imp=new("imp",this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual pcs10g_if)::get(this,"","vif",vif)) `uvm_fatal("NOVIF","scoreboard vif")
    endfunction
    function void write(pcs10g_txn t);
      if(t.cyc>=5) begin
        n_chk++;
        if(t.ready!==vif.mon_cb.expected_ready) `uvm_error("SB_RDY","input-history ready mismatch")
        for(int i=0;i<64;i++) begin
          if(!$isunknown(vif.mon_cb.expected_data[i])) begin
            n_bit++;
            if(t.data[i]!==vif.mon_cb.expected_data[i]) `uvm_error("SB_DAT",$sformatf("cycle=%0d bit=%0d expected=%b actual=%b",t.cyc,i,vif.mon_cb.expected_data[i],t.data[i]))
          end else n_skipx++;
        end
      end
    endfunction
    function void report_phase(uvm_phase phase);
      if(n_chk<100 || n_bit<1000) `uvm_error("VACUOUS","insufficient independent comparisons")
      `uvm_info("SB",$sformatf("checked_cycles=%0d checked_bits=%0d unspecified_bits=%0d",n_chk,n_bit,n_skipx),UVM_LOW)
    endfunction
  endclass

  // ---------------------------------------------------------------- coverage
  class pcs10g_cov extends uvm_subscriber #(pcs10g_txn);
    `uvm_component_utils(pcs10g_cov)
    pcs_mode_e   cur_mode;
    logic [7:0]  m_txc;
    int          m_lsb;
    int          m_start;
    logic        m_ready;

    covergroup cg_feat();
      option.per_instance = 1;
      cp_mode: coverpoint cur_mode;
      cp_txc: coverpoint m_txc {
        bins b_data  = {8'h00};
        bins b_strt0 = {8'h01};
        bins b_k2    = {8'h03};
        bins b_k3    = {8'h07};
        bins b_k4    = {8'h0f};
        bins b_k5    = {8'h1f};
        bins b_k6    = {8'h3f};
        bins b_strt4 = {8'h10};
        bins b_hi    = {8'h80, 8'hc0};
        bins b_idle  = {8'hff};
        bins b_xterm = {8'he0, 8'hf0, 8'hf8, 8'hfc, 8'hfe};
        bins b_rand  = default;
      }
      cp_lsb: coverpoint m_lsb {
        bins p0 = {0}; bins p1 = {1}; bins p2 = {2}; bins p3 = {3};
        bins p4 = {4}; bins p5 = {5}; bins p6 = {6}; bins p7 = {7};
        bins pn = {8};
      }
      cp_start: coverpoint m_start {
        bins s_none = {0}; bins s_l0 = {1}; bins s_l4 = {2}; bins s_both = {3};
      }
      cp_rdy: coverpoint m_ready { bins r0 = {1'b0}; bins r1 = {1'b1}; }
      x_mode_rdy: cross cp_mode, cp_rdy;
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      cg_feat  = new();
      cur_mode = M_BOOT;
    endfunction

    function void write(pcs10g_txn t);
      logic [7:0] m8;
      m_txc   = t.txc;
      m_ready = t.ready;
      m8      = ~t.txc + 8'd1;
      m_lsb   = 8;
      for (int i = 0; i < 8; i++) if (m8[i]) m_lsb = i;
      m_start = ((t.txd[39:32] == 8'hfb) ? 2 : 0) + ((t.txd[7:0] == 8'hfb) ? 1 : 0);
      cg_feat.sample();
    endfunction
  endclass

  // ---------------------------------------------------------------- agent / env
  class pcs10g_agent extends uvm_agent;
    `uvm_component_utils(pcs10g_agent)
    pcs10g_driver                    drv;
    pcs10g_monitor                   mon;
    uvm_sequencer #(pcs10g_txn)      sqr;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = pcs10g_monitor::type_id::create("mon", this);
      drv = pcs10g_driver     ::type_id::create("drv", this);
      sqr = uvm_sequencer #(pcs10g_txn)::type_id::create("sqr", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class pcs10g_env extends uvm_component;
    `uvm_component_utils(pcs10g_env)
    pcs10g_agent ag;
    pcs10g_sb    sb;
    pcs10g_cov   cov;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ag  = pcs10g_agent::type_id::create("ag",  this);
      sb  = pcs10g_sb   ::type_id::create("sb",  this);
      cov = pcs10g_cov  ::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ag.mon.ap.connect(sb.imp);
      ag.mon.ap.connect(cov.analysis_export);
    endfunction
  endclass

  // ---------------------------------------------------------------- sequences
  class pcs10g_base_seq extends uvm_sequence #(pcs10g_txn);
    `uvm_object_utils(pcs10g_base_seq)
    function new(string name = "pcs10g_base_seq");
      super.new(name);
    endfunction

    task drv_word(bit [63:0] d, bit [7:0] c, int unsigned reps = 1, bit strict = 1'b0);
      pcs10g_txn t = pcs10g_txn::type_id::create("t");
      start_item(t);
      t.txd = d; t.txc = c; t.reps = reps; t.strict = strict; t.do_reset = 1'b0;
      finish_item(t);
    endtask

    task drv_reset();
      pcs10g_txn t = pcs10g_txn::type_id::create("t");
      start_item(t);
      t.do_reset = 1'b1;
      finish_item(t);
    endtask

    // random words; fixed=1 pins txc to cval; sanitize keeps the term X
    // pattern (txc[7]=1 with FD at the selected lsb_ctrl byte) out of the
    // random stream -- X is injected only by the dedicated XTERM segment.
    task drv_rand(int unsigned n, bit strict, bit fixed, bit [7:0] cval);
      pcs10g_txn t;
      bit [7:0]  m8;
      int        hi;
      repeat (n) begin
        t = pcs10g_txn::type_id::create("t");
        void'(t.randomize());
        if (fixed) t.txc = cval;
        if (t.txc[7] === 1'b1) begin
          m8 = ~t.txc + 8'd1;
          hi = -1;
          for (int i = 0; i < 8; i++) if (m8[i]) hi = i;
          if (hi >= 0 && t.txd[8*hi +: 8] == 8'hfd) t.txd[8*hi +: 8] = 8'h5a;
        end
        start_item(t);
        t.reps = 1; t.strict = strict; t.do_reset = 1'b0;
        finish_item(t);
      end
    endtask
  endclass

  class s_boot extends pcs10g_base_seq;      // F01
    `uvm_object_utils(s_boot)
    function new(string name = "s_boot"); super.new(name); endfunction
    task body();
      drv_word(64'h0707070707070707, 8'hff, 8);
    endtask
  endclass

  class s_idle extends pcs10g_base_seq;      // F02: full gearbox round on idle
    `uvm_object_utils(s_idle)
    function new(string name = "s_idle"); super.new(name); endfunction
    task body();
      drv_word(64'h0707070707070707, 8'hff, 36);
    endtask
  endclass

  class s_data extends pcs10g_base_seq;      // F03 + F06 TERM_0 case
    `uvm_object_utils(s_data)
    function new(string name = "s_data"); super.new(name); endfunction
    task body();
      drv_word(64'h0, 8'h00, 2);
      drv_word({64{1'b1}}, 8'h00, 2);
      for (int k = 0; k < 8; k++) drv_word(64'h1 << (8*k), 8'h00);
      drv_word(~(64'h1 << 31), 8'h00);
      drv_word({64{1'b0}}, 8'h00, 1);
      drv_rand(30, 1'b0, 1'b1, 8'h00);
    endtask
  endclass

  class s_strm extends pcs10g_base_seq;      // F06/F09: keep sweep + strict ready
    `uvm_object_utils(s_strm)
    function new(string name = "s_strm"); super.new(name); endfunction
    task body();
      bit [7:0] safe[11] = '{8'h00, 8'h01, 8'h03, 8'h07, 8'h0f, 8'h1f,
                            8'h3f, 8'h10, 8'h80, 8'hc0, 8'hff};
      bit [63:0] w;
      foreach (safe[i]) begin
        for (int r = 0; r < 2; r++) begin
          w = {$urandom, $urandom};
          if (i == 1) w[7:0]   = 8'hfb;   // START_0 word
          if (i == 7) w[39:32] = 8'hfb;   // START_4 word
          if (i >= 8) w[7:0]   = r ? 8'hfd : 8'h07;  // safe term / idle lsb
          drv_word(w, safe[i], 1, 1'b1);
        end
      end
    endtask
  endclass

  class s_frame extends pcs10g_base_seq;     // F04/F05
    `uvm_object_utils(s_frame)
    function new(string name = "s_frame"); super.new(name); endfunction
    task body();
      bit [63:0] w;
      // frame 1: start@0, 3 data, term@0 (TERM_6)
      w = {$urandom, $urandom}; w[7:0] = 8'hfb;    drv_word(w, 8'h01);
      repeat (3) drv_word({$urandom, $urandom}, 8'h00);
      drv_word(64'h07070707070707fd, 8'hff);
      // frame 2: start@0, 1 data, term@7 (TERM_0)
      w = {$urandom, $urandom}; w[7:0] = 8'hfb;    drv_word(w, 8'h01);
      drv_word({$urandom, $urandom}, 8'h00);
      w = {$urandom, $urandom}; w[63:56] = 8'hfd;  drv_word(w, 8'h80);
      // frame 3: start@0, 1 data, term@6 (TERM_0)
      w = {$urandom, $urandom}; w[7:0] = 8'hfb;    drv_word(w, 8'h01);
      drv_word({$urandom, $urandom}, 8'h00);
      w = {$urandom, $urandom}; w[63:56] = 8'h07; w[55:48] = 8'hfd; drv_word(w, 8'hc0);
      // frame 4: term@2 + start@4 in one word, 1 data, term@0
      w = {$urandom, $urandom}; w[63:56] = 8'h00; w[23:16] = 8'hfd; w[39:32] = 8'hfb;
      drv_word(w, 8'h14);
      drv_word({$urandom, $urandom}, 8'h00);
      drv_word(64'h07070707070707fd, 8'hff);
      // F05: FB in both start positions / FB inside pure data
      w = {$urandom, $urandom}; w[7:0] = 8'hfb; w[39:32] = 8'hfb; drv_word(w, 8'h00);
      w = {$urandom, $urandom}; w[7:0] = 8'hfb; w[39:32] = 8'hfb; drv_word(w, 8'h01);
    endtask
  endclass

  class s_err extends pcs10g_base_seq;       // err_v decode path
    `uvm_object_utils(s_err)
    function new(string name = "s_err"); super.new(name); endfunction
    task body();
      bit [63:0] w;
      drv_word(64'h07070707070707fe, 8'hff, 2);
      w = {$urandom, $urandom}; w[63:56] = 8'hfe; drv_word(w, 8'h80);
      w = {$urandom, $urandom}; w[7:0]   = 8'hfe; drv_word(w, 8'hff);
    endtask
  endclass

  class s_midrst extends pcs10g_base_seq;    // F01/F07: reset arcs + recovery
    `uvm_object_utils(s_midrst)
    function new(string name = "s_midrst"); super.new(name); endfunction
    task body();
      drv_word(64'h0707070707070707, 8'hff, 6);
      drv_reset();
      drv_rand(12, 1'b0, 1'b1, 8'h00);
      drv_word(64'h0707070707070707, 8'hff, 4);
    endtask
  endclass

  class s_rand extends pcs10g_base_seq;      // F03/F09: randomized pressure
    `uvm_object_utils(s_rand)
    int unsigned n      = 40;
    bit          strict = 1'b0;
    function new(string name = "s_rand"); super.new(name); endfunction
    task body();
      drv_rand(n, strict, 1'b0, 8'h00);
    endtask
  endclass

  class s_xterm extends pcs10g_base_seq;     // default case -> X block type
    `uvm_object_utils(s_xterm)
    function new(string name = "s_xterm"); super.new(name); endfunction
    task body();
      bit [63:0] w;
      // term@1..5: keep+1 not one-hot -> term_block_type = X
      w = {$urandom, $urandom}; w[63:16] = 48'h070707070707; w[15:8]  = 8'hfd; drv_word(w, 8'hfe);
      w = {$urandom, $urandom}; w[63:24] = 40'h0707070707;   w[23:16] = 8'hfd; drv_word(w, 8'hfc);
      w = {$urandom, $urandom}; w[63:32] = 32'h07070707;     w[31:24] = 8'hfd; drv_word(w, 8'hf8);
      w = {$urandom, $urandom}; w[63:40] = 24'h070707;       w[39:32] = 8'hfd; drv_word(w, 8'hf0);
      w = {$urandom, $urandom}; w[63:48] = 16'h0707;         w[47:40] = 8'hfd; drv_word(w, 8'he0);
      drv_word(64'h0707070707070707, 8'hff, 6);
    endtask
  endclass

  // ---------------------------------------------------------------- test
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    pcs10g_env env;

    function new(string name = "dvbench_test", uvm_component parent = null);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = pcs10g_env::type_id::create("env", this);
    endfunction

    task run_seg(pcs10g_base_seq s, pcs_mode_e m);
      env.cov.cur_mode = m;
      s.start(env.ag.sqr);
    endtask

    task run_phase(uvm_phase phase);
      s_rand r;
      r = s_rand::type_id::create("rnd1");
      phase.raise_objection(this, "t_main");

      run_seg(s_boot::type_id::create("boot"),   M_BOOT);   // F01
      run_seg(s_idle::type_id::create("idle"),   M_IDLE);   // F02
      run_seg(s_data::type_id::create("data"),   M_DATA);   // F03/F06
      run_seg(s_strm ::type_id::create("strm"),  M_STRM);   // F06/F09
      run_seg(s_frame::type_id::create("frame"), M_FRAME);  // F04/F05
      run_seg(s_err  ::type_id::create("err"),   M_ERR);
      run_seg(s_midrst::type_id::create("mr1"),  M_MIDRST); // F01/F07
      r.n = 70; r.strict = 1'b0;
      run_seg(r, M_RAND);
      run_seg(s_xterm::type_id::create("xterm"), M_XTERM);  // default case
      run_seg(s_midrst::type_id::create("mr2"),  M_MIDRST); // reset clears X
      r = s_rand::type_id::create("rnd2"); r.n = 40; r.strict = 1'b1;
      run_seg(r, M_RAND);

      phase.drop_objection(this, "t_main");
    endtask

    function void report_phase(uvm_phase phase);
      if(uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0 && uvm_report_server::get_server().get_severity_count(UVM_FATAL)==0)
        `uvm_info("DVBench_COMPLETED","DVBench_COMPLETED",UVM_NONE)
    endfunction
  endclass

endpackage
