// rdma_if.sv — axi_rdma interface (single clock, self-maintained reset, clock frequency can change at runtime)
`timescale 1ns/1ps

interface rdma_if ();

  logic aresetn = 0;
  logic aclk = 0;

  // Integer half-period (real delays trigger analog-style scheduling, ~300× slower)
  int unsigned half = 2;   // Period 4ns
  initial forever #(half) aclk = ~aclk;

  initial #40 aresetn = 1;

  task set_half(int h);
    half = h;
  endtask

  task pulse_reset();   // F06: Reset during transfer (discarding in-flight data is expected)
    @(negedge aclk); aresetn = 0;
    repeat (5) @(negedge aclk);
    aresetn = 1;
  endtask

  // ---- cmd side (driven by TB) ----
  logic [31:0] cmd_address, cmd_bytes;
  logic        cmd_valid, cmd_ready;
  // ---- AXI read address channel (DUT output / TB return) ----
  logic [3:0]  axi_m_arid;
  logic [31:0] axi_m_araddr;
  logic [7:0]  axi_m_arlen;
  logic [2:0]  axi_m_arsize;
  logic [1:0]  axi_m_arburst;
  logic        axi_m_arvalid, axi_m_arready;
  // ---- AXI read data channel (TB output / DUT return) ----
  logic [3:0]  axi_m_rid;
  logic [31:0] axi_m_rdata;
  logic [1:0]  axi_m_rresp;
  logic        axi_m_rlast, axi_m_rvalid, axi_m_rready;
  // ---- dout stream (DUT output / TB return) ----
  logic [31:0] dout_tdata;
  logic [3:0]  dout_tkeep;
  logic        dout_tlast, dout_tvalid, dout_tready;

  // cmd-side driving block (cmd_ready is a registered output; CB driving is safe)
  clocking cb @(posedge aclk);
    default input #1step output #1;
    output cmd_address, cmd_bytes, cmd_valid;
    input  cmd_ready;
  endclocking

  // G5/V9: Concurrent assertions for AXI/AXIS protocol invariants (previously the tb had zero protocol checks, and DUT glitch violations were invisible to the scoreboard)
  // (1) Once asserted, arvalid remains high until arready; araddr/arlen remain stable while valid is high
  logic [31:0] previous_araddr, previous_dout_data;
  logic [7:0] previous_arlen;
  logic [3:0] previous_dout_keep;
  logic previous_dout_last;
  always @(posedge aclk) begin
    previous_araddr <= axi_m_araddr;
    previous_arlen <= axi_m_arlen;
    previous_dout_data <= dout_tdata;
    previous_dout_keep <= dout_tkeep;
    previous_dout_last <= dout_tlast;
  end

  property p_ar_stable;
    @(posedge aclk) disable iff (!aresetn)
      (axi_m_arvalid && !axi_m_arready) |=>
        (axi_m_arvalid && (axi_m_araddr === previous_araddr) && (axi_m_arlen === previous_arlen));
  endproperty
  a_ar_stable: assert property (p_ar_stable);
  // (2) AR fixed-field constants (single-ID, fixed-length INCR burst semantics; originally compared only by SB at runtime)
  property p_ar_const;
    @(posedge aclk) disable iff (!aresetn)
      axi_m_arvalid |-> (axi_m_arsize == 3'd2 &&
                         axi_m_arburst == 2'b01 && axi_m_arid == 4'd0);
  endproperty
  a_ar_const: assert property (p_ar_const);
  // (3) dout_tvalid must not be withdrawn before the handshake; data/keep/last remain stable on cycles without a handshake
  property p_do_stable;
    @(posedge aclk) disable iff (!aresetn)
      (dout_tvalid && !dout_tready) |=>
        (dout_tvalid && (dout_tdata === previous_dout_data) && (dout_tkeep === previous_dout_keep) &&
         (dout_tlast === previous_dout_last));
  endproperty
  a_do_stable: assert property (p_do_stable);

endinterface
