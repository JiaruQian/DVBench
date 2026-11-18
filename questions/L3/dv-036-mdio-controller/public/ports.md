# Native Interface

Top level `mdio_controller_sim_model`, model top level `dvbench_model`. Fixed parameters use default values:

{"AXI_ADDR_WIDTH": "8", "INIT_PHY_ADDR": "5'b10", "INIT_WAIT_CYCLES": "2000000", "INIT_POLL_CYCLES": "1430000"}

| Name | Direction | Bit width | Index |
|---|---|---|---|
| init_done_o | Out | 1 | [] |
| init_fail_o | Out | 1 | [] |
| init_go_i | In | 1 | [] |
| mdc_o | Out | 1 | [] |
| mdio_io | InOut | 1 | [] |
| phy_link_change_o | Out | 1 | [] |
| phy_link_o | Out | 1 | [] |
| s_axi_araddr | In | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| s_axi_arready | Out | 1 | [] |
| s_axi_arvalid | In | 1 | [] |
| s_axi_awaddr | In | 8 | [{'kind': 'packed', 'left': 7, 'right': 0}] |
| s_axi_awready | Out | 1 | [] |
| s_axi_awvalid | In | 1 | [] |
| s_axi_bready | In | 1 | [] |
| s_axi_bresp | Out | 2 | [{'kind': 'packed', 'left': 1, 'right': 0}] |
| s_axi_bvalid | Out | 1 | [] |
| s_axi_lite_clk | In | 1 | [] |
| s_axi_lite_resetn | In | 1 | [] |
| s_axi_rdata | Out | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| s_axi_rready | In | 1 | [] |
| s_axi_rresp | Out | 2 | [{'kind': 'packed', 'left': 1, 'right': 0}] |
| s_axi_rvalid | Out | 1 | [] |
| s_axi_wdata | In | 32 | [{'kind': 'packed', 'left': 31, 'right': 0}] |
| s_axi_wready | Out | 1 | [] |
| s_axi_wstrb | In | 4 | [{'kind': 'packed', 'left': 3, 'right': 0}] |
| s_axi_wvalid | In | 1 | [] |
