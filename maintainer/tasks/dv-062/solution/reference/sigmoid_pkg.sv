`timescale 1ns/1ps
// Native bit-exact scalar prediction is supplied only by model/model.sv.
package sigmoid_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  typedef enum int { OP_BEAT, OP_IDLE, OP_CLEAR, OP_RESET } op_e;
  typedef enum int { S_SPEC, S_SWEEP, S_RAND, S_GAP, S_CLEAR, S_RST } scn_e;

  // ---------- Real-number helpers ----------
  function automatic logic [31:0] f_bits(logic s, int field, int frac23);
    return {s, field[7:0], frac23[22:0]};
  endfunction

  // Normal real -> fp32 bit pattern (this environment only needs the normal range with |x|<=16)
  function automatic logic [31:0] real2bits(logic s, real v);
    int e; real f; int fr;
    logic [7:0] ef;
    if (v <= 0.0) return {s, 31'd0};
    e = $rtoi($floor($ln(v) / $ln(2.0)));
    f = v / $pow(2.0, e) - 1.0;
    if (f < 0.0) begin e = e - 1; f = v / $pow(2.0, e) - 1.0; end
    if (f >= 1.0) begin e = e + 1; f = v / $pow(2.0, e) - 1.0; end
    fr = $rtoi($floor(f * 8388608.0));
    if (fr > 8388607) begin fr = 0; e = e + 1; end
    ef = 8'(127 + e);
    return {s, ef, fr[22:0]};
  endfunction

  function automatic real bits2real(logic [31:0] b);
    if (b[30:23] == 8'd0) return 0.0;
    return $pow(2.0, real'(int'(b[30:23])) - 127.0) *
           (1.0 + real'(b[22:0]) / 8388608.0);
  endfunction

  // Coverage derivation: exp LUT segment index (mirrors rtl's m16*log2(e) multiplication + RNE; the top level forces the sign negative,
  // the segment index depends only on the magnitude; both positive and negative inputs are sampled)

  function automatic int exp_segment(logic [31:0] d);
    longint unsigned m,q;
    int exponent;
    if(d[30:23]==8'hff || d[30:0]>31'h41800000) return -1;
    exponent=int'(d[30:23]);m=0;
    if(exponent>=111 && exponent<=131)
      m=(64'd8388608+longint'(d[22:0]))>>(134-exponent);
    q=dvbench_sigmoid_math::rne_shift(m*64'd94548,16);
    return int'((q>>12)&64'd15);
  endfunction
  function automatic int recip_segment(logic [31:0] d);
    logic [31:0] denominator;
    if(d[30:23]==8'hff) return -1;
    denominator=dvbench_sigmoid_math::add_one(dvbench_sigmoid_math::exponential(d[30:0]));
    return int'(denominator[22:19]);
  endfunction

  // Deterministic random source
  function automatic logic [31:0] lcg32(logic [31:0] s);
    return s * 32'h41c64e6d + 32'h3039;
  endfunction

  // Input classification enumeration (for coverage sampling)
  function automatic int in_class(logic [31:0] d);
    logic [7:0] fld;
    fld = d[30:23];
    if ((fld == 8'hff) && (d[22:0] != 23'd0)) return 0;  // NaN
    if (fld == 8'hff) return d[31] ? 1 : 2;              // -Inf / +Inf
    if (d[30:0] == 31'd0) return d[31] ? 3 : 4;          // -0 / +0
    if (fld == 8'd0) return d[31] ? 5 : 6;               // Negative/positive subnormal
    if (!d[31]) return 7;                                // Positive normal
    if ({1'b0, d[30:0]} > 32'h41800000) return 8;        // x < -16
    if (d == 32'hc1800000) return 9;                     // Exactly at the -16 boundary
    return 10;                                           // Negative normal range
  endfunction

  // ---------- Transactions ----------
  class sig_txn extends uvm_sequence_item;
    rand op_e       op;
    rand logic [31:0] data;
    rand logic      invalid;
    rand int unsigned gap;      // Number of idle cycles after a beat
    rand int unsigned idle;     // Number of OP_IDLE cycles
    rand scn_e      scn;
    int unsigned    cyc;        // Filled by monitor
    int             dut;        // Filled by monitor
    logic           mon_out;    // 0=in 1=out
    logic [31:0]    rdata;      // out: result_o
    logic           rvalid;
    logic           evalid;
    logic [31:0]    edata;
    logic           einv;
    logic           rinv;       // out: invalid_o

    `uvm_object_utils_begin(sig_txn)
      `uvm_field_enum(op_e, op, UVM_ALL_ON)
      `uvm_field_int(data, UVM_ALL_ON)
      `uvm_field_int(invalid, UVM_ALL_ON)
      `uvm_field_int(gap, UVM_ALL_ON)
      `uvm_field_int(idle, UVM_ALL_ON)
      `uvm_field_enum(scn_e, scn, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "sig_txn");
      super.new(name);
      op = OP_BEAT; data = 32'h0; invalid = 1'b0; gap = 0; idle = 0;
      scn = S_SPEC; cyc = 0; dut = 0; mon_out = 0; rdata = 32'h0;
    endfunction
  endclass

  // ---------- Sequence base class (directed send, explicitly supplying all arguments) ----------
  class s_base extends uvm_sequence #(sig_txn);
    `uvm_object_utils(s_base)
    logic [31:0] seed;
    function new(string name = "s_base");
      super.new(name);
      seed = 32'h5eed_0001;
    endfunction

    task send(logic [31:0] d, logic v, int unsigned g, scn_e s);
      sig_txn t;
      t = sig_txn::type_id::create("t");
      start_item(t);
      t.op = OP_BEAT; t.data = d; t.invalid = v; t.gap = g; t.scn = s;
      finish_item(t);
    endtask

    task idle_for(int unsigned n);
      sig_txn t;
      t = sig_txn::type_id::create("t");
      start_item(t);
      t.op = OP_IDLE; t.idle = n; t.gap = 0;
      finish_item(t);
    endtask

    task clear_pulse();
      sig_txn t;
      t = sig_txn::type_id::create("t");
      start_item(t);
      t.op = OP_CLEAR; t.gap = 0;
      finish_item(t);
    endtask

    task reset_pulse();
      sig_txn t;
      t = sig_txn::type_id::create("t");
      start_item(t);
      t.op = OP_RESET; t.gap = 0;
      finish_item(t);
    endtask

    // Used as a drain sequence when the base class is started directly
    task body();
      idle_for(60);
    endtask
  endclass

  // F02/F03: special classes + invalid cross
  class s_spec extends s_base;
    `uvm_object_utils(s_spec)
    function new(string name = "s_spec"); super.new(name); endfunction

    task body();
      logic [31:0] spec_q [$];
      // NaN variants
      spec_q.push_back(32'h7fc00000); spec_q.push_back(32'hffa00000);
      spec_q.push_back(32'h7f800001); spec_q.push_back(32'hffffffff);
      // ±Inf
      spec_q.push_back(32'h7f800000); spec_q.push_back(32'hff800000);
      // ±0
      spec_q.push_back(32'h00000000); spec_q.push_back(32'h80000000);
      // Subnormals (positive -> 0.5; negative magnitude <2^-16 takes the m16=0 datapath -> 0.5)
      spec_q.push_back(32'h00000001); spec_q.push_back(32'h80000001);
      spec_q.push_back(32'h007fffff); spec_q.push_back(32'h807fffff);
      spec_q.push_back(32'h00800000);
      // Positive normals
      spec_q.push_back(32'h3f800000); spec_q.push_back(32'h40490fdb);
      spec_q.push_back(32'h7f7fffff); spec_q.push_back(32'h7f000000);
      // Boundaries and out-of-domain values
      spec_q.push_back(32'hc1800000); spec_q.push_back(32'hc1800001);
      spec_q.push_back(32'hc17fffff); spec_q.push_back(32'hf0000000);
      spec_q.push_back(32'hdf000000); spec_q.push_back(32'h807f0000);
      // Representative points in the negative normal range
      spec_q.push_back(32'hbf800000); spec_q.push_back(32'hbf000000);
      spec_q.push_back(32'hc0490fdb); spec_q.push_back(32'h33800000);
      spec_q.push_back(32'hb4000000); spec_q.push_back(32'h38000000);
      spec_q.push_back(32'hb8000000); spec_q.push_back(32'h3b000000);
      foreach (spec_q[i]) send(spec_q[i], 1'b0, 0, S_SPEC);
      foreach (spec_q[i]) send(spec_q[i], 1'b1, 0, S_SPEC);
    endtask
  endclass

  // F04/F05: [-16,0] sweep (exp segment × recip segment) + tiny values in the Q5.16 clamp region
  class s_sweep extends s_base;
    `uvm_object_utils(s_sweep)
    function new(string name = "s_sweep"); super.new(name); endfunction

    task body();
      logic [31:0] halfway_words[$]='{32'hbea52600,32'hbf65fd00,32'hbfbb5500,32'hbfc71180,32'hbff87880,32'hc010b540,32'hc02d19c0,32'hc0362000,32'hc03ffd40,32'hc0488700,32'hc05180c0,32'hc057f0c0,32'hc059efc0,32'hc0615740,32'hc06c51c0,32'hc07c2140,32'hc0832520,32'hc089c540,32'hc0994b00,32'hc09a5740,32'hc0a278e0,32'hc0be6760,32'hc0be7980,32'hc0be8ba0,32'hc0c598c0,32'hc0c5b200,32'hc0dbc0c0,32'hc0e50e00,32'hc0f16e20,32'hc0f1e260,32'hc103c190};
      logic [31:0] partial_words[$]='{32'hbd7a7000,32'hbed01200,32'hbf052100,32'hbf945500,32'hbfd64c00,32'hc045f000,32'hc0a5c720,32'hc0c3b5e0,32'hc0ca1fa0,32'hc0e00660,32'hc1003f00,32'hc117fe40,32'hc11abad0,32'hc11e8350};
      foreach(partial_words[index]) begin
        send(partial_words[index],1'b0,0,S_SWEEP);
        send(partial_words[index],1'b1,0,S_SWEEP);
        send(partial_words[index]&32'h7fffffff,1'b0,0,S_SWEEP);
        send(partial_words[index]-1,1'b0,0,S_SWEEP);
        send(partial_words[index]+1,1'b0,0,S_SWEEP);
      end
      foreach(halfway_words[index]) begin
        send(halfway_words[index],1'b0,0,S_SWEEP);
        send(halfway_words[index],1'b1,0,S_SWEEP);
        send(halfway_words[index]&32'h7fffffff,1'b0,0,S_SWEEP);
        send(halfway_words[index]-1,1'b0,0,S_SWEEP);
        send(halfway_words[index]+1,1'b0,0,S_SWEEP);
      end
      idle_for(60);
      for (int k = 1; k <= 96; k++)
        send(real2bits(1'b1, 16.0 * real'(k) / 96.0), 1'b0, 0, S_SWEEP);
      // m16=0 clamping (|x| < on the order of 2^-16) and the extremely small normal range
      send(32'hb7f00000, 1'b0, 0, S_SWEEP);
      send(32'h387fffff, 1'b0, 0, S_SWEEP);   // Positive tiny value -> 0.5 inv=1
      send(32'hb8f00000, 1'b0, 0, S_SWEEP);
      send(32'hba000000, 1'b0, 0, S_SWEEP);
      for (int k = 1; k <= 24; k++)
        send(real2bits(1'b1, 1.0 * real'(k) / 24.0), 1'b0, 0, S_SWEEP);
      // Directed: x=-k/8 (odd k -> the low 21 mantissa bits are 0 -> Q5.16 truncation sticky=0,
      // hits the exact carry condition branch of exp RNE with q15=1/sticky=0)
      for (int k = 1; k <= 128; k++)
        send(real2bits(1'b1, real'(k) / 8.0), 1'b0, 0, S_SWEEP);
      send(32'hbf000000, 1'b1, 0, S_SWEEP);   // In-domain + invalid
    endtask
  endclass

  // F02/F09: deterministic random over the full 32-bit value range
  class s_rand extends s_base;
    `uvm_object_utils(s_rand)
    int unsigned n;
    function new(string name = "s_rand");
      super.new(name);
      n = 120;
    endfunction

    task body();
      logic [31:0] d;
      for (int k = 0; k < n; k++) begin
        seed = lcg32(seed);
        d = seed;
        send(d, seed[17], (k % 7 == 6) ? 1 : 0, S_RAND);
      end
    endtask
  endclass

  // F01: back-to-back / bubbles / latency invariance
  class s_gap extends s_base;
    `uvm_object_utils(s_gap)
    function new(string name = "s_gap"); super.new(name); endfunction

    task body();
      int gaps [5] = '{0, 1, 2, 4, 8};
      for (int k = 0; k < 40; k++)
        send(real2bits(1'b1, 16.0 * real'((k * 7) % 97 + 1) / 97.0),
             1'b0, gaps[k % 5], S_GAP);
    endtask
  endclass

  // F06: clear pulse while in flight (discards tokens), idle clear, and restart after clear
  class s_clear extends s_base;
    `uvm_object_utils(s_clear)
    function new(string name = "s_clear"); super.new(name); endfunction

    task body();
      for (int k = 0; k < 30; k++)
        send(real2bits(1'b1, 16.0 * real'(k + 1) / 30.0), 1'b0, 0, S_CLEAR);
      clear_pulse();                       // Discard in-flight tokens
      idle_for(4);
      for (int k = 0; k < 10; k++)
        send(32'hbf800000 + k, 1'b0, 0, S_CLEAR);
      idle_for(60);                        // Drain and check for no spurious valid_o
      clear_pulse();                       // Idle clear
      idle_for(4);
      for (int k = 0; k < 6; k++)
        send(32'h3f000000 + (k << 3), 1'b0, 0, S_CLEAR);
      idle_for(60);
    endtask
  endclass

  // F07: reset during operation + clean restart after reset
  class s_rst extends s_base;
    `uvm_object_utils(s_rst)
    function new(string name = "s_rst"); super.new(name); endfunction

    task body();
      for (int k = 0; k < 30; k++)
        send(real2bits(1'b1, 15.9 * real'(k + 1) / 30.0), 1'b0, 0, S_RST);
      reset_pulse();
      idle_for(4);
      for (int k = 0; k < 12; k++)
        send(real2bits(1'b1, 16.0 * real'(k + 1) / 12.0), 1'b0, 0, S_RST);
      idle_for(60);
    endtask
  endclass

  // ---------- driver ----------
  class sig_driver extends uvm_driver #(sig_txn);
    `uvm_component_utils(sig_driver)
    virtual sigmoid_if vif;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual sigmoid_if)::get(this, "", "vif", vif))
        `uvm_fatal("DRV", "vif not set")
    endfunction

    task run_phase(uvm_phase phase);
      vif.release_reset();
      forever begin
        seq_item_port.get_next_item(req);
        case (req.op)
          OP_BEAT: begin
            @(vif.cb);
            vif.cb.valid   <= 1'b1;
            vif.cb.data    <= req.data;
            vif.cb.invalid <= req.invalid;
            vif.cb.scn     <= 3'(req.scn);
            @(vif.cb);                       // Sampled by the DUT on this cycle
            if (req.gap > 0) begin
              vif.cb.valid <= 1'b0;
              repeat (req.gap) @(vif.cb);
            end
            // gap==0: valid stays asserted, data changes on the next BEAT -> true back-to-back full throughput
          end
          OP_IDLE: begin
            vif.cb.valid <= 1'b0;
            repeat (req.idle) @(vif.cb);
          end
          OP_CLEAR: begin
            @(vif.cb);
            vif.cb.valid <= 1'b0;
            vif.cb.clear <= 1'b1;
            @(vif.cb);
            vif.cb.clear <= 1'b0;
          end
          OP_RESET: vif.pulse_reset();
          default: ;
        endcase
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------- monitor ----------
  class sig_monitor extends uvm_component;
    `uvm_component_utils(sig_monitor)
    virtual sigmoid_if vif;
    int dut;
    int unsigned cyc;
    int unsigned last_in;
    uvm_analysis_port #(sig_txn) ap;

    function new(string name, uvm_component parent);
      super.new(name, parent);
      ap = new("ap", this);
      cyc = 0;
      last_in = 0;
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual sigmoid_if)::get(this, "", "vif", vif))
        `uvm_fatal("MON", "vif not set")
    endfunction

    task run_phase(uvm_phase phase);
      sig_txn t;
      forever begin
        @(posedge vif.clk);
        cyc++;
        if (vif.rst) begin
          t = sig_txn::type_id::create("t");
          t.op = OP_RESET; t.dut = dut; t.cyc = cyc;
          ap.write(t);
        end else begin
          if (vif.valid) begin               // Input beat (enqueue first)
            t = sig_txn::type_id::create("t");
            t.op = OP_BEAT; t.mon_out = 1'b0; t.dut = dut; t.cyc = cyc;
            t.data = vif.data; t.invalid = vif.invalid;
            t.scn = scn_e'(vif.scn);
            t.gap = (cyc > last_in + 1) ? (cyc - last_in - 1) : 0;
            if (t.gap > 8) t.gap = 8;
            last_in = cyc;
            ap.write(t);
          end
          begin // sample every output cycle, including missing/extra valid             // Output beat (match afterward)
            t = sig_txn::type_id::create("t");
            t.op = OP_BEAT; t.mon_out = 1'b1; t.dut = dut; t.cyc = cyc;
            t.rdata = vif.result_o; t.rinv = vif.invalid_o;
            t.rvalid = vif.valid_o; t.evalid = vif.expected_valid;
            t.edata = vif.expected_result; t.einv = vif.expected_invalid;
            ap.write(t);
          end
          if (vif.clear) begin               // Finally clear in-flight expectations
            t = sig_txn::type_id::create("t");
            t.op = OP_CLEAR; t.dut = dut; t.cyc = cyc;
            ap.write(t);
          end
        end
      end
    endtask
  endclass

  // ---------- scoreboard ----------

  class sig_sb extends uvm_component;
    `uvm_component_utils(sig_sb)
    uvm_analysis_imp #(sig_txn, sig_sb) imp;
    int unsigned inputs=0, cycles=0, valid_checks=0, errors=0;
    function new(string name,uvm_component parent);
      super.new(name,parent);
      imp=new("imp",this);
    endfunction
    function void mismatch(string reason,sig_txn t);
      errors++;
      if(errors<=32)
        `uvm_error("SBD",$sformatf("dut=%0d cycle=%0d %s actual=(%b,%h,%b) expected=(%b,%h,%b)",
                   t.dut,t.cyc,reason,t.rvalid,t.rdata,t.rinv,t.evalid,t.edata,t.einv))
    endfunction
    function void write(sig_txn t);
      if(t.op!=OP_BEAT) return;
      if(!t.mon_out) begin inputs++; return; end
      cycles++;
      if(t.rvalid !== t.evalid) mismatch("valid/latency/flush",t);
      if(t.evalid===1'b1) begin
        valid_checks++;
        if(t.rinv !== t.einv) mismatch("invalid flag",t);
        if(t.rdata !== t.edata) mismatch("bit-exact fixed-point/RNE probability",t);
      end
    endfunction
    function void report_phase(uvm_phase phase);
      `uvm_info("COUNTS",$sformatf("inputs=%0d cycles=%0d valid_checks=%0d mismatches=%0d",
                 inputs,cycles,valid_checks,errors),UVM_LOW)
      if(inputs<1000 || valid_checks<1000 || cycles<1000)
        `uvm_error("VACUITY","Insufficient executed input/output comparisons")
      if(errors>32) `uvm_error("SBD_TOTAL",$sformatf("total mismatches=%0d",errors))
    endfunction
  endclass

  // ---------- coverage ----------
  class sig_cov extends uvm_component;
    `uvm_component_utils(sig_cov)
    uvm_analysis_imp #(sig_txn, sig_cov) imp;

    int unsigned q_class, q_inv, q_dut, q_scn, q_gap, q_eseg, q_rseg, q_mz;
    int unsigned q_inv_o, q_bkt;

    covergroup cg_inp();
      cp_class: coverpoint q_class {
        bins nan      = {0};
        bins ninf     = {1};
        bins pinf     = {2};
        bins nzero    = {3};
        bins pzero    = {4};
        bins nsub     = {5};
        bins psub     = {6};
        bins pos_norm = {7};
        bins below    = {8};
        bins b16      = {9};
        bins neg_norm = {10};
      }
      cp_inv: coverpoint q_inv { bins i0 = {0}; bins i1 = {1}; }
      cp_dut: coverpoint q_dut { bins ftz0 = {0}; bins ftz1 = {1}; }
      x_ci: cross cp_class, cp_inv;
      x_cd: cross cp_class, cp_dut;
    endgroup

    covergroup cg_seg();
      cp_eseg: coverpoint q_eseg {
        bins s[16] = {[0:15]};
      }
      cp_rseg: coverpoint q_rseg {
        bins s[16] = {[0:15]};
      }
      cp_mz: coverpoint q_mz { bins mzero = {1}; bins other = {0}; }
    endgroup

    covergroup cg_scn();
      cp_scn: coverpoint q_scn {
        bins spec  = {S_SPEC};
        bins sweep = {S_SWEEP};
        bins rand_ = {S_RAND};
        bins gap   = {S_GAP};
        bins clr   = {S_CLEAR};
        bins rst   = {S_RST};
      }
      cp_gap: coverpoint q_gap {
        bins b2b = {0};
        bins g1  = {1};
        bins g2  = {2};
        bins g3p = {[3:8]};
      }
    endgroup

    covergroup cg_out();
      cp_inv_o: coverpoint q_inv_o { bins o0 = {0}; bins o1 = {1}; }
      cp_bkt: coverpoint q_bkt {
        bins tiny = {0};
        bins sml  = {1};
        bins mid  = {2};
        bins lrg  = {3};
        bins half = {4};
      }
    endgroup

    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this);
      cg_inp = new(); cg_seg = new(); cg_scn = new(); cg_out = new();
    endfunction

    function void write(sig_txn t);
      real g;
      if (t.op == OP_BEAT && !t.mon_out) begin
        q_class = in_class(t.data); q_inv = t.invalid; q_dut = t.dut;
        q_scn = t.scn;
        q_gap = t.gap;
        q_eseg = exp_segment(t.data);
        q_rseg = recip_segment(t.data);
        // m16=0 clamp region: negative value and field<111 (including negative subnormals, |x|< on the order of 2^-15)
        q_mz = (t.data[31] && t.data[30:23] < 8'd111) ? 1 : 0;
        cg_inp.sample(); cg_seg.sample(); cg_scn.sample();
      end else if (t.op == OP_BEAT && t.mon_out && t.rvalid) begin
        q_inv_o = t.rinv;
        g = bits2real(t.rdata);
        if (g < 1.0e-6)             q_bkt = 0;
        else if (g < 0.01)          q_bkt = 1;
        else if (g < 0.1)           q_bkt = 2;
        else if (g < 0.49)          q_bkt = 3;
        else                        q_bkt = 4;
        cg_out.sample();
      end
    endfunction
  endclass

  // ---------- agent / env ----------
  class sig_agent extends uvm_component;
    `uvm_component_utils(sig_agent)
    sig_driver    drv;
    uvm_sequencer #(sig_txn) sqr;
    sig_monitor   mon;
    int dut = 0;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = sig_driver::type_id::create("drv", this);
      sqr = uvm_sequencer#(sig_txn)::type_id::create("sqr", this);
      mon = sig_monitor::type_id::create("mon", this);
      mon.dut = dut;
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class sig_env extends uvm_env;
    `uvm_component_utils(sig_env)
    sig_agent agn0, agn1;
    sig_sb    sb;
    sig_cov   cov;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agn0 = sig_agent::type_id::create("agn0", this);
      agn1 = sig_agent::type_id::create("agn1", this);
      agn1.dut = 1;   // Passed to mon within agent build_phase
      sb  = sig_sb::type_id::create("sb", this);
      cov = sig_cov::type_id::create("cov", this);
    endfunction

    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agn0.mon.ap.connect(sb.imp);
      agn1.mon.ap.connect(sb.imp);
      agn0.mon.ap.connect(cov.imp);
      agn1.mon.ap.connect(cov.imp);
    endfunction
  endclass

  // ---------- dvbench_test: default comprehensive test (the acceptance checker does not pass +UVM_TESTNAME) ----------
  class dvbench_test extends uvm_test;
    `uvm_component_utils(dvbench_test)
    sig_env env;

    function new(string name, uvm_component parent);
      super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = sig_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
      int unsigned run_seed;
      s_spec  sp;
      s_sweep sw;
      s_rand  rn;
      s_gap   gp;
      s_clear cl;
      s_rst   rs;
      if(!$value$plusargs("ntb_random_seed=%d",run_seed)) run_seed=1;
      `uvm_info("INPUT_SEED",$sformatf("LCG history seed=%0d",run_seed),UVM_LOW)
      phase.raise_objection(this);
      fork
        begin // dut0 (FTZ=0): all features in sequence
          sp = s_spec::type_id::create("sp");  sp.seed = 32'h5eed_0001 ^ run_seed;
          sp.start(env.agn0.sqr);
          sw = s_sweep::type_id::create("sw");
          sw.start(env.agn0.sqr);
          rn = s_rand::type_id::create("rn");  rn.seed = 32'h5eed_0002 ^ run_seed; rn.n = 300;
          rn.start(env.agn0.sqr);
          gp = s_gap::type_id::create("gp");
          gp.start(env.agn0.sqr);
          cl = s_clear::type_id::create("cl");
          cl.start(env.agn0.sqr);
          rs = s_rst::type_id::create("rs");
          rs.start(env.agn0.sqr);
        end
        begin // dut1 (FTZ=1): special classes + sweep (parameter-variant equivalence)
          s_spec  sp1;
          s_sweep sw1;
          s_rand  rn1;
          sp1 = s_spec::type_id::create("sp1"); sp1.seed = 32'h5eed_0011 ^ run_seed;
          sp1.start(env.agn1.sqr);
          sw1 = s_sweep::type_id::create("sw1");
          sw1.start(env.agn1.sqr);
          rn1 = s_rand::type_id::create("rn1"); rn1.seed = 32'h5eed_0012 ^ run_seed; rn1.n = 150;
          rn1.start(env.agn1.sqr);
          begin
            s_base dr;
            dr = s_base::type_id::create("dr");   // Drain dut1
            dr.start(env.agn1.sqr);
          end
        end
      join
      phase.drop_objection(this);
    endtask

    function void final_phase(uvm_phase phase);
      uvm_report_server srv=uvm_report_server::get_server();
      if(srv.get_severity_count(UVM_ERROR)==0 && srv.get_severity_count(UVM_FATAL)==0)
        $display("DVBench_COMPLETED");
    endfunction
  endclass

endpackage
