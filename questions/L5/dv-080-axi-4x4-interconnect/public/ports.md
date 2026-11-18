# Fixed Native Interface

DUT top level `axi_interconnect`; model top level `dvbench_model`. See the table for all vector directions; each port is [width-1:0].

Fixed parameters (SV elaboration values):

- S_COUNT = 4
- M_COUNT = 4
- DATA_WIDTH = 32
- ADDR_WIDTH = 32
- STRB_WIDTH = 4
- ID_WIDTH = 8
- AWUSER_ENABLE = 0
- AWUSER_WIDTH = 1
- WUSER_ENABLE = 0
- WUSER_WIDTH = 1
- BUSER_ENABLE = 0
- BUSER_WIDTH = 1
- ARUSER_ENABLE = 0
- ARUSER_WIDTH = 1
- RUSER_ENABLE = 0
- RUSER_WIDTH = 1
- FORWARD_ID = 0
- M_REGIONS = 1
- M_BASE_ADDR = 0
- M_ADDR_WIDTH = 128'h18000000180000001800000018
- M_CONNECT_READ = 16'd65535
- M_CONNECT_WRITE = 16'd65535
- M_SECURE = 4'b0

|Port|Direction|Bit width|
|---|---|---:|
|`clk`|In|1|
|`m_axi_araddr`|Out|128|
|`m_axi_arburst`|Out|8|
|`m_axi_arcache`|Out|16|
|`m_axi_arid`|Out|32|
|`m_axi_arlen`|Out|32|
|`m_axi_arlock`|Out|4|
|`m_axi_arprot`|Out|12|
|`m_axi_arqos`|Out|16|
|`m_axi_arready`|In|4|
|`m_axi_arregion`|Out|16|
|`m_axi_arsize`|Out|12|
|`m_axi_aruser`|Out|4|
|`m_axi_arvalid`|Out|4|
|`m_axi_awaddr`|Out|128|
|`m_axi_awburst`|Out|8|
|`m_axi_awcache`|Out|16|
|`m_axi_awid`|Out|32|
|`m_axi_awlen`|Out|32|
|`m_axi_awlock`|Out|4|
|`m_axi_awprot`|Out|12|
|`m_axi_awqos`|Out|16|
|`m_axi_awready`|In|4|
|`m_axi_awregion`|Out|16|
|`m_axi_awsize`|Out|12|
|`m_axi_awuser`|Out|4|
|`m_axi_awvalid`|Out|4|
|`m_axi_bid`|In|32|
|`m_axi_bready`|Out|4|
|`m_axi_bresp`|In|8|
|`m_axi_buser`|In|4|
|`m_axi_bvalid`|In|4|
|`m_axi_rdata`|In|128|
|`m_axi_rid`|In|32|
|`m_axi_rlast`|In|4|
|`m_axi_rready`|Out|4|
|`m_axi_rresp`|In|8|
|`m_axi_ruser`|In|4|
|`m_axi_rvalid`|In|4|
|`m_axi_wdata`|Out|128|
|`m_axi_wlast`|Out|4|
|`m_axi_wready`|In|4|
|`m_axi_wstrb`|Out|16|
|`m_axi_wuser`|Out|4|
|`m_axi_wvalid`|Out|4|
|`rst`|In|1|
|`s_axi_araddr`|In|128|
|`s_axi_arburst`|In|8|
|`s_axi_arcache`|In|16|
|`s_axi_arid`|In|32|
|`s_axi_arlen`|In|32|
|`s_axi_arlock`|In|4|
|`s_axi_arprot`|In|12|
|`s_axi_arqos`|In|16|
|`s_axi_arready`|Out|4|
|`s_axi_arsize`|In|12|
|`s_axi_aruser`|In|4|
|`s_axi_arvalid`|In|4|
|`s_axi_awaddr`|In|128|
|`s_axi_awburst`|In|8|
|`s_axi_awcache`|In|16|
|`s_axi_awid`|In|32|
|`s_axi_awlen`|In|32|
|`s_axi_awlock`|In|4|
|`s_axi_awprot`|In|12|
|`s_axi_awqos`|In|16|
|`s_axi_awready`|Out|4|
|`s_axi_awsize`|In|12|
|`s_axi_awuser`|In|4|
|`s_axi_awvalid`|In|4|
|`s_axi_bid`|Out|32|
|`s_axi_bready`|In|4|
|`s_axi_bresp`|Out|8|
|`s_axi_buser`|Out|4|
|`s_axi_bvalid`|Out|4|
|`s_axi_rdata`|Out|128|
|`s_axi_rid`|Out|32|
|`s_axi_rlast`|Out|4|
|`s_axi_rready`|In|4|
|`s_axi_rresp`|Out|8|
|`s_axi_ruser`|Out|4|
|`s_axi_rvalid`|Out|4|
|`s_axi_wdata`|In|128|
|`s_axi_wlast`|In|4|
|`s_axi_wready`|Out|4|
|`s_axi_wstrb`|In|16|
|`s_axi_wuser`|In|4|
|`s_axi_wvalid`|In|4|
