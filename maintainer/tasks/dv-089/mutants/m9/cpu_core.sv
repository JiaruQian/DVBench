`default_nettype none
module cpu_core (
  input  logic        clk_i,
  input  logic        rst_i,
  output logic        i_req_valid_o,
  input  logic        i_req_ready_i,
  output logic [31:0] i_req_addr_o,
  input  logic        i_rsp_valid_i,
  output logic        i_rsp_ready_o,
  input  logic [31:0] i_rsp_rdata_i,
  input  logic        i_rsp_error_i,
  output logic        d_req_valid_o,
  input  logic        d_req_ready_i,
  output logic [31:0] d_req_addr_o,
  output logic        d_req_write_o,
  output logic [31:0] d_req_wdata_o,
  output logic [3:0]  d_req_wstrb_o,
  input  logic        d_rsp_valid_i,
  output logic        d_rsp_ready_o,
  input  logic [31:0] d_rsp_rdata_i,
  input  logic        d_rsp_error_i,
  input  logic        timer_irq_i,
  input  logic        external_irq_i,
  output logic        halted_o,
  output logic        trap_o,
  output logic [7:0]  trap_cause_o,
  output logic [31:0] trap_badaddr_o,
  output logic        retire_valid_o,
  output logic [31:0] retire_pc_o,
  output logic [31:0] retire_instruction_o
);
  import cpu_pkg::*;

  // Fetch request/response state and one response buffer.
  logic [31:0] fetch_pc_q, fetch_request_pc_q;
  logic fetch_waiting_q, fetch_epoch_q, fetch_request_epoch_q;
  logic fetch_buffer_valid_q, fetch_buffer_error_q;
  logic [31:0] fetch_buffer_pc_q, fetch_buffer_instruction_q;

  // Decode/execute stage.
  logic x_valid_q, x_fetch_error_q;
  logic [31:0] x_pc_q, x_instruction_q;

  // Memory/writeback stage. Architectural effects occur only here.
  logic w_valid_q, w_writes_rd_q, w_memory_q, w_memory_write_q;
  logic w_trap_q, w_halt_q, w_memory_request_sent_q, w_system_q;
  logic [3:0] w_rd_q, w_memory_wstrb_q;
  logic [2:0] w_memory_subop_q;
  logic [7:0] w_trap_cause_q;
  system_op_t w_system_op_q;
  logic [7:0] w_csr_addr_q;
  logic [31:0] w_pc_q, w_instruction_q, w_result_q;
  logic [31:0] w_memory_addr_q, w_memory_wdata_q, w_trap_badaddr_q;
  logic [31:0] w_trap_epc_q, w_system_write_data_q, halt_resume_pc_q;

  // Decoder outputs for X.
  logic decode_legal, decode_uses_rs1, decode_uses_rs2, decode_writes_rd;
  logic decode_immediate_alu, decode_load, decode_store, decode_branch;
  logic decode_jump, decode_jump_register, decode_link, decode_lui;
  logic decode_system;
  logic [3:0] decode_rd, decode_rs1, decode_rs2;
  logic [2:0] decode_memory_subop;
  logic [7:0] decode_csr, decode_system_imm;
  logic [31:0] decode_immediate;
  alu_op_t decode_alu_op;
  branch_op_t decode_branch_op;
  system_op_t decode_system_op;

  logic [31:0] rs1_register, rs2_register, rs1_value, rs2_value;
  logic [31:0] alu_rhs, alu_result, effective_addr, control_target;
  logic [31:0] w_forward_value, load_value;
  logic branch_taken, alignment_error, x_fault, x_halt, x_csr_valid;
  logic [7:0] x_fault_cause;
  logic [31:0] x_fault_badaddr, x_fault_epc, x_result;
  logic [3:0] x_memory_wstrb;
  logic [31:0] x_memory_wdata;

  logic forward_rs1, forward_rs2, hazard_stall;
  logic w_result_ready, w_complete, w_terminal;
  logic w_register_write, w_successful_completion;
  logic x_advance, fetch_to_x, redirect_valid;
  logic [31:0] redirect_target;
  logic sync_trap_event, halt_event, mret_event, interrupt_take;
  logic pipeline_control_event, csr_redirect_event;
  logic [31:0] next_arch_pc, csr_redirect_target;
  logic csr_read_valid, csr_write_valid, csr_interrupt_enable;
  logic [1:0] csr_interrupt_pending;
  logic [31:0] csr_read_data, csr_trap_vector, csr_epc;
  logic csr_write_en, csr_retire, csr_trap_enter;
  logic [7:0] csr_trap_cause;
  logic [31:0] csr_trap_epc, csr_trap_badaddr;

  cpu_decode decoder (
    .instruction_i(x_instruction_q), .legal_o(decode_legal),
    .rd_o(decode_rd), .rs1_o(decode_rs1), .rs2_o(decode_rs2),
    .immediate_o(decode_immediate), .uses_rs1_o(decode_uses_rs1),
    .uses_rs2_o(decode_uses_rs2), .writes_rd_o(decode_writes_rd),
    .immediate_alu_o(decode_immediate_alu), .alu_op_o(decode_alu_op),
    .load_o(decode_load), .store_o(decode_store),
    .memory_subop_o(decode_memory_subop), .branch_o(decode_branch),
    .branch_op_o(decode_branch_op), .jump_o(decode_jump),
    .jump_register_o(decode_jump_register), .link_o(decode_link),
    .lui_o(decode_lui), .system_o(decode_system),
    .system_op_o(decode_system_op), .csr_o(decode_csr),
    .system_imm_o(decode_system_imm)
  );

  cpu_register_file register_file (
    .clk_i(clk_i), .rst_i(rst_i), .rs1_addr_i(decode_rs1),
    .rs2_addr_i(decode_rs2), .rs1_data_o(rs1_register),
    .rs2_data_o(rs2_register), .write_en_i(w_register_write),
    .write_addr_i(w_rd_q), .write_data_i(w_forward_value)
  );

  cpu_csr csr (
    .clk_i(clk_i), .rst_i(rst_i),
    .read_en_i(w_valid_q && w_system_q && (w_system_op_q == SYS_CSRR)),
    .read_addr_i(w_csr_addr_q), .read_data_o(csr_read_data),
    .read_valid_o(csr_read_valid), .write_en_i(csr_write_en),
    .write_addr_i(w_csr_addr_q), .write_data_i(w_system_write_data_q),
    .write_valid_o(csr_write_valid), .retire_i(csr_retire),
    .trap_enter_i(csr_trap_enter),
    .trap_interrupt_i(interrupt_take), .trap_cause_i(csr_trap_cause),
    .trap_epc_i(csr_trap_epc), .trap_badaddr_i(csr_trap_badaddr),
    .mret_i(mret_event),
    .set_ie_i(w_complete && w_system_q && (w_system_op_q == SYS_EI)),
    .clear_ie_i(w_complete && w_system_q && (w_system_op_q == SYS_DI)),
    .timer_pending_i(timer_irq_i), .external_pending_i(external_irq_i),
    .interrupt_enable_o(csr_interrupt_enable),
    .interrupt_pending_o(csr_interrupt_pending),
    .trap_vector_o(csr_trap_vector), .epc_o(csr_epc)
  );

  cpu_hazard hazard (
    .execute_valid_i(x_valid_q), .execute_uses_rs1_i(decode_uses_rs1),
    .execute_uses_rs2_i(decode_uses_rs2), .execute_rs1_i(decode_rs1),
    .execute_rs2_i(decode_rs2), .writeback_valid_i(w_valid_q),
    .writeback_writes_rd_i(w_writes_rd_q),
    .writeback_result_ready_i(w_result_ready), .writeback_rd_i(w_rd_q),
    .forward_rs1_o(forward_rs1), .forward_rs2_o(forward_rs2),
    .stall_o(hazard_stall)
  );

  assign rs1_value = forward_rs1 ? w_forward_value : rs1_register;
  assign rs2_value = forward_rs2 ? w_forward_value : rs2_register;
  assign alu_rhs = decode_immediate_alu ? decode_immediate : rs2_value;
  cpu_alu alu (.op_i(decode_alu_op), .lhs_i(rs1_value),
                   .rhs_i(alu_rhs), .result_o(alu_result));

  always_comb begin
    unique case (decode_branch_op)
      BR_EQ:  branch_taken = rs1_value == rs2_value;
      BR_NE:  branch_taken = rs1_value != rs2_value;
      BR_LT:  branch_taken = $signed(rs1_value) < $signed(rs2_value);
      BR_GE:  branch_taken = $signed(rs1_value) >= $signed(rs2_value);
      BR_LTU: branch_taken = rs1_value < rs2_value;
      BR_GEU: branch_taken = rs1_value >= rs2_value;
      default: branch_taken = 1'b0;
    endcase
  end

  assign effective_addr = rs1_value + decode_immediate;
  assign control_target = decode_jump_register ? effective_addr
                                                : x_pc_q + decode_immediate;

  always_comb begin
    unique case (decode_memory_subop)
      3'd0, 3'd1: alignment_error = 1'b0;
      3'd2, 3'd3: alignment_error = effective_addr[0];
      3'd4:       alignment_error = |effective_addr[1:0];
      default:    alignment_error = 1'b1;
    endcase
  end

  always_comb begin
    x_csr_valid = 1'b1;
    if (decode_system_op == SYS_CSRR)
      x_csr_valid = decode_csr <= 8'h0a;
    else if (decode_system_op == SYS_CSRW)
      x_csr_valid = (decode_csr == 8'h00) || (decode_csr == 8'h02) ||
                    (decode_csr == 8'h04) || (decode_csr == 8'h0a);
    x_fault = x_fetch_error_q || !decode_legal;
    x_fault_cause = x_fetch_error_q ? 8'd3 : 8'd1;
    x_fault_badaddr = x_fetch_error_q ? x_pc_q : x_instruction_q;
    x_fault_epc = x_pc_q;
    x_halt = 1'b0;
    if (decode_legal && (decode_load || decode_store) && alignment_error) begin
      x_fault = 1'b1;
      x_fault_cause = decode_store ? 8'd6 : 8'd4;
      x_fault_badaddr = effective_addr;
    end else if (decode_legal && decode_jump && (|control_target[1:0])) begin
      x_fault = 1'b1; x_fault_cause = 8'd2;
      x_fault_badaddr = control_target;
    end else if (decode_legal && decode_system) begin
      if (!x_csr_valid) begin
        x_fault = 1'b1; x_fault_cause = 8'd1;
        x_fault_badaddr = x_instruction_q;
      end else if (decode_system_op == SYS_HALT) begin
        x_halt = 1'b1;
      end else if ((decode_system_op == SYS_EBREAK) ||
                   (decode_system_op == SYS_TRAP)) begin
        x_fault = 1'b1;
        if (decode_system_op == SYS_EBREAK) x_fault_cause = 8'd9;
        else begin x_fault_cause = 8'd8; x_fault_epc = x_pc_q + 32'd4; end
        x_fault_badaddr = (decode_system_op == SYS_TRAP)
                          ? {24'b0, decode_system_imm} : x_instruction_q;
      end
    end
  end

  always_comb begin
    if (decode_lui) x_result = decode_immediate;
    else if (decode_link) x_result = x_pc_q + 32'd4;
    else x_result = alu_result;
    unique case (decode_memory_subop)
      3'd0: begin
        x_memory_wstrb = decode_store ? (4'b0001 << effective_addr[1:0]) : 4'b0;
        x_memory_wdata = rs2_value << (effective_addr[1:0] * 8);
      end
      3'd2: begin
        x_memory_wstrb = decode_store ? (4'b0011 << effective_addr[1:0]) : 4'b0;
        x_memory_wdata = rs2_value << (effective_addr[1:0] * 8);
      end
      default: begin
        x_memory_wstrb = decode_store ? 4'b1111 : 4'b0;
        x_memory_wdata = rs2_value;
      end
    endcase
  end

  always_comb begin
    logic [7:0] selected_byte;
    logic [15:0] selected_half;
    selected_byte = d_rsp_rdata_i >> (w_memory_addr_q[1:0] * 8);
    selected_half = d_rsp_rdata_i >> (w_memory_addr_q[1] * 16);
    unique case (w_memory_subop_q)
      3'd0: load_value = {{24{selected_byte[7]}}, selected_byte};
      3'd1: load_value = {24'b0, selected_byte};
      3'd2: load_value = {{16{selected_half[15]}}, selected_half};
      3'd3: load_value = {16'b0, selected_half};
      default: load_value = d_rsp_rdata_i;
    endcase
  end

  assign w_result_ready = !w_memory_q ||
                          (!w_memory_write_q && w_memory_request_sent_q &&
                           d_rsp_valid_i && !d_rsp_error_i);
  assign w_forward_value = (w_system_q && (w_system_op_q == SYS_CSRR))
                           ? csr_read_data
                           : (w_memory_q ? load_value : w_result_q);
  assign w_complete = w_valid_q &&
                      (!w_memory_q ||
                       (w_memory_request_sent_q && d_rsp_valid_i));
  assign sync_trap_event = w_complete &&
                           (w_trap_q || (w_memory_q && d_rsp_error_i));
  assign halt_event = w_complete && w_halt_q && !sync_trap_event;
  assign mret_event = w_complete && w_system_q &&
                      (w_system_op_q == SYS_MRET) && !sync_trap_event;
  assign w_terminal = sync_trap_event || halt_event || mret_event;
  assign w_successful_completion = w_complete && !w_trap_q &&
                                   !(w_memory_q && d_rsp_error_i);
  assign w_register_write = w_successful_completion && w_writes_rd_q &&
                            (w_rd_q != 4'd0);

  always_comb begin
    if (halted_o) next_arch_pc = halt_resume_pc_q;
    else if (x_valid_q) next_arch_pc = x_pc_q;
    else if (fetch_buffer_valid_q) next_arch_pc = fetch_buffer_pc_q;
    else if (fetch_waiting_q && (fetch_request_epoch_q == fetch_epoch_q))
      next_arch_pc = fetch_request_pc_q;
    else next_arch_pc = fetch_pc_q;
  end

  assign interrupt_take = csr_interrupt_enable &&
                          (|csr_interrupt_pending) && !sync_trap_event &&
                          !mret_event && !halt_event &&
                          (halted_o || !w_valid_q ||
                           (w_complete && !w_system_q));
  assign pipeline_control_event = w_terminal || interrupt_take;
  assign csr_redirect_event = sync_trap_event || mret_event || interrupt_take;
  assign csr_redirect_target = mret_event ? csr_epc : csr_trap_vector;

  assign x_advance = x_valid_q && !hazard_stall &&
                     (!w_valid_q || w_complete) && !pipeline_control_event &&
                     !(w_valid_q && w_system_q);
  assign redirect_valid = x_advance && !x_fault &&
                          (decode_jump || (decode_branch && branch_taken));
  assign redirect_target = control_target;
  assign fetch_to_x = fetch_buffer_valid_q && (!x_valid_q || x_advance) &&
                      !redirect_valid && !pipeline_control_event;

  assign csr_write_en = w_complete && w_system_q &&
                        (w_system_op_q == SYS_CSRW);
  assign csr_retire = w_successful_completion;
  assign csr_trap_enter = sync_trap_event || interrupt_take;
  assign csr_trap_cause = interrupt_take
                          ? (external_irq_i ? 8'd17 : 8'd16)
                          : (w_trap_q ? w_trap_cause_q
                                     : (w_memory_write_q ? 8'd7 : 8'd5));
  assign csr_trap_epc = interrupt_take ? next_arch_pc
                                      : (w_trap_q ? w_trap_epc_q : w_pc_q);
  assign csr_trap_badaddr = interrupt_take ? 32'b0
                          : (w_trap_q ? w_trap_badaddr_q : w_memory_addr_q);

  assign i_req_valid_o = fetch_waiting_q && !fetch_buffer_valid_q &&
                         !halted_o;
  assign i_req_addr_o = fetch_pc_q;
  assign i_rsp_ready_o = fetch_waiting_q;
  assign d_req_valid_o = w_valid_q && w_memory_q &&
                         !w_memory_request_sent_q;
  assign d_req_addr_o = w_memory_addr_q;
  assign d_req_write_o = w_memory_write_q;
  assign d_req_wdata_o = w_memory_wdata_q;
  assign d_req_wstrb_o = w_memory_wstrb_q;
  assign d_rsp_ready_o = w_valid_q && w_memory_q &&
                         w_memory_request_sent_q;

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      fetch_pc_q <= 32'b0; fetch_request_pc_q <= 32'b0;
      fetch_waiting_q <= 1'b0; fetch_epoch_q <= 1'b0;
      fetch_request_epoch_q <= 1'b0; fetch_buffer_valid_q <= 1'b0;
      fetch_buffer_error_q <= 1'b0; fetch_buffer_pc_q <= 32'b0;
      fetch_buffer_instruction_q <= 32'b0;
      x_valid_q <= 1'b0; x_fetch_error_q <= 1'b0;
      x_pc_q <= 32'b0; x_instruction_q <= 32'b0;
      w_valid_q <= 1'b0; w_writes_rd_q <= 1'b0; w_memory_q <= 1'b0;
      w_memory_write_q <= 1'b0; w_trap_q <= 1'b0; w_halt_q <= 1'b0;
      w_system_q <= 1'b0; w_system_op_q <= SYS_NOP; w_csr_addr_q <= 8'b0;
      w_memory_request_sent_q <= 1'b0; w_rd_q <= 4'b0;
      w_memory_wstrb_q <= 4'b0; w_memory_subop_q <= 3'b0;
      w_trap_cause_q <= 8'b0; w_pc_q <= 32'b0; w_instruction_q <= 32'b0;
      w_result_q <= 32'b0; w_memory_addr_q <= 32'b0;
      w_memory_wdata_q <= 32'b0; w_trap_badaddr_q <= 32'b0;
      w_trap_epc_q <= 32'b0; w_system_write_data_q <= 32'b0;
      halt_resume_pc_q <= 32'b0;
      halted_o <= 1'b0; trap_o <= 1'b0; trap_cause_o <= 8'b0;
      trap_badaddr_o <= 32'b0; retire_valid_o <= 1'b0;
      retire_pc_o <= 32'b0; retire_instruction_o <= 32'b0;
    end else begin
      retire_valid_o <= 1'b0;
      trap_o <= 1'b0;

      // Fetch transactions remain stable while waiting and carry an epoch.
      if (i_req_valid_o && i_req_ready_i) begin
        fetch_waiting_q <= 1'b1;
        fetch_request_pc_q <= fetch_pc_q;
        fetch_request_epoch_q <= fetch_epoch_q;
        fetch_pc_q <= fetch_pc_q + 32'd4;
      end
      if (i_rsp_valid_i && i_rsp_ready_o) begin
        fetch_waiting_q <= 1'b0;
        if ((fetch_request_epoch_q == fetch_epoch_q) &&
            !redirect_valid && !pipeline_control_event && !halted_o) begin
          fetch_buffer_valid_q <= 1'b1;
          fetch_buffer_error_q <= i_rsp_error_i;
          fetch_buffer_pc_q <= fetch_request_pc_q;
          fetch_buffer_instruction_q <= i_rsp_rdata_i;
        end
      end
      if (fetch_to_x) fetch_buffer_valid_q <= 1'b0;

      // Execute register accepts only current-epoch buffered instructions.
      if (pipeline_control_event || redirect_valid) begin
        x_valid_q <= 1'b0;
      end else if (fetch_to_x) begin
        x_valid_q <= 1'b1; x_fetch_error_q <= fetch_buffer_error_q;
        x_pc_q <= fetch_buffer_pc_q;
        x_instruction_q <= fetch_buffer_instruction_q;
      end else if (x_advance) begin
        x_valid_q <= 1'b0;
      end

      // W may complete an old instruction while accepting X in the same cycle.
      if (x_advance) begin
        w_valid_q <= 1'b1; w_pc_q <= x_pc_q;
        w_instruction_q <= x_instruction_q;
        w_writes_rd_q <= decode_writes_rd && !x_fault && !x_halt;
        w_rd_q <= decode_rd; w_result_q <= x_result;
        w_memory_q <= (decode_load || decode_store) && !x_fault;
        w_memory_write_q <= decode_store;
        w_memory_addr_q <= effective_addr;
        w_memory_wdata_q <= x_memory_wdata;
        w_memory_wstrb_q <= x_memory_wstrb;
        w_memory_subop_q <= decode_memory_subop;
        w_memory_request_sent_q <= 1'b0;
        w_trap_q <= x_fault; w_halt_q <= x_halt;
        w_trap_cause_q <= x_fault_cause;
        w_trap_badaddr_q <= x_fault_badaddr;
        w_trap_epc_q <= x_fault_epc;
        w_system_q <= decode_system && !x_fault;
        w_system_op_q <= decode_system_op;
        w_csr_addr_q <= decode_csr;
        w_system_write_data_q <= rs1_value;
      end else if (w_complete) begin
        w_valid_q <= 1'b0;
      end
      if (d_req_valid_o && d_req_ready_i)
        w_memory_request_sent_q <= 1'b1;

      // Commit is the only producer of architectural trace and trap state.
      if (w_complete) begin
        if (sync_trap_event) begin
          trap_o <= 1'b1;
          trap_cause_o <= csr_trap_cause;
          trap_badaddr_o <= csr_trap_badaddr;
        end else begin
          retire_valid_o <= 1'b1; retire_pc_o <= w_pc_q;
          retire_instruction_o <= w_instruction_q;
          if (w_halt_q) begin
            halted_o <= 1'b1;
            halt_resume_pc_q <= w_pc_q + 32'd4;
          end
        end
      end
      if (interrupt_take) begin
        trap_o <= 1'b1; trap_cause_o <= csr_trap_cause;
        trap_badaddr_o <= 32'b0; halted_o <= 1'b0;
      end

      // Redirects invalidate younger fetch state; accepted old requests drain.
      if (redirect_valid) begin
        fetch_epoch_q <= ~fetch_epoch_q;
        fetch_pc_q <= redirect_target;
        fetch_buffer_valid_q <= 1'b0;
      end
      if (halt_event) begin
        fetch_epoch_q <= ~fetch_epoch_q;
        fetch_buffer_valid_q <= 1'b0;
        x_valid_q <= 1'b0;
      end
      if (csr_redirect_event) begin
        fetch_epoch_q <= ~fetch_epoch_q;
        fetch_pc_q <= csr_redirect_target;
        fetch_buffer_valid_q <= 1'b0;
        x_valid_q <= 1'b0;
        halted_o <= 1'b0;
      end
    end
  end

  logic unused_decode;
  assign unused_decode = &{1'b0, csr_read_valid, csr_write_valid};
endmodule
`default_nettype wire
