`timescale 1ns/1ps
module CKLNQD12(input logic TE,CP,E,output wire Q);
logic held_enable;
always @* if(!CP)held_enable=E|TE;
assign Q=CP&held_enable;
endmodule
