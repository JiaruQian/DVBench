module dvbench_model(
  input logic [0:3] alu_cmd,
  input logic [0:63] fxu_areg_q, fxu_breg_q,
  input logic local_error_found,
  output logic [0:63] bin_sum,
  output logic bin_ovfl
);
  logic [0:63] effective_b;
  logic signed [64:0] wide_result;
  always_comb begin
    effective_b = fxu_breg_q;
    effective_b[51] = local_error_found ? fxu_breg_q[50] : fxu_breg_q[51];
    effective_b[59] = local_error_found ? fxu_breg_q[58] : fxu_breg_q[59];
    wide_result = (alu_cmd == 4'b0010)
      ? $signed({fxu_areg_q[0], fxu_areg_q}) - $signed({fxu_breg_q[0], fxu_breg_q})
      : $signed({fxu_areg_q[0], fxu_areg_q}) + $signed({effective_b[0], effective_b});
    bin_sum = wide_result[63:0];
    bin_ovfl = wide_result[64] ^ wide_result[63];
  end
endmodule
