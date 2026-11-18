`timescale 1ns/1ps
module dvbench_model #(
    parameter C_PCI_DATA_WIDTH = 9'd128,
    parameter C_NUM_CHNL = 4'd12,
    parameter C_MAX_READ_REQ_BYTES = 512,
    parameter C_TAG_WIDTH = 5,
    parameter C_PCI_DATA_WORD = C_PCI_DATA_WIDTH/32,
    parameter C_PCI_DATA_COUNT_WIDTH = $clog2(C_PCI_DATA_WORD+1),
    parameter C_NUM_TAGS = 2**C_TAG_WIDTH,
    parameter C_DW_PER_TAG = C_MAX_READ_REQ_BYTES/4,
    parameter C_TAG_DW_COUNT_WIDTH = $clog2(C_DW_PER_TAG+1),
    parameter C_DATA_ADDR_STRIDE_WIDTH = $clog2(C_DW_PER_TAG/C_PCI_DATA_WORD),
    parameter C_DATA_ADDR_WIDTH = C_TAG_WIDTH+C_DATA_ADDR_STRIDE_WIDTH
) (
    input CLK, RST, VALID,
    input [C_PCI_DATA_WIDTH-1:0] DATA,
    input [C_PCI_DATA_WORD-1:0] DATA_EN,
    input [C_PCI_DATA_COUNT_WIDTH-1:0] DATA_EN_COUNT,
    input DONE, ERR,
    input [C_TAG_WIDTH-1:0] TAG,
    input [5:0] INT_TAG,
    input INT_TAG_VALID,
    output logic [C_TAG_WIDTH-1:0] EXT_TAG,
    output logic EXT_TAG_VALID,
    output logic [C_PCI_DATA_WIDTH-1:0] ENG_DATA,
    output logic [C_NUM_CHNL*C_PCI_DATA_COUNT_WIDTH-1:0] MAIN_DATA_EN, SG_RX_DATA_EN, SG_TX_DATA_EN,
    output logic [C_NUM_CHNL-1:0] MAIN_DONE, MAIN_ERR, SG_RX_DONE, SG_RX_ERR, SG_TX_DONE, SG_TX_ERR
);
    logic [31:0] payload [0:C_NUM_TAGS-1][0:C_DW_PER_TAG-1];
    integer lengths [0:C_NUM_TAGS-1];
    integer routes [0:C_NUM_TAGS-1];
    integer ready_at [0:C_NUM_TAGS-1];
    logic allocated [0:C_NUM_TAGS-1];
    logic final_done [0:C_NUM_TAGS-1];
    logic final_error [0:C_NUM_TAGS-1];
    integer cycle_number = 0;
    integer head_tag = 0;
    integer cursor = 0;
    integer eligible_cycle = 0;
    integer emitted_words;
    integer route_index;
    integer channel_index;
    integer group_index;
    integer slot_index;
    integer lane_index;
    integer next_slot;
    logic [C_PCI_DATA_WIDTH-1:0] next_data;
    logic route_initialized = 0;

    initial begin
        EXT_TAG = 0; EXT_TAG_VALID = 0; ENG_DATA = 0;
        MAIN_DATA_EN = 0; SG_RX_DATA_EN = 0; SG_TX_DATA_EN = 0;
        MAIN_DONE = 0; MAIN_ERR = 0; SG_RX_DONE = 0; SG_RX_ERR = 0; SG_TX_DONE = 0; SG_TX_ERR = 0;
        for (slot_index = 0; slot_index < C_NUM_TAGS; slot_index = slot_index + 1) begin
            allocated[slot_index] = 0; lengths[slot_index] = 0; ready_at[slot_index] = -1;
        end
    end

    always @(posedge CLK) begin
        cycle_number = cycle_number + 1;
        MAIN_DATA_EN <= #1 0; SG_RX_DATA_EN <= #1 0; SG_TX_DATA_EN <= #1 0;
        MAIN_DONE <= #1 0; MAIN_ERR <= #1 0; SG_RX_DONE <= #1 0; SG_RX_ERR <= #1 0; SG_TX_DONE <= #1 0; SG_TX_ERR <= #1 0;
        if (RST) begin
            EXT_TAG <= #1 0; EXT_TAG_VALID <= #1 0;
            head_tag = 0; cursor = 0; eligible_cycle = cycle_number;
            for (slot_index = 0; slot_index < C_NUM_TAGS; slot_index = slot_index + 1) begin
                allocated[slot_index] = 0; lengths[slot_index] = 0; ready_at[slot_index] = -1;
            end
        end else begin
            if (!route_initialized) begin
                MAIN_DATA_EN <= #1 'x; SG_RX_DATA_EN <= #1 'x; SG_TX_DATA_EN <= #1 'x;
                MAIN_DONE <= #1 'x; MAIN_ERR <= #1 'x; SG_RX_DONE <= #1 'x; SG_RX_ERR <= #1 'x; SG_TX_DONE <= #1 'x; SG_TX_ERR <= #1 'x;
            end
            next_slot = EXT_TAG;
            if (INT_TAG_VALID && EXT_TAG_VALID) begin
                routes[EXT_TAG] = INT_TAG;
                allocated[EXT_TAG] = 1;
                lengths[EXT_TAG] = 0; ready_at[EXT_TAG] = -1;
                next_slot = (EXT_TAG + 1) % C_NUM_TAGS;
            end
            EXT_TAG <= #1 next_slot;
            EXT_TAG_VALID <= #1 !allocated[next_slot];
            if (VALID) begin
                for (lane_index = 0; lane_index < C_PCI_DATA_WORD; lane_index = lane_index + 1)
                    if (DATA_EN[lane_index]) begin
                        payload[TAG][lengths[TAG]] = DATA[lane_index*32 +:32];
                        lengths[TAG] = lengths[TAG] + 1;
                    end
                if (DONE || ERR) begin
                    ready_at[TAG] = cycle_number + 10;
                    final_done[TAG] = DONE; final_error[TAG] = ERR;
                end
            end
            if (ready_at[head_tag] >= 0 && cycle_number >= ready_at[head_tag] && cycle_number >= eligible_cycle) begin
                emitted_words = lengths[head_tag] - cursor;
                route_initialized = 1;
                MAIN_DATA_EN <= #1 0; SG_RX_DATA_EN <= #1 0; SG_TX_DATA_EN <= #1 0;
                MAIN_DONE <= #1 0; MAIN_ERR <= #1 0; SG_RX_DONE <= #1 0; SG_RX_ERR <= #1 0; SG_TX_DONE <= #1 0; SG_TX_ERR <= #1 0;
                if (emitted_words > C_PCI_DATA_WORD) emitted_words = C_PCI_DATA_WORD;
                next_data = '0;
                for (lane_index = 0; lane_index < emitted_words; lane_index = lane_index + 1)
                    next_data[lane_index*32 +:32] = payload[head_tag][cursor+lane_index];
                ENG_DATA <= #1 next_data;
                route_index = routes[head_tag]; channel_index = route_index % 16; group_index = route_index / 16;
                if (channel_index < C_NUM_CHNL) begin
                    case (group_index)
                        0: MAIN_DATA_EN[channel_index*C_PCI_DATA_COUNT_WIDTH +:C_PCI_DATA_COUNT_WIDTH] <= #1 emitted_words;
                        1: SG_RX_DATA_EN[channel_index*C_PCI_DATA_COUNT_WIDTH +:C_PCI_DATA_COUNT_WIDTH] <= #1 emitted_words;
                        2: SG_TX_DATA_EN[channel_index*C_PCI_DATA_COUNT_WIDTH +:C_PCI_DATA_COUNT_WIDTH] <= #1 emitted_words;
                    endcase
                    if (cursor + emitted_words == lengths[head_tag]) begin
                        case (group_index)
                            0: begin MAIN_DONE[channel_index] <= #1 final_done[head_tag] | final_error[head_tag]; MAIN_ERR[channel_index] <= #1 final_error[head_tag]; end
                            1: begin SG_RX_DONE[channel_index] <= #1 final_done[head_tag] | final_error[head_tag]; SG_RX_ERR[channel_index] <= #1 final_error[head_tag]; end
                            2: begin SG_TX_DONE[channel_index] <= #1 final_done[head_tag] | final_error[head_tag]; SG_TX_ERR[channel_index] <= #1 final_error[head_tag]; end
                        endcase
                    end
                end
                cursor = cursor + emitted_words;
                if (cursor == lengths[head_tag]) begin
                    eligible_cycle = cycle_number + ((lengths[head_tag] <= C_PCI_DATA_WORD) ? 2 : 1);
                    allocated[head_tag] = 0; ready_at[head_tag] = -1;
                    head_tag = (head_tag + 1) % C_NUM_TAGS; cursor = 0;
                end
            end
        end
    end
endmodule
