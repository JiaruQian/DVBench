`default_nettype none
module cpu_hazard (
  input  logic       execute_valid_i,
  input  logic       execute_uses_rs1_i,
  input  logic       execute_uses_rs2_i,
  input  logic [3:0] execute_rs1_i,
  input  logic [3:0] execute_rs2_i,
  input  logic       writeback_valid_i,
  input  logic       writeback_writes_rd_i,
  input  logic       writeback_result_ready_i,
  input  logic [3:0] writeback_rd_i,
  output logic       forward_rs1_o,
  output logic       forward_rs2_o,
  output logic       stall_o
);
  logic rs1_dependency, rs2_dependency;

  always_comb begin
    rs1_dependency = execute_valid_i && execute_uses_rs1_i &&
                     (execute_rs1_i != 4'd0) && writeback_valid_i &&
                     writeback_writes_rd_i &&
                     (execute_rs1_i == writeback_rd_i);
    rs2_dependency = execute_valid_i && execute_uses_rs2_i &&
                     (execute_rs2_i != 4'd0) && writeback_valid_i &&
                     writeback_writes_rd_i &&
                     (execute_rs2_i == writeback_rd_i);
    forward_rs1_o = rs1_dependency && writeback_result_ready_i;
    forward_rs2_o = rs2_dependency && writeback_result_ready_i;
    stall_o = (rs1_dependency || rs2_dependency) &&
              !writeback_result_ready_i;
  end
endmodule
`default_nettype wire
