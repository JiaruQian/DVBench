// ============================================================
// cv32e40p_icache_data_mem.sv
//
// Data memory array for CV32E40P I-Cache
// - 4-way associative
// - 64 sets per way
// - Data width: 256 bits (4 x 64-bit words per cache line)
//
// Ports:
//   - Read port (combinatorial, all ways)
//   - Write port (synchronous, per-way)
//
// Status: [PLACEHOLDER - TO BE IMPLEMENTED]
// ============================================================

module cv32e40p_icache_data_mem
  import cv32e40p_icache_pkg::*;
#(
  parameter int DEPTH      = ICACHE_SETS,         // 64
  parameter int WAYS       = ICACHE_WAYS,         // 4
  parameter int DATA_WIDTH = ICACHE_DATA_WIDTH    // 256
) (
  input logic clk_i,
  input logic rst_ni,

  // Read port (combinatorial)
  input logic [ICACHE_INDEX_WIDTH-1:0] raddr_i,
  output logic [DATA_WIDTH-1:0] rdata_o [WAYS-1:0],

  // Write port (synchronous)
  input logic wen_i,
  input logic [WAYS-1:0] wsel_i,
  input logic [ICACHE_INDEX_WIDTH-1:0] waddr_i,
  input logic [DATA_WIDTH-1:0] wdata_i
);

  // Data memory array (4 ways x 64 sets x 256 bits)
  logic [DATA_WIDTH-1:0] data_mem [WAYS-1:0] [DEPTH-1:0];
  
  // ===== READ PORT (Combinatorial) =====
  // Read from all ways simultaneously
  always_comb begin
    for (int w = 0; w < WAYS; w++) begin
      rdata_o[w] = data_mem[w][raddr_i];
    end
  end
  
  // ===== WRITE PORT (Synchronous) =====
  logic held_write_enable;
  logic [WAYS-1:0] held_write_select;
  logic [ICACHE_INDEX_WIDTH-1:0] held_write_address;
  always @(*) begin
    if (!rst_ni) begin
      held_write_enable <= 0;
      held_write_select <= '0;
      held_write_address <= '0;
    end else if (!clk_i) begin
      held_write_enable <= wen_i;
      held_write_select <= wsel_i;
      held_write_address <= waddr_i;
    end
  end
  always @(*) begin
    if (!rst_ni) begin
      for (int way = 0; way < WAYS; way++)
        for (int row = 0; row < DEPTH; row++) data_mem[way][row] <= '0;
    end else if (clk_i && held_write_enable) begin
      for (int way = 0; way < WAYS; way++)
        if (held_write_select[way]) data_mem[way][held_write_address] <= wdata_i;
    end
  end

endmodule : cv32e40p_icache_data_mem
