// logic_hash_pkg.sv — logic_hash UVM environment
// feature index: F01 handshake(valid idle cycles/back-to-back) F02 data(0/all ones/random) F03 frame classes(T1/T2/T3/single-beat/long frames)
//               F04 table lookup(hash hit/miss, serial number match/mismatch, unwritten fid) F05 output paths(ecdsa/t2 shift/t1to2 truncation/discard/lat)
//               F06 interleaving(T3 alternating with T12/T1, FSM in both directions) F07 reset F08 table rewrite/concurrent writes F09 coverage
`timescale 1ns/1ps
package logic_hash_pkg;
  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import meta_package::*;

  `uvm_analysis_imp_decl(_in)
  `uvm_analysis_imp_decl(_pp)
  `uvm_analysis_imp_decl(_ecd)
  `uvm_analysis_imp_decl(_hash)

  typedef enum {K_WR, K_FRM, K_IDLE} kind_e;
  typedef enum {F_T1, F_T2, F_T3, F_T1X3} ftype_e;
  typedef enum {P_RND, P_ZERO, P_ONES} pat_e;
  typedef enum {E_WR, E_FRM_IN, E_FRM_PP, E_FRM_ECD, E_HASH} ekind_e;
  typedef enum int {R_LAT=0, R_T2=1, R_T12=2, R_DISC=3, R_ECD=4} route_e;
  typedef enum int {HC_NA=0, HC_HIT=1, HC_MISS=2} hc_e;
  typedef enum int {SC_NA=0, SC_MATCH=1, SC_MISMATCH=2} sc_e;
  typedef struct { bit [127:0] data; bit sop; bit eop; } ob_t;

  // ---------------- Expected frame (internal to scoreboard) ----------------
  class exp_frm;
    int cls;                    // 0=lat 1=t2 2=t12 3=disc
    ob_t b[$];
    irl_lh_meta_type meta;
    function new(int c, irl_lh_meta_type m); cls = c; meta = m; endfunction
  endclass

  // ---------------- Event txn (monitor → scoreboard/cov) ----------------
  class lh_evt extends uvm_object;
    ekind_e kind;
    bit [11:0]  waddr;
    bit [255:0] wdata;
    bit [63:0]  sn;
    bit [5:0]   ppl;
    bit [255:0] hdata;
    irl_lh_meta_type    meta;     // Input-side frame meta (sampled on the sop beat)
    lh_pp_meta_type     pp_meta;
    lh_ecdsa_meta_type  ecd_meta;
    bit [127:0] data[$];
    bit         sop[$], eop[$];
    bit         trunc;
    int         gap;      // Number of idle cycles since the previous frame's eop (inter-frame gap)
    int         igap;     // Accumulated valid idle cycles within the frame (igap)
    `uvm_object_utils(lh_evt)
    function new(string n = "lh_evt"); super.new(n); endfunction
  endclass

  // ---------------- Stimulus txn (sequence → driver) ----------------
  class lh_txn extends uvm_sequence_item;
    rand kind_e       kind;
    rand ftype_e      ftype;
    rand int unsigned len;
    rand int unsigned gap;     // Idle cycles before the frame / K_IDLE duration
    rand int unsigned igap;    // valid idle cycles within the frame (F01)
    rand pat_e        pat;
    rand bit [11:0]   fid;
    rand bit [63:0]   serial;
    bit               ser_ov_en;
    bit [63:0]        serial_ov;
    // WR fields
    rand bit [11:0]  waddr;
    rand bit [255:0] wdata;
    rand bit [63:0]  wsn;
    rand bit [5:0]   wppl;
    // meta random fields
    rand bit [7:0]  m_tclass;
    rand bit [7:0]  m_hdr_len;
    rand bit [11:0] m_buf;
    rand bit [13:0] m_len;
    rand bit [2:0]  m_port;
    rand bit [11:0] m_rci;
    rand bit [9:0]  m_tid;
    rand bit        m_disc;

    constraint c_len  { len inside {[4:20]}; }
    constraint c_gap  { gap dist {0 := 6, 1 := 2, [2:5] := 2}; }
    constraint c_igap { igap dist {0 := 8, 1 := 1, 2 := 1}; }
    constraint c_fid  { fid inside {0, 1, 2, 3, 4, 5, 6, 7, 128, 4095}; }
    constraint c_ser  { serial[63] == 1'b1; }   // Random serial number ≠ table value (table value bit63=0)
    constraint c_disc { m_disc == 1'b0; }
    `uvm_object_utils(lh_txn)
    function new(string n = "lh_txn"); super.new(n); endfunction
  endclass

  // ---------------- coverage ----------------
  class lh_cov extends uvm_subscriber #(lh_evt);
    `uvm_component_utils(lh_cov)
    ftype_e   ft;
    int       len;
    int       fid;
    pat_e     pt;
    bit [7:0] tclass;
    bit [2:0] port;
    route_e   route;
    hc_e      hc;
    sc_e      sc;
    int       gap;
    int       igap;
    bit [255:0] htab[bit [11:0]];
    bit [63:0]  stab[bit [11:0]];
    covergroup cg_feat();
      option.per_instance = 1;
      cp_ft: coverpoint ft;                                        // F03/F04/F05
      cp_route: coverpoint route {                                 // F05 five output paths (V1/V4/V5)
        bins lat  = {R_LAT};
        bins t2   = {R_T2};
        bins t12  = {R_T12};
        bins disc = {R_DISC};
        bins ecd  = {R_ECD};
      }
      cp_len: coverpoint len {                                     // F03
        bins b1 = {1}; bins b2 = {2}; bins b4 = {[3:5]};
        bins b6 = {6}; bins mid = {[7:15]}; bins big = {[16:64]};
      }
      cp_fid: coverpoint fid {                                     // F04 grouped by written fid set/boundaries
        bins f0 = {0}; bins f_low = {[1:7]}; bins f_mid_lo = {[8:127]};
        bins f128 = {128}; bins f_mid_hi = {[129:4094]}; bins f_max = {4095};
      }
      cp_pat: coverpoint pt;                                       // F02
      cp_tc: coverpoint tclass {                                   // F04 meta boundaries (including all 1)
        bins z = {0}; bins lo = {[1:127]}; bins hi = {[128:254]}; bins f = {255};
      }
      cp_port: coverpoint port;
      cp_hc: coverpoint hc {                                       // V5 hash hit/mismatch
        ignore_bins na = {HC_NA};
        bins hit = {HC_HIT}; bins miss = {HC_MISS};
      }
      cp_sc: coverpoint sc {                                       // V4 serial number match/mismatch
        ignore_bins na = {SC_NA};
        bins match = {SC_MATCH}; bins mismatch = {SC_MISMATCH};
      }
      cp_gap: coverpoint gap {                                     // V10 inter-frame back-to-back/gap
        bins b2b = {[0:1]}; bins gapped = {[2:8]}; bins big = {[9:8191]};
      }
      cp_igap: coverpoint igap {                                   // V10 idle cycles within the frame
        bins none = {0}; bins some = {[1:64]};
      }
      x_ft_len: cross cp_ft, cp_len {
        ignore_bins t2_len1 = binsof(cp_ft) intersect {F_T2} && binsof(cp_len) intersect {1};
      }
      x_ft_pat: cross cp_ft, cp_pat;
      x_ft_route: cross cp_ft, cp_route {
        ignore_bins t3_lat_only =
          binsof(cp_ft) intersect {F_T3, F_T1X3} && binsof(cp_route) intersect {R_T2, R_T12, R_DISC, R_ECD};
        ignore_bins t2_route =
          binsof(cp_ft) intersect {F_T2} && binsof(cp_route) intersect {R_LAT, R_T12, R_ECD};
        ignore_bins t1_route =
          binsof(cp_ft) intersect {F_T1} && binsof(cp_route) intersect {R_LAT, R_T2};
      }
      x_ft_hc: cross cp_ft, cp_hc {
        ignore_bins t3_no_hash = binsof(cp_ft) intersect {F_T3, F_T1X3};
      }
      x_ft_sc: cross cp_ft, cp_sc {
        ignore_bins not_t1 = binsof(cp_ft) intersect {F_T2, F_T3, F_T1X3};
      }
      x_len_sc: cross cp_len, cp_sc {
        ignore_bins match_short = binsof(cp_len) intersect {1, 2, [3:5]} && binsof(cp_sc) intersect {SC_MATCH};
      }
    endgroup
    function new(string name, uvm_component parent);
      super.new(name, parent); cg_feat = new();
    endfunction
    function bit [255:0] get_h(bit [11:0] f); return htab.exists(f) ? htab[f] : 256'h0; endfunction
    function bit [63:0]  get_s(bit [11:0] f); return stab.exists(f) ? stab[f] : 64'h0; endfunction
    function void write(lh_evt t);
      if (t.kind == E_WR) begin
        htab[t.waddr] = t.wdata; stab[t.waddr] = t.sn;
        return;
      end
      if (t.kind != E_FRM_IN) return;
      ft = t.meta.type3 ? (t.meta.type1 ? F_T1X3 : F_T3)
                       : (t.meta.type1 ? F_T1 : F_T2);
      len = t.data.size();
      fid = t.meta.fid;
      tclass = t.meta.traffic_class;
      port = t.meta.port;
      gap = t.gap;
      igap = t.igap;
      pt = P_RND;
      if (t.data.size() > 1) begin
        if (t.data[1] == 128'h0) pt = P_ZERO;
        else if (t.data[1] == {128{1'b1}}) pt = P_ONES;
      end
      // Routing/table lookup results (mirror scoreboard decisions for coverage sampling)
      if (ft == F_T3 || ft == F_T1X3) begin
        route = R_LAT; hc = HC_NA; sc = SC_NA;
      end else if (get_h(fid) != 256'h0) begin
        route = R_DISC; hc = HC_MISS; sc = SC_NA;
      end else begin
        hc = HC_HIT;
        if (ft == F_T1) begin
          if (t.data[0][63:0] == get_s(fid)) begin
            route = R_T12; sc = SC_MATCH;
          end else begin
            route = R_ECD; sc = SC_MISMATCH;
          end
        end else begin
          route = R_T2; sc = SC_NA;
        end
      end
      cg_feat.sample();
    endfunction
  endclass

  // ---------------- monitor ----------------
  class lh_mon extends uvm_monitor;
    `uvm_component_utils(lh_mon)
    virtual logic_hash_if vif;
    string side;
    uvm_analysis_port #(lh_evt) ap;
    function new(string name, uvm_component parent);
      super.new(name, parent); ap = new("ap", this);
    endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual logic_hash_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    task run_phase(uvm_phase phase);
      lh_evt e = null, w;
      int gap_cnt = 0, igap_cnt = 0;
      forever begin
        @(vif.cb);
        case (side)
          "IN": begin
            // TB-driven signals are cb outputs; VCS does not allow sampling through cb, so read the original interface signals instead
            if (vif.rst_n == 1'b0) begin
              e = null; gap_cnt = 0; igap_cnt = 0;   // Reset discards partial frames and counts
            end else begin
              if (vif.ecdsa_lh_wr) begin
                w = lh_evt::type_id::create("w"); w.kind = E_WR;
                w.waddr = vif.ecdsa_lh_waddr; w.wdata = vif.ecdsa_lh_wdata;
                w.sn = vif.ecdsa_lh_sn_wdata; w.ppl = vif.ecdsa_lh_ppl_wdata;
                ap.write(w);
              end
              if (vif.irl_lh_valid) begin
                if (vif.irl_lh_sop) begin
                  e = lh_evt::type_id::create("e"); e.kind = E_FRM_IN;
                  e.meta = vif.irl_lh_meta_data;
                  e.gap = gap_cnt;
                  gap_cnt = 0;
                end
                if (e == null)
                  `uvm_error("MON", "beat without sop on the in side")
                else begin
                  e.data.push_back(vif.irl_lh_hdr_data);
                  e.sop.push_back(vif.irl_lh_sop);
                  e.eop.push_back(vif.irl_lh_eop);
                  if (vif.irl_lh_eop) begin
                    e.igap = igap_cnt;
                    igap_cnt = 0;
                    ap.write(e); e = null;
                  end
                end
              end else begin
                if (e != null) igap_cnt++;
                else gap_cnt++;
              end
            end
          end
          "PP": begin
            if (vif.cb.lh_pp_valid) begin
              if (vif.cb.lh_pp_sop) begin
                if (e != null) begin
                  e.trunc = 1; ap.write(e);
                  `uvm_error("MON", "previous frame on the pp side is missing eop (truncated)")
                end
                e = lh_evt::type_id::create("e"); e.kind = E_FRM_PP;
                e.pp_meta = vif.cb.lh_pp_meta_data;
              end
              if (e == null)
                `uvm_error("MON", "beat without sop on the pp side")
              else begin
                e.data.push_back(vif.cb.lh_pp_hdr_data);
                e.sop.push_back(vif.cb.lh_pp_sop);
                e.eop.push_back(vif.cb.lh_pp_eop);
                if (vif.cb.lh_pp_eop) begin ap.write(e); e = null; end
              end
            end
          end
          "ECD": begin
            if (vif.cb.lh_ecdsa_valid) begin
              if (vif.cb.lh_ecdsa_sop) begin
                if (e != null) begin
                  e.trunc = 1; ap.write(e);
                  `uvm_error("MON", "previous frame on the ecdsa side is missing eop (truncated)")
                end
                e = lh_evt::type_id::create("e"); e.kind = E_FRM_ECD;
                e.ecd_meta = vif.cb.lh_ecdsa_meta_data;
              end
              if (e == null)
                `uvm_error("MON", "beat without sop on the ecdsa side")
              else begin
                e.data.push_back(vif.cb.lh_ecdsa_hdr_data);
                e.sop.push_back(vif.cb.lh_ecdsa_sop);
                e.eop.push_back(vif.cb.lh_ecdsa_eop);
                if (vif.cb.lh_ecdsa_eop) begin ap.write(e); e = null; end
              end
            end
          end
          "HASH": if (vif.cb.lh_ecdsa_hash_valid) begin
            w = lh_evt::type_id::create("w"); w.kind = E_HASH;
            w.hdata = vif.cb.lh_ecdsa_hash_data;
            ap.write(w);
          end
        endcase
      end
    endtask
  endclass

  // ---------------- driver ----------------
  class lh_drv extends uvm_driver #(lh_txn);
    `uvm_component_utils(lh_drv)
    virtual logic_hash_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if (!uvm_config_db#(virtual logic_hash_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "vif is not configured")
    endfunction
    function irl_lh_meta_type mk_meta(lh_txn t);
      irl_lh_meta_type m;
      m.traffic_class = t.m_tclass; m.hdr_len = t.m_hdr_len;
      m.buf_ptr = t.m_buf; m.len = t.m_len; m.port = t.m_port;
      m.rci = t.m_rci; m.fid = t.fid; m.tid = t.m_tid;
      m.type1 = (t.ftype == F_T1) || (t.ftype == F_T1X3);
      m.type3 = (t.ftype == F_T3) || (t.ftype == F_T1X3);
      m.discard = t.m_disc;
      return m;
    endfunction
    function bit [127:0] beat_data(lh_txn t, int i, bit [63:0] ser);
      bit [63:0] up;
      case (t.pat)
        P_ZERO: up = 64'h0;
        P_ONES: up = 64'hFFFF_FFFF_FFFF_FFFF;
        default: up = {$urandom(), $urandom()};
      endcase
      if (i == 0) return {up, ser};
      if (t.pat == P_ZERO) return 128'h0;
      if (t.pat == P_ONES) return {128{1'b1}};
      return {$urandom(), $urandom(), $urandom(), $urandom()};
    endfunction
    task drive_idle(int n);
      repeat (n) begin
        vif.cb.irl_lh_valid <= 1'b0;
        vif.cb.ecdsa_lh_ready <= ($urandom_range(0, 3) != 0);   // Input ready toggling (tgl)
        @(vif.cb);
      end
      vif.cb.ecdsa_lh_ready <= 1'b1;
    endtask
    task drive_wr(lh_txn t);
      vif.cb.ecdsa_lh_wr <= 1'b1;
      vif.cb.ecdsa_lh_waddr <= t.waddr;
      vif.cb.ecdsa_lh_wdata <= t.wdata;
      vif.cb.ecdsa_lh_sn_wdata <= t.wsn;
      vif.cb.ecdsa_lh_ppl_wdata <= t.wppl;
      @(vif.cb);
      vif.cb.ecdsa_lh_wr <= 1'b0;
      @(vif.cb);
    endtask
    task drive_frm(lh_txn t);
      bit [63:0] ser = t.ser_ov_en ? t.serial_ov : t.serial;
      irl_lh_meta_type m = mk_meta(t);
      if (t.gap) drive_idle(t.gap);
      for (int i = 0; i < t.len; i++) begin
        if (i == t.len / 2 && t.igap) drive_idle(t.igap);
        vif.cb.irl_lh_valid <= 1'b1;
        vif.cb.irl_lh_hdr_data <= beat_data(t, i, ser);
        vif.cb.irl_lh_meta_data <= m;
        vif.cb.irl_lh_sop <= (i == 0);
        vif.cb.irl_lh_eop <= (i == t.len - 1);
        @(vif.cb);
      end
      vif.cb.irl_lh_valid <= 1'b0;
      vif.cb.irl_lh_sop <= 1'b0;
      vif.cb.irl_lh_eop <= 1'b0;
      @(vif.cb);
    endtask
    task run_phase(uvm_phase phase);
      lh_txn t;
      irl_lh_meta_type m0 = '{default:'0};
      vif.cb.irl_lh_valid <= 1'b0;
      vif.cb.irl_lh_sop <= 1'b0;
      vif.cb.irl_lh_eop <= 1'b0;
      vif.cb.irl_lh_hdr_data <= '0;
      vif.cb.irl_lh_meta_data <= m0;
      vif.cb.ecdsa_lh_wr <= 1'b0;
      vif.cb.ecdsa_lh_waddr <= '0;
      vif.cb.ecdsa_lh_wdata <= '0;
      vif.cb.ecdsa_lh_sn_wdata <= '0;
      vif.cb.ecdsa_lh_ppl_wdata <= '0;
      vif.cb.ecdsa_lh_ready <= 1'b1;
      forever begin
        seq_item_port.get_next_item(t);
        case (t.kind)
          K_IDLE: drive_idle(t.gap > 0 ? t.gap : 1);
          K_WR:   drive_wr(t);
          K_FRM:  drive_frm(t);
        endcase
        seq_item_port.item_done();
      end
    endtask
  endclass

  // ---------------- scoreboard ----------------
  class lh_sb extends uvm_scoreboard;
    `uvm_component_utils(lh_sb)
    uvm_analysis_imp_in   #(lh_evt, lh_sb) in_imp;
    uvm_analysis_imp_pp   #(lh_evt, lh_sb) pp_imp;
    uvm_analysis_imp_ecd  #(lh_evt, lh_sb) ecd_imp;
    uvm_analysis_imp_hash #(lh_evt, lh_sb) hash_imp;
    bit [255:0] htab[bit [11:0]];   // Default 0 (corresponding to RAM init clearing to zero)
    bit [63:0]  stab[bit [11:0]];
    exp_frm q_lat[$], q_t2[$], q_t12[$], q_disc[$], q_ecd[$];
    int n_exp_hash = 0;
    int n_in = 0, n_pp = 0, n_ecd = 0, n_hash = 0, n_chk = 0;
    function new(string name, uvm_component parent);
      super.new(name, parent);
      in_imp = new("in_imp", this); pp_imp = new("pp_imp", this);
      ecd_imp = new("ecd_imp", this); hash_imp = new("hash_imp", this);
    endfunction
    function bit [255:0] get_h(bit [11:0] f); return htab.exists(f) ? htab[f] : 256'h0; endfunction
    function bit [63:0]  get_s(bit [11:0] f); return stab.exists(f) ? stab[f] : 64'h0; endfunction
    function ob_t pf(bit [127:0] d, bit s, bit e);   // Pass-through beat
      pf.data = d; pf.sop = s; pf.eop = e;
    endfunction
    function ob_t sh(bit [127:0] p, bit [127:0] c, bit s, bit e); // Shifted beat {low 112 bits of previous beat, high 16 bits of current beat}
      sh.data = {p[111:0], c[127:112]}; sh.sop = s; sh.eop = e;
    endfunction
    function void write_in(lh_evt e);
      exp_frm f;
      int n;
      if (e.kind == E_WR) begin
        htab[e.waddr] = e.wdata; stab[e.waddr] = e.sn;
        return;
      end
      n_in++;
      n = e.data.size();
      if (e.meta.type3) begin
        f = new(0, e.meta);
        for (int i = 0; i < n; i++)
          f.b.push_back(pf(e.data[i], e.sop[i], e.eop[i]));        // lat: pass through unchanged
        q_lat.push_back(f);
      end else begin
        n_exp_hash++;                                    // 1 hash pulses per non-type3 frame
        if (get_h(e.meta.fid) != 256'h0) begin
          f = new(3, e.meta);                            // hash mismatch → discard
          f.b.push_back(pf(e.data[n-1], 1'b1, 1'b1));    // Original data of the last beat as a single beat, sop=eop=1
          q_disc.push_back(f);
        end else if (e.meta.type1) begin
          if (e.data[0][63:0] == get_s(e.meta.fid)) begin
            f = new(2, e.meta);                          // Serial number match → t1to2 (drop the first 4 beats, pass data through without shifting)
            if (n < 6) begin
              `uvm_error("SB", "t1to2 frame length is less than 6, sequence configuration error")
              return;
            end
            for (int i = 4; i < n; i++)
              f.b.push_back(pf(e.data[i], (i == 4), (i == n - 1)));
            q_t12.push_back(f);
          end else begin
            f = new(4, e.meta);                          // Serial number mismatch → ecdsa pass-through
            for (int i = 0; i < n; i++)
              f.b.push_back(pf(e.data[i], e.sop[i], e.eop[i]));
            q_ecd.push_back(f);
          end
        end else begin
          f = new(1, e.meta);                            // type2 → 2-byte shift + last-beat overflow
          if (n < 2) begin
            `uvm_error("SB", "t2 frame length is less than 2, sequence configuration error")
            return;
          end
          for (int i = 1; i < n; i++)
            f.b.push_back(sh(e.data[i-1], e.data[i], (i == 1), 1'b0));
          f.b.push_back(sh(e.data[n-1], e.data[n-1], 1'b0, 1'b1));
          q_t2.push_back(f);
        end
      end
    endfunction
    function void cmp_pp_meta(lh_pp_meta_type o, irl_lh_meta_type i, bit frc);
      if (o.hdr_len !== i.hdr_len || o.buf_ptr !== i.buf_ptr || o.len !== i.len ||
          o.port !== i.port || o.rci !== i.rci || o.fid !== i.fid || o.tid !== i.tid ||
          o.type1 !== i.type1 || o.type3 !== (i.type3 | frc) ||
          o.discard !== (i.discard | frc))
        `uvm_error("SB", $sformatf("pp meta mismatch: fid=%0d type1=%b type3=%b disc=%b (exp type3=%b disc=%b)",
                   o.fid, o.type1, o.type3, o.discard, i.type3 | frc, i.discard | frc))
    endfunction
    function void write_pp(lh_evt e);
      exp_frm f = null;
      int cls;
      cls = (e.pp_meta.type3 && e.pp_meta.discard) ? 3 :
             e.pp_meta.type3 ? 0 : e.pp_meta.type1 ? 2 : 1;
      case (cls)
        0: if (q_lat.size())  f = q_lat.pop_front();
        1: if (q_t2.size())   f = q_t2.pop_front();
        2: if (q_t12.size())  f = q_t12.pop_front();
        default: if (q_disc.size()) f = q_disc.pop_front();
      endcase
      if (f == null) begin
        `uvm_error("SB", $sformatf("extra frame on the pp side cls=%0d len=%0d", cls, e.data.size()))
        return;
      end
      n_pp++;
      if (e.trunc) return;   // Truncated frame already reported as an error by monitor
      if (e.data.size() != f.b.size())
        `uvm_error("SB", $sformatf("pp frame length mismatch cls=%0d exp=%0d got=%0d fid=%0d",
                   cls, f.b.size(), e.data.size(), e.pp_meta.fid))
      else begin
        for (int i = 0; i < f.b.size(); i++) begin
          if (e.sop[i] != f.b[i].sop || e.eop[i] != f.b[i].eop)
            `uvm_error("SB", $sformatf("pp sop/eop mismatch cls=%0d i=%0d", cls, i))
          if (e.data[i] !== f.b[i].data)
            `uvm_error("SB", $sformatf("pp data mismatch cls=%0d i=%0d got=%032x exp=%032x",
                       cls, i, e.data[i], f.b[i].data))
          else n_chk++;
        end
        cmp_pp_meta(e.pp_meta, f.meta, (cls == 3));
      end
    endfunction
    function void write_ecd(lh_evt e);
      exp_frm f = null;
      n_ecd++;
      if (q_ecd.size()) f = q_ecd.pop_front();
      if (f == null) begin
        `uvm_error("SB", $sformatf("extra frame on ecdsa side len=%0d", e.data.size()))
        return;
      end
      if (e.trunc) return;
      if (e.data.size() != f.b.size())
        `uvm_error("SB", $sformatf("ecdsa frame length mismatch exp=%0d got=%0d", f.b.size(), e.data.size()))
      else begin
        for (int i = 0; i < f.b.size(); i++) begin
          if (e.sop[i] != f.b[i].sop || e.eop[i] != f.b[i].eop)
            `uvm_error("SB", $sformatf("ecdsa sop/eop mismatch i=%0d", i))
          if (e.data[i] !== f.b[i].data)
            `uvm_error("SB", $sformatf("ecdsa data mismatch i=%0d got=%032x exp=%032x",
                       i, e.data[i], f.b[i].data))
          else n_chk++;
        end
        if (e.ecd_meta.traffic_class !== f.meta.traffic_class ||
            e.ecd_meta.hdr_len !== f.meta.hdr_len ||
            e.ecd_meta.buf_ptr !== f.meta.buf_ptr || e.ecd_meta.len !== f.meta.len ||
            e.ecd_meta.port !== f.meta.port || e.ecd_meta.rci !== f.meta.rci ||
            e.ecd_meta.fid !== f.meta.fid || e.ecd_meta.tid !== f.meta.tid ||
            e.ecd_meta.type1 !== f.meta.type1 || e.ecd_meta.type3 !== f.meta.type3 ||
            e.ecd_meta.discard !== f.meta.discard)
          `uvm_error("SB", "ecdsa meta mismatch")
      end
    endfunction
    function void write_hash(lh_evt e);
      n_hash++;
      if (n_exp_hash == 0)
        `uvm_error("SB", "extra pulse on hash side")
      else if (e.hdata !== 256'h0)
        `uvm_error("SB", $sformatf("hash data nonzero: %064x", e.hdata))
      else n_exp_hash--;
    endfunction
    function void flush();
      q_lat.delete(); q_t2.delete(); q_t12.delete(); q_disc.delete(); q_ecd.delete();
      n_exp_hash = 0;
      htab.delete(); stab.delete();   // RAM is zeroed again after reset; clear the mirrors accordingly
    endfunction
    function void report_phase(uvm_phase phase);
      super.report_phase(phase);
      if (q_lat.size() || q_t2.size() || q_t12.size() || q_disc.size() ||
          q_ecd.size() || n_exp_hash)
        `uvm_error("SB", $sformatf("model leftovers: lat=%0d t2=%0d t12=%0d disc=%0d ecd=%0d hash=%0d",
                   q_lat.size(), q_t2.size(), q_t12.size(), q_disc.size(),
                   q_ecd.size(), n_exp_hash))
      `uvm_info("SB", $sformatf(
        "frame statistics: in=%0d pp=%0d ecd=%0d hash=%0d compared beats=%0d",
        n_in, n_pp, n_ecd, n_hash, n_chk), UVM_LOW)
    endfunction
  endclass

  // ---------------- agent / env ----------------
  class lh_agent extends uvm_agent;
    `uvm_component_utils(lh_agent)
    lh_drv drv;
    lh_mon mon_in, mon_pp, mon_ecd, mon_hash;
    uvm_sequencer #(lh_txn) sqr;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      drv = lh_drv::type_id::create("drv", this);
      mon_in = lh_mon::type_id::create("mon_in", this);     mon_in.side = "IN";
      mon_pp = lh_mon::type_id::create("mon_pp", this);     mon_pp.side = "PP";
      mon_ecd = lh_mon::type_id::create("mon_ecd", this);   mon_ecd.side = "ECD";
      mon_hash = lh_mon::type_id::create("mon_hash", this); mon_hash.side = "HASH";
      sqr = uvm_sequencer#(lh_txn)::type_id::create("sqr", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      drv.seq_item_port.connect(sqr.seq_item_export);
    endfunction
  endclass

  class lh_env extends uvm_env;
    `uvm_component_utils(lh_env)
    lh_agent agent;
    lh_sb sb;
    lh_cov cov;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      agent = lh_agent::type_id::create("agent", this);
      sb = lh_sb::type_id::create("sb", this);
      cov = lh_cov::type_id::create("cov", this);
    endfunction
    function void connect_phase(uvm_phase phase);
      super.connect_phase(phase);
      agent.mon_in.ap.connect(sb.in_imp);
      agent.mon_pp.ap.connect(sb.pp_imp);
      agent.mon_ecd.ap.connect(sb.ecd_imp);
      agent.mon_hash.ap.connect(sb.hash_imp);
      agent.mon_in.ap.connect(cov.analysis_export);
    endfunction
  endclass

  // ---------------- sequences ----------------
  class seq_base extends uvm_sequence #(lh_txn);
    `uvm_object_utils(seq_base)
    function new(string n = "seq_base"); super.new(n); endfunction
    task send_idle(int n);
      lh_txn t = lh_txn::type_id::create("t");
      start_item(t); void'(t.randomize());
      t.kind = K_IDLE; t.gap = n; finish_item(t);
    endtask
    task send_wr(bit [11:0] a, bit [255:0] d, bit [63:0] s, bit [5:0] p);
      lh_txn t = lh_txn::type_id::create("t");
      start_item(t); void'(t.randomize());
      t.kind = K_WR; t.waddr = a; t.wdata = d; t.wsn = s; t.wppl = p; finish_item(t);
    endtask
    task send_frm(ftype_e ft, bit [11:0] fid, int len, bit [63:0] ser,
                  int gap = 0, pat_e pat = P_RND, bit disc = 0, int igap = 0);
      lh_txn t = lh_txn::type_id::create("t");
      start_item(t); void'(t.randomize());
      t.kind = K_FRM;
      t.ftype = ft; t.fid = fid; t.len = len; t.gap = gap; t.pat = pat;
      t.m_disc = disc; t.igap = igap;
      t.ser_ov_en = 1; t.serial_ov = ser;
      finish_item(t);
    endtask
    task send_frm_tc(ftype_e ft, bit [11:0] fid, int len, bit [63:0] ser, bit [7:0] tc,
                     int gap = 0, pat_e pat = P_RND, bit disc = 0, int igap = 0);
      lh_txn t = lh_txn::type_id::create("t");
      start_item(t); void'(t.randomize());
      t.kind = K_FRM;
      t.ftype = ft; t.fid = fid; t.len = len; t.gap = gap; t.pat = pat;
      t.m_disc = disc; t.igap = igap;
      t.ser_ov_en = 1; t.serial_ov = ser;
      t.m_tclass = tc;
      finish_item(t);
    endtask
  endclass

  // F08: Lookup table initialization (hash=0 hit / hash≠0 discard / serial number table)
  class seq_table extends seq_base;
    `uvm_object_utils(seq_table)
    function new(string n = "seq_table"); super.new(n); endfunction
    task body();
      send_wr(12'd1, 256'h0, 64'h0000_1111_2222_3333, 6'd1);
      send_wr(12'd2, 256'hA5A5_5A5A_C3C3_3C3C_9696_6969_F0F0_0F0F_1B1B_B1B1,
                   64'h0000_4444_5555_6666, 6'd2);
      send_wr(12'd3, 256'h0, 64'h0, 6'd21);
      send_wr(12'd4, 256'h0, 64'h7FFF_FFFF_FFFF_FFFF, 6'd63);
      send_wr(12'd5, 256'h0, 64'h0000_AAAA_BBBB_CCCC, 6'd0);
      send_wr(12'd6, 256'h0, 64'h0000_0F0F_0F0F_0F0F, 6'd15);
      send_wr(12'd7, 256'h1, 64'h0, 6'd7);       // Second fid with hash≠0
      send_wr(12'd0, 256'h0, 64'h0000_00FF_FF00_00FF, 6'd8);
      send_wr(12'd4095, 256'h0, 64'h0, 6'd63);
      send_wr(12'd128, 256'h0, 64'h0000_1234_5678_9ABC, 6'd42);
      send_wr(12'd64, 256'h0, 64'h0000_0000_0000_0001, 6'd3);   // Mid-range fid
      send_wr(12'd200, 256'h0, 64'h0, 6'd4);                     // High-order fid
    endtask
  endclass

  // F03/F04/F05: Directed frames (at least one frame for each classification/length/data pattern)
  class seq_directed extends seq_base;
    `uvm_object_utils(seq_directed)
    function new(string n = "seq_directed"); super.new(n); endfunction
    task body();
      // type3 pass-through: single beat / multiple beats / idle beats within a frame
      send_frm(F_T3, 12'd0, 1, 64'h0, 1);
      send_frm(F_T3, 12'd0, 5, 64'h0, 0, P_ONES);
      send_frm(F_T3, 12'd128, 9, 64'h0, 2, P_ZERO, 0, 2);
      // type2 shift path: shortest/medium/long + discard flag pass-through
      send_frm(F_T2, 12'd3, 2, 64'h0, 0, P_ZERO);
      send_frm(F_T2, 12'd3, 6, 64'h0, 0, P_RND);
      send_frm(F_T2, 12'd5, 16, 64'h0, 2, P_ONES);
      send_frm(F_T2, 12'd5, 8, 64'h0, 0, P_RND, 1);
      // type1 serial number mismatch → ecdsa pass-through
      send_frm(F_T1, 12'd3, 6, 64'hFFFF_0000_1111_2222, 1);
      send_frm(F_T1, 12'd4, 8, 64'h8000_0000_0000_0001, 0, P_ONES);
      send_frm(F_T1, 12'd4095, 7, 64'hDEAD_BEEF_0000_0001, 1);
      // type1 serial number match → t1to2 truncation path
      send_frm(F_T1, 12'd1, 8, 64'h0000_1111_2222_3333, 1);
      send_frm(F_T1, 12'd4, 6, 64'h7FFF_FFFF_FFFF_FFFF, 0, P_ZERO);
      send_frm(F_T1, 12'd3, 10, 64'h0, 1);        // Table value 0, serial number 0 → match
      // hash mismatch → discard (type1 serial number match/mismatch × type2)
      send_frm(F_T1, 12'd2, 8, 64'h0000_4444_5555_6666, 1);
      send_frm(F_T1, 12'd2, 8, 64'hFFFF_0000_1111_2222, 0, P_ZERO);
      send_frm(F_T2, 12'd2, 6, 64'h0, 0, P_RND);
      send_frm(F_T2, 12'd7, 9, 64'h0, 1, P_ONES);
      // Both type1&type3 bits set → type3 takes priority (lat pass-through)
      send_frm(F_T1X3, 12'd0, 6, 64'h1234_0000_0000_0000, 1);
      // V7: F_T1X3 multiple lengths/multiple patterns (fill the F_T1X3 bins of x_ft_len/x_ft_pat)
      send_frm(F_T1X3, 12'd0, 1, 64'h0, 0);
      send_frm(F_T1X3, 12'd0, 2, 64'h0, 0, P_ZERO);
      send_frm(F_T1X3, 12'd0, 4, 64'h0, 0, P_ONES);
      send_frm(F_T1X3, 12'd0, 8, 64'h0, 0);
      send_frm(F_T1X3, 12'd0, 20, 64'h0, 0);
      // Complete length boundary coverage: F_T3 len2 / F_T2 len4 / F_T1 len1,2,4,20 (ecdsa)
      send_frm(F_T3, 12'd0, 2, 64'h0, 0);
      send_frm(F_T2, 12'd3, 4, 64'h0, 0, P_RND);
      send_frm(F_T1, 12'd4, 1, 64'h0000_0000_0000_0001, 0);
      send_frm(F_T1, 12'd4, 2, 64'h0000_0000_0000_0001, 0);
      send_frm(F_T1, 12'd4, 4, 64'h0000_0000_0000_0001, 0);
      send_frm(F_T1, 12'd4, 20, 64'h0000_0000_0000_0001, 0);
      // Mid-range/high-order fid (cp_fid boundary grouping)
      send_frm(F_T2, 12'd64, 6, 64'h0, 0, P_RND);
      send_frm(F_T1, 12'd200, 6, 64'h0000_0000_0000_0001, 0);
      // traffic_class boundaries (cp_tc z/lo/hi/f)
      send_frm_tc(F_T3, 12'd0, 4, 64'h0, 8'h0, 0);
      send_frm_tc(F_T2, 12'd3, 6, 64'h0, 8'h40, 0);
      send_frm_tc(F_T1, 12'd4, 6, 64'h0000_0000_0000_0001, 8'hC8, 0);
      send_frm_tc(F_T3, 12'd0, 4, 64'h0, 8'hFF, 0);
    endtask
  endclass

  // F01/F06: Back-to-back burst (sfifo2f1 full flag, sc continuous pairing)
  class seq_burst extends seq_base;
    `uvm_object_utils(seq_burst)
    function new(string n = "seq_burst"); super.new(n); endfunction
    task body();
      repeat (4) send_frm(F_T2, 12'd3, 6, 64'h0, 0, P_RND);            // 4×t2 back-to-back
      repeat (3) send_frm(F_T1, 12'd3, 6, 64'hFFFF_0000_1111_2222, 0); // 3×t1 back-to-back
      send_frm(F_T1, 12'd3, 6, 64'hFFFF_0000_1111_2222, 0);
      send_frm(F_T1, 12'd1, 8, 64'h0000_1111_2222_3333, 0);            // t12
      send_frm(F_T2, 12'd3, 7, 64'h0, 0);
      send_frm(F_T2, 12'd2, 7, 64'h0, 0);                              // disc
    endtask
  endclass

  // F06: T3 interleaved with T12/T1 (bidirectional FSM transitions; T3 following T2 requires a large gap to prevent the last beat from being discarded)
  class seq_interleave extends seq_base;
    `uvm_object_utils(seq_interleave)
    function new(string n = "seq_interleave"); super.new(n); endfunction
    task body();
      send_frm(F_T3, 12'd0, 4, 64'h0, 0);
      send_frm(F_T1, 12'd1, 8, 64'h0000_1111_2222_3333, 0);   // t12 immediately follows t3
      send_frm(F_T3, 12'd0, 4, 64'h0, 0);
      send_frm(F_T1, 12'd3, 6, 64'hFFFF_0000_1111_2222, 0);   // ecdsa path
      send_frm(F_T3, 12'd0, 1, 64'h0, 0);
      send_frm(F_T1, 12'd1, 6, 64'h0000_1111_2222_3333, 0);
      send_frm(F_T3, 12'd0, 6, 64'h0, 0, P_ONES);
      send_frm(F_T2, 12'd3, 6, 64'h0, 0);
      send_idle(20);                                            // Wait for t2 to drain
      send_frm(F_T3, 12'd0, 4, 64'h0, 0);
    endtask
  endclass

  // F03 boundary: Long frames (approaching in_fifo depth 64)
  class seq_long extends seq_base;
    `uvm_object_utils(seq_long)
    function new(string n = "seq_long"); super.new(n); endfunction
    task body();
      send_frm(F_T2, 12'd3, 62, 64'h0, 1);
      send_frm(F_T3, 12'd0, 62, 64'h0, 1, P_ONES);
      send_frm(F_T1, 12'd1, 40, 64'h0000_1111_2222_3333, 1);  // Long t12
      send_idle(50);
      send_frm(F_T3, 12'd0, 4, 64'h0, 0);
    endtask
  endclass

  // F08: Table rewrite (hit→discard→hit)
  class seq_rewrite extends seq_base;
    `uvm_object_utils(seq_rewrite)
    function new(string n = "seq_rewrite"); super.new(n); endfunction
    task body();
      send_frm(F_T2, 12'd5, 8, 64'h0, 2);
      send_idle(40);
      send_wr(12'd5, {256{1'b1}}, 64'h0000_AAAA_BBBB_CCCC, 6'd5);
      send_idle(10);
      send_frm(F_T2, 12'd5, 8, 64'h0, 2);                      // → disc
      send_idle(40);
      send_wr(12'd5, 256'h0, 64'h0000_AAAA_BBBB_CCCC, 6'd5);
      send_idle(10);
      send_frm(F_T2, 12'd5, 8, 64'h0, 2);                      // → restore
    endtask
  endclass

  // Random (no T3, arbitrary gaps—mixing t2 and t3 risks discarding the last beat, so keep them separate)
  class seq_random24 extends seq_base;
    `uvm_object_utils(seq_random24)
    function new(string n = "seq_random24"); super.new(n); endfunction
    task body();
      lh_txn t;
      repeat (24) begin
        t = lh_txn::type_id::create("t");
        start_item(t); void'(t.randomize());
        t.kind = K_FRM;
        t.ftype = ($urandom_range(0, 9) < 5) ? F_T1 : F_T2;
        finish_item(t);
      end
    endtask
  endclass

  // Random (T3+T1 mixed, arbitrary gaps are safe: neither has pp last-beat latency)
  class seq_random_t3mix extends seq_base;
    `uvm_object_utils(seq_random_t3mix)
    function new(string n = "seq_random_t3mix"); super.new(n); endfunction
    task body();
      lh_txn t;
      repeat (16) begin
        t = lh_txn::type_id::create("t");
        start_item(t); void'(t.randomize());
        t.kind = K_FRM;
        t.ftype = ($urandom_range(0, 9) < 6) ? F_T3 : F_T1;
        finish_item(t);
        // While T1 occupies in_fifo, lat_fifo stops draining; consecutive T3 frames will accumulate and overflow (depth 64):
        // Force a wait for draining after T1 before sending subsequent T3
        if (t.ftype == F_T1) send_idle(t.len + 8);
      end
    endtask
  endclass

  // V11: Functional recovery after reset (all-0 table: hash hit; type1 serial number 0 matches / non-0 mismatches)
  class seq_recover extends seq_base;
    `uvm_object_utils(seq_recover)
    function new(string n = "seq_recover"); super.new(n); endfunction
    task body();
      send_frm(F_T3, 12'd0, 4, 64'h0, 0);   // lat
      send_frm(F_T2, 12'd0, 6, 64'h0, 0);   // t2 (hash hit)
      send_frm(F_T1, 12'd0, 8, 64'h0, 0);   // t1to2 (serial number match)
      send_frm(F_T1, 12'd0, 8, 64'h1, 0);   // ecdsa (serial number mismatch)
    endtask
  endclass

  // ---------------- tests ----------------
  class test_base extends uvm_test;
    `uvm_component_utils(test_base)
    lh_env env;
    virtual logic_hash_if vif;
    function new(string name, uvm_component parent); super.new(name, parent); endfunction
    function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      env = lh_env::type_id::create("env", this);
      if (!uvm_config_db#(virtual logic_hash_if)::get(this, "", "vif", vif))
        `uvm_fatal("NOVIF", "tb_top vif not configured")
    endfunction
    task run_seq(seq_base s); s.start(env.agent.sqr); endtask
    task run_phase(uvm_phase phase);
      phase.raise_objection(this);
      wait (vif.rst_n === 1'b1);
      repeat (4200) @(vif.cb);   // RAM self-initialization takes 4097 cycles
      body();
      repeat (400) @(vif.cb);    // Drain everything
      phase.drop_objection(this);
    endtask
    virtual task body(); endtask
  endclass

  class t_smoke extends test_base;
    `uvm_component_utils(t_smoke)
    function new(string n = "t_smoke", uvm_component p = null); super.new(n, p); endfunction
    task body();
      run_seq(seq_table::type_id::create("tb1"));
      run_seq(seq_directed::type_id::create("d1"));
    endtask
  endclass

  // Comprehensive test: Run all feature sections serially (default entry point, complete coverage collection within one test)
  class t_main extends test_base;
    `uvm_component_utils(t_main)
    function new(string n = "t_main", uvm_component p = null); super.new(n, p); endfunction
    task body();
      run_seq(seq_table::type_id::create("tbl"));
      run_seq(seq_directed::type_id::create("dir"));
      run_seq(seq_burst::type_id::create("bst"));
      run_seq(seq_interleave::type_id::create("itl"));
      run_seq(seq_long::type_id::create("lng"));
      run_seq(seq_rewrite::type_id::create("rwt"));
      run_seq(seq_random24::type_id::create("r24"));
      run_seq(seq_random_t3mix::type_id::create("r3m"));
      repeat (400) @(vif.cb);    // Reset after draining
      // V11: Reset during transfer → outputs quiescent → RAM reinitialization → functional recovery
      begin
        irl_lh_meta_type rm = '{default:'0};
        rm.type1 = 1'b1; rm.fid = 12'd1;
        vif.cb.irl_lh_valid <= 1'b1;
        vif.cb.irl_lh_sop <= 1'b1;
        vif.cb.irl_lh_eop <= 1'b0;
        vif.cb.irl_lh_hdr_data <= 128'h0;
        vif.cb.irl_lh_meta_data <= rm;
        @(vif.cb);
        vif.cb.irl_lh_sop <= 1'b0;
        repeat (2) @(vif.cb);     // 3 beats in total, frame incomplete (no eop)
        vif.pulse_reset();        // Reset during transfer
        vif.cb.irl_lh_valid <= 1'b0;
        vif.cb.irl_lh_sop <= 1'b0;
        vif.cb.irl_lh_eop <= 1'b0;
        vif.cb.irl_lh_hdr_data <= '0;
        vif.cb.irl_lh_meta_data <= '{default:'0};
        repeat (3) @(vif.cb);
      end
      repeat (20) begin
        @(vif.cb);
        if (vif.cb.lh_pp_valid || vif.cb.lh_ecdsa_valid || vif.cb.lh_ecdsa_hash_valid)
          `uvm_error("RST", "outputs not quiescent after reset")
      end
      env.sb.flush();            // Clear queues + table mirrors (RAM is zeroed after reset)
      repeat (4097) @(vif.cb);   // Wait for RAM reinitialization
      run_seq(seq_recover::type_id::create("rcv"));   // Functional recovery after reset
    endtask
  endclass

endpackage
