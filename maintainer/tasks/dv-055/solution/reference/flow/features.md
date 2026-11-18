# features

## F-INPUT-WRITE

requirement_ids: R-dv-055-001

module: fft_wrapper input storage

definition: A rising edge with m_we high stores m_data at m_addr. A frame under test supplies one new value to each address 0 through 31.

interface: clk, m_we, m_addr, m_data

timing: The input memory write is sampled at the rising edge of clk.

boundary: The input memory is not initialized by rst. Tests write all 32 words before checking a frame. With m_we low, address and data changes do not alter stored values.

## F-FFT-DATA

requirement_ids: R-dv-055-003, R-dv-055-004

module: fft_wrapper continuous transform

definition: The fixed default profile computes a 32-point forward radix-2 transform of signed Q8.8 real samples. It uses the public coefficient table, bit-reversed input order, separately truncated Q8.8 products, and 16-bit wraparound at each addition or subtraction. For each stage span L=2,4,8,16,32 and j=0..L/2-1, k=j*32/L, t_r=qmul(b_r,C[k])+qmul(b_i,S[k]), t_i=qmul(b_i,C[k])-qmul(b_r,S[k]); the two butterfly results are a+t and a-t. qmul truncates the unsigned magnitude product by 256 toward zero then restores its sign. Output frequency indices are natural order.

interface: clk, rst, m_addr, m_data, m_we, s_addr, s_re, s_data

timing: The core runs continuously without start, ready, or done. The transform result is checked after all 32 frame words are written and at least 20 rising edges elapse with no further writes.

boundary: The task fixes DIVISOR=5, N=16, Q=8, ADDR_WIDTH=5, DATA_WIDTH=16, DEPTH=32. Partial frames and intermediate outputs during writes are outside the checked window. Active-high asynchronous rst restarts control; RAM contents are not initialized. After reset rewrite all 32 addresses and wait the same 20-edge interval.

## F-OUTPUT-READ

requirement_ids: R-dv-055-002

module: fft_wrapper output storage

definition: s_re requests a registered read of the output word selected by s_addr. s_data packs the signed real result in bits 31:16 and the signed imaginary result in bits 15:0.

interface: clk, s_re, s_addr, s_data

timing: The read address is sampled at a rising edge; s_data updates after that edge. When s_re is low, s_data holds its previous value.

boundary: The output memory and s_data register are not reset. Comparisons occur only after one complete, settled frame has made the selected output word known.
