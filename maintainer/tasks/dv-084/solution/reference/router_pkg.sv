// router_pkg.sv — yapp_router UVM environment (full feature coverage version)
// F01 Handshake(vld/suspend) F02 Data(length/boundary values) F03 Frame(bad address/bad length/bad checksum)
// F04 Flow control(channel backpressure→FIFO full→in_suspend) F05 Clock(frequency change) F06 Reset(hard/soft,during transfer)
// F07 Status(counters/interrupts/W1C/last_pkt) F08 Parameters(max_pkt_len register variants) F09 Discard
// All RTL samples on negedge → driver/monitor unified in the negedge domain (same view as DUT, zero races)
`timescale 1ns/1ps
package router_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"

  `uvm_analysis_imp_decl(_c0)
  `uvm_analysis_imp_decl(_c1)
  `uvm_analysis_imp_decl(_c2)
  `uvm_analysis_imp_decl(_hb)

  // hbus register addresses
  localparam bit [15:0] HA_CTRL = 16'h1000;
  localparam bit [15:0] HA_EN   = 16'h1001;
  localparam bit [15:0] HA_IEN  = 16'h1002;
  localparam bit [15:0] HA_INT  = 16'h1003;
  localparam bit [15:0] HA_PCNT = 16'h1004;
  localparam bit [15:0] HA_LCNT = 16'h1005;
  localparam bit [15:0] HA_ICNT = 16'h1006;
  localparam bit [15:0] HA_A0   = 16'h1009;
  localparam bit [15:0] HA_A1   = 16'h100a;
  localparam bit [15:0] HA_A2   = 16'h100b;
  localparam bit [15:0] HA_RST  = 16'h100c;
  localparam bit [15:0] HA_LSZ  = 16'h100d;
  localparam bit [15:0] HA_MEM  = 16'h1010;   // last_pkt_mem RO 65B
  localparam bit [15:0] HA_RW   = 16'h1100;   // RW mem 256B

  typedef enum {K_GOOD, K_ILL, K_LEN0, K_GTMAX} pkt_kind_e;
  typedef enum {M_NORM, M_BACKP, M_RESET, M_FASTCLK, M_ENOFF} cov_mode_e;
  typedef enum {S_NONE, S_HDR, S_MID} susp_e;

  // ---------- txn ----------
  class yapp_txn extends uvm_sequence_item;
    rand bit [1:0] addr;
    rand bit [5:0] length;
    rand bit [7:0] payload[];
    rand bit       bad_parity;
    rand int       gap;
    constraint c_pl { payload.size() == length; }
    // Filled by the monitoring side
    bit [7:0] bytes[$];
    bit [7:0] parity_acc;
    bit       err_seen;
    susp_e    susp = S_NONE;
    int       last_size_m;
    bit [7:0] mem_m [0:64];   // last_pkt_mem faithful mirror (including residual semantics)
    `uvm_object_utils(yapp_txn)
    function new(string name = "yapp_txn"); super.new(name); endfunction
  endclass

  class ch_txn extends uvm_sequence_item;
    bit [7:0] data;
    `uvm_object_utils(ch_txn)
    function new(string name = "ch_txn"); super.new(name); endfunction
  endclass

  class hbus_txn extends uvm_sequence_item;
    bit        wr;
    bit [15:0] addr;
    bit [7:0]  wdata;
    bit [7:0]  rdata;
    `uvm_object_utils(hbus_txn)
    function new(string name = "hbus_txn"); super.new(name); endfunction
  endclass

  // ---------- coverage (only define bins that t_main must hit) ----------
  class router_cov extends uvm_component;
    `uvm_component_utils(router_cov)
    uvm_analysis_imp    #(yapp_txn, router_cov) imp;
    uvm_analysis_imp_c0 #(ch_txn,   router_cov) imp_c0;
    uvm_analysis_imp_c1 #(ch_txn,   router_cov) imp_c1;
    uvm_analysis_imp_c2 #(ch_txn,   router_cov) imp_c2;
    uvm_analysis_imp_hb #(hbus_txn, router_cov) imp_hb;
    cov_mode_e cur_mode = M_NORM;
    bit [1:0] q_addr; bit [5:0] q_len; bit q_par; susp_e q_susp;
    bit [7:0] q_data;
    bit q_wr; bit [15:0] q_haddr;
    covergroup cg_yapp();
      option.per_instance = 1;
      cp_mode: coverpoint cur_mode;                    // F04/F05/F06/F09 context
      // V2 illegal-domain enforcement: ill explicitly declared with illegal_bins; iff guard prevents VCS FCIBH
      // (Hitting illegal_bins immediately terminates simulation—V2/V4 of this test intentionally send illegal packets; illegal-domain counting
      //  is handled by cp_addr_x/c_mode_addr; if RTL regresses to silent forwarding, SB reports a mismatch error)
      cp_addr: coverpoint q_addr iff (q_addr != 2'b11) {
        bins ch0 = {2'b00}; bins ch1 = {2'b01}; bins ch2 = {2'b10};
        illegal_bins ill = {2'b11};
      }
      cp_addr_x: coverpoint q_addr;                    // Dedicated to cross: auto bins include the illegal domain (V2 combinations)
      cp_len:  coverpoint q_len {                      // F02/F03/F08
        bins l0   = {0}; bins l1 = {1};
        bins lmid = {[2:8]}; bins lbig = {[9:20]}; bins l63 = {63};
      }
      cp_par:  coverpoint q_par;                       // F03 Bad checksum
      cp_susp: coverpoint q_susp;                      // F01/F04 Suspension position
      // Combination dimensions (review V2/V4/V5): illegal_bins does not enter cross, so use cp_addr_x for the addr cross
      c_mode_addr: cross cp_mode, cp_addr_x;           // Illegal address × operating context (5×4=20)
      c_len_par:   cross cp_len,  cp_par;              // Bad parity × length category (5×2=10)
      c_susp_mode: cross cp_susp, cp_mode;             // Suspend position × operating mode (3×5=15)
    endgroup
    covergroup cg_ch();
      option.per_instance = 1;
      cp_data: coverpoint q_data {                     // F02 boundary values
        bins zero = {8'h00}; bins maxv = {8'hFF}; bins mid = {[8'h01:8'hFE]};
      }
    endgroup
    covergroup cg_hbus();
      option.per_instance = 1;
      cp_op: coverpoint q_wr;                          // F07 reads/writes
      cp_reg: coverpoint q_haddr {                     // F07/F08 each register + out-of-range
        bins r_ctrl = {HA_CTRL}; bins r_en = {HA_EN};
        bins r_ien  = {HA_IEN};  bins r_int = {HA_INT};
        bins r_pcnt = {HA_PCNT}; bins r_lcnt = {HA_LCNT}; bins r_icnt = {HA_ICNT};
        bins r_a0   = {HA_A0};   bins r_a1 = {HA_A1};  bins r_a2 = {HA_A2};
        bins r_rst  = {HA_RST};  bins r_lsz = {HA_LSZ}; bins r_mem = {HA_MEM};
        bins r_rw   = {HA_RW};   bins r_rwx = {HA_RW + 16'h00FF};
        bins r_oor_lo = {16'h0000}; bins r_oor_hi = {16'h3000};
        bins r_unmap  = {16'h1007};
        bins r_unmap2 = {16'h1008}; bins r_100e = {16'h100e};  // Unmapped within range/YPARITY_RCVD_OFF (reads Z)
      }
    endgroup
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this); imp_c0 = new("imp_c0", this);
      imp_c1 = new("imp_c1", this); imp_c2 = new("imp_c2", this);
      imp_hb = new("imp_hb", this);
      cg_yapp = new(); cg_ch = new(); cg_hbus = new();
    endfunction
    function void write(yapp_txn t);
      bit [7:0] h;
      if (t.bytes.size() == 0) return;
      h = t.bytes[0];
      q_addr = h[1:0]; q_len = h[7:2]; q_par = (t.parity_acc != 8'h00);
      q_susp = t.susp;
      cg_yapp.sample();
    endfunction
    function void write_c0(ch_txn t); q_data = t.data; cg_ch.sample(); endfunction
    function void write_c1(ch_txn t); q_data = t.data; cg_ch.sample(); endfunction
    function void write_c2(ch_txn t); q_data = t.data; cg_ch.sample(); endfunction
    function void write_hb(hbus_txn t);
      q_wr = t.wr; q_haddr = t.addr;
      cg_hbus.sample();
    endfunction
  endclass

  // ---------- yapp driver (negedge domain: same view as RTL sampling) ----------
  class yapp_drv extends uvm_driver #(yapp_txn);
    `uvm_component_utils(yapp_drv)
    virtual yapp_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual yapp_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "yapp vif not configured")
    endfunction
    task run_phase(uvm_phase phase);
      yapp_txn t;
      vif.in_data <= 8'h00;
      vif.in_data_vld <= 1'b0;
      wait (vif.reset === 1'b0);
      forever begin
        seq_item_port.get_next_item(t);
        drive_pkt(t);
        seq_item_port.item_done();
      end
    endtask
    // For each byte: wait for a negedge with in_suspend==0 before driving the byte (the NBA occurs after this negedge,
    // and is sampled exactly at the next negedge → each byte is evaluated exactly once, with no loss/duplication)
    task put_byte(bit [7:0] b);
      forever begin
        @(negedge vif.clk);
        if (vif.in_suspend === 1'b0) break;
      end
      vif.in_data <= b;
      vif.in_data_vld <= 1'b1;
    endtask
    task drive_pkt(yapp_txn t);
      bit [7:0] par;
      put_byte({t.length, t.addr});
      par = {t.length, t.addr};
      foreach (t.payload[i]) begin
        put_byte(t.payload[i]);
        par ^= t.payload[i];
      end
      if (t.bad_parity) par ^= 8'hFF;
      put_byte(par);
      // Wait for the negedge at which the parity byte is accepted, then deassert vld and zero in_data
      // (RTL compares parity!=in_data(0) on the first cycle with vld=0 → error semantics = nonzero XOR of the entire packet)
      forever begin
        @(negedge vif.clk);
        if (vif.in_suspend === 1'b0) break;
      end
      vif.in_data <= 8'h00;
      vif.in_data_vld <= 1'b0;
      if (t.gap > 0) repeat (t.gap) @(negedge vif.clk);
    endtask
  endclass

  // ---------- yapp monitor (including a mirror of RTL parity/pkt_start quirks) ----------
  class yapp_mon extends uvm_monitor;
    `uvm_component_utils(yapp_mon)
    virtual yapp_if vif;
    uvm_analysis_port #(yapp_txn) ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual yapp_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "yapp vif not configured")
    endfunction
    task run_phase(uvm_phase phase);
      bit [7:0] byte_q[$], parity_acc;
      bit done_pending = 0;
      // last_pkt mirror (replicate the fsm_core parity_calc block + host_ctl sampled writes cycle by cycle):
      // For each byte, first write mem using the old (pst,paddr,pdata), then update state according to this cycle's acceptance/suspend/idle
      bit pst = 0;                 // pkt_start_int
      bit [6:0] paddr = 0;         // pkt_addr_int
      bit [7:0] pdata = 0;         // pkt_data_int
      bit [5:0] lsize = 0;         // last_pkt_size_int
      int idle = 0, last_size_m = 0;
      bit [7:0] mem_m [0:64];
      susp_e susp_f = S_NONE;
      yapp_txn t;
      for (int k = 0; k <= 64; k++) mem_m[k] = 8'h00;
      forever begin
        @(negedge vif.clk);
        if (pst) mem_m[paddr] = pdata;   // host_ctl: when pkt_start, mem[pkt_addr]<=pkt_data
        if (vif.reset === 1'b1) begin    // F06: reset flushes the mirror (including reset_mem)
          byte_q.delete(); parity_acc = 0; done_pending = 0;
          pst = 0; paddr = 0; pdata = 0; lsize = 0; idle = 0;
          for (int k = 0; k <= 64; k++) mem_m[k] = 8'h00;
          last_size_m = 0; susp_f = S_NONE;
          continue;
        end
        if (done_pending) begin
          t = yapp_txn::type_id::create("m");
          t.bytes = byte_q; t.parity_acc = parity_acc;
          t.err_seen = vif.error;        // Check result from the previous negedge (sampled before clearing)
          t.susp = susp_f; t.last_size_m = last_size_m;
          t.mem_m = mem_m;
          ap.write(t);
          byte_q.delete(); parity_acc = 0;
          done_pending = 0; susp_f = S_NONE;
        end
        else if (vif.in_data_vld === 1'b1) begin
          idle = 0;
          if (vif.in_suspend === 1'b1) begin
            // Measured RTL parity_calc has no (vld=1&&sus=1) branch: on suspend cycles,
            // parity/pkt_start/pkt_addr/pkt_data all hold → the mirror only marks the suspend position
            susp_f = (byte_q.size() == 0) ? S_HDR : S_MID;
          end
          else begin
            byte_q.push_back(vif.in_data);
            parity_acc ^= vif.in_data;
            if (!pst) begin
              pst = 1; paddr = 0;
              lsize = vif.in_data[7:2];
              last_size_m = vif.in_data[7:2];
            end
            else if (paddr < lsize + 1) paddr++;
            pdata = vif.in_data;
          end
        end
        else begin  // vld==0
          if (byte_q.size() > 0) begin
            done_pending = 1;
            // DATA_LOAD error cycle: pkt_data <= in_data(=0), written to mem on the next cycle
            if (parity_acc != 8'h00) pdata = 8'h00;
          end
          idle++;
          if (idle >= 2) pst = 0;   // comb clears pkt_start after the FSM returns to HEADER_WAIT
        end
      end
    endtask
  endclass

  // ---------- channel monitor (negedge: same criterion as FIFO pop) ----------
  class ch_mon extends uvm_monitor;
    `uvm_component_utils(ch_mon)
    virtual channel_if vif;
    uvm_analysis_port #(ch_txn) ap;
    int n_bytes = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual channel_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "channel vif not configured")
    endfunction
    task run_phase(uvm_phase phase);
      ch_txn t;
      wait (vif.rst === 1'b0);
      forever begin
        @(negedge vif.clk);
        if (vif.data_vld === 1'b1 && vif.suspend === 1'b0) begin
          t = ch_txn::type_id::create("c");
          t.data = vif.data;
          n_bytes++;
          ap.write(t);
        end
      end
    endtask
  endclass

  // ---------- hbus driver (negedge single-cycle operations) ----------
  class hbus_drv extends uvm_driver;
    `uvm_component_utils(hbus_drv)
    virtual hbus_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual hbus_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "hbus vif not configured")
    endfunction
    task run_phase(uvm_phase phase);
      vif.hen <= 1'b0; vif.hdrive <= 1'b0; vif.hwr_rd <= 1'b0; vif.haddr <= '0;
      wait (vif.clk === 1'b0);   // Align just before a negedge
      forever @(negedge vif.clk);
    endtask
    task op(bit wr, bit [15:0] a, bit [7:0] d, output bit [7:0] rd);
      @(negedge vif.clk);
      vif.haddr <= a; vif.hwr_rd <= wr; vif.hen <= 1'b1;
      if (wr) begin vif.hdrive <= 1'b1; vif.hdata_w <= d; end
      else vif.hdrive <= 1'b0;
      @(negedge vif.clk);              // Complete decode at this negedge
      vif.hen <= 1'b0; vif.hdrive <= 1'b0;
      if (!wr) begin
        @(posedge vif.clk);            // Sample before Z is driven at the next negedge
        rd = vif.hdata;
        @(negedge vif.clk);            // Spacing between operations (int_data returns to Z)
      end
      else
        @(negedge vif.clk);
    endtask
  endclass

  // ---------- hbus monitor ----------
  class hbus_mon extends uvm_monitor;
    `uvm_component_utils(hbus_mon)
    virtual hbus_if vif;
    uvm_analysis_port #(hbus_txn) ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual hbus_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "hbus vif not configured")
    endfunction
    task run_phase(uvm_phase phase);
      hbus_txn t;
      forever begin
        @(negedge vif.clk);
        if (vif.hen === 1'b1) begin
          t = hbus_txn::type_id::create("h");
          t.wr = vif.hwr_rd; t.addr = vif.haddr;
          if (t.wr) begin
            t.wdata = vif.hdata;
            ap.write(t);
          end
          else begin
            @(posedge vif.clk);
            t.rdata = vif.hdata;
            ap.write(t);
          end
        end
      end
    endtask
  endclass

  // ---------- scoreboard ----------
  class router_sb extends uvm_scoreboard;
    `uvm_component_utils(router_sb)
    uvm_analysis_imp    #(yapp_txn, router_sb) imp;
    uvm_analysis_imp_c0 #(ch_txn,   router_sb) imp_c0;
    uvm_analysis_imp_c1 #(ch_txn,   router_sb) imp_c1;
    uvm_analysis_imp_c2 #(ch_txn,   router_sb) imp_c2;
    uvm_analysis_imp_hb #(hbus_txn, router_sb) imp_hb;
    bit [7:0] exp_q0[$], exp_q1[$], exp_q2[$];
    // ch observation buffer: RTL output flows out while the packet is being driven, but exp is enqueued only at the end-of-packet txn (reversed timing),
    // reconcile upon arrival in either queue (when draining a full FIFO, exp instead precedes got, so both directions must trigger)
    bit [7:0] got_q0[$], got_q1[$], got_q2[$];
    // Register/counter mirrors
    bit a0_en, a1_en, a2_en, ill_en, len_en, par_en, router_en;
    bit [2:0] ien_m;
    bit [5:0] max_m;
    int par_cnt, len_cnt, ill_cnt, addr_cnt[3];
    bit [2:0] int_exp;
    bit [4:0] rst_val_m;
    int last_size_sb;
    bit [7:0] mem_sb [0:64];       // last_pkt_mem mirror (faithful residual semantics)
    bit [7:0] rw_mem[bit [7:0]];
    int n_pkt = 0, n_chk = 0, n_hb = 0, n_err = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      imp = new("imp", this); imp_c0 = new("imp_c0", this);
      imp_c1 = new("imp_c1", this); imp_c2 = new("imp_c2", this);
      imp_hb = new("imp_hb", this);
      reset_model();
    endfunction
    function void reset_model();
      exp_q0.delete(); exp_q1.delete(); exp_q2.delete();
      got_q0.delete(); got_q1.delete(); got_q2.delete();
      router_en = 1; par_en = 0; len_en = 0; ill_en = 0;
      a0_en = 0; a1_en = 0; a2_en = 0;
      ien_m = 3'b000; max_m = 6'h3F;
      par_cnt = 0; len_cnt = 0; ill_cnt = 0;
      addr_cnt = '{0, 0, 0};
      int_exp = 3'b000; rst_val_m = 5'b00000;
      last_size_sb = 0;
      for (int k = 0; k <= 64; k++) mem_sb[k] = 8'h00;
    endfunction
    function void write(yapp_txn t);
      bit [7:0] h; bit [1:0] a; bit [5:0] l; pkt_kind_e k;
      if (t.bytes.size() == 0) return;
      n_pkt++;
      h = t.bytes[0]; a = h[1:0]; l = h[7:2];
      if (a == 2'd3) k = K_ILL;
      else if (l == 0) k = K_LEN0;
      else if (l > max_m) k = K_GTMAX;
      else k = K_GOOD;
      if (k == K_GOOD) begin
        foreach (t.bytes[i]) begin
          case (a)
            2'd0: exp_q0.push_back(t.bytes[i]);
            2'd1: exp_q1.push_back(t.bytes[i]);
            default: exp_q2.push_back(t.bytes[i]);
          endcase
        end
        if (a == 0 && a0_en) addr_cnt[0]++;
        if (a == 1 && a1_en) addr_cnt[1]++;
        if (a == 2 && a2_en) addr_cnt[2]++;
        if (t.parity_acc != 8'h00) begin
          if (par_en) par_cnt++;
          if (ien_m[0]) int_exp[0] = 1;
          if (t.err_seen !== 1'b1) begin
            n_err++; `uvm_error("SB", $sformatf("Packet with bad parity did not report error (par_acc=%02x)", t.parity_acc))
          end
        end
        else if (t.err_seen !== 1'b0) begin
          n_err++; `uvm_error("SB", "Packet with good parity falsely reported error")
        end
      end
      else begin
        if (t.err_seen !== 1'b0) begin
          n_err++; `uvm_error("SB", "Dropped packet should not report error")
        end
        if (k == K_ILL) begin
          if (ill_en) begin
            ill_cnt++;
            if (ien_m[2]) int_exp[2] = 1;
          end
        end
        else begin  // K_LEN0 / K_GTMAX
          if (len_en) begin
            len_cnt++;
            if (ien_m[1]) int_exp[1] = 1;
          end
        end
      end
      last_size_sb = t.last_size_m;
      mem_sb = t.mem_m;
      match_q(0, exp_q0, got_q0);   // Compare upon arrival on the exp side (got may already have the entire packet ready)
      match_q(1, exp_q1, got_q1);
      match_q(2, exp_q2, got_q2);
    endfunction
    // Bidirectional comparison: arrival on either exp/got side triggers byte-by-byte comparison at the queue heads; report actual mismatches byte by byte
    function void match_q(int ch, ref bit [7:0] eq[$], ref bit [7:0] gq[$]);
      bit [7:0] e, g;
      while (eq.size() > 0 && gq.size() > 0) begin
        e = eq.pop_front(); g = gq.pop_front();
        if (e !== g) begin
          n_err++; `uvm_error("SB", $sformatf("ch%0d mismatch exp=%02x got=%02x", ch, e, g))
        end
        else n_chk++;
      end
    endfunction
    function void write_c0(ch_txn t);
      got_q0.push_back(t.data); match_q(0, exp_q0, got_q0);
    endfunction
    function void write_c1(ch_txn t);
      got_q1.push_back(t.data); match_q(1, exp_q1, got_q1);
    endfunction
    function void write_c2(ch_txn t);
      got_q2.push_back(t.data); match_q(2, exp_q2, got_q2);
    endfunction
    function void write_hb(hbus_txn t);
      bit [7:0] e;
      n_hb++;
      if (t.wr) begin
        case (t.addr)
          HA_CTRL: max_m = t.wdata[5:0];
          HA_EN: begin
            ill_en = t.wdata[7]; a2_en = t.wdata[6]; a1_en = t.wdata[5];
            a0_en = t.wdata[4]; len_en = t.wdata[2]; par_en = t.wdata[1];
            router_en = t.wdata[0];
          end
          HA_IEN: ien_m = t.wdata[2:0];
          HA_INT: begin   // W1C: requires ien+stat to be active simultaneously
            if (ien_m[0] && t.wdata[0] && int_exp[0]) int_exp[0] = 0;
            if (ien_m[1] && t.wdata[1] && int_exp[1]) int_exp[1] = 0;
            if (ien_m[2] && t.wdata[2] && int_exp[2]) int_exp[2] = 0;
          end
          HA_RST: begin   // Bit ordering mirrors RTL: {ram,ien_stat,addr_cnts,err_cnts,yapp}
            rst_val_m = t.wdata[4:0];
            if (t.wdata[0]) begin           // rst_yapp: full reset (registers return to defaults + FIFO cleared)
              reset_model();
            end
            if (t.wdata[1]) begin           // rst_err_cnts
              par_cnt = 0; len_cnt = 0; ill_cnt = 0;
            end
            if (t.wdata[2]) addr_cnt = '{0, 0, 0};  // rst_addr_cnts
            if (t.wdata[3]) begin           // rst_ien_stat: clear status and enable together
              int_exp = 0; ien_m = 3'b000;
            end
            if (t.wdata[4]) begin           // rst_ram: only last_pkt_mem (LSZ retained)
              for (int k = 0; k <= 64; k++) mem_sb[k] = 8'h00;
            end
          end
          default: if (t.addr inside {[HA_RW:HA_RW + 16'h00FF]})
                     rw_mem[t.addr[7:0]] = t.wdata;
        endcase
      end
      else begin
        e = exp_read(t.addr);
        if (e === 8'bz) begin
          if (t.rdata !== 8'bz) begin
            n_err++; `uvm_error("SB", $sformatf("hbus read %04x should be Z, got %02x", t.addr, t.rdata))
          end
        end
        else if (t.rdata !== e) begin
          n_err++; `uvm_error("SB", $sformatf("hbus read %04x mismatch exp=%02x got=%02x", t.addr, e, t.rdata))
        end
      end
    endfunction
    function bit [7:0] exp_read(bit [15:0] a);
      int idx;
      bit [7:0] r;
      case (a)
        HA_CTRL: return {2'b00, max_m};
        HA_EN:   return {ill_en, a2_en, a1_en, a0_en, 1'b0, len_en, par_en, router_en};
        HA_IEN:  return {5'b0, ien_m};
        HA_INT:  return {5'b0, int_exp};
        HA_PCNT: begin r = par_cnt; return r; end
        HA_LCNT: begin r = len_cnt; return r; end
        HA_ICNT: begin r = ill_cnt; return r; end
        HA_A0:   begin r = addr_cnt[0]; return r; end
        HA_A1:   begin r = addr_cnt[1]; return r; end
        HA_A2:   begin r = addr_cnt[2]; return r; end
        HA_RST:  return {3'b0, rst_val_m};
        HA_LSZ:  begin r = last_size_sb; return r; end
        default: begin
          if (a inside {[HA_MEM:HA_MEM + 16'h0040]}) begin
            idx = a - HA_MEM;
            return mem_sb[idx];
          end
          if (a inside {[HA_RW:HA_RW + 16'h00FF]}) begin
            if (rw_mem.exists(a[7:0])) return rw_mem[a[7:0]];
            else return 8'h00;
          end
          return 8'bz;   // Out-of-range/unmapped
        end
      endcase
    endfunction
    function void report_phase(uvm_phase phase);
      bit residue;
      super.report_phase(phase);
      residue = (exp_q0.size() + exp_q1.size() + exp_q2.size() != 0) ||
                (got_q0.size() + got_q1.size() + got_q2.size() != 0);
      if (residue)
        `uvm_error("SB", $sformatf("Model residuals exp ch0=%0d ch1=%0d ch2=%0d got ch0=%0d ch1=%0d ch2=%0d",
                   exp_q0.size(), exp_q1.size(), exp_q2.size(),
                   got_q0.size(), got_q1.size(), got_q2.size()))
      `uvm_info("SB", $sformatf("pkt=%0d byte comparisons=%0d hbus=%0d err=%0d",
                n_pkt, n_chk, n_hb, n_err), UVM_LOW)
      // Acceptance is determined by the simv exit code: any mismatch causes a nonzero exit
      if (n_err == 0 && !residue && uvm_report_server::get_server().get_severity_count(UVM_ERROR)==0)
        `uvm_info("DVBench_COMPLETED", "DVBench_COMPLETED", UVM_NONE)
    endfunction
  endclass

  // ---------- agents / env ----------
  class yapp_agent extends uvm_agent;
    `uvm_component_utils(yapp_agent)
    yapp_drv drv;
    yapp_mon mon;
    uvm_sequencer #(yapp_txn) sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = yapp_drv::type_id::create("drv", this);
      mon = yapp_mon::type_id::create("mon", this);
      sqr = uvm_sequencer#(yapp_txn)::type_id::create("sqr", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class ch_agent extends uvm_agent;
    `uvm_component_utils(ch_agent)
    ch_mon mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      mon = ch_mon::type_id::create("mon", this);
    endfunction
  endclass

  class hbus_agent extends uvm_agent;
    `uvm_component_utils(hbus_agent)
    hbus_drv drv;
    hbus_mon mon;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = hbus_drv::type_id::create("drv", this);
      mon = hbus_mon::type_id::create("mon", this);
    endfunction
  endclass

  class router_env extends uvm_env;
    `uvm_component_utils(router_env)
    yapp_agent ya;
    ch_agent   ca0, ca1, ca2;
    hbus_agent hb;
    router_sb  sb;
    router_cov cov;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      ya  = yapp_agent::type_id::create("ya", this);
      ca0 = ch_agent::type_id::create("ca0", this);
      ca1 = ch_agent::type_id::create("ca1", this);
      ca2 = ch_agent::type_id::create("ca2", this);
      hb  = hbus_agent::type_id::create("hb", this);
      sb  = router_sb::type_id::create("sb", this);
      cov = router_cov::type_id::create("cov", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      ya.mon.ap.connect(sb.imp);
      ya.mon.ap.connect(cov.imp);
      ca0.mon.ap.connect(sb.imp_c0); ca0.mon.ap.connect(cov.imp_c0);
      ca1.mon.ap.connect(sb.imp_c1); ca1.mon.ap.connect(cov.imp_c1);
      ca2.mon.ap.connect(sb.imp_c2); ca2.mon.ap.connect(cov.imp_c2);
      hb.mon.ap.connect(sb.imp_hb);  hb.mon.ap.connect(cov.imp_hb);
    endfunction
  endclass

  // ---------- sequences (each feature ≥1) ----------
  class seq_base extends uvm_sequence #(yapp_txn);
    `uvm_object_utils(seq_base)
    function new(string name = "seq_base"); super.new(name); endfunction
    task pkt(bit [1:0] a, int len, int gap = 1, bit bp = 0, bit edge_bytes = 0);
      yapp_txn t = yapp_txn::type_id::create("t");
      int i;
      start_item(t);
      t.addr = a; t.length = len[5:0]; t.gap = gap; t.bad_parity = bp;
      t.payload = new[len];
      for (i = 0; i < len; i++) begin
        if (edge_bytes && i == 0) t.payload[i] = 8'h00;
        else if (edge_bytes && i == 1) t.payload[i] = 8'hFF;
        else t.payload[i] = $urandom();
      end
      finish_item(t);
    endtask
  endclass

  class s_f12_basic extends seq_base;   // F01 handshake/gap + F02 data/boundary values
    `uvm_object_utils(s_f12_basic)
    function new(string n = "s_f12_basic"); super.new(n); endfunction
    task body();
      pkt(0, 2, 1, 0, 1);   // 0x00/0xFF boundary values
      pkt(0, 6, 1);         // Back-to-back on the same channel → suspend while waiting at the header
      pkt(1, 1, 1);
      pkt(2, 2, 1);
      pkt(1, 8, 1);
      pkt(2, 12, 2);
      pkt(0, 63, 2);        // Maximum length
      pkt(1, 3, 2);
    endtask
  endclass

  class s_one extends seq_base;         // Single packet (fields specified externally)
    `uvm_object_utils(s_one)
    bit [1:0] a;
    int len;
    function new(string n = "s_one"); super.new(n); endfunction
    task body(); pkt(a, len, 2); endtask
  endclass

  class s_f3_err extends seq_base;      // F03 bad frame/bad parity + F09 drop
    `uvm_object_utils(s_f3_err)
    function new(string n = "s_f3_err"); super.new(n); endfunction
    task body();
      pkt(3, 4, 1);         // Illegal address
      pkt(3, 0, 1);         // Illegal address takes priority over length
      pkt(0, 0, 1);         // Zero length
      pkt(1, 5, 1, 1);      // Bad parity
      pkt(2, 4, 1, 1);
      pkt(0, 1, 2, 1);
      // Complete c_len_par: len0/lbig/l63 × bad parity (RTL checks parity only in DATA_LOAD → len0 is DUMP and does not report error)
      pkt(0, 0, 1, 1);      // l0 × bad parity (K_LEN0 path)
      pkt(1, 12, 1, 1);     // lbig × bad checksum
      pkt(0, 63, 1, 1);     // l63 × bad checksum
    endtask
  endclass

  class s_f8_len extends seq_base;      // F08 max_pkt_len boundary
    `uvm_object_utils(s_f8_len)
    function new(string n = "s_f8_len"); super.new(n); endfunction
    task body();
      pkt(2, 12, 1);        // > max(8) → drop
      pkt(2, 9, 1);
      pkt(1, 8, 1);         // == max, the only legal case
      pkt(1, 9, 2);         // still > max → drop (63 is restored only after the sequence ends)
    endtask
  endclass

  class s_f4_flow extends seq_base;     // F04 transmission under backpressure
    `uvm_object_utils(s_f4_flow)
    function new(string n = "s_f4_flow"); super.new(n); endfunction
    task body();
      pkt(1, 16, 2);        // fill FIFO → stall midway (RTL quirk absorbed by the mirror)
    endtask
  endclass

  class s_f67 extends seq_base;         // F06 before and after reset
    `uvm_object_utils(s_f67)
    function new(string n = "s_f67"); super.new(n); endfunction
    task body();
      pkt(2, 10, 2);        // before reset: retained in FIFO and cleared
      pkt(2, 5, 2);         // after reset: clean path
    endtask
  endclass

  class s_f5_fast extends seq_base;     // F05 under a variable-frequency clock
    `uvm_object_utils(s_f5_fast)
    function new(string n = "s_f5_fast"); super.new(n); endfunction
    task body();
      pkt(0, 4, 2);
      pkt(1, 4, 2);
    endtask
  endclass

  class s_enoff extends seq_base;       // F09 counting-disabled context
    `uvm_object_utils(s_enoff)
    function new(string n = "s_enoff"); super.new(n); endfunction
    task body();
      pkt(0, 2, 2);
    endtask
  endclass

  class s_cov_cnt extends seq_base;    // F07 counter high-bit coverage (drive each counter to ≥8)
    `uvm_object_utils(s_cov_cnt)
    function new(string n = "s_cov_cnt"); super.new(n); endfunction
    task body();
      repeat (8) pkt(3, 1, 1);          // ill → ICNT=8
      repeat (8) pkt(0, 0, 1);          // len0 → LCNT=8
      repeat (8) pkt(1, 1, 1, 1);       // bad checksum → PCNT=8
      repeat (7) pkt(0, 1, 1);          // A0 +7
      repeat (6) pkt(2, 1, 1);          // A2 +6
    endtask
  endclass

  class s_final extends seq_base;
    `uvm_object_utils(s_final)
    function new(string n = "s_final"); super.new(n); endfunction
    task body();
      pkt(1, 3, 2);
    endtask
  endclass

  // ---------- tests ----------
  class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    router_env env;
    virtual yapp_if vif;
    virtual channel_if cv0, cv1, cv2;
    virtual hbus_if hif;
    bit [7:0] rd;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = router_env::type_id::create("env", this);
      uvm_config_db#(virtual yapp_if)::get(this, "", "in_vif", vif);
      uvm_config_db#(virtual channel_if)::get(this, "", "ch_vif_0", cv0);
      uvm_config_db#(virtual channel_if)::get(this, "", "ch_vif_1", cv1);
      uvm_config_db#(virtual channel_if)::get(this, "", "ch_vif_2", cv2);
      uvm_config_db#(virtual hbus_if)::get(this, "", "hb_vif", hif);
      uvm_config_db#(virtual yapp_if)::set(this, "env.ya*", "vif", vif);
      uvm_config_db#(virtual channel_if)::set(this, "env.ca0*", "vif", cv0);
      uvm_config_db#(virtual channel_if)::set(this, "env.ca1*", "vif", cv1);
      uvm_config_db#(virtual channel_if)::set(this, "env.ca2*", "vif", cv2);
      uvm_config_db#(virtual hbus_if)::set(this, "env.hb*", "vif", hif);
    endfunction
    task hb_wr(bit [15:0] a, bit [7:0] d); env.hb.drv.op(1, a, d, rd); endtask
    task hb_rd(bit [15:0] a); env.hb.drv.op(0, a, 8'h00, rd); endtask
    task run_seq(seq_base s); s.start(env.ya.sqr); endtask
    task pkt_in(bit [1:0] a, int len);
      s_one s = s_one::type_id::create("one");
      s.a = a; s.len = len;
      s.start(env.ya.sqr);
    endtask
    // Backpressure section (V5 c_susp_mode directed): stall→FIFO full→S_MID; send header while draining after release→S_HDR
    task susp_ep(int ch, bit [1:0] a, int len);
      case (ch)
        0: cv0.cb.suspend <= 1'b1;
        1: cv1.cb.suspend <= 1'b1;
        default: cv2.cb.suspend <= 1'b1;
      endcase
      fork
        pkt_in(a, len);
        begin
          repeat (28) @(negedge vif.clk);
          case (ch)
            0: cv0.cb.suspend <= 1'b0;
            1: cv1.cb.suspend <= 1'b0;
            default: cv2.cb.suspend <= 1'b0;
          endcase
        end
      join
      pkt_in(a, 1);                     // header-wait stall → S_HDR
      repeat (34) @(negedge vif.clk);   // drain
    endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wait (vif.reset === 1'b0);
      repeat (3) @(negedge vif.clk);
      fork
        begin body();repeat(60) @(negedge vif.clk);end
        begin
          uvm_report_server server=uvm_report_server::get_server();
          while(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
            @(negedge vif.clk);
          repeat(3) @(negedge vif.clk);
        end
      join_any
      disable fork;   // drain
      phase.drop_objection(this);
    endtask
    virtual task body(); endtask
  endclass

  class t_smoke extends test_base;
    `uvm_component_utils(t_smoke)
    function new(string n = "t_smoke", uvm_component p = null); super.new(n, p); endfunction
    task body();
      env.cov.cur_mode = M_NORM;
      hb_wr(HA_EN, 8'hF7);
      run_seq(s_f12_basic::type_id::create("sm"));
    endtask
  endclass

  // Comprehensive test: all feature sections in sequence (default entry point)
  class dvbench_test extends test_base;
    `uvm_component_utils(dvbench_test)
    function new(string n = "dvbench_test", uvm_component p = null); super.new(n, p); endfunction
    task body();
      // F07/F08 configuration: all counters + interrupts enabled
      hb_wr(HA_EN, 8'hF7);
      cv0.cb.suspend <= 1'b1;
      repeat (12) @(negedge vif.clk);
      pkt_in(1, 4);
      pkt_in(2, 5);
      repeat (12) @(negedge vif.clk);
      cv0.cb.suspend <= 1'b0;
      repeat (40) @(negedge vif.clk);

      hb_wr(HA_IEN, 8'h07);
      hb_rd(HA_CTRL);                       // default max=63
      hb_wr(HA_RW, 8'h00); hb_wr(HA_RW + 16'h00FF, 8'hFF);
      hb_rd(HA_RW); hb_rd(HA_RW + 16'h00FF); // RW memory
      // F01/F02 basic packets
      env.cov.cur_mode = M_NORM;
      run_seq(s_f12_basic::type_id::create("b1"));
      // F03/F09 bad packets
      run_seq(s_f3_err::type_id::create("e1"));
      // F07 read all registers + interrupt W1C
      hb_rd(HA_CTRL); hb_rd(HA_EN); hb_rd(HA_IEN); hb_rd(HA_INT);
      hb_rd(HA_PCNT); hb_rd(HA_LCNT); hb_rd(HA_ICNT);
      hb_rd(HA_A0); hb_rd(HA_A1); hb_rd(HA_A2); hb_rd(HA_RST);
      hb_rd(16'h1007); hb_rd(16'h1008); hb_rd(16'h100e);   // unmapped within range (including YPARITY_RCVD_OFF) → Z
      hb_rd(16'h0000); hb_rd(16'h3000);                    // out of bounds → Z
      hb_wr(HA_INT, 8'h02);                 // W1C single-bit clear (bit0 retained) → data=0 arc
      hb_rd(HA_INT);                        // read back 0x05 (bit0/2 still pending)
      hb_wr(HA_INT, 8'h07);                 // W1C clear all
      hb_rd(HA_INT);
      hb_wr(HA_MEM, 8'h5A);                 // writes to RO registers ignored → write without default arc
      hb_rd(16'h1200); hb_rd(16'h1400); hb_rd(16'h1800);  // addr[11:9] toggles (ZZ)
      hb_rd(16'h4000); hb_rd(16'hC000);     // addr[15:14] toggles (ZZ)
      // F08 max_pkt_len small-value variant
      hb_wr(HA_CTRL, 8'd8);
      run_seq(s_f8_len::type_id::create("l1"));
      hb_rd(HA_LCNT);
      hb_wr(HA_CTRL, 8'd63);
      hb_wr(HA_CTRL, 8'd4);                // max_pkt_size[3]→0 toggle
      hb_wr(HA_CTRL, 8'd63);
      // F04 channel backpressure → FIFO full → in_suspend → recovery
      env.cov.cur_mode = M_BACKP;
      cv1.cb.suspend <= 1'b1;
      fork
        run_seq(s_f4_flow::type_id::create("fl"));
        begin
          repeat (25) @(negedge vif.clk);
          cv1.cb.suspend <= 1'b0;
        end
      join
      repeat (30) @(negedge vif.clk);
      hb_rd(HA_LSZ); hb_rd(HA_MEM); hb_rd(HA_MEM + 16'h1);  // last_pkt snapshot
      // F04-ext ch0 backpressure: write-full/hold branches + send header immediately after release → S_HDR stall
      cv0.cb.suspend <= 1'b1;
      fork
        pkt_in(0, 18);
        begin
          repeat (28) @(negedge vif.clk);
          cv0.cb.suspend <= 1'b0;
        end
      join
      pkt_in(0, 1);                         // send header while FIFO is draining → header-wait stall
      repeat (34) @(negedge vif.clk);       // drain
      // F04-ext ch2 backpressure: queue_2 full branch
      cv2.cb.suspend <= 1'b1;
      fork
        pkt_in(2, 18);
        begin
          repeat (28) @(negedge vif.clk);
          cv2.cb.suspend <= 1'b0;
        end
      join
      repeat (34) @(negedge vif.clk);       // drain
      pkt_in(3, 1);                         // c_mode_addr: BACKP × illegal address
      // F06 reset: hard reset while a packet is retained in FIFO
      env.cov.cur_mode = M_RESET;
      cv2.cb.suspend <= 1'b1;
      pkt_in(2, 10);
      env.sb.reset_model();
      vif.pulse_reset();
      cv2.cb.suspend <= 1'b0;
      repeat (10) @(negedge vif.clk);
      pkt_in(2, 5);
      hb_rd(HA_LSZ); hb_rd(HA_MEM); hb_rd(HA_A2); hb_rd(HA_PCNT);
      // c_susp_mode/c_mode_addr directed: stall in RESET context + RESET × each address
      susp_ep(2, 2, 18);
      pkt_in(0, 1);
      pkt_in(1, 1);
      pkt_in(3, 1);
      // F05 variable-frequency clock
      env.cov.cur_mode = M_FASTCLK;
      vif.set_half(3);
      run_seq(s_f5_fast::type_id::create("f1"));
      vif.set_half(5);
      pkt_in(2, 4);
      pkt_in(3, 1);                         // c_mode_addr: FASTCLK × illegal address
      susp_ep(1, 1, 18);                    // c_susp_mode：FASTCLK × S_MID/S_HDR
      // F09 counting-disabled context
      env.cov.cur_mode = M_ENOFF;
      hb_wr(HA_EN, 8'h00);
      run_seq(s_enoff::type_id::create("eo"));
      pkt_in(3, 2);                         // EN=0: router shutdown path (fsm 855 arc)
      pkt_in(1, 0);
      hb_wr(HA_EN, 8'h01);                  // only router_en: HEADER_WAIT enable arc
      pkt_in(0, 0);
      pkt_in(2, 1);                         // c_mode_addr：ENOFF × ch2
      susp_ep(0, 0, 18);                    // c_susp_mode：ENOFF × S_MID/S_HDR
      hb_wr(HA_EN, 8'hF7);
      // F07-ext drive counters to ≥8 (high-bit toggles: fsm counting int + host_ctl register)
      run_seq(s_cov_cnt::type_id::create("cc"));
      hb_rd(HA_PCNT); hb_rd(HA_LCNT); hb_rd(HA_ICNT);
      hb_rd(HA_A0); hb_rd(HA_A1); hb_rd(HA_A2);
      // F06 soft-reset register (all fields)
      hb_wr(HA_RST, 8'h1F);
      hb_wr(HA_RST, 8'h00);
      hb_wr(HA_EN, 8'hF7); hb_wr(HA_IEN, 8'h07);
      env.cov.cur_mode = M_NORM;
      run_seq(s_final::type_id::create("fi"));
      hb_rd(HA_A1); hb_rd(HA_RST); hb_rd(HA_LSZ);
      // F06-ext single-bit soft reset (fsm resets[4:1] independent branches and hold arcs)
      hb_wr(HA_RST, 8'h02);                 // rst_err_cnts held
      pkt_in(3, 1);                         // error packet during hold → en&&!resets[1] arc
      pkt_in(0, 0);
      hb_wr(HA_RST, 8'h02);                 // rewrite the same value: clear the mirror to zero again to align with RTL holding 0
      hb_wr(HA_RST, 8'h04);                 // rst_addr_cnts held
      pkt_in(0, 1);                         // good packets forwarded as usual, address count held
      pkt_in(1, 1);
      pkt_in(2, 1);
      hb_wr(HA_RST, 8'h04);                 // rewrite the same value for alignment
      hb_wr(HA_RST, 8'h08);                 // rst_ien_stat independent arc
      hb_wr(HA_RST, 8'h10);                 // rst_ram independent arc
      hb_wr(HA_RST, 8'h00);
      susp_ep(0, 0, 18);                    // c_susp_mode：NORM × S_MID/S_HDR
    endtask
  endclass

  // ---------- report server (do not print rows for severities with zero counts) ----------
  // UVM base class report_summarize also prints lines such as "UVM_ERROR : 0" for severities with a count of 0,
  // so the log of a clean run contains the words UVM_ERROR/UVM_FATAL; print only nonzero counts,
  // actual ERROR/FATAL message lines and nonzero summary lines are unaffected
  class yapp_rpt_srv extends uvm_default_report_server;
    function new(string name = "yapp_rpt_srv");
      super.new(name);
    endfunction
    virtual function void report_summarize(UVM_FILE file = 0);
      uvm_report_catcher::summarize();
      $display("\n--- UVM Report Summary ---\n");
      $display("** Report counts by severity (nonzero only)");
      if (get_severity_count(UVM_INFO)    != 0) $display("UVM_INFO :%5d",    get_severity_count(UVM_INFO));
      if (get_severity_count(UVM_WARNING) != 0) $display("UVM_WARNING :%5d", get_severity_count(UVM_WARNING));
      if (get_severity_count(UVM_ERROR)   != 0) $display("UVM_ERROR :%5d",   get_severity_count(UVM_ERROR));
      if (get_severity_count(UVM_FATAL)   != 0) $display("UVM_FATAL :%5d",   get_severity_count(UVM_FATAL));
    endfunction
  endclass

endpackage
