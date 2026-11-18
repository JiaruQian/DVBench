`timescale 1ns/1ps
// Input-history predictor derived from audited source TB mathematical/window model.
// No RTL body, DUT hierarchy/output, memory backdoor, or recorded golden trace.
package dvbench_video_math;
  localparam int IW=384;
  class svf_mtxn;
    logic [23:0] din;
    logic dhs,dvs,dvde;
    logic [3:0] sw,btn;
  endclass
  function automatic logic [7:0] svf_cl8(int x);
    return (x < 0) ? 8'h00 : ((x > 255) ? 8'hFF : x[7:0]);
  endfunction

  // font row table (only characters used in filter names; all others default 0, consistent with font_rom)
  function automatic logic [7:0] svf_frow(int cc, int rr);
    case (cc)
      65: case (rr) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h66; 7:return 8'h00; default:return 8'h00; endcase
      66: case (rr) 0:return 8'h7C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7C; 4:return 8'h66; 5:return 8'h66; 6:return 8'h7C; 7:return 8'h00; default:return 8'h00; endcase
      67: case (rr) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h60; 4:return 8'h60; 5:return 8'h66; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      68: case (rr) 0:return 8'h78; 1:return 8'h6C; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h6C; 6:return 8'h78; 7:return 8'h00; default:return 8'h00; endcase
      69: case (rr) 0:return 8'h7E; 1:return 8'h60; 2:return 8'h60; 3:return 8'h7C; 4:return 8'h60; 5:return 8'h60; 6:return 8'h7E; 7:return 8'h00; default:return 8'h00; endcase
      71: case (rr) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h6E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      72: case (rr) 0:return 8'h66; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h66; 7:return 8'h00; default:return 8'h00; endcase
      73: case (rr) 0:return 8'h3C; 1:return 8'h18; 2:return 8'h18; 3:return 8'h18; 4:return 8'h18; 5:return 8'h18; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      76: case (rr) 0:return 8'h60; 1:return 8'h60; 2:return 8'h60; 3:return 8'h60; 4:return 8'h60; 5:return 8'h60; 6:return 8'h7E; 7:return 8'h00; default:return 8'h00; endcase
      77: case (rr) 0:return 8'h42; 1:return 8'h66; 2:return 8'h7E; 3:return 8'h5A; 4:return 8'h42; 5:return 8'h42; 6:return 8'h42; 7:return 8'h00; default:return 8'h00; endcase
      78: case (rr) 0:return 8'h66; 1:return 8'h76; 2:return 8'h7E; 3:return 8'h6E; 4:return 8'h66; 5:return 8'h66; 6:return 8'h66; 7:return 8'h00; default:return 8'h00; endcase
      79: case (rr) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      80: case (rr) 0:return 8'h7C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7C; 4:return 8'h60; 5:return 8'h60; 6:return 8'h60; 7:return 8'h00; default:return 8'h00; endcase
      82: case (rr) 0:return 8'h7C; 1:return 8'h66; 2:return 8'h66; 3:return 8'h7C; 4:return 8'h6C; 5:return 8'h66; 6:return 8'h66; 7:return 8'h00; default:return 8'h00; endcase
      83: case (rr) 0:return 8'h3C; 1:return 8'h66; 2:return 8'h60; 3:return 8'h3C; 4:return 8'h06; 5:return 8'h66; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      84: case (rr) 0:return 8'h7E; 1:return 8'h18; 2:return 8'h18; 3:return 8'h18; 4:return 8'h18; 5:return 8'h18; 6:return 8'h18; 7:return 8'h00; default:return 8'h00; endcase
      85: case (rr) 0:return 8'h66; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h66; 6:return 8'h3C; 7:return 8'h00; default:return 8'h00; endcase
      86: case (rr) 0:return 8'h66; 1:return 8'h66; 2:return 8'h66; 3:return 8'h66; 4:return 8'h66; 5:return 8'h3C; 6:return 8'h18; 7:return 8'h00; default:return 8'h00; endcase
      89: case (rr) 0:return 8'h66; 1:return 8'h66; 2:return 8'h66; 3:return 8'h3C; 4:return 8'h18; 5:return 8'h18; 6:return 8'h18; 7:return 8'h00; default:return 8'h00; endcase
      default: return 8'h00;
    endcase
  endfunction

  class wg_m;
    int id;
    logic [7:0] mem1 [0:IW-1];
    logic [7:0] mem2 [0:IW-1];
    int ptr1, ptr2;
    logic [7:0] l1o, l2o;
    logic [7:0] p00, p01, p02, p10, p11, p12, p20, p21, p22;
    function new(int id_);
      id = id_;
    endfunction
    function void do_rst();
      ptr1 = 0; ptr2 = 0; l1o = 0; l2o = 0;
      p00=0;p01=0;p02=0;p10=0;p11=0;p12=0;p20=0;p21=0;p22=0;
    endfunction
    function void step(logic [7:0] px, logic vde);
      logic [7:0] n_l1o = l1o, n_l2o = l2o;
      int n_p1 = ptr1, n_p2 = ptr2;
      logic [7:0] n00=p00,n01=p01,n02=p02,n10=p10,n11=p11,n12=p12,n20=p20,n21=p21,n22=p22;
      if (vde) begin
        n_l1o = mem1[ptr1];       // Read the old value first, then write the new value (read old and write new in the same cycle)
        mem1[ptr1] = px;
        n_p1 = (ptr1 == IW-1) ? 0 : ptr1 + 1;
        n_l2o = mem2[ptr2];
        mem2[ptr2] = l1o;
        n_p2 = (ptr2 == IW-1) ? 0 : ptr2 + 1;
        n22 = px;  n21 = p22; n20 = p21;
        n12 = l1o; n11 = p12; n10 = p11;
        n02 = l2o; n01 = p02; n00 = p01;
      end
      l1o=n_l1o; l2o=n_l2o; ptr1=n_p1; ptr2=n_p2;
      p00=n00;p01=n01;p02=n02;p10=n10;p11=n11;p12=n12;p20=n20;p21=n21;p22=n22;
    endfunction
  endclass

  class svf_model;
    logic [23:0] gs_d, ng_d, th_d, ga_d, sh_d, so_d, em_d;  // 7 filter data registers
    logic st_h, st_v, st_V;                                  // Filter timing registers (identical values across 7 paths)
    logic [7:0] thr;
    logic up_p, dn_p;
    logic [1:0] gmode, smode;
    logic gp, sp;
    wg_m wg[8];
    int ov_x, ov_y;
    logic ov_lV, ov_lVS;
    logic [23:0] ov_d;
    int x_cnt;
    longint b_cnt;
    int unsigned db_count;
    logic b_en;
    string NAMES [8];
    // Current-cycle output snapshot (for cycle-by-cycle comparison by sb)
    logic [23:0] l_d;
    logic l_h, l_v, l_V;
    logic [3:0] l_led;

    function new();
      for (int k = 0; k < 8; k++) wg[k] = new(k);
      NAMES = '{"NORMAL", "GREYSCALE", "NEGATIVE", "THRESHOLD", "GAUSSIAN", "SHARPEN", "SOBEL", "EMBOSS"};
      do_rst();
    endfunction

    function void do_rst();
      gs_d=0; ng_d=0; th_d=0; ga_d=0; sh_d=0; so_d=0; em_d=0;
      st_h=0; st_v=0; st_V=0;
      thr = 8'd128; up_p = 0; dn_p = 0;
      gmode = 2'd1; gp = 0; smode = 2'd0; sp = 0;
      for (int k = 0; k < 8; k++) wg[k].do_rst();
      ov_x = 0; ov_y = 0; ov_lV = 0; ov_lVS = 0; ov_d = 0;
      x_cnt = 0; b_cnt = 0; b_en = 0; db_count=0;
    endfunction


    // Cycle-by-cycle stepping: t = input snapshot at this edge; o = outputs that should appear after this edge + coverage context
    function void step(svf_mtxn t);
      logic [7:0] r, g, b, grey;
      logic [7:0] n_gs, to;
      logic [23:0] n_gsd, n_ngd, n_thd, n_gad, n_shd, n_sod, n_emd;
      logic [7:0] n_thr;
      logic [1:0] n_gm, n_sm;
      logic n_up, n_dn, n_gp, n_sp;
      logic up, dn, gb, sb;
      int kc, ke, kq, kv, rs, gs2, bs2, rsum, gsum, bsum;
      int Gx, Gy, Gxa, Gya, mag, es;
      logic [7:0] eo, r8, g8, b8;
      logic [23:0] seld, n_ovd;
      int uy, txv, tyv, ci, cp, cr, fi;
      logic inbox, intx, pon;
      logic [7:0] cchr, bm;
      string nm;
      int n_ox, n_oy, n_x;
      longint n_bc;
      logic n_be, diva, spla, b_old;
      logic [3:0] n_led;
      logic [7:0] thr_old;
      int gm_old, sm_old;
      logic [23:0] n_od;
      logic n_oh, n_ov2, n_oV;

      r = t.din[23:16]; g = t.din[15:8]; b = t.din[7:0];
      grey = (((r * 77) + (g * 150) + (b * 29)) >> 8) & 255;
      thr_old = thr; gm_old = gmode; sm_old = smode; b_old = b_en;

      // ---- Single-pixel filter outputs (next-cycle register values, formulas use current-cycle inputs) ----
      n_gs = grey;
      n_gsd = {n_gs, n_gs, n_gs};
      n_ngd = {~r, ~g, ~b};
      to = (grey >= thr) ? 8'hFF : 8'h00;
      n_thd = {to, to, to};

      // ---- Buttons (DUT samples every cycle when dbnc_f=1) ----
      n_thr = thr; n_up = up_p; n_dn = dn_p; n_gm = gmode; n_gp = gp; n_sm = smode; n_sp = sp;
      up = (t.sw[2:0] == 3'b011) ? t.btn[0] : 1'b0;
      dn = (t.sw[2:0] == 3'b011) ? t.btn[1] : 1'b0;
      gb = (t.sw[2:0] == 3'b100) ? t.btn[0] : 1'b0;
      sb = (t.sw[2:0] == 3'b110) ? t.btn[0] : 1'b0;
      if (db_count == 2500000) begin
        if (up && !up_p)
          n_thr = ((thr + 8'd5 > 8'd255) || (thr > 8'd250)) ? 8'd255 : thr + 8'd5;
        else if (dn && !dn_p)
          n_thr = (thr < 8'd5) ? 8'd0 : thr - 8'd5;
        n_up = up; n_dn = dn;
        if (gb && !gp) n_gm = (gmode == 2'd2) ? 2'd0 : gmode + 2'd1;
        n_gp = gb;
        if (sb && !sp) n_sm = (smode == 2'd2) ? 2'd0 : smode + 2'd1;
        n_sp = sb;
      end

      // ---- gaussian: kernel coefficients use current gmode, window uses current p values (before stepping) ----
      if (gm_old == 0) begin kc=1; ke=1; kq=2; kv=10; end
      else if (gm_old == 1) begin kc=1; ke=2; kq=4; kv=16; end
      else begin kc=1; ke=3; kq=9; kv=25; end
      rs = kc*wg[0].p00 + ke*wg[0].p01 + kc*wg[0].p02 + ke*wg[0].p10 + kq*wg[0].p11 +
           ke*wg[0].p12 + kc*wg[0].p20 + ke*wg[0].p21 + kc*wg[0].p22;
      gs2 = kc*wg[1].p00 + ke*wg[1].p01 + kc*wg[1].p02 + ke*wg[1].p10 + kq*wg[1].p11 +
            ke*wg[1].p12 + kc*wg[1].p20 + ke*wg[1].p21 + kc*wg[1].p22;
      bs2 = kc*wg[2].p00 + ke*wg[2].p01 + kc*wg[2].p02 + ke*wg[2].p10 + kq*wg[2].p11 +
            ke*wg[2].p12 + kc*wg[2].p20 + ke*wg[2].p21 + kc*wg[2].p22;
      r8 = rs / kv; g8 = gs2 / kv; b8 = bs2 / kv;
      n_gad = {r8, g8, b8};

      // ---- sharpen ----
      rsum = 5*wg[3].p11 - wg[3].p01 - wg[3].p10 - wg[3].p12 - wg[3].p21;
      gsum = 5*wg[4].p11 - wg[4].p01 - wg[4].p10 - wg[4].p12 - wg[4].p21;
      bsum = 5*wg[5].p11 - wg[5].p01 - wg[5].p10 - wg[5].p12 - wg[5].p21;
      n_shd = {svf_cl8(rsum), svf_cl8(gsum), svf_cl8(bsum)};

      // ---- sobel (grayscale window wg[6]) ----
      Gx = (-(wg[6].p00) + wg[6].p02) + 2*(-(wg[6].p10) + wg[6].p12) + (-(wg[6].p20) + wg[6].p22);
      Gy = (-(wg[6].p00) - 2*wg[6].p01 - wg[6].p02) + (wg[6].p20 + 2*wg[6].p21 + wg[6].p22);
      Gxa = (Gx < 0) ? -Gx : Gx;
      Gya = (Gy < 0) ? -Gy : Gy;
      mag = Gxa + Gya;
      if (sm_old == 0)      eo = (mag > 255) ? 8'hFF : mag[7:0];
      else if (sm_old == 1) eo = (Gxa > 255) ? 8'hFF : Gxa[7:0];
      else                  eo = (Gya > 255) ? 8'hFF : Gya[7:0];
      n_sod = {eo, eo, eo};

      // ---- emboss (grayscale window wg[7]) ----
      es = -2*wg[7].p00 - wg[7].p01 - wg[7].p10 + wg[7].p11 + wg[7].p12 + wg[7].p21 + 2*wg[7].p22 + 128;
      n_emd = {svf_cl8(es), svf_cl8(es), svf_cl8(es)};

      // ---- Window stepping (step only after reading the old p values) ----
      wg[0].step(r,  t.dvde); wg[1].step(g,  t.dvde); wg[2].step(b,  t.dvde);
      wg[3].step(r,  t.dvde); wg[4].step(g,  t.dvde); wg[5].step(b,  t.dvde);
      wg[6].step(grey, t.dvde); wg[7].step(grey, t.dvde);

      // ---- mux (current-cycle sw + current filter register values) ----
      case (t.sw[2:0])
        3'b000: seld = t.din;
        3'b001: seld = gs_d;
        3'b010: seld = ng_d;
        3'b011: seld = th_d;
        3'b100: seld = ga_d;
        3'b101: seld = sh_d;
        3'b110: seld = so_d;
        3'b111: seld = em_d;
      endcase

      // ---- Combinational overlay (current ov_x, y uses the forced value or internal count) ----
      uy = ov_y;
      inbox = (ov_x >= (IW - 368)) && (ov_x < IW) && (uy < 48);
      txv = (ov_x - (IW - 368) - 4) & 2047;
      tyv = (uy - 4) & 2047;
      intx = inbox && (ov_x >= 4) && (uy >= 4) && (txv < 360) && (tyv < 40);
      ci = txv / 40; cp = (txv % 40) / 5; cr = tyv / 5;
      fi = t.sw[2:0];
      cchr = 8'd32;
      if (ci <= 8) begin
        nm = NAMES[fi];
        cchr = (ci < nm.len()) ? nm[ci] : 8'd32;
      end
      bm = svf_frow(cchr, cr);
      pon = bm[7 - cp];
      n_ovd = (intx && pon) ? 24'hFFFFFF : (inbox ? 24'h000000 : seld);

      // ---- overlay counters ----
      n_ox = t.dvde ? ((ov_x == IW-1) ? 0 : ov_x + 1) : 0;
      if (!t.dvs && ov_lVS) n_oy = 0;
      else if (!t.dvde && ov_lV) n_oy = (ov_y + 1) & 2047;
      else n_oy = ov_y;

      // ---- top outputs (divider/split use current x_cnt; right half/normal use current ov_d) ----
      diva = t.sw[3] && (x_cnt >= 191) && (x_cnt <= 193);
      spla = t.sw[3] && (x_cnt >= 192);
      n_od = diva ? 24'hFFFFFF :
             (t.sw[3] && spla) ? ov_d :
             t.sw[3] ? t.din : ov_d;
      n_oh = (t.sw[2:0]==0) ? t.dhs : st_h; n_ov2 = (t.sw[2:0]==0) ? t.dvs : st_v; n_oV = (t.sw[2:0]==0) ? t.dvde : st_V;
      n_led = b_en ? (4'b0001 << t.sw[1:0]) : 4'b0000;
      n_x = t.dvde ? ((x_cnt == IW-1) ? 0 : x_cnt + 1) : 0;
      if (b_cnt >= 6) begin n_bc = 0; n_be = !b_en; end
      else begin n_bc = b_cnt + 1; n_be = b_en; end

      db_count=(db_count==2500000) ? 0 : db_count+1;
      // ---- Commit ----
      gs_d=n_gsd; ng_d=n_ngd; th_d=n_thd; ga_d=n_gad; sh_d=n_shd; so_d=n_sod; em_d=n_emd;
      st_h=t.dhs; st_v=t.dvs; st_V=t.dvde;
      thr=n_thr; up_p=n_up; dn_p=n_dn; gmode=n_gm; gp=n_gp; smode=n_sm; sp=n_sp;
      ov_x=n_ox; ov_y=n_oy; ov_lV=t.dvde; ov_lVS=t.dvs; ov_d=n_ovd;
      x_cnt=n_x; b_cnt=n_bc; b_en=n_be;
      l_d=n_od; l_h=n_oh; l_v=n_ov2; l_V=n_oV; l_led=n_led;

    endfunction
    function void step_rst();
      do_rst(); l_d=0; l_h=0; l_v=0; l_V=0; l_led=0;
    endfunction
    function void quiet_step(svf_mtxn t);
      l_led = b_en ? (4'b0001 << t.sw[1:0]) : 0;
      if(b_cnt>=6) begin b_cnt=0; b_en=!b_en; end else b_cnt++;
      db_count++;
    endfunction
  endclass

endpackage
module dvbench_model #(
 parameter DATA_WIDTH=24, IMAGE_WIDTH=384, IMAGE_HEIGHT=64,
 parameter BLINK_RATE=26'd6, DEBOUNCE_LIMIT=22'd2500000
)(input logic clk,n_rst, input logic [3:0] sw,btn,
 output logic [3:0] led,
 input logic [DATA_WIDTH-1:0] i_vid_data,
 input logic i_vid_hsync,i_vid_vsync,i_vid_VDE,
 output logic [DATA_WIDTH-1:0] o_vid_data,
 output logic o_vid_hsync,o_vid_vsync,o_vid_VDE);
 import dvbench_video_math::*;
 svf_model m; svf_mtxn t;
 logic [35:0] previous_input;
 int quiet_count=0;
 bit slot;
 initial begin
   if(DATA_WIDTH!=24 || IMAGE_WIDTH!=384 || IMAGE_HEIGHT!=64 || BLINK_RATE!=6 || DEBOUNCE_LIMIT!=2500000)
      $fatal(1,"unsupported fixed public video profile");
   m=new(); t=new(); previous_input='x;
 end
 always @(posedge clk) begin
   t.din=i_vid_data; t.dhs=i_vid_hsync; t.dvs=i_vid_vsync; t.dvde=i_vid_VDE; t.sw=sw; t.btn=btn;
   slot=(m.db_count==2500000);
   if(!n_rst) begin m.step_rst(); quiet_count=0; end
   else begin
     if(quiet_count>=4 && !i_vid_VDE && !slot &&
        ({n_rst,sw,btn,i_vid_data,i_vid_hsync,i_vid_vsync,i_vid_VDE}===previous_input))
        m.quiet_step(t);
     else m.step(t);
     if(slot || ({n_rst,sw,btn,i_vid_data,i_vid_hsync,i_vid_vsync,i_vid_VDE}!==previous_input)) quiet_count=0;
     else if(quiet_count<5) quiet_count++;
   end
   previous_input={n_rst,sw,btn,i_vid_data,i_vid_hsync,i_vid_vsync,i_vid_VDE};
   led<=m.l_led; o_vid_data<=m.l_d; o_vid_hsync<=m.l_h; o_vid_vsync<=m.l_v; o_vid_VDE<=m.l_V;
 end
endmodule
