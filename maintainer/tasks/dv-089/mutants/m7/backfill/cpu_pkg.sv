`default_nettype none
package cpu_pkg;
  localparam logic [5:0] OP_ALU_R  = 6'h00;
  localparam logic [5:0] OP_ALU_I  = 6'h01;
  localparam logic [5:0] OP_LUI    = 6'h02;
  localparam logic [5:0] OP_LOAD   = 6'h03;
  localparam logic [5:0] OP_STORE  = 6'h04;
  localparam logic [5:0] OP_BRANCH = 6'h05;
  localparam logic [5:0] OP_J      = 6'h06;
  localparam logic [5:0] OP_JAL    = 6'h07;
  localparam logic [5:0] OP_JR     = 6'h08;
  localparam logic [5:0] OP_JALR   = 6'h09;
  localparam logic [5:0] OP_SYSTEM = 6'h0a;

  typedef enum logic [3:0] {
    ALU_ADD  = 4'h0, ALU_SUB  = 4'h1, ALU_NEG  = 4'h2,
    ALU_MUL  = 4'h3, ALU_AND  = 4'h4, ALU_OR   = 4'h5,
    ALU_XOR  = 4'h6, ALU_NOT  = 4'h7, ALU_SLL  = 4'h8,
    ALU_SRL  = 4'h9, ALU_SRA  = 4'ha, ALU_SLT  = 4'hb,
    ALU_SLTU = 4'hc, ALU_SEQ  = 4'hd, ALU_SNE  = 4'he
  } alu_op_t;

  typedef enum logic [2:0] {
    BR_EQ = 3'd0, BR_NE = 3'd1, BR_LT = 3'd2,
    BR_GE = 3'd3, BR_LTU = 3'd4, BR_GEU = 3'd5
  } branch_op_t;

  typedef enum logic [3:0] {
    SYS_NOP = 4'd0, SYS_HALT = 4'd1, SYS_EBREAK = 4'd2,
    SYS_TRAP = 4'd3, SYS_MRET = 4'd4, SYS_CSRR = 4'd5,
    SYS_CSRW = 4'd6, SYS_EI = 4'd7, SYS_DI = 4'd8
  } system_op_t;
endpackage
`default_nettype wire
