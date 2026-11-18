# GBE Receive Filter

Native top level `gbe_rx_filter`, fixed 8-bit data interface. Fixed native default parameters: U_DLY=1, ST_MAC_WIDTH=8, ST_MAC_HEAD=8'd1, ST_IP_HEAD=8'd2, ST_NOT_IP=8'd4, ST_UDP_HEAD=8'd8, ST_UDP_SEARCH=8'd16, ST_NOT_UDP=8'd32, ST_CHECKSUM_ERR=8'd64, ST_UDP_SEARCH_END=8'd128. These parameters are fixed to the listed values; state-encoding, width, or latency variants are not accepted. Inputs and outputs interact only through native ports.

### R-dv-016-gbe-rx-filter-001 — Reset and Observation

rst is asynchronous active-high and clears the packet type, index, search flag, table address, and both counters to zero; after release, inputs are accepted on rising edges of clk, and outputs become valid after a 1ns delay from that edge. Inputs must be stable at the sampling edge; comparisons should wait for this delay.

### R-dv-016-gbe-rx-filter-002 — Byte Position and Frame Termination

mac_i_valid receives one byte on each sampling edge at which it is high; byte positions count from 0 and hold during gaps. mac_i_last is independent of valid; on every sampling edge at which it is high, it terminates position counting and increments the packet count by one; valid on the same edge still contributes to the byte count. The frame header is at least 14 bytes, and legal frames do not exceed 4096 bytes; last is not asserted on non-final bytes.

### R-dv-016-gbe-rx-filter-003 — Ethernet and IP Filtering

EtherType 0800 parses an IPv4 header at fixed offsets. UDP is parsed only when the version is 4, header length is 5, protocol is 17, and the IP checksum is acceptable; other IP packets enter the non-UDP branch, where an exact destination-IP match against one of the 8 filter_ip_addr entries can produce type 2. Other EtherTypes default to type 0, with ARP handled by dedicated rules.

### R-dv-016-gbe-rx-filter-004 — IP Checksum

For IP header bytes 14..33, every two network-order bytes form a 16-bit word; after 32-bit accumulation, fold the high 16 and low 16 bits only once, then take the one's complement of the low 16 bits. If the header checksum field is 0, skip verification; otherwise, a nonzero result enters the error branch, producing type 3 at frame end. Frames decidable in this run must receive at least the complete 34 bytes.

### R-dv-016-gbe-rx-filter-005 — UDP Length Threshold and Checksum

If the UDP length in bytes 38..39 is less than 196, do not search; at termination, if the UDP checksum is nonzero and incorrect, type 3 takes priority; otherwise, a small packet has type 0. A UDP checksum field of 0 in bytes 40..41 means skip verification; when nonzero, accumulate UDP data as network-order 16-bit words and add the four 16-bit halfwords of the source/destination IP addresses, the IP protocol number, and the IP total length minus 4 times the header length; a nonzero one's complement after one fold of the 32-bit sum indicates an error. Legal UDP frames are at least 42 bytes and must provide complete byte pairs, with enough time left before frame end for the specified search timing.

### R-dv-016-gbe-rx-filter-006 — Table Search Procedure

When the UDP length is at least 196, start searching after byte 41 is completed. is_searching reflects the search window on each clk; when the old local count after entering the search is 1, read address 255 and set the probe number to 1; subsequently, when the local count equals 4 times the probe number plus 1, compare the low 48 bits of table_rd_data with the 48-bit key composed of the destination port and destination IP. On equality, latch the high 16-bit index and end the search; if the table key is larger, subtract the step size to move downward, with no further subtraction at address 0; if smaller, add the step size to move upward, truncating the address to 9 bits. For probe numbers 1..9, the step sizes are, in order, 128, 64, 32, 16, 8, 4, 2, 1, 1, and 0 thereafter; exit upon reaching 11 or obtaining a hit. Clear the address and hit status at each new frame header. The external source supplies the corresponding 64-bit sorted table entry for each address; data must be stable at the comparison edge.

### R-dv-016-gbe-rx-filter-007 — End Type and Index

pkt_type is output for only one cycle after the edge that samples mac_i_last and is 0 in all other cycles. The priority order is: UDP checksum error at search end, 3; small packet at search end, 0; already hit and UDP checksum accepted, 1; IP error, 3; ARP or non-UDP address match, 2; otherwise, 0. udp_filter_index outputs the latched index when last is asserted and a hit has occurred, without cancellation due to a checksum error; it is 0 in other cycles. Legal long UDP frames must allow up to 46 cycles before last for search completion; sufficient payload may be delivered continuously.

### R-dv-016-gbe-rx-filter-008 — ARP Destination Address

For EtherType 0806, after byte 14 is received, collect the ARP target IPv4 address from bytes 38..41; when the subsequent last of a complete frame arrives, output type 2 if the target equals local_ip or local_ip2, otherwise 0. last clears the ARP state; to include the complete target in the decision, there must be at least one more sampling cycle after the final byte of the ARP target.

### R-dv-016-gbe-rx-filter-009 — Counter Hold and Wraparound

gbe_rx_pkt_cnt increments by 1 on each last edge, and gbe_rx_byte_cnt increments by 1 on each valid edge; both are 32-bit unsigned counters wrapping modulo 2^32, holding when not enabled, with reset taking priority. The last and valid inputs may be independent, so no fixed ratio between the two counts is imposed.

