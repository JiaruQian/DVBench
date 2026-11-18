`default_nettype none
module cpu_csr (
  input  logic        clk_i,
  input  logic        rst_i,
  input  logic        read_en_i,
  input  logic [7:0]  read_addr_i,
  output logic [31:0] read_data_o,
  output logic        read_valid_o,
  input  logic        write_en_i,
  input  logic [7:0]  write_addr_i,
  input  logic [31:0] write_data_i,
  output logic        write_valid_o,
  input  logic        retire_i,
  input  logic        trap_enter_i,
  input  logic        trap_interrupt_i,
  input  logic [7:0]  trap_cause_i,
  input  logic [31:0] trap_epc_i,
  input  logic [31:0] trap_badaddr_i,
  input  logic        mret_i,
  input  logic        set_ie_i,
  input  logic        clear_ie_i,
  input  logic        timer_pending_i,
  input  logic        external_pending_i,
  output logic        interrupt_enable_o,
  output logic [1:0]  interrupt_pending_o,
  output logic [31:0] trap_vector_o,
  output logic [31:0] epc_o
);
  logic [1:0] status_q;
  logic [31:0] epc_q, cause_q, tvec_q, badaddr_q, scratch_q;
  logic [63:0] cycle_q, instret_q;

  assign interrupt_enable_o = status_q[0];
  assign interrupt_pending_o = {external_pending_i, timer_pending_i};
  assign trap_vector_o = tvec_q;
  assign epc_o = epc_q;

  always_comb begin
    read_data_o = 32'b0;
    read_valid_o = read_en_i;
    unique case (read_addr_i)
      8'h00: read_data_o = {30'b0, status_q};
      8'h01: read_data_o = {30'b0, interrupt_pending_o};
      8'h02: read_data_o = epc_q;
      8'h03: read_data_o = cause_q;
      8'h04: read_data_o = tvec_q;
      8'h05: read_data_o = badaddr_q;
      8'h06: read_data_o = cycle_q[31:0];
      8'h07: read_data_o = cycle_q[63:32];
      8'h08: read_data_o = instret_q[31:0];
      8'h09: read_data_o = instret_q[63:32];
      8'h0a: read_data_o = scratch_q;
      default: begin read_data_o = 32'b0; read_valid_o = 1'b0; end
    endcase
  end

  always_comb begin
    unique case (write_addr_i)
      8'h00, 8'h02, 8'h04, 8'h0b: write_valid_o = write_en_i;
      default: write_valid_o = 1'b0;
    endcase
  end

  always_ff @(posedge clk_i) begin
    if (rst_i) begin
      status_q <= 2'b0; epc_q <= 32'b0; cause_q <= 32'b0;
      tvec_q <= 32'b0; badaddr_q <= 32'b0; scratch_q <= 32'b0;
      cycle_q <= 64'b0; instret_q <= 64'b0;
    end else begin
      cycle_q <= cycle_q + 64'd1;
      if (retire_i) instret_q <= instret_q + 64'd1;

      if (trap_enter_i) begin
        epc_q <= {trap_epc_i[31:2], 2'b0};
        cause_q <= {trap_interrupt_i, 23'b0, trap_cause_i};
        badaddr_q <= trap_badaddr_i;
        status_q[1] <= status_q[0];
        status_q[0] <= 1'b0;
      end else if (mret_i) begin
        status_q[0] <= status_q[1];
        status_q[1] <= 1'b1;
      end else begin
        if (write_en_i && write_valid_o) begin
          unique case (write_addr_i)
            8'h00: status_q <= write_data_i[1:0];
            8'h02: epc_q <= {write_data_i[31:2], 2'b0};
            8'h04: tvec_q <= {write_data_i[31:2], 2'b0};
            8'h0a: scratch_q <= write_data_i;
            default: begin end
          endcase
        end
        if (set_ie_i) status_q[0] <= 1'b1;
        if (clear_ie_i) status_q[0] <= 1'b0;
      end
    end
  end
endmodule
`default_nettype wire
