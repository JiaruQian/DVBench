`timescale 1ns/1ps
// Behavioral predictor: input-history windows and scalar mathematical decisions.
// No DUT instance, output read, internal hierarchy or golden-output trace.
module dvbench_model(
 input clk,reset_n,bayer_format,
 input [7:0] i_dpc_threshold,input [2:0] i_video_syn,
 input [7:0] i_data_r0,i_data_r1,i_data_r2,i_data_r3,i_data_r4,
 output [2:0] o_video_sync,output reg [7:0] o_data
);
 logic [7:0] pixels[5][5];
 logic [11:0] sync_v,sync_d,sync_h;
 logic px_phase,line_phase,previous_gate;
 logic [7:0] windows[7][9];
 integer differences[4][8];
 logic [7:0] threshold_history[2];
 logic [7:0] incoming[5],selected[9],ordered[9],median_value;
 logic [7:0] sign_pattern;
 integer difference,magnitude;
 logic replace_pixel;
 always_comb begin
   incoming[0]=i_data_r0; incoming[1]=i_data_r1; incoming[2]=i_data_r2;
   incoming[3]=i_data_r3; incoming[4]=i_data_r4;
   if(px_phase==line_phase) begin
     for(int r=0;r<3;r++) for(int c=0;c<3;c++) selected[3*r+c]=pixels[2*r][2*c];
   end else begin
     selected[0]=pixels[1][1]; selected[1]=pixels[0][2]; selected[2]=pixels[1][3];
     selected[3]=pixels[2][0]; selected[4]=pixels[2][2]; selected[5]=pixels[2][4];
     selected[6]=pixels[3][1]; selected[7]=pixels[4][2]; selected[8]=pixels[3][3];
   end
 end
 // Only sampling history and parity are reset; arithmetic observation is masked
 // by the public 16-edge settling window in the scoreboard.
 always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
     foreach(pixels[r,c]) pixels[r][c]<=0;
     sync_v<=0; sync_d<=0; sync_h<=0;
     px_phase<=0; line_phase<=0; previous_gate<=0;
   end else begin
     for(int r=0;r<5;r++) begin
       for(int c=0;c<4;c++) pixels[r][c]<=pixels[r][c+1];
       pixels[r][4]<=incoming[r];
     end
     sync_v<={sync_v[10:0],i_video_syn[2]};
     sync_d<={sync_d[10:0],i_video_syn[1]};
     sync_h<={sync_h[10:0],i_video_syn[0]};
     if(sync_d[4:3]==2'b01) px_phase<=~bayer_format;
     else if(sync_d[4]) px_phase<=~px_phase;
     if(sync_v[4:3]==2'b10) line_phase<=0;
     else if(sync_d[4:3]==2'b01) line_phase<=~line_phase;
     previous_gate<=sync_d[5];
   end
 end
 always @(posedge clk) begin
   // Entire neighborhood sorting is independent of the DUT sorting network.
   for(int i=0;i<9;i++) ordered[i]=windows[5][i];
   for(int i=0;i<9;i++) for(int j=i+1;j<9;j++)
     if(ordered[j]<ordered[i]) begin
       median_value=ordered[i]; ordered[i]=ordered[j]; ordered[j]=median_value;
     end
   median_value=ordered[4];
   sign_pattern=0; replace_pixel=1;
   for(int k=0;k<8;k++) begin
     difference=differences[3][k];
     sign_pattern[7-k]=(difference<0);
     magnitude=(difference<0)?(-difference-1):difference;
     if(!(magnitude>threshold_history[1])) replace_pixel=0;
   end
   replace_pixel=replace_pixel && (sign_pattern==8'h00 || sign_pattern==8'h0f);
   if(replace_pixel===1'b1) o_data<=median_value;
   else o_data<=windows[6][4];
   for(int i=6;i>0;i--) for(int k=0;k<9;k++) windows[i][k]<=windows[i-1][k];
   for(int k=0;k<9;k++) windows[0][k]<=selected[k];
   for(int i=3;i>0;i--) for(int k=0;k<8;k++) differences[i][k]<=differences[i-1][k];
   if(previous_gate) begin
     for(int k=0;k<8;k++) begin
       difference=int'(windows[1][4])-int'(windows[1][k<4?k:k+1]);
       differences[0][k]<=difference;
     end
   end
   threshold_history[0]<=reset_n?i_dpc_threshold:8'd0;
   threshold_history[1]<=threshold_history[0];
 end
 assign o_video_sync={sync_v[11],sync_d[11],sync_h[11]};
endmodule
