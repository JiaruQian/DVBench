`timescale 1ns/1ps
module dvbench_model(
input logic clk,
input logic rst_n,
input logic uart_rd_uart,
input logic uart_wr_uart,
input logic [7:0] uart_wr_data,
input logic uart_rx,
output logic uart_tx,
output logic [7:0] uart_rd_data,
output logic uart_rx_empty,
output logic uart_tx_full,
input logic kb_ps2d,
input logic kb_ps2c,
input logic kb_rd_fifo,
output logic [8:0] kb_rd_data,
output logic kb_fifo_empty,
output logic [7:0] ascii
);
integer baud_phase=0;
logic baud_started=0;
wire tick=baud_started && baud_phase==0;
integer tx_position,tx_ticks,rx_position,rx_ticks;
logic [7:0] tx_payload,rx_payload;
wire [7:0] tx_head;
wire tx_empty;
wire tx_complete=tx_position==9 && tx_ticks==15 && tick;
wire rx_complete=rx_position==8 && rx_ticks==15 && tick;
dvbench_queue4 #(.WIDTH(8)) transmit_queue(clk,rst_n,uart_wr_uart,tx_complete,uart_wr_data,tx_head,tx_empty,uart_tx_full);
dvbench_queue4 #(.WIDTH(8)) receive_queue(clk,rst_n,rx_complete,uart_rd_uart,rx_payload,uart_rd_data,uart_rx_empty,);
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin baud_phase<=0;baud_started<=0;end
else begin baud_phase<=(baud_phase+1)%4;baud_started<=1;end
end
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin tx_position<=-1;tx_ticks<=0;tx_payload<=0;uart_tx<=0;end
else if(tx_position==-1) begin
uart_tx<=1;
if(!tx_empty) begin tx_payload<=tx_head;tx_position<=0;tx_ticks<=0;end
end else begin
if(tx_position==0) uart_tx<=0;
else if(tx_position==9) uart_tx<=1;
else uart_tx<=tx_payload[tx_position-1];
if(tick) begin
if(tx_ticks==15) begin tx_ticks<=0;tx_position<=tx_position==9 ? -1 : tx_position+1;end
else tx_ticks<=tx_ticks+1;
end
end
end
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin rx_position<=-2;rx_ticks<=0;rx_payload<=0;end
else if(rx_position==-2) begin
if(!uart_rx) begin rx_position<=-1;rx_ticks<=0;end
end else if(tick) begin
if((rx_position==-1 && rx_ticks==7)||(rx_position>=0 && rx_ticks==15)) begin
rx_ticks<=0;
if(rx_position>=0 && rx_position<8) rx_payload[rx_position]<=uart_rx;
rx_position<=rx_position==8 ? -2 : rx_position+1;
end else rx_ticks<=rx_ticks+1;
end
end
logic [7:0] ps2_history;
logic ps2_filtered,ps2_previous;
logic [10:0] ps2_frame;
logic [7:0] ps2_byte;
integer ps2_count;
logic ps2_completed;
wire ps2_falling=ps2_previous && !ps2_filtered;
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin ps2_history<=0;ps2_filtered<=0;ps2_previous<=0;ps2_frame<=0;ps2_count<=0;ps2_completed<=0;ps2_byte<=0;end
else begin
ps2_history<={ps2_history[6:0],kb_ps2c};
if(ps2_history==8'hff) ps2_filtered<=1;
else if(ps2_history==0) ps2_filtered<=0;
ps2_previous<=ps2_filtered;
ps2_completed<=0;
if(ps2_falling) begin
ps2_frame[ps2_count]<=kb_ps2d;
if(ps2_count==10) begin ps2_byte<=ps2_frame[8:1];ps2_completed<=1;ps2_count<=0;end
else ps2_count<=ps2_count+1;
end
end
end
logic shift_pressed,drop_next,key_pending;
logic [8:0] key_pending_data;
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin shift_pressed<=0;drop_next<=0;key_pending<=0;key_pending_data<=0;end
else begin
key_pending<=0;
if(ps2_completed) begin
if(drop_next) begin
drop_next<=0;
if(ps2_byte==8'h12 || ps2_byte==8'h59) shift_pressed<=0;
end else if(ps2_byte==8'hf0) drop_next<=1;
else if(ps2_byte==8'h12 || ps2_byte==8'h59) shift_pressed<=1;
else begin key_pending<=1;key_pending_data<={shift_pressed,ps2_byte};end
end
end
end
dvbench_queue4 #(.WIDTH(9)) keyboard_queue(clk,rst_n,key_pending,kb_rd_fifo,key_pending_data,kb_rd_data,kb_fifo_empty,);
dvbench_ascii_reference decoder(.rd_data(kb_rd_data),.ascii(ascii));
endmodule

module dvbench_queue4 #(parameter WIDTH=8)(input wire clk,input wire rst_n,input wire push,input wire pop,input wire [WIDTH-1:0] incoming,output wire [WIDTH-1:0] outgoing,output wire empty,output wire full);
logic [WIDTH-1:0] history[0:3];
integer first=0,next=0,occupancy=0;
assign outgoing=history[first];
assign empty=occupancy==0;
assign full=occupancy==4;
always @(posedge clk or negedge rst_n) begin
if(!rst_n) begin first<=0;next<=0;occupancy<=0;end
else case({pop,push})
2'b01:if(occupancy<4) begin history[next]<=incoming;next<=(next+1)%4;occupancy<=occupancy+1;end
2'b10:if(occupancy>0) begin first<=(first+1)%4;occupancy<=occupancy-1;end
2'b11:if(occupancy>0 && occupancy<4) begin history[next]<=incoming;next<=(next+1)%4;first<=(first+1)%4;end
default:begin end
endcase
end
endmodule

module dvbench_ascii_reference(
input logic [8:0] rd_data,
output logic [7:0] ascii
);
integer index; logic [7:0] codes [0:25]; logic [7:0] digits [0:9]; logic [7:0] punctuation [0:13]; logic [7:0] values [0:13];
initial begin
codes[0]=8'h1c;
codes[1]=8'h32;
codes[2]=8'h21;
codes[3]=8'h23;
codes[4]=8'h24;
codes[5]=8'h2b;
codes[6]=8'h34;
codes[7]=8'h33;
codes[8]=8'h43;
codes[9]=8'h3b;
codes[10]=8'h42;
codes[11]=8'h4b;
codes[12]=8'h3a;
codes[13]=8'h31;
codes[14]=8'h44;
codes[15]=8'h4d;
codes[16]=8'h15;
codes[17]=8'h2d;
codes[18]=8'h1b;
codes[19]=8'h2c;
codes[20]=8'h3c;
codes[21]=8'h2a;
codes[22]=8'h1d;
codes[23]=8'h22;
codes[24]=8'h35;
codes[25]=8'h1a;
digits[0]=8'h45;
digits[1]=8'h16;
digits[2]=8'h1e;
digits[3]=8'h26;
digits[4]=8'h25;
digits[5]=8'h2e;
digits[6]=8'h36;
digits[7]=8'h3d;
digits[8]=8'h3e;
digits[9]=8'h46;
punctuation[0]=8'h0e;
punctuation[1]=8'h4e;
punctuation[2]=8'h55;
punctuation[3]=8'h54;
punctuation[4]=8'h5b;
punctuation[5]=8'h5d;
punctuation[6]=8'h4c;
punctuation[7]=8'h52;
punctuation[8]=8'h41;
punctuation[9]=8'h49;
punctuation[10]=8'h4a;
punctuation[11]=8'h29;
punctuation[12]=8'h5a;
punctuation[13]=8'h66;
values[0]=8'h60;
values[1]=8'h2d;
values[2]=8'h3d;
values[3]=8'h5b;
values[4]=8'h5d;
values[5]=8'h5c;
values[6]=8'h3b;
values[7]=8'h27;
values[8]=8'h2c;
values[9]=8'h2e;
values[10]=8'h2f;
values[11]=8'h20;
values[12]=8'h0d;
values[13]=8'h08;
end
always @* begin
ascii=8'h2a;
for(index=0;index<26;index=index+1) begin
if(rd_data === {1'b0,codes[index]}) ascii=8'd97+index;
if(rd_data === {1'b1,codes[index]}) ascii=8'd65+index;
end
for(index=0;index<10;index=index+1) if(rd_data === {1'b0,digits[index]}) ascii=8'd48+index;
for(index=0;index<14;index=index+1) if(rd_data === {1'b0,punctuation[index]}) ascii=values[index];
end
endmodule
