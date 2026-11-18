## T-GBE-001

**feature_ids**: ["F-GBE-001"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-001"]

**stimulus**: First produce nonzero counts/search activity, then assert rst between edges, hold and release it, and observe reset values and restarting.

**expected**: rst is asynchronous active-high and clears the packet type, index, search flag, table address, and both counters to zero; after release, inputs are accepted on rising edges of clk, and outputs become valid after a 1ns delay from that edge. Inputs must be stable at the sampling edge; comparisons should wait for this delay.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-002

**feature_ids**: ["F-GBE-002"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-002"]

**stimulus**: Send 64/240-byte frames starting at position 0, insert valid=0 at non-final positions, and exercise both last and valid high together as well as only last high.

**expected**: mac_i_valid receives one byte on each sampling edge at which it is high; byte positions count from 0 and hold during gaps. mac_i_last is independent of valid; on every sampling edge at which it is high, it terminates position counting and increments the packet count by one; valid on the same edge still contributes to the byte count. The frame header is at least 14 bytes, and legal frames do not exceed 4096 bytes; last is not asserted on non-final bytes.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-003

**feature_ids**: ["F-GBE-003"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-003"]

**stimulus**: Send 0801, and non-UDP protocol 6 and UDP17 for 0800, respectively, with destination IPs covering the 8 filter addresses and a nonmatching value.

**expected**: EtherType 0800 parses an IPv4 header at fixed offsets. UDP is parsed only when the version is 4, header length is 5, protocol is 17, and the IP checksum is acceptable; other IP packets enter the non-UDP branch, where an exact destination-IP match against one of the 8 filter_ip_addr entries can produce type 2. Other EtherTypes default to type 0, with ARP handled by dedicated rules.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-004

**feature_ids**: ["F-GBE-004"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-004"]

**stimulus**: Construct a zero checksum, an independently calculated correct nonzero checksum, and an incorrect checksum with one header byte flipped; pause before and after byte 33.

**expected**: Every two network-order bytes in IP header bytes 14..33 form a 16-bit word. After 32-bit accumulation, fold the upper 16 and lower 16 bits only once, then take the one's complement of the lower 16 bits. Skip verification when the header checksum field is 0; otherwise, a nonzero result enters the error branch, with type 3 at frame end. At least the complete 34 bytes must be received for a frame decidable in this case.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-005

**feature_ids**: ["F-GBE-005"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-005"]

**stimulus**: Construct UDP lengths of 195, 196, and longer, with zero/correct nonzero/incorrect nonzero checksums and even-byte payloads, with last after search completion.

**expected**: Do not search if UDP length bytes 38..39 are less than 196; at termination, if the UDP checksum is nonzero and incorrect, type 3 takes priority; otherwise, a small packet has type 0. A UDP checksum field of 0 at 40..41 means skip; when nonzero, accumulate UDP data as network-order 16-bit words and add the four 16-bit halfwords of the source/destination IP addresses, the IP protocol number, and the IP total length minus 4 times the header length; a nonzero one's complement after a single fold of the 32-bit sum indicates an error. A legal UDP frame is at least 42 bytes and must provide complete byte pairs, with enough time for the stated search timing before frame end.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-006

**feature_ids**: ["F-GBE-006"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-006"]

**stimulus**: Construct a sorted 512-entry table, with destination-key hits at 0, 255, and 511, misses in the middle and outside the upper and lower bounds; provide the corresponding table entry for each read address until termination in at most 46 cycles.

**expected**: When the UDP length is at least 196, start the search after completing byte 41. is_searching reflects the search window on each clk; when the old local count after entering the search is 1, the read address is 255 and the probe number is 1. Thereafter, when the local count equals 4 times the probe number plus 1, compare the lower 48 bits of table_rd_data with the 48-bit key composed of the destination port and destination IP. On equality, latch the upper 16-bit index and end the search; if the table key is larger, decrement by the step size, with no further decrement at address 0; if smaller, increment by the step size, truncating the 9-bit address. For probe numbers 1..9, the step sizes are 128, 64, 32, 16, 8, 4, 2, 1, 1 in order, then 0; exit upon reaching 11 or a hit. Clear the address and hit state at the start of each new frame. Externally provide the 64-bit sorted table entry corresponding to the address; the data must be stable at the comparison edge.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-007

**feature_ids**: ["F-GBE-007"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-007"]

**stimulus**: Construct complete frames for hits, misses, small packets, bad IP, and bad UDP, leave observation cycles before and after last, and combine a hit with bad UDP to confirm that type and index are independent.

**expected**: pkt_type is output for only one cycle after the edge that samples mac_i_last, and is 0 in other cycles. The priority order is UDP checksum error at search end: 3; small packet at search end: 0; an existing hit with accepted UDP checksum: 1; IP error: 3; ARP or non-UDP address match: 2; otherwise: 0. udp_filter_index outputs the latched index when last is asserted and a hit has occurred, is not canceled by a checksum error, and is 0 in other cycles. A legal long UDP frame must allow enough time before last for search completion, at most 46 cycles; sufficient payload may be supplied continuously.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-008

**feature_ids**: ["F-GBE-008"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-008"]

**stimulus**: Construct ARP targets equal to the two local addresses and a nonmatching address; continue sending padding after target byte 41, then assert last.

**expected**: With EtherType 0806 and after receiving byte 14, collect the ARP target IPv4 address from bytes 38..41; when the subsequent last of the complete frame arrives, the type is 2 if the target equals local_ip or local_ip2, otherwise 0. last clears the ARP state; to include the complete target in the decision, there must be at least one more sampling cycle after the last byte of the ARP target.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict

## T-GBE-009

**feature_ids**: ["F-GBE-009"]

**requirement_ids**: ["R-dv-016-gbe-rx-filter-009"]

**stimulus**: Record the independent valid/last input counts cycle by cycle, mixing gaps, consecutive frames, and resets.

**expected**: gbe_rx_pkt_cnt increments by 1 on each last edge, and gbe_rx_byte_cnt increments by 1 on each valid edge; both are 32-bit unsigned values wrapping modulo 2^32, hold when not enabled, and give reset priority. Input last and valid may be independent, so no fixed ratio between the two counts is imposed.

**checker**: Build independent integer parsing and summation expectations from input frame bytes, table data, and sampling-edge history; compare all valid native outputs with dvbench_model 2ns after the edge; issue UVM_ERROR for any four-state mismatch and accumulate a nonzero number of comparison points. Also check asynchronous reset before the next clk edge.

**implementation_id**: GBE-cycle-monitor

**source**: gbe_pkg.sv:gbe_sequence.body,gbe_monitor.run_phase,gbe_scoreboard.write,gbe_protocol_checker.run_phase; model/model.sv:predict
