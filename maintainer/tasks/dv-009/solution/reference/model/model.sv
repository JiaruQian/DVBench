`timescale 1ns/1ps
module dvbench_model #(parameter FALL_THROUGH = 1, parameter FPGA_ALTERA = 0, parameter DATA_WIDTH = 32, parameter DEPTH = 8, parameter FPGA_EN = 0) (
input logic clk_i,
input logic rst_ni,
input logic flush_i,
input logic testmode_i,
output logic full_o,
output logic empty_o,
output logic [2:0] usage_o,
input logic [31:0] data_i,
input logic push_i,
output logic [31:0] data_o,
input logic pop_i
);
logic [31:0] pending_words[$];
logic [31:0] removed_word;
integer update_epoch=0;
always @(posedge clk_i or negedge rst_ni) begin
  if (!rst_ni) pending_words.delete();
  else if (flush_i) pending_words.delete();
  else if (!(pending_words.size()==0 && push_i && pop_i)) begin
    if (pop_i && pending_words.size()>0) removed_word=pending_words.pop_front();
    if (push_i) pending_words.push_back(data_i);
  end
  update_epoch=update_epoch+1;
end
always @(update_epoch or push_i or data_i) begin
  full_o=(pending_words.size()==8);
  usage_o=pending_words.size()%8;
  empty_o=(pending_words.size()==0 && !push_i);
  if (pending_words.size()>0) data_o=pending_words[0];
  else if (push_i) data_o=data_i;
  else data_o='0;
end
endmodule
