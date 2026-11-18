`default_nettype none
module cpu_alu (
  input  cpu_pkg::alu_op_t op_i,
  input  logic [31:0]           lhs_i,
  input  logic [31:0]           rhs_i,
  output logic [31:0]           result_o
);
  import cpu_pkg::*;

  always_comb begin
    unique case (op_i)
      ALU_ADD:  result_o = lhs_i + rhs_i;
      ALU_SUB:  result_o = lhs_i - rhs_i;
      ALU_NEG:  result_o = 32'b0 - lhs_i;
      ALU_MUL:  result_o = lhs_i * rhs_i;
      ALU_AND:  result_o = lhs_i & rhs_i;
      ALU_OR:   result_o = lhs_i | rhs_i;
      ALU_XOR:  result_o = lhs_i ^ rhs_i;
      ALU_NOT:  result_o = ~lhs_i;
      ALU_SLL:  result_o = lhs_i << rhs_i[4:0];
      ALU_SRL:  result_o = lhs_i >> rhs_i[4:0];
      ALU_SRA:  result_o = $unsigned($signed(lhs_i) >>> rhs_i[4:0]);
      ALU_SLT:  result_o = {31'b0, $signed(lhs_i) < $signed(rhs_i)};
      ALU_SLTU: result_o = {31'b0, lhs_i < rhs_i};
      ALU_SEQ:  result_o = {31'b0, lhs_i == rhs_i};
      ALU_SNE:  result_o = {31'b0, lhs_i != rhs_i};
      default:  result_o = 32'b0;
    endcase
  end
endmodule
`default_nettype wire
