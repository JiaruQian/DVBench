`default_nettype none
module cpu_decode (
  input  logic [31:0] instruction_i,
  output logic        legal_o,
  output logic [3:0]  rd_o,
  output logic [3:0]  rs1_o,
  output logic [3:0]  rs2_o,
  output logic [31:0] immediate_o,
  output logic        uses_rs1_o,
  output logic        uses_rs2_o,
  output logic        writes_rd_o,
  output logic        immediate_alu_o,
  output cpu_pkg::alu_op_t alu_op_o,
  output logic        load_o,
  output logic        store_o,
  output logic [2:0]  memory_subop_o,
  output logic        branch_o,
  output cpu_pkg::branch_op_t branch_op_o,
  output logic        jump_o,
  output logic        jump_register_o,
  output logic        link_o,
  output logic        lui_o,
  output logic        system_o,
  output cpu_pkg::system_op_t system_op_o,
  output logic [7:0]  csr_o,
  output logic [7:0]  system_imm_o
);
  import cpu_pkg::*;
  logic [5:0] opcode;
  logic [5:0] function6;
  logic [2:0] subop;

  always_comb begin
    opcode = instruction_i[31:26];
    function6 = instruction_i[13:8];
    subop = instruction_i[17:15];
    rd_o = instruction_i[25:22];
    rs1_o = instruction_i[21:18];
    rs2_o = instruction_i[17:14];
    immediate_o = {{17{instruction_i[14]}}, instruction_i[14:0]};
    legal_o = 1'b0;
    uses_rs1_o = 1'b0; uses_rs2_o = 1'b0; writes_rd_o = 1'b0;
    immediate_alu_o = 1'b0; alu_op_o = ALU_ADD;
    load_o = 1'b0; store_o = 1'b0; memory_subop_o = subop;
    branch_o = 1'b0; branch_op_o = BR_EQ;
    jump_o = 1'b0; jump_register_o = 1'b0; link_o = 1'b0;
    lui_o = 1'b0; system_o = 1'b0; system_op_o = SYS_NOP;
    csr_o = instruction_i[15:8]; system_imm_o = instruction_i[7:0];

    unique case (opcode)
      OP_ALU_R: begin
        uses_rs1_o = 1'b1; uses_rs2_o = 1'b1; writes_rd_o = 1'b1;
        legal_o = (instruction_i[7:0] == 8'b0) && (function6 <= 6'h0e);
        unique case (function6)
          6'h00: alu_op_o = ALU_ADD;  6'h01: alu_op_o = ALU_SUB;
          6'h02: alu_op_o = ALU_NEG;  6'h03: alu_op_o = ALU_MUL;
          6'h04: alu_op_o = ALU_AND;  6'h05: alu_op_o = ALU_OR;
          6'h06: alu_op_o = ALU_XOR;  6'h07: alu_op_o = ALU_NOT;
          6'h08: alu_op_o = ALU_SLL;  6'h09: alu_op_o = ALU_SRL;
          6'h0a: alu_op_o = ALU_SRA;  6'h0b: alu_op_o = ALU_SLT;
          6'h0c: alu_op_o = ALU_SLTU; 6'h0d: alu_op_o = ALU_SEQ;
          6'h0e: alu_op_o = ALU_SNE;  default: alu_op_o = ALU_ADD;
        endcase
        if ((function6 == 6'h02) || (function6 == 6'h07)) begin
          legal_o = legal_o && (rs2_o == 4'd0);
          uses_rs2_o = 1'b0;
        end
      end
      OP_ALU_I: begin
        uses_rs1_o = 1'b1; writes_rd_o = 1'b1; immediate_alu_o = 1'b1;
        legal_o = subop <= 3'd6;
        unique case (subop)
          3'd0: alu_op_o = ALU_ADD; 3'd1: alu_op_o = ALU_AND;
          3'd2: alu_op_o = ALU_OR;  3'd3: alu_op_o = ALU_XOR;
          3'd4: alu_op_o = ALU_SLL; 3'd5: alu_op_o = ALU_SRL;
          3'd6: alu_op_o = ALU_SRA; default: alu_op_o = ALU_ADD;
        endcase
        if (subop >= 3'd4) legal_o = legal_o && (instruction_i[14:5] == 10'b0);
      end
      OP_LUI: begin
        legal_o = instruction_i[5:0] == 6'b0; writes_rd_o = 1'b1; lui_o = 1'b1;
        immediate_o = {instruction_i[21:6], 16'b0};
      end
      OP_LOAD: begin
        legal_o = (subop <= 3'd4); uses_rs1_o = 1'b1;
        writes_rd_o = 1'b1; load_o = 1'b1;
      end
      OP_STORE: begin
        rs2_o = instruction_i[25:22];
        legal_o = (subop == 3'd0) || (subop == 3'd2) || (subop == 3'd4);
        uses_rs1_o = 1'b1; uses_rs2_o = 1'b1; store_o = 1'b1;
      end
      OP_BRANCH: begin
        rs2_o = instruction_i[25:22];
        legal_o = subop <= 3'd5; uses_rs1_o = 1'b1; uses_rs2_o = 1'b1;
        branch_o = 1'b1;
        unique case (subop)
          3'd0: branch_op_o = BR_EQ;  3'd1: branch_op_o = BR_NE;
          3'd2: branch_op_o = BR_LT;  3'd3: branch_op_o = BR_GE;
          3'd4: branch_op_o = BR_LTU; 3'd5: branch_op_o = BR_GEU;
          default: branch_op_o = BR_EQ;
        endcase
        immediate_o = {{15{instruction_i[14]}}, instruction_i[14:0], 2'b0};
      end
      OP_J, OP_JAL: begin
        legal_o = ((opcode == OP_J) && (rd_o == 4'd0)) ||
                  ((opcode == OP_JAL) && (rd_o != 4'd0));
        jump_o = 1'b1; link_o = opcode == OP_JAL; writes_rd_o = link_o;
        immediate_o = {{8{instruction_i[21]}}, instruction_i[21:0], 2'b0};
      end
      OP_JR, OP_JALR: begin
        legal_o = (subop == 3'd0) &&
                  (((opcode == OP_JR) && (rd_o == 4'd0)) ||
                   ((opcode == OP_JALR) && (rd_o != 4'd0)));
        uses_rs1_o = 1'b1; jump_o = 1'b1; jump_register_o = 1'b1;
        link_o = opcode == OP_JALR; writes_rd_o = link_o;
      end
      OP_SYSTEM: begin
        rd_o = instruction_i[19:16];
        system_o = 1'b1;
        if (instruction_i[25:20] <= 6'h08) begin
          unique case (instruction_i[25:20])
            6'h00: system_op_o = SYS_NOP;    6'h01: system_op_o = SYS_HALT;
            6'h02: system_op_o = SYS_EBREAK; 6'h03: system_op_o = SYS_TRAP;
            6'h04: system_op_o = SYS_MRET;   6'h05: system_op_o = SYS_CSRR;
            6'h06: system_op_o = SYS_CSRW;   6'h07: system_op_o = SYS_EI;
            6'h08: system_op_o = SYS_DI;     default: system_op_o = SYS_NOP;
          endcase
          unique case (instruction_i[25:20])
            6'h00, 6'h01, 6'h02, 6'h04, 6'h07, 6'h08:
              legal_o = instruction_i[19:0] == 20'b0;
            6'h03: legal_o = (rd_o == 4'd0) && (csr_o == 8'b0);
            6'h05: begin legal_o = system_imm_o == 8'b0; writes_rd_o = 1'b1; end
            6'h06: begin legal_o = (rd_o == 4'd0) && (system_imm_o[7:4] == 4'b0);
                            rs1_o = system_imm_o[3:0]; uses_rs1_o = 1'b1; end
            default: legal_o = 1'b0;
          endcase
        end
      end
      default: legal_o = 1'b0;
    endcase
  end
endmodule
`default_nettype wire
