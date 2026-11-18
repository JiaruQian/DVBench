`timescale 1ns/1ps
interface gbe_if;
logic rst;
int table_profile=0;
logic clk;
logic [7:0] mac_i_data;
logic mac_i_valid;
logic mac_i_last;
wire [63:0] table_rd_data;
logic [31:0] local_ip;
logic [31:0] local_ip2;
logic [31:0] filter_ip_addr1;
logic [31:0] filter_ip_addr2;
logic [31:0] filter_ip_addr3;
logic [31:0] filter_ip_addr4;
logic [31:0] filter_ip_addr5;
logic [31:0] filter_ip_addr6;
logic [31:0] filter_ip_addr7;
logic [31:0] filter_ip_addr8;
logic is_searching;
logic [8:0] table_rd_addr;
logic [1:0] pkt_type;
logic [15:0] udp_filter_index;
logic [31:0] gbe_rx_pkt_cnt;
logic [31:0] gbe_rx_byte_cnt;
logic e_is_searching;
logic [8:0] e_table_rd_addr;
logic [1:0] e_pkt_type;
logic [15:0] e_udp_filter_index;
logic [31:0] e_gbe_rx_pkt_cnt;
logic [31:0] e_gbe_rx_byte_cnt;
assign table_rd_data=table_profile==1 ? {16'(table_rd_addr*513),16'(16'h7f00+table_rd_addr),(32'h0a000000+table_rd_addr)} : {16'(table_rd_addr*513),16'(table_rd_addr*123),(32'h0a000000+table_rd_addr)};
initial begin clk=0;forever #5 clk=~clk;end
endinterface
