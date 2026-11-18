module reorder_queue_probe;
    logic CLK = 1'b0;
    logic RST = 1'b1;
    logic VALID = 1'b0;
    logic [127:0] DATA = '0;
    logic [3:0] DATA_EN = '0;
    logic [2:0] DATA_EN_COUNT = '0;
    logic DONE = 1'b0;
    logic ERR = 1'b0;
    logic [4:0] TAG = '0;
    logic [5:0] INT_TAG = '0;
    logic INT_TAG_VALID = 1'b0;
    wire [4:0] EXT_TAG;
    wire EXT_TAG_VALID;
    wire [127:0] ENG_DATA;
    wire [35:0] MAIN_DATA_EN;
    wire [11:0] MAIN_DONE;
    wire [11:0] MAIN_ERR;
    wire [35:0] SG_RX_DATA_EN;
    wire [11:0] SG_RX_DONE;
    wire [11:0] SG_RX_ERR;
    wire [35:0] SG_TX_DATA_EN;
    wire [11:0] SG_TX_DONE;
    wire [11:0] SG_TX_ERR;
    integer cycle_index = 0;

    always #5 CLK = ~CLK;

    reorder_queue dut (
        .CLK(CLK), .RST(RST), .VALID(VALID), .DATA(DATA), .DATA_EN(DATA_EN),
        .DATA_EN_COUNT(DATA_EN_COUNT), .DONE(DONE), .ERR(ERR), .TAG(TAG),
        .INT_TAG(INT_TAG), .INT_TAG_VALID(INT_TAG_VALID), .EXT_TAG(EXT_TAG),
        .EXT_TAG_VALID(EXT_TAG_VALID), .ENG_DATA(ENG_DATA), .MAIN_DATA_EN(MAIN_DATA_EN),
        .MAIN_DONE(MAIN_DONE), .MAIN_ERR(MAIN_ERR), .SG_RX_DATA_EN(SG_RX_DATA_EN),
        .SG_RX_DONE(SG_RX_DONE), .SG_RX_ERR(SG_RX_ERR), .SG_TX_DATA_EN(SG_TX_DATA_EN),
        .SG_TX_DONE(SG_TX_DONE), .SG_TX_ERR(SG_TX_ERR)
    );

    initial begin
        repeat (3) @(negedge CLK);
        RST = 1'b0;
        repeat (3) @(negedge CLK);
        if (EXT_TAG_VALID !== 1'b1 || EXT_TAG !== 0) $fatal(1, "initial tag contract mismatch");
        INT_TAG = 6'd5;
        INT_TAG_VALID = 1'b1;
        @(negedge CLK);
        INT_TAG_VALID = 1'b0;
        repeat (3) @(negedge CLK);
        TAG = 0;
        DATA = {32'h04040404,32'h03030303,32'h02020202,32'h01010101};
        DATA_EN = 4'b1111;
        DATA_EN_COUNT = 3'd4;
        DONE = 1'b1;
        VALID = 1'b1;
        @(negedge CLK);
        DONE = 1'b0;
        VALID = 1'b0;
        DATA_EN = '0;
        DATA_EN_COUNT = '0;
        repeat (40) begin
            @(negedge CLK);
            cycle_index = cycle_index + 1;
            if (MAIN_DATA_EN != 0 || MAIN_DONE != 0 || MAIN_ERR != 0 || SG_RX_DATA_EN != 0 || SG_RX_DONE != 0 || SG_RX_ERR != 0 || SG_TX_DATA_EN != 0 || SG_TX_DONE != 0 || SG_TX_ERR != 0)
                $display("OUT cycle=%0d tag=%0d ext_valid=%0b eng=%h main_en=%h main_done=%h main_err=%h rx_en=%h rx_done=%h rx_err=%h tx_en=%h tx_done=%h tx_err=%h", cycle_index, EXT_TAG, EXT_TAG_VALID, ENG_DATA, MAIN_DATA_EN, MAIN_DONE, MAIN_ERR, SG_RX_DATA_EN, SG_RX_DONE, SG_RX_ERR, SG_TX_DATA_EN, SG_TX_DONE, SG_TX_ERR);
        end
        $display("PROBE_DONE tag=%0d ext_valid=%0b", EXT_TAG, EXT_TAG_VALID);
        $finish;
    end
endmodule
