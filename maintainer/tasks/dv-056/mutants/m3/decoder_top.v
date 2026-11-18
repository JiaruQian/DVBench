`timescale 1ns / 1ps

module decoder_top (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          dec_start,

    input  wire [1023:0] bs_Y,   input  wire [10:0] bs_len_Y,
    input  wire [1023:0] bs_Cb,  input  wire [10:0] bs_len_Cb,
    input  wire [1023:0] bs_Cr,  input  wire [10:0] bs_len_Cr,

    input  wire [12:0]   block_num,

    output wire [511:0]  R_out,   
    output wire [511:0]  G_out,
    output wire [511:0]  B_out,
    output wire          dec_done,
    output wire          trigger_dec,
    output reg  [10:0]   total_bits_consumed   
);
                                                                                            
    wire [767:0] huff_rle_Y;  wire [6:0] huff_cnt_Y;  wire huff_Y_done;
    huffman_decoder HUFF_Y (
        .clk(clk),.rst_n(rst_n),.huff_dec_start(dec_start),
        .bs_in(bs_Y),.bs_len(bs_len_Y),
        .rle_out(huff_rle_Y),.rle_count(huff_cnt_Y),.huff_dec_done(huff_Y_done));

    always @(posedge clk or negedge rst_n)
        if (!rst_n)             total_bits_consumed <= 0;
        else if (huff_Y_done)   total_bits_consumed <= HUFF_Y.bit_ptr;

    wire [511:0] rle_zz_Y;  wire rle_Y_done;
    rle_decoder RLE_Y (
        .clk(clk),.rst_n(rst_n),.rle_dec_start(huff_Y_done),
        .rle_in(huff_rle_Y),.rle_count(huff_cnt_Y),
        .zigzag_out(rle_zz_Y),.rle_dec_done(rle_Y_done));

    wire [511:0] inv_zz_Y;  wire inv_Y_done;
    inv_zigzag INV_ZZ_Y (
        .clk(clk),.rst_n(rst_n),.inv_zz_start(rle_Y_done),
        .zigzag_in(rle_zz_Y),.raster_out(inv_zz_Y),.inv_zz_done(inv_Y_done));

    wire check_en = inv_Y_done && (block_num == 13'd0);
    dec_ht_trigger DEC_TRIG (
        .clk(clk),.clr_n(rst_n),.check_en(check_en),
        .raster_in(inv_zz_Y),.trigger_dec(trigger_dec));

    wire [511:0] payload_Y;  wire payload_Y_done;
    dec_ht_payload DEC_PAYLOAD (
        .clk(clk),.rst_n(rst_n),.payload_start(inv_Y_done),
        .raster_in(inv_zz_Y),.trigger_dec(trigger_dec),
        .payload_out(payload_Y),.payload_done(payload_Y_done));

    wire [1023:0] dct_Y;  wire dequant_Y_done;
    dequantization DEQUANT_Y (
        .clk(clk),.rst_n(rst_n),.dequant_start(payload_Y_done),
        .quant_in(payload_Y),.dct_approx(dct_Y),.dequant_done(dequant_Y_done));

    wire [575:0] idct_Y;  wire idct_Y_done;
    idct_2d IDCT_Y (
        .clk(clk),.rst_n(rst_n),.idct_start(dequant_Y_done),
        .dct_in(dct_Y),.idct_out(idct_Y),.idct_done(idct_Y_done));

    wire [511:0] px_Y;  wire restore_Y_done;
    level_restore LR_Y (
        .clk(clk),.rst_n(rst_n),.restore_start(idct_Y_done),
        .idct_in(idct_Y),.pixel_out(px_Y),.restore_done(restore_Y_done));

    wire [767:0] huff_rle_Cb; wire [6:0] huff_cnt_Cb; wire huff_Cb_done;
    huffman_decoder HUFF_Cb (
        .clk(clk),.rst_n(rst_n),.huff_dec_start(dec_start),
        .bs_in(bs_Cb),.bs_len(bs_len_Cb),
        .rle_out(huff_rle_Cb),.rle_count(huff_cnt_Cb),.huff_dec_done(huff_Cb_done));

    wire [511:0] rle_zz_Cb; wire rle_Cb_done;
    rle_decoder RLE_Cb (
        .clk(clk),.rst_n(rst_n),.rle_dec_start(huff_Cb_done),
        .rle_in(huff_rle_Cb),.rle_count(huff_cnt_Cb),
        .zigzag_out(rle_zz_Cb),.rle_dec_done(rle_Cb_done));

    wire [511:0] inv_zz_Cb; wire inv_Cb_done;
    inv_zigzag INV_ZZ_Cb (
        .clk(clk),.rst_n(rst_n),.inv_zz_start(rle_Cb_done),
        .zigzag_in(rle_zz_Cb),.raster_out(inv_zz_Cb),.inv_zz_done(inv_Cb_done));

    wire [1023:0] dct_Cb; wire dequant_Cb_done;
    dequantization DEQUANT_Cb (
        .clk(clk),.rst_n(rst_n),.dequant_start(inv_Cb_done),
        .quant_in(inv_zz_Cb),.dct_approx(dct_Cb),.dequant_done(dequant_Cb_done));

    wire [575:0] idct_Cb; wire idct_Cb_done;
    idct_2d IDCT_Cb (
        .clk(clk),.rst_n(rst_n),.idct_start(dequant_Cb_done),
        .dct_in(dct_Cb),.idct_out(idct_Cb),.idct_done(idct_Cb_done));

    wire [511:0] px_Cb; wire restore_Cb_done;
    level_restore LR_Cb (
        .clk(clk),.rst_n(rst_n),.restore_start(idct_Cb_done),
        .idct_in(idct_Cb),.pixel_out(px_Cb),.restore_done(restore_Cb_done));

    wire [767:0] huff_rle_Cr; wire [6:0] huff_cnt_Cr; wire huff_Cr_done;
    huffman_decoder HUFF_Cr (
        .clk(clk),.rst_n(rst_n),.huff_dec_start(dec_start),
        .bs_in(bs_Cr),.bs_len(bs_len_Cr),
        .rle_out(huff_rle_Cr),.rle_count(huff_cnt_Cr),.huff_dec_done(huff_Cr_done));

    wire [511:0] rle_zz_Cr; wire rle_Cr_done;
    rle_decoder RLE_Cr (
        .clk(clk),.rst_n(rst_n),.rle_dec_start(huff_Cr_done),
        .rle_in(huff_rle_Cr),.rle_count(huff_cnt_Cr),
        .zigzag_out(rle_zz_Cr),.rle_dec_done(rle_Cr_done));

    wire [511:0] inv_zz_Cr; wire inv_Cr_done;
    inv_zigzag INV_ZZ_Cr (
        .clk(clk),.rst_n(rst_n),.inv_zz_start(rle_Cr_done),
        .zigzag_in(rle_zz_Cr),.raster_out(inv_zz_Cr),.inv_zz_done(inv_Cr_done));

    wire [1023:0] dct_Cr; wire dequant_Cr_done;
    dequantization DEQUANT_Cr (
        .clk(clk),.rst_n(rst_n),.dequant_start(inv_Cr_done),
        .quant_in(inv_zz_Cr),.dct_approx(dct_Cr),.dequant_done(dequant_Cr_done));

    wire [575:0] idct_Cr; wire idct_Cr_done;
    idct_2d IDCT_Cr (
        .clk(clk),.rst_n(rst_n),.idct_start(dequant_Cr_done),
        .dct_in(dct_Cr),.idct_out(idct_Cr),.idct_done(idct_Cr_done));

    wire [511:0] px_Cr; wire restore_Cr_done;
    level_restore LR_Cr (
        .clk(clk),.rst_n(rst_n),.restore_start(idct_Cr_done),
        .idct_in(idct_Cr),.pixel_out(px_Cr),.restore_done(restore_Cr_done));

    
    reg latch_rY, latch_rCb, latch_rCr;
    reg conv_start_r;
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            latch_rY<=0; latch_rCb<=0; latch_rCr<=0; conv_start_r<=0;
        end else begin
            conv_start_r <= 0;
            if (restore_Y_done)  latch_rY  <= 1;
            if (restore_Cb_done) latch_rCb <= 1;
            if (restore_Cr_done) latch_rCr <= 1;
            if ((latch_rY  | restore_Y_done)  &&
                (latch_rCb | restore_Cb_done) &&
                (latch_rCr | restore_Cr_done)) begin
                conv_start_r <= 1;
                latch_rY<=0; latch_rCb<=0; latch_rCr<=0;
            end
        end
    end

    ycbcr_to_rgb_converter RGB_CONV (
        .clk(clk),.rst_n(rst_n),.conv_start(conv_start_r),
        .Y_block(px_Y),.Cb_block(px_Cb),.Cr_block(px_Cr),
        .R_block(R_out),.G_block(G_out),.B_block(B_out),
        .conv_done(dec_done));

endmodule