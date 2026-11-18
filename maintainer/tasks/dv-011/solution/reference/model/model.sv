module dvbench_model(
  input logic Clock, input logic Reset, input logic Enabled,
  output logic OutVisible, output logic OutFP, output logic OutSP,
  output logic OutBP, output logic OutMax, output logic [9:0] OutCounter
);
  always_ff @(posedge Clock) begin
    if (Reset) OutCounter <= 10'd1;
    else if (Enabled) OutCounter <= (OutCounter == 10'd524) ? 10'd0 : OutCounter + 10'd1;
  end
  always_comb begin
    OutVisible = (OutCounter < 10'd480);
    OutFP = (OutCounter >= 10'd480) && (OutCounter < 10'd490);
    OutSP = (OutCounter >= 10'd490) && (OutCounter < 10'd492);
    OutBP = (OutCounter >= 10'd492) && (OutCounter < 10'd525);
    OutMax = (OutCounter == 10'd524);
  end
endmodule
