`timescale 1ns/1ps
// Input-history parser and integer checksum predictor; no RTL instances or actual-output feedback.
module dvbench_model #(
 parameter U_DLY=1,
 parameter ST_MAC_WIDTH=8,
 parameter ST_MAC_HEAD=8'd1,
 parameter ST_IP_HEAD=8'd2,
 parameter ST_NOT_IP=8'd4,
 parameter ST_UDP_HEAD=8'd8,
 parameter ST_UDP_SEARCH=8'd16,
 parameter ST_NOT_UDP=8'd32,
 parameter ST_CHECKSUM_ERR=8'd64,
 parameter ST_UDP_SEARCH_END=8'd128
)(
 input rst,clk,input [7:0] mac_i_data,input mac_i_valid,mac_i_last,
 output reg is_searching,output reg [8:0] table_rd_addr,input [63:0] table_rd_data,
 input [31:0] local_ip,local_ip2,filter_ip_addr1,filter_ip_addr2,filter_ip_addr3,filter_ip_addr4,
 filter_ip_addr5,filter_ip_addr6,filter_ip_addr7,filter_ip_addr8,
 output reg [1:0] pkt_type,output reg [15:0] udp_filter_index,
 output reg [31:0] gbe_rx_pkt_cnt,gbe_rx_byte_cnt);
 typedef enum {ETH,IP,OTHER,UDP,SEARCH,NONUDP,BAD,DONE} phase_t;
 phase_t phase;
 reg [7:0] header[0:41];
 int unsigned pos,search_tick,probe;
 reg hit,arp,filter_ok;
 reg [15:0] index_value;
 reg [47:0] key_d;
 reg [31:0] target_arp;
 reg [31:0] ipsum,udpsum;
 reg [7:0] prev_ip,prev_udp;
 int step_d;
 function automatic [15:0] word_at(input int n); return {header[n],header[n+1]}; endfunction
 function automatic [31:0] address_at(input int n); return {header[n],header[n+1],header[n+2],header[n+3]}; endfunction
 function automatic [15:0] folded(input reg [31:0] n);
 reg [31:0] f; f=(n>>16)+(n&32'hffff); return ~f[15:0]; endfunction
 always @(posedge clk or posedge rst) begin : predict
  reg [31:0] ipnow,udpnow,pseudo,dip;
  reg [15:0] ipresult,udpresult;
  phase_t nextphase;
  bit ipword,udpword;
  if(rst) begin
   phase=ETH;pos=0;search_tick=0;probe=0;hit=0;arp=0;filter_ok=0;index_value=0;key_d=0;
   target_arp=0;ipsum=0;udpsum=0;prev_ip=0;prev_udp=0;step_d=0;
   for(int i=0;i<42;i++)header[i]=0;
   header[33]=1;
   is_searching<=0;table_rd_addr<=0;pkt_type<=0;udp_filter_index<=0;gbe_rx_pkt_cnt<=0;gbe_rx_byte_cnt<=0;
  end else begin
   dip=address_at(30);
   ipword=pos[0] && mac_i_valid && phase==IP;
   udpword=pos[0] && mac_i_valid && (phase inside {UDP,SEARCH,DONE});
   ipnow=ipsum+(ipword?{prev_ip,mac_i_data}:16'b0);
   udpnow=udpsum+(udpword?{prev_udp,mac_i_data}:16'b0);
   pseudo=word_at(26)+word_at(28)+word_at(30)+word_at(32)+header[23]+word_at(16)-(header[14][3:0]<<2);
   ipresult=(mac_i_valid && phase==IP && pos==33)?folded(ipnow):0;
   udpresult=mac_i_last?folded(udpnow+pseudo):0;
   pkt_type<=#U_DLY 0;udp_filter_index<=#U_DLY 0;
   if(mac_i_last) begin
    gbe_rx_pkt_cnt<=#U_DLY gbe_rx_pkt_cnt+1;
    if(phase==DONE && word_at(40)!=0 && udpresult!=0)pkt_type<=#U_DLY 3;
    else if(phase==DONE && word_at(38)<196)pkt_type<=#U_DLY 0;
    else if(hit && (word_at(40)==0 || udpresult==0))pkt_type<=#U_DLY 1;
    else if(phase==BAD)pkt_type<=#U_DLY 3;
    else if((arp && (target_arp==local_ip || target_arp==local_ip2)) || (filter_ok && phase==NONUDP))pkt_type<=#U_DLY 2;
    if(hit)udp_filter_index<=#U_DLY index_value;
   end
   if(mac_i_valid)gbe_rx_byte_cnt<=#U_DLY gbe_rx_byte_cnt+1;
   is_searching<=#U_DLY (phase==SEARCH);
   nextphase=phase;
   case(phase)
    ETH:if(mac_i_valid && pos==13)nextphase=(header[12]==8'h08 && mac_i_data==0)?IP:OTHER;
    IP:if(mac_i_valid && pos==33)begin
     if(word_at(24)!=0 && ipresult!=0)nextphase=BAD;
     else nextphase=(header[14]==8'h45 && header[23]==17)?UDP:NONUDP;
    end
    UDP:if(mac_i_valid && pos==41)nextphase=word_at(38)<196?DONE:SEARCH;
    SEARCH:if(probe>=11 || hit)nextphase=DONE;
    default:if(mac_i_last)nextphase=ETH;
   endcase
   if(phase==ETH)begin table_rd_addr<=#U_DLY 0;hit=0;probe=0;index_value=0;end
   else if(phase==SEARCH)begin
    if(search_tick==1)begin table_rd_addr<=#U_DLY 255;probe=1;end
    else if(search_tick==probe*4+1)begin
     if(table_rd_data[47:0]==key_d)begin index_value=table_rd_data[63:48];hit=1;table_rd_addr<=#U_DLY 0;probe=0;end
     else begin
      if(table_rd_data[47:0]>key_d)begin if(table_rd_addr!=0)table_rd_addr<=#U_DLY table_rd_addr-step_d;end
      else table_rd_addr<=#U_DLY table_rd_addr+step_d;
      probe++;
     end
    end
   end
   // step reflects previous probe, not the probe selected above.
   // prior value needed at comparator edge; for all legal probes it has settled for three cycles.
   if(probe>=1 && probe<=8)step_d=256>>probe;else if(probe==9)step_d=1;else step_d=0;
   search_tick=(phase==SEARCH)?((search_tick+1)&255):0;
   key_d={word_at(36),dip};
   filter_ok=(dip==filter_ip_addr1||dip==filter_ip_addr2||dip==filter_ip_addr3||dip==filter_ip_addr4||dip==filter_ip_addr5||dip==filter_ip_addr6||dip==filter_ip_addr7||dip==filter_ip_addr8);
   if(mac_i_last)begin arp=0;target_arp=0;end
   else begin
    if(mac_i_valid && pos==14)arp=word_at(12)==16'h0806;
    if(mac_i_valid && arp && pos>=38 && pos<=41)target_arp[8*(41-pos)+:8]=mac_i_data;
   end
   if(mac_i_valid && phase==IP && pos==14)ipsum=0;else if(ipword)ipsum=ipnow;
   if(mac_i_valid && phase==UDP && pos==34)udpsum=0;else if(udpword)udpsum=udpnow;
   if(!pos[0])begin prev_ip=mac_i_data;prev_udp=mac_i_data;end
   if(mac_i_valid) begin
    if((phase==ETH && pos<14)||(phase==IP && pos>=14 && pos<=33)||(phase==UDP && pos>=34 && pos<=41))header[pos]=mac_i_data;
    else if(mac_i_last)begin
     if(phase!=ETH)begin for(int i=0;i<14;i++)header[i]=0;end
     if(phase!=IP)begin for(int i=14;i<34;i++)header[i]=0;header[33]=1;end
     if(phase!=UDP)begin for(int i=34;i<42;i++)header[i]=0;end
    end
   end
   pos=mac_i_last?0:(mac_i_valid?((pos+1)&4095):pos);
   phase=nextphase;
  end
 end
endmodule
