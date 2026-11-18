`timescale 1ns / 1ps

module idct_1d #(
    parameter INPUT_WIDTH = 16
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire        valid_in,

    input  wire signed [INPUT_WIDTH-1:0] x0,x1,x2,x3,
    input  wire signed [INPUT_WIDTH-1:0] x4,x5,x6,x7,

    output reg         valid_out,
    output reg signed [24:0] Y0,Y1,Y2,Y3,
    output reg signed [24:0] Y4,Y5,Y6,Y7
);

    localparam signed [8:0] C4 = 9'd90;
    localparam signed [8:0] C6 = 9'd49;
    localparam signed [8:0] S6 = 9'd118;
    localparam signed [8:0] C2 = 9'd118;
    localparam signed [8:0] S2 = 9'd49;

    wire signed [INPUT_WIDTH-1:0] e0,e1,e2,e3;
    wire signed [INPUT_WIDTH-1:0] o0,o1,o2,o3;

    assign e0=x0; assign e1=x4;
    assign e2=x2; assign e3=x6;
    assign o0=x7; assign o1=x5;
    assign o2=x3; assign o3=x1;

    reg signed [INPUT_WIDTH:0]    r0,r1,r4,r5,r6,r7;
    reg signed [INPUT_WIDTH+8:0]  r2,r3;
    reg valid_s1;

    reg signed [INPUT_WIDTH+9:0]  s0,s1,s2,s3;
    reg signed [INPUT_WIDTH+9:0]  s4,s5,s6,s7;
    reg valid_s2;

    reg signed [INPUT_WIDTH+10:0] t0,t1,t2,t3,t4,t5,t6,t7;
    reg valid_s3;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            r0<=0;r1<=0;r2<=0;r3<=0;
            r4<=0;r5<=0;r6<=0;r7<=0;
            valid_s1 <= 0;
        end
        else begin
            valid_s1 <= valid_in;
            if (valid_in) begin
                r0 <= e0 + e1;
                r1 <= e0 - e1;
                r2 <= (e2 * C4) >>> 7;
                r3 <= (e3 * C4) >>> 7;
                r4 <= o3 + o0;
                r5 <= o2 + o1;
                r6 <= o2 - o1;
                r7 <= o3 - o0;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            s0<=0;s1<=0;s2<=0;s3<=0;
            s4<=0;s5<=0;s6<=0;s7<=0;
            valid_s2 <= 0;
        end
        else begin
            valid_s2 <= valid_s1;
            if (valid_s1) begin
                s0 <= r0 + r2;
                s1 <= r1 + r3;
                s2 <= r1 - r3;
                s3 <= r0 - r2;
                s4 <= (r4 * C6 + r7 * S6) >>> 7;
                s5 <= (r5 * C2 + r6 * S2) >>> 7;
                s6 <= (r6 * C2 - r5 * S2) >>> 7;
                s7 <= (r7 * C6 - r4 * S6) >>> 7;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            t0<=0;t1<=0;t2<=0;t3<=0;
            t4<=0;t5<=0;t6<=0;t7<=0;
            valid_s3 <= 0;
        end
        else begin
            valid_s3 <= valid_s2;
            if (valid_s2) begin
                t0 <= s0 + s4;
                t1 <= s1 + s5;
                t2 <= s2 + s6;
                t3 <= s3 + s7;
                t4 <= s3 - s7;
                t5 <= s2 - s6;
                t6 <= s1 - s5;
                t7 <= s0 - s4;
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Y0<=0;Y1<=0;Y2<=0;Y3<=0;
            Y4<=0;Y5<=0;Y6<=0;Y7<=0;
            valid_out <= 0;
        end
        else begin
            valid_out <= valid_s3;
            if (valid_s3) begin
                Y0<=t0; Y1<=t1; Y2<=t2; Y3<=t3;
                Y4<=t4; Y5<=t5; Y6<=t6; Y7<=t7;
            end
        end
    end

endmodule