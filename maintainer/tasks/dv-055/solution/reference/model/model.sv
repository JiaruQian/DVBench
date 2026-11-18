`timescale 1ns/1ps

module dvbench_model (
  input  logic        clk,
  input  logic        rst,
  input  logic [4:0]  m_addr,
  input  logic [15:0] m_data,
  input  logic        m_we,
  input  logic [4:0]  s_addr,
  input  logic        s_re,
  output logic [31:0] s_data
);

  localparam logic [15:0] TR [0:15] = '{16'h0100,16'h00FB,16'h00EC,16'h00D4,
    16'h00B4,16'h008E,16'h0062,16'h0031,16'h0000,16'hFFCF,16'hFF9E,
    16'hFF72,16'hFF4C,16'hFF2C,16'hFF14,16'hFF05};
  localparam logic [15:0] TI [0:15] = '{16'h0000,16'h0031,16'h0062,16'h008E,
    16'h00B4,16'h00D4,16'h00EC,16'h00FB,16'h0100,16'h00FB,16'h00EC,
    16'h00D4,16'h00B4,16'h008E,16'h0062,16'h0031};
  logic [15:0] input_words [0:31];
  logic [31:0] output_words [0:31];
  logic [31:0] pending_words [0:31];
  logic [31:0] frame_seen;
  logic        frame_pending;
  logic [4:0]  settle_count;

  function automatic logic [15:0] qmul(input logic [15:0] a, input logic [15:0] b);
    logic [15:0] ma, mb, magnitude;
    logic [31:0] product;
    begin
      ma = a[15] ? (~a + 16'h0001) : a;
      mb = b[15] ? (~b + 16'h0001) : b;
      product = ma * mb;
      magnitude = product[23:8];
      qmul = (a[15] ^ b[15]) ? (~magnitude + 16'h0001) : magnitude;
    end
  endfunction

  function automatic logic [15:0] neg16(input logic [15:0] value);
    neg16 = ~value + 16'h0001;
  endfunction

  task automatic compute_frame(input logic [4:0] final_addr,
                               input logic [15:0] final_data);
    logic [15:0] sr [0:31], si [0:31], nr [0:31], ni [0:31];
    logic [15:0] xin [0:31];
    logic [15:0] ar, ai, br, bi, wr, wi;
    integer i, stage, span, half_span, base, j, left_index, right_index;
    integer twiddle;
    logic [4:0] reversed;
    begin
      for (i = 0; i < 32; i = i + 1) begin
        reversed = {i[0], i[1], i[2], i[3], i[4]};
        xin[i] = (reversed == final_addr) ? final_data : input_words[reversed];
        sr[i] = 16'h0000;
        si[i] = 16'h0000;
      end
      for (stage = 0; stage < 5; stage = stage + 1) begin
        span = 1 << (stage + 1);
        half_span = span >> 1;
        for (base = 0; base < 32; base = base + span) begin
          for (j = 0; j < half_span; j = j + 1) begin
            left_index = base + j;
            right_index = left_index + half_span;
            if (stage == 0) begin
              ar = xin[left_index]; ai = 16'h0000;
              br = xin[right_index]; bi = 16'h0000;
            end else begin
              ar = sr[left_index]; ai = si[left_index];
              br = sr[right_index]; bi = si[right_index];
            end
            twiddle = j * (32 / span);
            wr = TR[twiddle];
            wi = TI[twiddle];
            nr[left_index] = ar + qmul(br, wr) + qmul(bi, wi);
            ni[left_index] = ai + neg16(qmul(br, wi)) + qmul(bi, wr);
            nr[right_index] = ar + neg16(qmul(br, wr)) + neg16(qmul(bi, wi));
            ni[right_index] = ai + neg16(qmul(bi, wr)) + qmul(br, wi);
          end
        end
        for (i = 0; i < 32; i = i + 1) begin
          sr[i] = nr[i];
          si[i] = ni[i];
        end
      end
      for (i = 0; i < 32; i = i + 1)
        pending_words[i] = {sr[i], si[i]};
    end
  endtask

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      frame_seen   <= 32'b0;
      frame_pending <= 1'b0;
      settle_count <= 5'b0;
    end else begin
      if (frame_pending) begin
        if (settle_count == 5'd19) begin
          for (integer k = 0; k < 32; k = k + 1)
            output_words[k] <= pending_words[k];
          frame_pending <= 1'b0;
        end else begin
          settle_count <= settle_count + 1'b1;
        end
      end

      if (m_we) begin
        input_words[m_addr] <= m_data;
        if (&frame_seen)
          frame_seen <= (32'b1 << m_addr);
        else
          frame_seen[m_addr] <= 1'b1;

        if (!( &frame_seen) &&
            ((frame_seen | (32'b1 << m_addr)) == 32'hffff_ffff)) begin
          compute_frame(m_addr, m_data);
          frame_pending <= 1'b1;
          settle_count <= 5'b0;
        end
      end
    end
  end

  always @(posedge clk) begin
    if (s_re)
      s_data <= output_words[s_addr];
  end

endmodule
