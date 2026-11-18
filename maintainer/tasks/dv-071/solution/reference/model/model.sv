`timescale 1ns/1ps
module dvbench_model(
  input logic Reset, Clk, clk_en, iEmpty,
  input logic [15:0] i8Data,
  output logic [7:0] gmii_txd,
  output logic gmii_tx_en, gmii_tx_er, complete, oRead,
  output logic [2:0] diagnostic,
  output logic [8:0] Addres
);
  localparam logic [95:0] HEADER=96'hc8600098ccbe123456789abc;
  integer phase, phase_age, byte_index;
  logic read_parity=0, fifo_available;
  logic [7:0] queued_byte;
  logic queued_valid, queued_crc_byte, queued_crc_init, queued_crc_read;
  logic [31:0] reflected_crc;
  function automatic logic [31:0] update_crc(input logic [31:0] previous, input logic [7:0] data);
    logic [31:0] accumulator;
    accumulator=previous;
    for (int bit_index=0; bit_index<8; bit_index++)
      accumulator=(accumulator>>1) ^ ((accumulator[0]^data[bit_index]) ? 32'hedb88320 : 32'b0);
    return accumulator;
  endfunction
  always_comb begin
    diagnostic=phase[2:0];
    complete=(phase==0);
    Addres=(byte_index>>1)&9'h1ff;
    oRead=~read_parity;
    gmii_tx_er=0;
  end
  always @(negedge Clk) begin
    if (Reset) read_parity<=0;
    else read_parity<=~read_parity;
  end
  always @(posedge Clk) begin : predict_history
    integer next_phase;
    logic [7:0] emitted_byte;
    if (Reset) begin
      phase=0; phase_age=0; byte_index=0; fifo_available=0;
      queued_byte=0; queued_valid=0; queued_crc_byte=0;
      queued_crc_init=0; queued_crc_read=0;
      reflected_crc=32'hffffffff;
      gmii_txd<=0; gmii_tx_en<=0;
    end else if (clk_en) begin
      if (phase==5 && phase_age>=1) begin
        gmii_txd<=~reflected_crc[7:0]; gmii_tx_en<=1;
      end else begin
        gmii_txd<=queued_byte; gmii_tx_en<=queued_valid;
      end
      if (queued_crc_init) reflected_crc=32'hffffffff;
      else if (queued_crc_byte) reflected_crc=update_crc(reflected_crc,queued_byte);
      else if (queued_crc_read) reflected_crc=(reflected_crc>>8)|32'hff000000;
      next_phase=phase;
      case (phase)
        0: if (!iEmpty) next_phase=1;
        1: if (phase_age==6) next_phase=2;
        2: next_phase=3;
        3: if (phase_age==11) next_phase=4;
        4: if (iEmpty || byte_index==1023 || !fifo_available) next_phase=5;
        5: if (phase_age==4) next_phase=6;
        6: if (phase_age==12) next_phase=0;
      endcase
      emitted_byte=0;
      case (phase)
        1: emitted_byte=8'h55;
        2: emitted_byte=8'hd5;
        3: emitted_byte=HEADER>>(8*(11-phase_age));
        4: emitted_byte=byte_index[0] ? i8Data[7:0] : i8Data[15:8];
      endcase
      queued_byte=emitted_byte;
      queued_valid=phase>=1 && phase<=4;
      queued_crc_byte=phase==3 || phase==4;
      queued_crc_init=phase==2;
      queued_crc_read=phase==5;
      fifo_available=!iEmpty && byte_index!=1023 && ((phase==3 && phase_age>=10) || phase==4);
      if (phase==4 && !iEmpty && byte_index!=1023) byte_index++;
      else byte_index=0;
      if (next_phase!=phase) phase_age=0;
      else if (phase!=0) phase_age++;
      phase=next_phase;
    end
  end
endmodule
