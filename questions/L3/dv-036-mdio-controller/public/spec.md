# mdio_controller_sim_model

The complete mdio_controller_sim_model and its MDIO host, PHY initialization, and polling closure. Fixed default parameters AXI_ADDR_WIDTH=8, INIT_PHY_ADDR=2, INIT_WAIT_CYCLES=2000000, INIT_POLL_CYCLES=1430000. AXI inputs are two-state, mdio_io is a true tri-state line, and the peripheral drives only during read turnaround and data and provides a pull-up; it must not contend with write frames.

### R-dv-036-001 — AXI and Reset

Active-low resetn asynchronously clears AXI holding state and responses, clears the register configuration to zero, and sets divider=35. AW and W are accepted independently and in either order; an OKAY write response is generated once both have been received, and the response is held under backpressure. An OKAY read response is generated one cycle after AR is accepted, and read data and valid are held until the handshake. The MDIO master resets on a clock edge with resetn low.

### R-dv-036-002 — Registers and Byte Enables

0x00 provides read/write access to PHY address[4:0], REG address[12:8], and write_not_read[16], controlled by WSTRB0/1/2 respectively; 0x04 is 16-bit write data, and 0x14 is the 16-bit divider, both written according to the low two byte enables. 0x08 provides read-only MDIO read data, 0x0C reads as zero, and unknown addresses read as zero with no side effects on writes.

### R-dv-036-003 — Clause22 Write Frame and Timing

Writing bit0 in byte 0 of 0x0C starts a CPU transaction when idle. The 64-bit write frame consists, in order, of 32 ones, ST=01, OP=01, 5-bit PHY, 5-bit REG, TA=10, and 16-bit data, MSB first. MDC toggles every divider+1 source clock cycles and is 0 when idle; MDIO is driven throughout the write frame and released upon completion.

### R-dv-036-004 — Reads and Sticky Status

The read frame has OP=10, and the master releases MDIO during both TA bits and the 16 data bits; the second TA should be 0, otherwise an error is generated. The 16-bit data is shifted in on MDC rising edges. At 0x10, bit1 is sticky CPU completion and bit2 is sticky CPU error; writing 1 in byte 0 clears the corresponding bit individually, and other bits are not cleared; bit0 is actually busy AND init_active, and this bit remains 0 while the CPU is busy.

The complete 0x10 read layout is: bits31:10 read zero; bit9 is PHY link valid; bit8 is PHY full-duplex; bits7:6 are PHY speed; bit5 is PHY link; bit4 is initialization failure; bit3 is initialization done; bit2 is sticky CPU error; bit1 is sticky CPU completion; and bit0 is busy AND init_active. A successful PHY register 0x11 poll copies response bits15:14 to status bits7:6, response bit13 to status bit8, and response bit10 to status bit5, and sets status bit9. Read data captures these fields when the AXI read response is produced and stays stable until its handshake. W1C writes at 0x10 affect only bits1 and2 with WSTRB0 enabled.

### R-dv-036-005 — Start Arbitration

A new START is ignored while a CPU transaction is busy; a START while initialization/polling owns the master is recorded as one pending request and executed after the master is idle and initialization has released it. Initialization is triggered by a rising edge of init_go_i and is active during configuration; init_go_i low cancels subsequent steps in the wait state.

### R-dv-036-006 — PHY Initialization

After init_go_i rises, wait the default period, then first read PHY2 register 3 and require the upper 12 bits to be A23, otherwise fail. On success, in order, read MMD 0x1F address 006E and record bit11, read Clause22 register 10, then write that register with (old AND NOT(C400 OR (strap11?0800:0000))) OR 4000; read MMD address 0031 and write back old AND FF7F; read MMD address 0032 and write back (old AND FFFE) OR 0003; finally write MMD address 0086 with 0067, namely RX/TX delay codes 7/6. All numbers are hexadecimal. Each MMD indirect read or write sequentially writes Clause22 registers 0D=001F, 0E=target address, and 0D=401F, then finally reads or writes 0E. An incorrect TA causes initialization to fail.

### R-dv-036-007 — Link Polling

After successful initialization, done is held; first wait 1000 cycles before reading PHY register 0x11, then poll at intervals of INIT_POLL_CYCLES. On success, take bit10 as link, and map speed 15:14 and duplex 13 to the status register; a link change outputs a single-cycle change pulse. A polling error clears valid/link, and also emits change if the previous link=1. After init_go_i goes low, return to idle and clear link valid.

