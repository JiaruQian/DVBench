`timescale 1ns/1ps
module gbe_replay;gbe_if v();
`ifdef DVBENCH_REPLAY_MODEL
 dvbench_model unit_to_test(.rst(v.rst),.clk(v.clk),.mac_i_data(v.mac_i_data),.mac_i_valid(v.mac_i_valid),.mac_i_last(v.mac_i_last),.table_rd_data(v.table_rd_data),.local_ip(v.local_ip),.local_ip2(v.local_ip2),.filter_ip_addr1(v.filter_ip_addr1),.filter_ip_addr2(v.filter_ip_addr2),.filter_ip_addr3(v.filter_ip_addr3),.filter_ip_addr4(v.filter_ip_addr4),.filter_ip_addr5(v.filter_ip_addr5),.filter_ip_addr6(v.filter_ip_addr6),.filter_ip_addr7(v.filter_ip_addr7),.filter_ip_addr8(v.filter_ip_addr8),.is_searching(v.is_searching),.table_rd_addr(v.table_rd_addr),.pkt_type(v.pkt_type),.udp_filter_index(v.udp_filter_index),.gbe_rx_pkt_cnt(v.gbe_rx_pkt_cnt),.gbe_rx_byte_cnt(v.gbe_rx_byte_cnt));
`else
 gbe_rx_filter unit_to_test(.rst(v.rst),.clk(v.clk),.mac_i_data(v.mac_i_data),.mac_i_valid(v.mac_i_valid),.mac_i_last(v.mac_i_last),.table_rd_data(v.table_rd_data),.local_ip(v.local_ip),.local_ip2(v.local_ip2),.filter_ip_addr1(v.filter_ip_addr1),.filter_ip_addr2(v.filter_ip_addr2),.filter_ip_addr3(v.filter_ip_addr3),.filter_ip_addr4(v.filter_ip_addr4),.filter_ip_addr5(v.filter_ip_addr5),.filter_ip_addr6(v.filter_ip_addr6),.filter_ip_addr7(v.filter_ip_addr7),.filter_ip_addr8(v.filter_ip_addr8),.is_searching(v.is_searching),.table_rd_addr(v.table_rd_addr),.pkt_type(v.pkt_type),.udp_filter_index(v.udp_filter_index),.gbe_rx_pkt_cnt(v.gbe_rx_pkt_cnt),.gbe_rx_byte_cnt(v.gbe_rx_byte_cnt));
`endif
 reg [31:0] rng;int seed,point;reg [7:0] frame[0:239];
 function automatic [31:0] next_random();rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng;endfunction
 initial begin
 seed=1;if($value$plusargs("SEED=%d",seed))begin end rng=seed;v.rst=1;v.mac_i_data=0;v.mac_i_valid=0;v.mac_i_last=0;
 v.local_ip=32'h0a000001;v.local_ip2=32'h0a000002;v.filter_ip_addr1=32'h0a000003;v.filter_ip_addr2=4;v.filter_ip_addr3=5;v.filter_ip_addr4=6;v.filter_ip_addr5=7;v.filter_ip_addr6=8;v.filter_ip_addr7=9;v.filter_ip_addr8=10;
 repeat(4)@(negedge v.clk);v.rst=0;
 for(int f=0;f<80;f++)begin
  for(int i=0;i<240;i++)frame[i]=next_random();
  frame[12]=8'h08;frame[13]=(f%4==0)?6:(f%4==1)?1:0;frame[14]=8'h45;frame[16]=0;frame[17]=226;frame[23]=(f%4==2)?6:17;frame[24]=0;frame[25]=0;
  frame[30]=10;frame[31]=0;frame[32]=0;frame[33]=3;frame[36]=0;frame[37]=0;frame[38]=0;frame[39]=196;frame[40]=0;frame[41]=0;
  for(int i=0;i<240;i++)begin @(negedge v.clk);v.mac_i_valid=1;v.mac_i_last=(i==239);v.mac_i_data=frame[i];end
  @(negedge v.clk);v.mac_i_valid=0;v.mac_i_last=0;repeat(8)@(negedge v.clk);
 end
 $display("REPLAY_COMPLETED");$finish;
 end
 always @(posedge v.clk)begin #2;point++;$display("TRACE %0d %h %h %h %h %h %h",point,v.is_searching,v.table_rd_addr,v.pkt_type,v.udp_filter_index,v.gbe_rx_pkt_cnt,v.gbe_rx_byte_cnt);end
endmodule
