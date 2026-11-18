# Native Interface

Clock clk, asynchronous active-high rst; U_DLY=1ns. Fixed native default parameters: U_DLY=1, ST_MAC_WIDTH=8, ST_MAC_HEAD=8'd1, ST_IP_HEAD=8'd2, ST_NOT_IP=8'd4, ST_UDP_HEAD=8'd8, ST_UDP_SEARCH=8'd16, ST_NOT_UDP=8'd32, ST_CHECKSUM_ERR=8'd64, ST_UDP_SEARCH_END=8'd128. These parameters are fixed to the listed values; state-encoding, width, or latency variants are not accepted.

|Port|Direction|Index|
|---|---|---|
|clk|input|1|
|rst|input|1|
|mac_i_data|input|[7:0]|
|mac_i_valid|input|1|
|mac_i_last|input|1|
|is_searching|output|1|
|table_rd_addr|output|[8:0]|
|table_rd_data|input|[63:0]|
|local_ip|input|[31:0]|
|local_ip2|input|[31:0]|
|filter_ip_addr1|input|[31:0]|
|filter_ip_addr2|input|[31:0]|
|filter_ip_addr3|input|[31:0]|
|filter_ip_addr4|input|[31:0]|
|filter_ip_addr5|input|[31:0]|
|filter_ip_addr6|input|[31:0]|
|filter_ip_addr7|input|[31:0]|
|filter_ip_addr8|input|[31:0]|
|pkt_type|output|[1:0]|
|udp_filter_index|output|[15:0]|
|gbe_rx_pkt_cnt|output|[31:0]|
|gbe_rx_byte_cnt|output|[31:0]|
