## F-110-001

requirement_ids: R-N110-001

module: cv32e40p_compressed_decoder

definition: Fix FPU=0 and ZFINX=0. Purely combinational module, with no clock, reset, handshake, or state; observe after ensuring that the input combination has settled. When the low 2 bits of instr_i=11, instr_o equals all 32 bits of instr_i bit for bit, is_compressed=0, and illegal=0; the legality of the 32-bit instruction is not checked. For other low 2-bit values, is_compressed=1; only the low 16 bits participate in decoding, and the high 16 bits have no effect. When illegal=1, instr_o is outside the checking contract.

interface: instr_i, instr_o, is_compressed_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-002

requirement_ids: R-N110-002

module: cv32e40p_compressed_decoder

definition: A prime on a compressed register denotes x8..x15. Q0=00, funct3=000: C.ADDI4SPN expands to ADDI rd',x2,imm, with imm[9:6]=c[10:7], [5:4]=c[12:11], [3]=c[5], [2]=c[6], and the low 2 bits zero; imm=0 is illegal. funct3=010/110 is LW/SW, with rs1'=c[9:7]+8, rd'/rs2'=c[4:2]+8, and offset [6]=c[5], [5:3]=c[12:10], [2]=c[6], and the low 2 bits zero. funct3=100 is reserved and illegal.

interface: instr_i, instr_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-003

requirement_ids: R-N110-003

module: cv32e40p_compressed_decoder

definition: Q1=01. funct3=000 is ADDI rd,rd,sext(c12,c6:2); 010 is ADDI rd,x0,sext(c12,c6:2), namely LI. 011 with all 6 immediate bits zero is illegal; otherwise, rd=x2 is ADDI16SP, with imm[9]=c12, [8:7]=c4:3, [6]=c5, [5]=c2, [4]=c6, and the low 4 bits zero, sign-extended; other rd values give LUI, whose U immediate is sext(c12,c6:2)<<12. ADDI/LI/LUI with rd=0 and zero ADDI are legal hints.

interface: instr_i, instr_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-004

requirement_ids: R-N110-004

module: cv32e40p_compressed_decoder

definition: For Q1 funct3=100, c11:10=00/01 is SRLI/SRAI, operating on c9:7+8 with shift amount c6:2; c12=1 is illegal, and a zero shift is legal; 10 is ANDI using a signed 6-bit immediate; for 11 and c12=0, expand to SUB/XOR/OR/AND according to c6:5=00/01/10/11, with rs2=c4:2+8. 11 with c12=1 is reserved for RV64; all are illegal.

interface: instr_i, instr_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-005

requirement_ids: R-N110-005

module: cv32e40p_compressed_decoder

definition: Q1 funct3=001/101 is JAL x1/x0, with CJ offset [11]=c12, [10]=c8, [9:8]=c10:9, [7]=c6, [6]=c7, [5]=c2, [4]=c11, [3:1]=c5:3, and bit0=0, sign-extended. 110/111 is BEQ/BNE rs1',x0, with CB offset [8]=c12, [7:6]=c6:5, [5]=c2, [4:3]=c11:10, [2:1]=c4:3, and bit0=0, sign-extended into B format.

interface: instr_i, instr_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-006

requirement_ids: R-N110-006

module: cv32e40p_compressed_decoder

definition: Q2=10. funct3=000 is SLLI rd,rd,c6:2; c12=1 is illegal, and rd0/zero shift are legal hints. 010 is LW rd,imm(x2), with offset [7:6]=c3:2, [5]=c12, [4:2]=c6:4, and the low 2 bits zero; rd0 is illegal. 110 is SW rs2,imm(x2), with rs2=c6:2, offset [7:6]=c8:7, [5:2]=c12:9, and the low 2 bits zero. Group 100: when c12=0 and rs2=0, JR=JALR x0,rd,0, and rd0 is illegal; when c12=0 and rs2 is nonzero, MV=ADD rd,x0,rs2; when c12=1, rs2=0, and rd0, it is EBREAK=00100073, otherwise JALR x1,rd,0; when c12=1 and rs2 is nonzero, it is ADD rd,rd,rs2. rd0 for MV/ADD is a legal hint.

interface: instr_i, instr_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.

## F-110-007

requirement_ids: R-N110-007

module: cv32e40p_compressed_decoder

definition: Under the default parameters, funct3=001/011/101/111 in Q0 and Q2 are all illegal, with no expansion of floating-point memory accesses; the same funct3 values in Q1 still follow their integer definitions. Illegal compressed encodings still have is_compressed=1. There is no reset or dependence on the previous input; rapid alternation between legal/illegal inputs should yield the respective results after settling.

interface: instr_i, instr_o, is_compressed_o, illegal_instr_o

timing: Observe within the inter-edge, sampling-edge, and combinational-stability windows specified by this behavior.

boundary: Only the fixed default parameters and the legal input histories specified by this behavior apply; undefined outputs are not expanded into checking obligations.
