`timescale 1ns/1ps

module ycbcr_to_rgb_converter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        conv_start,        
    input  wire [511:0] Y_block,       
    input  wire [511:0] Cb_block,        
    input  wire [511:0] Cr_block,      

    output reg  [511:0] R_block,        
    output reg  [511:0] G_block,         
    output reg  [511:0] B_block,          
    output reg          conv_done
);

    function [7:0] clip8;
        input signed [19:0] v;
        begin
            if (v < 0)         clip8 = 8'd0;
            else if (v > 255)  clip8 = 8'd255;
            else               clip8 = v[7:0];
        end
    endfunction

    reg [5:0]  idx;
    reg        busy;

    wire [7:0] Y  = Y_block [idx*8 +: 8];
    wire [7:0] Cb = Cb_block[idx*8 +: 8];
    wire [7:0] Cr = Cr_block[idx*8 +: 8];

    wire signed [19:0] r_calc = ($signed({1'b0,Y})<<8) + 20'sd359*($signed({1'b0,Cr})-20'sd128);
    wire signed [19:0] g_calc = ($signed({1'b0,Y})<<8) - 20'sd88 *($signed({1'b0,Cb})-20'sd128)
                                                        - 20'sd183*($signed({1'b0,Cr})-20'sd128);
    wire signed [19:0] b_calc = ($signed({1'b0,Y})<<8) + 20'sd454*($signed({1'b0,Cb})-20'sd128);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idx <= 0; busy <= 0; conv_done <= 0;
            R_block <= 0; G_block <= 0; B_block <= 0;
        end else begin
            conv_done <= 0;
            if (conv_start) begin
                idx <= 0; busy <= 1;
                R_block <= 0; G_block <= 0; B_block <= 0;
            end else if (busy) begin
                R_block[idx*8 +: 8] <= clip8(r_calc >>> 8);
                G_block[idx*8 +: 8] <= clip8(g_calc >>> 8);
                B_block[idx*8 +: 8] <= clip8(b_calc >>> 8);
                if (idx == 6'd63) begin
                    busy <= 0; conv_done <= 1;
                end else
                    idx <= idx + 1;
            end
        end
    end
endmodule