`timescale 1ns/1ps
interface timer_if;
        logic HCLK=0;
        logic HRESETn=0;
        logic [11:0] PADDR=0;
        logic [31:0] PWDATA=0;
        logic PWRITE=0;
        logic PSEL=0;
        logic PENABLE=0;
        logic dft_cg_enable_i=0;
        logic ref_clk_i=0;
        logic event_lo_i=0;
        logic event_hi_i=0;
        logic [31:0] PRDATA;
        logic [31:0] expected_PRDATA;
        logic PREADY;
        logic expected_PREADY;
        logic PSLVERR;
        logic expected_PSLVERR;
        logic [31:0] timer_val_lo_o;
        logic [31:0] expected_timer_val_lo_o;
        logic irq_lo_o;
        logic expected_irq_lo_o;
        logic irq_hi_o;
        logic expected_irq_hi_o;
        logic busy_o;
        logic expected_busy_o;
    bit checking=0,stop_requested=0;
endinterface
