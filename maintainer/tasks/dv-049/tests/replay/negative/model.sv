// Input-history behavioral model. No DUT instance, output read, or golden trace.
module dvbench_model #(parameter XGMII_DATA_W=64)(
 input clk,nreset,input [XGMII_DATA_W-1:0] xgmii_txd_i,
 input [XGMII_DATA_W/8-1:0] xgmii_txc_i,
 output ready_o,output logic [XGMII_DATA_W-1:0] data_o);
 logic [5:0] phase;
 logic [57:0] history,after_word;
 logic [63:0] fragment,scrambled,encoded,next_fragment;
 logic [7:0] select_mask,selected_byte,kind,term_code;
 logic [57:0] serial_history;
 logic idle,term,start0;
 integer index,nkeep;
 always_comb begin
  select_mask = 8'(-xgmii_txc_i);
  selected_byte=0;
  for(integer lane=0;lane<8;lane++)
   if(select_mask[lane]) selected_byte=xgmii_txd_i[lane*8+:8];
  idle=xgmii_txc_i[7] && selected_byte==8'h07;
  term=xgmii_txc_i[7] && selected_byte==8'hfd;
  start0=!xgmii_txc_i[7] && xgmii_txd_i[7:0]==8'hfb && xgmii_txd_i[39:32]!=8'hfb;
  nkeep={2'b0,xgmii_txc_i[5:0]}+1;
  case(nkeep)
    1:term_code=8'h87;2:term_code=8'h99;4:term_code=8'haa;
    8:term_code=8'hb4;16:term_code=8'hcc;32:term_code=8'hd2;
    64:term_code=8'he1;128:term_code=8'hff;default:term_code='x;
  endcase
  kind=({8{idle}} & 8'h1e)|({8{term}} & term_code)|({8{start0}} & 8'h78);
  encoded=xgmii_txd_i;
  if(idle) encoded[63:8]=0;
  if(|xgmii_txc_i) encoded[7:0]=kind;
  serial_history=history;
  for(integer bitno=0;bitno<64;bitno++) begin
    scrambled[bitno]=encoded[bitno]^serial_history[38]^serial_history[57];
    serial_history={serial_history[56:0],scrambled[bitno]};
  end
  after_word=serial_history;
  data_o=fragment;
  if(phase==0) data_o={scrambled[61:0],(|xgmii_txc_i),!(|xgmii_txc_i)};
  next_fragment='x;
  index=2*(phase%32)+2;
  for(integer k=0;k<64;k++)
    if(k<index) next_fragment[k]=scrambled[64-index+k];
 end
 assign ready_o=(phase[5]);
 always @(posedge clk) begin
  fragment<=next_fragment;
  if(!nreset) begin phase<=0;history<='1;end
  else begin
    if(phase==32) phase<=0;else phase<=phase+1;
    if(phase!=32) history<=after_word;
  end
 end
endmodule
