# timer black-box behavior contract

This contract covers deterministic two-state inputs and the complete native port behavior. Inputs are stable within each observation window. State depends only on reset and input history.

## R-32C4343634EF-001 Asynchronous reset

reset is active high and asynchronous. It sets counter=0, compare=2^CNTw-1, prescaler=0, control configuration=0, ISR=0, read=0, and ack=0. sa_err_o and sa_rty_o are always zero. No rising clk edge is needed. Releasing reset does not itself update state. Reset dominates simultaneous reads, writes, counting, and IRQ events. Values are truncated separately for the 32-bit and CNTw=8 configurations.

## R-32C4343634EF-002 ACK and bus operation enables

At each non-reset rising edge, ack_next=sa_stb_i AND NOT old_ack. Reads and writes are enabled solely by sa_stb_i and sa_we_i; sa_cyc_i, sa_sel_i, and sa_tag_i do not affect them. ack is registered. With stb held high it alternates 1/0 each edge, and reads/writes also occur on edges whose ack is zero. stb=0 makes the next ack zero. Complete registers can be written with cyc=0 or sel=0.

## R-32C4343634EF-003 Register map and invalid addresses

Address 0 is control/ISR, 1 is counter, and 2 is compare. Writes occur when stb=1 and we=1. Addresses 1 and 2 take the low CNTw data bits; writes to other addresses have no effect. Writes occur at rising edges. Loading counter overrides normal counting at the same edge. For Aw=3, invalid addresses 3..7 do not change configuration, load counter, or update compare; counter may still count normally under its existing configuration.

## R-32C4343634EF-004 Registered reads

At a rising edge with stb=1 and we=0, address 0 samples old {ISR,configuration}, address 1 samples old counter, and address 2 samples old compare. Other addresses preserve old read. sa_dat_o zero-extends the CNTw-bit read register to Dw bits. Reads are registered and sample old state in parallel with same-edge counting. Without a read, read holds. This is not a combinational address mux. For CNTw=8 the upper 24 output bits must be zero.

## R-32C4343634EF-005 Control fields

Let D=ceil(log2(PRESCALER_WIDTH)). The low D+3 configuration bits, from low to high, are enable, int_enable, reset_on_compare, and the D-bit divider selection s. ISR occupies the following bit D+3. A write to address 0 replaces the low configuration bits. Counting and events at that edge use the old configuration; the new configuration applies to subsequent transitions. PRESCALER_WIDTH=8 gives D=3 and ISR bit 6; width 4 gives D=2 and ISR bit 5. Other high write bits are ignored.

## R-32C4343634EF-006 Prescaler phase

The terminal value is T=0 for s=0 and T=2^(s-1) for s>0. tick means that the low PRESCALER_WIDTH-1 bits of old prescaler equal T. When enable=1, tick clears prescaler to zero, otherwise prescaler increments. When enable=0, prescaler holds. Every decision uses pre-edge state; the highest prescaler bit does not participate in tick. The divider period is not simply 2^s: s=0 ticks every enabled edge, and s>0 starting at phase zero ticks every T+1 edges.

## R-32C4343634EF-007 Counting and compare reset

When enable=1 and tick is true, counter_next=0 if reset_on_compare=1 and old counter==old compare; otherwise counter_next=(counter+1) mod 2^CNTw. Without tick or when disabled, counter holds. Compare uses counter before increment, rather than clearing immediately after an increment reaches compare. A load overrides normal counter updates. Writing compare changes only compare; that edge still tests the old compare value.

## R-32C4343634EF-008 Interrupt latch

Without a control write, ISR_next=old_int_enable AND (old_ISR OR (tick AND reset_on_compare AND old_counter==old_compare)); irq=ISR. IRQ updates as a register using old configuration and old counter. The event itself does not require enable=1. int_enable=0 clears ISR at the next ordinary edge. With reset_on_compare=0, matching values do not generate the event.

## R-32C4343634EF-009 ISR write-one-to-clear priority

On an address-0 control write, ISR_next=old_ISR AND NOT sa_dat_i[D+3]. This write overrides the ordinary interrupt event: writing zero preserves old ISR, writing one clears it, and low configuration bits update simultaneously. A new event at the control-write edge does not set ISR. New int_enable must not generate a same-edge event. Writing ISR bit zero preserves an existing ISR even when new int_enable=0; only a later ordinary edge without a control write applies the ordinary clearing rule.

## R-32C4343634EF-010 Parameters and constant outputs

The fixed matrix contains PRESCALER_WIDTH=8,CNTw=32 and PRESCALER_WIDTH=4,CNTw=8. Both use Dw=32,Aw=3,SELw=4,TAGw=3. sa_err_o=sa_rty_o=0 in every state, independently of clock, reset, bus accesses, matches, or IRQ. Other parameter combinations are outside this contract. The 32-bit configuration must retain the complete width, including loads near overflow; checking only the smaller configuration is insufficient.
