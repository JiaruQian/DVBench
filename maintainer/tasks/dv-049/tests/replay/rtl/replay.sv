module replay_top;
 bit clk=0;always #5 clk=~clk;
 logic nreset=0;logic[63:0] xgmii_txd_i=0;logic[7:0] xgmii_txc_i=0;
 wire ready_o;wire[63:0] data_o;
 xgmii_pcs_10g_tx #(.XGMII_DATA_W(64)) oracle(.*);
 integer seed,c;
 task point(input integer p);$display("D_POINT %0d %b %b",p,ready_o,data_o);endtask
 initial begin
  seed=1;void'($value$plusargs("ntb_random_seed=%d",seed));seed=$urandom(seed);
  for(c=0;c<1200;c++) begin
   @(negedge clk);
   nreset=!(c<3 || c%197==0 || c%197==1);
   xgmii_txd_i={$urandom,$urandom};xgmii_txc_i=8'(c);
   if(c<80) begin xgmii_txc_i=0;xgmii_txd_i=(64'b1<<(c%64));end
   if(c%9==0) xgmii_txd_i='0;
   if(c%9==1) xgmii_txd_i='1;
   if(c%9==2) xgmii_txd_i=64'h0707070707070707;
   if(c%9==3) xgmii_txd_i=64'hfdfdfdfdfdfdfdfd;
   if(c%9==4) xgmii_txd_i=64'hfefefefefefefefe;
   if(c%9==5) xgmii_txd_i[7:0]=8'hfb;
   if(c%9==6) xgmii_txd_i[39:32]=8'hfb;
   if(c%9==7) begin xgmii_txd_i[7:0]=8'hfb;xgmii_txd_i[39:32]=8'hfb;end
   #4;point(2*c);
   @(posedge clk);#1;point(2*c+1);
  end
  $display("D_REPLAY_COMPLETED points=2400 seed=%0d",seed);$finish;
 end
endmodule
