// pcs10g_if.sv -- XGMII 10G PCS TX UVM interface
// DUT: xgmii_pcs_10g_tx (clk, nreset, xgmii_txd_i[63:0], xgmii_txc_i[7:0], ready_o, data_o[63:0])
interface pcs10g_if ();

  // integer half-period clock (real-valued delay is ~300x slower in VCS)
  int unsigned half = 5;              // 10ns period
  logic clk = 1'b0;

  // reset is self-held by the interface: driver/test never fight it
  logic nreset = 1'b0;

  // XGMII TX side. MUST be clean 2-state from t=0: any X fed through the
  // self-synchronous scrambler latches X into s_q permanently (until reset).
  logic [63:0] txd = 64'h0;
  logic [7:0]  txc = 8'hff;           // idle word during boot

  logic expected_ready;
  logic [63:0] expected_data;

  // serdes side (observe only)
  logic        ready_o;
  logic [63:0] data_o;

  initial forever #(half) clk = ~clk;

  // power-on reset release (between edges, no sampling race)
  initial begin
    repeat (3) @(negedge clk);
    nreset = 1'b1;
  end

  // mid-stream reset injection (F01/F07)
  task pulse_reset();
    @(negedge clk); nreset = 1'b0;
    repeat (4) @(posedge clk);
    @(negedge clk); nreset = 1'b1;
  endtask

  // driver is the sole writer of txd/txc
  clocking drv_cb @(posedge clk);
    default input #1step output #1;
    output txd, txc;
    input  ready_o;
  endclocking

  // monitor is read-only
  clocking mon_cb @(posedge clk);
    default input #1step;
    input txd, txc, nreset, ready_o, data_o, expected_ready, expected_data;
  endclocking

endinterface
