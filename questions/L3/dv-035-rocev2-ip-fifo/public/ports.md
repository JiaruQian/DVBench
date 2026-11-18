# Native Interface

Top level `ip_fifo`, model top level `dvbench_model`. Fixed parameters use the default values:

{"DATA_WIDTH": "64", "KEEP_ENABLE": "1'b1", "KEEP_WIDTH": "8", "PAYLOAD_FIFO_DEPTH": "2048", "HEADER_FIFO_DEPTH": "8"}

| Name | Direction | Bit width | Index |
|---|---|---|---|
| busy | Out | 1 | [] |
| clk | In | 1 | [] |
| m_eth_dest_mac | Out | 48 | [{'kind': 'packed', 'left': 47, 'right': 0}] |
| m_eth_src_mac | Out | 48 | [{'kind': 'packed', 'left': 47, 'right': 0}] |
| m_eth_type | Out | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| m_ip_dest_ip | Out | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| m_ip_dscp | Out | 6 | [{'kind': 'packed', 'left': 5, 'right': 0}] |
| m_ip_ecn | Out | 2 | [{'kind': 'packed', 'left': 1, 'right': 0}] |
| m_ip_flags | Out | 3 | [{'kind': 'packed', 'left': 2, 'right': 0}] |
| m_ip_fragment_offset | Out | 13 | [{'kind': 'packed', 'left': 12, 'right': 0}] |
| m_ip_hdr_ready | In | 1 | [] |
| m_ip_hdr_valid | Out | 1 | [] |
| m_ip_header_checksum | Out | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| m_ip_identification | Out | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| m_ip_ihl | Out | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
| m_ip_length | Out | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| m_ip_payload_axis_tdata | Out | 64 | [{'kind': 'packed', 'left': 63, 'right': 0}] |
| m_ip_payload_axis_tkeep | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| m_ip_payload_axis_tlast | Out | 1 | [] |
| m_ip_payload_axis_tready | In | 1 | [] |
| m_ip_payload_axis_tuser | Out | 1 | [] |
| m_ip_payload_axis_tvalid | Out | 1 | [] |
| m_ip_protocol | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| m_ip_source_ip | Out | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| m_ip_ttl | Out | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| m_ip_version | Out | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
| rst | In | 1 | [] |
| s_eth_dest_mac | In | 48 | [{'kind': 'packed', 'left': 47, 'right': 0}] |
| s_eth_src_mac | In | 48 | [{'kind': 'packed', 'left': 47, 'right': 0}] |
| s_eth_type | In | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| s_ip_dest_ip | In | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| s_ip_dscp | In | 6 | [{'kind': 'packed', 'left': 5, 'right': 0}] |
| s_ip_ecn | In | 2 | [{'kind': 'packed', 'left': 1, 'right': 0}] |
| s_ip_flags | In | 3 | [{'kind': 'packed', 'left': 2, 'right': 0}] |
| s_ip_fragment_offset | In | 13 | [{'kind': 'packed', 'left': 12, 'right': 0}] |
| s_ip_hdr_ready | Out | 1 | [] |
| s_ip_hdr_valid | In | 1 | [] |
| s_ip_header_checksum | In | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| s_ip_identification | In | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| s_ip_ihl | In | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
| s_ip_length | In | 16 | [{'kind': 'packed', 'left': 15, 'right': 0}] |
| s_ip_payload_axis_tdata | In | 64 | [{'kind': 'packed', 'left': 63, 'right': 0}] |
| s_ip_payload_axis_tkeep | In | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| s_ip_payload_axis_tlast | In | 1 | [] |
| s_ip_payload_axis_tready | Out | 1 | [] |
| s_ip_payload_axis_tuser | In | 1 | [] |
| s_ip_payload_axis_tvalid | In | 1 | [] |
| s_ip_protocol | In | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| s_ip_source_ip | In | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| s_ip_ttl | In | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| s_ip_version | In | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
