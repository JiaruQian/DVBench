`timescale 1ns/1ps
module dvbench_model (
input logic  alarm_button,
output logic  alarm_sound,
input logic  clock,
input logic  fastwatch,
input logic [3:0] key,
output logic [7:0] ls_hour,
output logic [7:0] ls_minute,
output logic [7:0] ms_hour,
output logic [7:0] ms_minute,
input logic  reset,
input logic  time_button
);

integer phase = 0;
integer minute_of_day = 0;
logic minute_pending = 0;
logic second_pending = 0;
always @(posedge clock or posedge reset) begin
  if (reset) begin
    phase = 0;
    minute_of_day = 0;
    minute_pending = 0;
    second_pending = 0;
  end else begin
    if (fastwatch ? second_pending : minute_pending)
      minute_of_day = (minute_of_day + 1) % 1440;
    phase = (phase + 1) % 15360;
    minute_pending = (phase == 0);
    second_pending = (phase % 256 == 0);
  end
end
always_comb begin
  ms_hour = 8'h30 + minute_of_day / 600;
  ls_hour = 8'h30 + (minute_of_day / 60) % 10;
  ms_minute = 8'h30 + (minute_of_day % 60) / 10;
  ls_minute = 8'h30 + minute_of_day % 10;
  alarm_sound = (minute_of_day == 0);
end

endmodule
