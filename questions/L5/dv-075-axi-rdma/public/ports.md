# Native Interface

DUT module `axi_rdma`; independent model module `dvbench_model`. Single clock, operating on rising edges, with asynchronous active-low aresetn.

|Port|Direction (relative to DUT)|Width/direction|
|---|---|---|
|aclk|In|Scalar|
|aresetn|In|Scalar|
|cmd_address|In|[31:0]|
|cmd_bytes|In|[31:0]|
|cmd_valid|In|Scalar|
|axi_m_arready|In|Scalar|
|axi_m_rid|In|[3:0]|
|axi_m_rdata|In|[31:0]|
|axi_m_rresp|In|[1:0]|
|axi_m_rlast|In|Scalar|
|axi_m_rvalid|In|Scalar|
|dout_tready|In|Scalar|
|cmd_ready|Out|Scalar|
|axi_m_arid|Out|[3:0]|
|axi_m_araddr|Out|[31:0]|
|axi_m_arlen|Out|[7:0]|
|axi_m_arsize|Out|[2:0]|
|axi_m_arburst|Out|[1:0]|
|axi_m_arvalid|Out|Scalar|
|axi_m_rready|Out|Scalar|
|dout_tdata|Out|[31:0]|
|dout_tkeep|Out|[3:0]|
|dout_tlast|Out|Scalar|
|dout_tvalid|Out|Scalar|

Default parameters: `ADDRESS_BITS=32`, `LENGTH_BITS=32`, `MAX_BURST=256`, `STREAM_BIG_ENDIAN=TRUE`, `MEM_BIG_ENDIAN=TRUE`.

This task verifies two complete axi_rdma instances in the same dvbench_top: BE16 (MAX_BURST=16, TRUE at both ends) and LE256 (MAX_BURST=256, FALSE at both ends), with ADDRESS_BITS and LENGTH_BITS both 32. Other widths or mixed-endianness configurations are not required. All outputs are driven separately by the DUT/model on separate nets; actual must not be connected to model inputs.
