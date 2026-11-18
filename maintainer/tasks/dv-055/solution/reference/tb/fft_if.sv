interface fft_if(input logic clk);
  logic rst;
  logic [4:0] m_addr;
  logic [15:0] m_data;
  logic m_we;
  logic [4:0] s_addr;
  logic s_re;
  logic [31:0] dut_data;
  logic [31:0] model_data;
  logic check_en = 0;
endinterface
