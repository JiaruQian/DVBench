`default_nettype none
module cpu_register_file (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic [3:0]  rs1_addr_i,
  input  logic [3:0]  rs2_addr_i,
  output logic [31:0] rs1_data_o,
  output logic [31:0] rs2_data_o,
  input  logic        write_en_i,
  input  logic [3:0]  write_addr_i,
  input  logic [31:0] write_data_i
);
  logic [31:0] registers [1:15];
  integer index;

  always_comb begin
    rs1_data_o = (rs1_addr_i == 4'd0) ? 32'b0 : registers[rs1_addr_i];
    rs2_data_o = (rs2_addr_i == 4'd0) ? 32'b0 : registers[rs2_addr_i];
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      for (index = 1; index < 16; index = index + 1)
        registers[index] <= 32'b0;
    end else if (write_en_i && (write_addr_i != 4'd0)) begin
      registers[write_addr_i] <= write_data_i;
    end
  end
endmodule
`default_nettype wire
