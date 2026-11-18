# TLFIFOFixer fixed native behavior

The target is the complete TLFIFOFixer native root, with its original integrated protocol checking. There are no parameters or required defines. Use the exact native interface in ports.md. All fields are unsigned known binary values. The fixed environment uses normal protocol checks and no timeout plusarg; there is no configured protocol timeout.

### R-p8-tlff-001 — Pair 0 A forwarding

For pair 0 A, auto_out_0_a_valid and every auto_out_0_a_bits field equal the corresponding auto_in_0_a input. auto_in_0_a_ready equals auto_out_0_a_ready independently of valid. Every native opcode, param, size, source, address, mask, data and corrupt bit is preserved.

### R-p8-tlff-002 — Pair 0 D forwarding

For pair 0 D, auto_in_0_d_valid and every auto_in_0_d_bits field equal the corresponding auto_out_0_d input. auto_out_0_d_ready equals auto_in_0_d_ready independently of valid. Every native opcode, param, size, source, sink, denied, data and corrupt bit is preserved.

### R-p8-tlff-003 — Pair 1 A and D forwarding

Pair 1 independently forwards A valid and all A fields from auto_in_1 to auto_out_1, and A ready in the reverse direction. It forwards D valid and all D fields from auto_out_1 to auto_in_1, and D ready in the reverse direction. The preserved fields are opcode, param, size, source, address, mask, data and corrupt for A, and opcode, param, size, source, sink, denied, data and corrupt for D.

### R-p8-tlff-004 — Pair 1 coherent side channels

Pair 1 forwards B valid, param and address from auto_out_1 to auto_in_1, and B ready in the reverse direction. It forwards C valid, opcode, param, size, source, address, data and corrupt from auto_in_1 to auto_out_1, and C ready in the reverse direction. It forwards E valid and sink from auto_in_1 to auto_out_1. E has no ready signal. Every field is preserved independently of other channels.

### R-p8-tlff-005 — Combinational boundaries and reset

All 55 native outputs follow their corresponding current inputs combinationally, without a clock edge, queue, buffering, reordering or stored output. The same equalities hold for invalid and stalled channels and while reset is asserted. Reset does not gate valid, ready or payload. The two port pairs and all channels are independent. clock has no direct output-latency effect; active-high synchronous reset initializes and aborts only the legal-history checking described in the input domain.

# Complete legal input domain

The following conditions define legal normal traffic for all five requirements. They do not introduce buffering or alter the output equalities. Use reset to initialize history before normal traffic. Illegal histories may terminate simulation. No external protocol rules beyond these conditions are assumed.

## Clock, reset and presentation

Use known binary inputs. Apply a rising clock edge with active-high reset before protocol traffic. Reset clears message progress, source tracking and sink tracking synchronously; it does not gate any native output. A reset aborts pending protocol histories. Monitor presentation and sequence constraints apply at rising edges with reset low. Conditions on a presented message apply whenever its valid is high, including when ready is low. A ready/valid channel accepts a beat exactly when both are high at that edge. E accepts whenever its valid is high.

During reset, binary payload and valid values remain within the combinational path contract, while protocol checks are disabled. Message header snapshots may capture accepted first beats during reset; they do not affect native outputs. After reset, establish each legal history from fresh requests.

## Address regions and alignment

All interval endpoints below are inclusive unsigned 33-bit byte addresses. Define the common regions as `[0x000000000,0x000001FFF]`, `[0x000003000,0x000003FFF]`, `[0x000100000,0x000100FFF]`, `[0x000110000,0x000110FFF]`, `[0x002000000,0x00200FFFF]`, `[0x00C000000,0x00FFFFFFF]`, `[0x080000000,0x0FFFFFFFF]` and `[0x100000000,0x17FFFFFFF]`. The read/probe regions additionally include `[0x000010000,0x00001FFFF]`.

Alignment means that the lowest `min(size,12)` address bits are zero. For supported A operations size is at most 12, so this is ordinary alignment to `2^size` bytes. For an A beat of size below 3, the byte mask selects the contiguous `2^size` bytes beginning at the low three address bits; for size at least 3 it is `0xFF`.

## A messages on both pairs

Pair 0 admits all 4-bit source values. Pair 1 admits sources 0 through 9 and 16; decimal 10 is not admitted. The entire A message holds opcode, param, size, source and address constant from its first accepted beat through its last presented beat. Data, mask and corrupt may vary subject to the operation-specific restrictions. These are multibeat header requirements, not an additional claim of a native payload buffer.

- Opcode 0, PutFull: param zero, size at most 12, aligned address in a common region, with size at most 6 except in `[0x3000,0x3FFF]`; mask equals the size/address mask. Corrupt is unrestricted.
- Opcode 1, PutPartial: the same address, size and param rules as PutFull; mask may be any subset of the size/address mask, including zero. Corrupt is unrestricted.
- Opcode 2, Arithmetic: size 0 through 3, param 0 through 4, aligned address in the common regions except the two high regions, and exact size/address mask. Corrupt is unrestricted.
- Opcode 3, Logical: the same address, size and mask rules as Arithmetic; param 0 through 3. Corrupt is unrestricted.
- Opcode 4, Get: param zero, corrupt zero, size at most 12 and exact size/address mask. The aligned address is in a read/probe region, with size at most 6 except in `[0x3000,0x3FFF]`.
- Opcode 5, Hint: param 0 or 1, corrupt zero, aligned address in `[0x3000,0x3FFF]`, size at most 12 and exact size/address mask.
- Opcodes 6 and 7, AcquireBlock and AcquirePerm, are prohibited on pair 0. On pair 1 they require source 0 through 8, size exactly 6, 64-byte aligned address in one of the two high regions, mask `0xFF` and corrupt zero. AcquireBlock param is 0, 1 or 2; AcquirePerm param is 1 or 2.

PutFull, PutPartial, Arithmetic and Logical carry `max(1,2^(size-3))` beats; Get, Hint and both Acquire operations each carry one A beat. Beat progress advances only on acceptance. A new request's source must not already be outstanding when its first beat is accepted.

## D responses and source lifetime

Each response matches a preceding request on the same pair by source and size. PutFull/PutPartial map to AccessAck (opcode 0); Arithmetic/Logical/Get map to AccessAckData (opcode 1); Hint maps to HintAck (opcode 2); AcquireBlock maps to Grant or GrantData (opcode 4 or 5); AcquirePerm maps to Grant (opcode 4). Pair 0 cannot present Grant, GrantData or ReleaseAck in a legal initialized history. Opcodes 3 and 7 do not form legal responses.

For AccessAck, AccessAckData and HintAck, param is zero. AccessAck and HintAck have corrupt zero. AccessAckData may be corrupt, and denied implies corrupt. Grant and GrantData have size at least 3 and param 0 or 1; Grant has corrupt zero and GrantData obeys denied-implies-corrupt. ReleaseAck has size at least 3, param zero, denied zero and corrupt zero. Pair 1 responses use the same source domain as its requests.

AccessAckData and GrantData carry the size-derived number of data beats; other D messages carry one beat. The opcode, param, size, source, sink and denied fields remain constant throughout a multibeat D message. A source becomes outstanding on request first-beat acceptance and is freed on response first-beat acceptance, not on its final data beat. A presented response first beat must already have a matching outstanding source. Presenting a request first beat and its response first beat with the same source in the same cycle is prohibited even if either ready is zero. Separate pair source spaces are independent.

## Pair 1 B, C and E

B is a single-beat Probe containing param and address only. Param is 0 through 2. Address is 64-byte aligned and lies in a read/probe region. It has no source, opcode or size port. B acceptance uses its valid and ready.

C sources for the named operations are 0 through 9 and 16. ProbeAck (opcode 4) and ProbeAckData (opcode 5) require a read/probe-region address, size at least 3, the alignment rule above and report param 0 through 5. ProbeAck has corrupt zero; ProbeAckData allows corrupt. Release and ReleaseData (opcodes 6 and 7) require source 0 through 8, size exactly 6, a 64-byte aligned address in a high region and param 0 through 5; Release has corrupt zero, while ReleaseData permits corrupt. C AccessAck, AccessAckData and HintAck (opcodes 0, 1 and 2) are also accepted by the fixed monitor with aligned read/probe-region address, legal source and param zero; C AccessAck/HintAck require corrupt zero. For C opcode 3 the fixed implementation imposes no operation-specific source, address, size, param or corrupt restriction; binary values are admitted subject to the same odd-opcode data-beat progress and header-stability rule. This is an explicit fixed-implementation boundary, with no additional inferred external protocol meaning or D response obligation.

C messages with odd opcode carry data beats, while even-opcode C messages carry one beat. For ordinary sizes through 12 the data-beat count is `max(1,2^(size-3))`; the fixed 9-bit progress counter yields 512 beats for C data sizes 13 through 15. Multibeat C headers preserve opcode, param, size, source and address. Release sources have a separate outstanding set from A request sources. Their first accepted beat reserves a source, ReleaseAck first-beat acceptance frees it, and response size matches the recorded release size. Reusing an outstanding release source or presenting an unsolicited ReleaseAck is prohibited. Release and matching ReleaseAck first beats cannot be presented in the same cycle; ProbeAck/ProbeAckData do not create a release response obligation.

Grant/GrantData first-beat acceptance reserves its 2-bit sink until E acknowledges that sink. A reserved sink cannot be granted again, including on a cycle that also acknowledges the old grant. E valid must identify a reserved sink or a sink granted in that same cycle; therefore same-cycle new Grant and E acknowledgement are allowed. E clears the selected sink without a ready input. No additional B-to-C request matching is implemented by this fixed root.

