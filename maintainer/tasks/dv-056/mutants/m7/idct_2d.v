`timescale 1ns / 1ps

module idct_2d (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          idct_start,
    input  wire [1023:0] dct_in,

    output reg           idct_done,
    output reg  [575:0]  idct_out
);

    // ── Explicit wire declarations for dct_in ─────────────
    wire signed [15:0] c00,c01,c02,c03,c04,c05,c06,c07;
    wire signed [15:0] c10,c11,c12,c13,c14,c15,c16,c17;
    wire signed [15:0] c20,c21,c22,c23,c24,c25,c26,c27;
    wire signed [15:0] c30,c31,c32,c33,c34,c35,c36,c37;
    wire signed [15:0] c40,c41,c42,c43,c44,c45,c46,c47;
    wire signed [15:0] c50,c51,c52,c53,c54,c55,c56,c57;
    wire signed [15:0] c60,c61,c62,c63,c64,c65,c66,c67;
    wire signed [15:0] c70,c71,c72,c73,c74,c75,c76,c77;

    assign c00=$signed(dct_in[(0*8+0)*16+:16]);
    assign c01=$signed(dct_in[(0*8+1)*16+:16]);
    assign c02=$signed(dct_in[(0*8+2)*16+:16]);
    assign c03=$signed(dct_in[(0*8+3)*16+:16]);
    assign c04=$signed(dct_in[(0*8+4)*16+:16]);
    assign c05=$signed(dct_in[(0*8+5)*16+:16]);
    assign c06=$signed(dct_in[(0*8+6)*16+:16]);
    assign c07=$signed(dct_in[(0*8+7)*16+:16]);

    assign c10=$signed(dct_in[(1*8+0)*16+:16]);
    assign c11=$signed(dct_in[(1*8+1)*16+:16]);
    assign c12=$signed(dct_in[(1*8+2)*16+:16]);
    assign c13=$signed(dct_in[(1*8+3)*16+:16]);
    assign c14=$signed(dct_in[(1*8+4)*16+:16]);
    assign c15=$signed(dct_in[(1*8+5)*16+:16]);
    assign c16=$signed(dct_in[(1*8+6)*16+:16]);
    assign c17=$signed(dct_in[(1*8+7)*16+:16]);

    assign c20=$signed(dct_in[(2*8+0)*16+:16]);
    assign c21=$signed(dct_in[(2*8+1)*16+:16]);
    assign c22=$signed(dct_in[(2*8+2)*16+:16]);
    assign c23=$signed(dct_in[(2*8+3)*16+:16]);
    assign c24=$signed(dct_in[(2*8+4)*16+:16]);
    assign c25=$signed(dct_in[(2*8+5)*16+:16]);
    assign c26=$signed(dct_in[(2*8+6)*16+:16]);
    assign c27=$signed(dct_in[(2*8+7)*16+:16]);

    assign c30=$signed(dct_in[(3*8+0)*16+:16]);
    assign c31=$signed(dct_in[(3*8+1)*16+:16]);
    assign c32=$signed(dct_in[(3*8+2)*16+:16]);
    assign c33=$signed(dct_in[(3*8+3)*16+:16]);
    assign c34=$signed(dct_in[(3*8+4)*16+:16]);
    assign c35=$signed(dct_in[(3*8+5)*16+:16]);
    assign c36=$signed(dct_in[(3*8+6)*16+:16]);
    assign c37=$signed(dct_in[(3*8+7)*16+:16]);

    assign c40=$signed(dct_in[(4*8+0)*16+:16]);
    assign c41=$signed(dct_in[(4*8+1)*16+:16]);
    assign c42=$signed(dct_in[(4*8+2)*16+:16]);
    assign c43=$signed(dct_in[(4*8+3)*16+:16]);
    assign c44=$signed(dct_in[(4*8+4)*16+:16]);
    assign c45=$signed(dct_in[(4*8+5)*16+:16]);
    assign c46=$signed(dct_in[(4*8+6)*16+:16]);
    assign c47=$signed(dct_in[(4*8+7)*16+:16]);

    assign c50=$signed(dct_in[(5*8+0)*16+:16]);
    assign c51=$signed(dct_in[(5*8+1)*16+:16]);
    assign c52=$signed(dct_in[(5*8+2)*16+:16]);
    assign c53=$signed(dct_in[(5*8+3)*16+:16]);
    assign c54=$signed(dct_in[(5*8+4)*16+:16]);
    assign c55=$signed(dct_in[(5*8+5)*16+:16]);
    assign c56=$signed(dct_in[(5*8+6)*16+:16]);
    assign c57=$signed(dct_in[(5*8+7)*16+:16]);

    assign c60=$signed(dct_in[(6*8+0)*16+:16]);
    assign c61=$signed(dct_in[(6*8+1)*16+:16]);
    assign c62=$signed(dct_in[(6*8+2)*16+:16]);
    assign c63=$signed(dct_in[(6*8+3)*16+:16]);
    assign c64=$signed(dct_in[(6*8+4)*16+:16]);
    assign c65=$signed(dct_in[(6*8+5)*16+:16]);
    assign c66=$signed(dct_in[(6*8+6)*16+:16]);
    assign c67=$signed(dct_in[(6*8+7)*16+:16]);

    assign c70=$signed(dct_in[(7*8+0)*16+:16]);
    assign c71=$signed(dct_in[(7*8+1)*16+:16]);
    assign c72=$signed(dct_in[(7*8+2)*16+:16]);
    assign c73=$signed(dct_in[(7*8+3)*16+:16]);
    assign c74=$signed(dct_in[(7*8+4)*16+:16]);
    assign c75=$signed(dct_in[(7*8+5)*16+:16]);
    assign c76=$signed(dct_in[(7*8+6)*16+:16]);
    assign c77=$signed(dct_in[(7*8+7)*16+:16]);

    // ── Transpose buffer ──────────────────────────────────
    reg signed [24:0] t00,t01,t02,t03,t04,t05,t06,t07;
    reg signed [24:0] t10,t11,t12,t13,t14,t15,t16,t17;
    reg signed [24:0] t20,t21,t22,t23,t24,t25,t26,t27;
    reg signed [24:0] t30,t31,t32,t33,t34,t35,t36,t37;
    reg signed [24:0] t40,t41,t42,t43,t44,t45,t46,t47;
    reg signed [24:0] t50,t51,t52,t53,t54,t55,t56,t57;
    reg signed [24:0] t60,t61,t62,t63,t64,t65,t66,t67;
    reg signed [24:0] t70,t71,t72,t73,t74,t75,t76,t77;

    // ── Column IDCT ───────────────────────────────────────
    reg        col_valid;
    reg [2:0]  col_idx;
    reg signed [15:0] cx0,cx1,cx2,cx3,cx4,cx5,cx6,cx7;
    wire        col_dct_valid;
    wire signed [24:0] cY0,cY1,cY2,cY3,cY4,cY5,cY6,cY7;

    idct_1d #(.INPUT_WIDTH(16)) COL_IDCT (
        .clk(clk),.rst_n(rst_n),
        .valid_in(col_valid),
        .x0(cx0),.x1(cx1),.x2(cx2),.x3(cx3),
        .x4(cx4),.x5(cx5),.x6(cx6),.x7(cx7),
        .valid_out(col_dct_valid),
        .Y0(cY0),.Y1(cY1),.Y2(cY2),.Y3(cY3),
        .Y4(cY4),.Y5(cY5),.Y6(cY6),.Y7(cY7)
    );

    // ── Row IDCT ──────────────────────────────────────────
    reg        row_valid;
    reg [2:0]  row_idx;
    reg signed [24:0] rx0,rx1,rx2,rx3,rx4,rx5,rx6,rx7;
    wire        row_dct_valid;
    wire signed [24:0] rY0,rY1,rY2,rY3,rY4,rY5,rY6,rY7;

    idct_1d #(.INPUT_WIDTH(25)) ROW_IDCT (
        .clk(clk),.rst_n(rst_n),
        .valid_in(row_valid),
        .x0(rx0),.x1(rx1),.x2(rx2),.x3(rx3),
        .x4(rx4),.x5(rx5),.x6(rx6),.x7(rx7),
        .valid_out(row_dct_valid),
        .Y0(rY0),.Y1(rY1),.Y2(rY2),.Y3(rY3),
        .Y4(rY4),.Y5(rY5),.Y6(rY6),.Y7(rY7)
    );

    // ── FSM ───────────────────────────────────────────────
    localparam S_IDLE     = 3'd0;
    localparam S_COL_FEED = 3'd1;
    localparam S_COL_WAIT = 3'd2;
    localparam S_ROW_FEED = 3'd3;
    localparam S_ROW_WAIT = 3'd4;
    localparam S_DONE     = 3'd5;

    reg [2:0] state;
    reg [2:0] wait_cnt;
    reg [2:0] trans_col_wr;
    reg [2:0] result_row_wr;
    reg        load_cx;
    reg [2:0]  load_cx_col;
    reg        load_rx;
    reg [2:0]  load_rx_row;

    // ── Load cx from input ────────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cx0<=0;cx1<=0;cx2<=0;cx3<=0;
            cx4<=0;cx5<=0;cx6<=0;cx7<=0;
        end
        else if (load_cx) begin
            case (load_cx_col)
                3'd0: begin cx0<=c00;cx1<=c10;cx2<=c20;cx3<=c30;
                            cx4<=c40;cx5<=c50;cx6<=c60;cx7<=c70; end
                3'd1: begin cx0<=c01;cx1<=c11;cx2<=c21;cx3<=c31;
                            cx4<=c41;cx5<=c51;cx6<=c61;cx7<=c71; end
                3'd2: begin cx0<=c02;cx1<=c12;cx2<=c22;cx3<=c32;
                            cx4<=c42;cx5<=c52;cx6<=c62;cx7<=c72; end
                3'd3: begin cx0<=c03;cx1<=c13;cx2<=c23;cx3<=c33;
                            cx4<=c43;cx5<=c53;cx6<=c63;cx7<=c73; end
                3'd4: begin cx0<=c04;cx1<=c14;cx2<=c24;cx3<=c34;
                            cx4<=c44;cx5<=c54;cx6<=c64;cx7<=c74; end
                3'd5: begin cx0<=c05;cx1<=c15;cx2<=c25;cx3<=c35;
                            cx4<=c45;cx5<=c55;cx6<=c65;cx7<=c75; end
                3'd6: begin cx0<=c06;cx1<=c16;cx2<=c26;cx3<=c36;
                            cx4<=c46;cx5<=c56;cx6<=c66;cx7<=c76; end
                3'd7: begin cx0<=c07;cx1<=c17;cx2<=c27;cx3<=c37;
                            cx4<=c47;cx5<=c57;cx6<=c67;cx7<=c77; end
            endcase
        end
    end

    // ── Load rx from transpose ────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx0<=0;rx1<=0;rx2<=0;rx3<=0;
            rx4<=0;rx5<=0;rx6<=0;rx7<=0;
        end
        else if (load_rx) begin
            case (load_rx_row)
                3'd0: begin rx0<=t00;rx1<=t01;rx2<=t02;rx3<=t03;
                            rx4<=t04;rx5<=t05;rx6<=t06;rx7<=t07; end
                3'd1: begin rx0<=t10;rx1<=t11;rx2<=t12;rx3<=t13;
                            rx4<=t14;rx5<=t15;rx6<=t16;rx7<=t17; end
                3'd2: begin rx0<=t20;rx1<=t21;rx2<=t22;rx3<=t23;
                            rx4<=t24;rx5<=t25;rx6<=t26;rx7<=t27; end
                3'd3: begin rx0<=t30;rx1<=t31;rx2<=t32;rx3<=t33;
                            rx4<=t34;rx5<=t35;rx6<=t36;rx7<=t37; end
                3'd4: begin rx0<=t40;rx1<=t41;rx2<=t42;rx3<=t43;
                            rx4<=t44;rx5<=t45;rx6<=t46;rx7<=t47; end
                3'd5: begin rx0<=t50;rx1<=t51;rx2<=t52;rx3<=t53;
                            rx4<=t54;rx5<=t55;rx6<=t56;rx7<=t57; end
                3'd6: begin rx0<=t60;rx1<=t61;rx2<=t62;rx3<=t63;
                            rx4<=t64;rx5<=t65;rx6<=t66;rx7<=t67; end
                3'd7: begin rx0<=t70;rx1<=t71;rx2<=t72;rx3<=t73;
                            rx4<=t74;rx5<=t75;rx6<=t76;rx7<=t77; end
            endcase
        end
    end

    // ── Capture col IDCT → transpose (as COLUMNS) ────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            trans_col_wr <= 3'd0;
        else if (idct_start)
            trans_col_wr <= 3'd0;
        else if (col_dct_valid) begin
            case (trans_col_wr)
                3'd0: begin t00<=cY0;t10<=cY1;t20<=cY2;t30<=cY3;
                            t40<=cY4;t50<=cY5;t60<=cY6;t70<=cY7; end
                3'd1: begin t01<=cY0;t11<=cY1;t21<=cY2;t31<=cY3;
                            t41<=cY4;t51<=cY5;t61<=cY6;t71<=cY7; end
                3'd2: begin t02<=cY0;t12<=cY1;t22<=cY2;t32<=cY3;
                            t42<=cY4;t52<=cY5;t62<=cY6;t72<=cY7; end
                3'd3: begin t03<=cY0;t13<=cY1;t23<=cY2;t33<=cY3;
                            t43<=cY4;t53<=cY5;t63<=cY6;t73<=cY7; end
                3'd4: begin t04<=cY0;t14<=cY1;t24<=cY2;t34<=cY3;
                            t44<=cY4;t54<=cY5;t64<=cY6;t74<=cY7; end
                3'd5: begin t05<=cY0;t15<=cY1;t25<=cY2;t35<=cY3;
                            t45<=cY4;t55<=cY5;t65<=cY6;t75<=cY7; end
                3'd6: begin t06<=cY0;t16<=cY1;t26<=cY2;t36<=cY3;
                            t46<=cY4;t56<=cY5;t66<=cY6;t76<=cY7; end
                3'd7: begin t07<=cY0;t17<=cY1;t27<=cY2;t37<=cY3;
                            t47<=cY4;t57<=cY5;t67<=cY6;t77<=cY7; end
            endcase
            trans_col_wr <= trans_col_wr + 1;
        end
    end

    // ── Capture row IDCT → idct_out ──────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            result_row_wr <= 3'd0;
            idct_out      <= 576'd0;
        end
        else if (idct_start)
            result_row_wr <= 3'd0;
        else if (row_dct_valid) begin
            idct_out[(result_row_wr*8+0)*9+:9] <= rY0 >>> 6;
            idct_out[(result_row_wr*8+1)*9+:9] <= rY1 >>> 6;
            idct_out[(result_row_wr*8+2)*9+:9] <= rY2 >>> 6;
            idct_out[(result_row_wr*8+3)*9+:9] <= rY3 >>> 6;
            idct_out[(result_row_wr*8+4)*9+:9] <= rY4 >>> 6;
            idct_out[(result_row_wr*8+5)*9+:9] <= rY5 >>> 6;
            idct_out[(result_row_wr*8+6)*9+:9] <= rY6 >>> 6;
            idct_out[(result_row_wr*8+7)*9+:9] <= rY7 >>> 6;
            result_row_wr <= result_row_wr + 1;
        end
    end

    // ── MAIN FSM ──────────────────────────────────────────
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state       <= S_IDLE;
            col_idx     <= 3'd0;
            row_idx     <= 3'd0;
            col_valid   <= 1'b0;
            row_valid   <= 1'b0;
            wait_cnt    <= 3'd0;
            idct_done   <= 1'b0;
            load_cx     <= 1'b0;
            load_cx_col <= 3'd0;
            load_rx     <= 1'b0;
            load_rx_row <= 3'd0;
        end
        else begin
            idct_done <= 1'b0;
            col_valid <= 1'b0;
            row_valid <= 1'b0;
            load_cx   <= 1'b0;
            load_rx   <= 1'b0;

            case (state)
                S_IDLE: begin
                    if (idct_start) begin
                        col_idx     <= 3'd0;
                        row_idx     <= 3'd0;
                        load_cx     <= 1'b1;
                        load_cx_col <= 3'd0;
                        state       <= S_COL_FEED;
                    end
                end

                S_COL_FEED: begin
                    col_valid <= 1'b1;
                    if (col_idx == 3'd7) begin
                        wait_cnt <= 3'd0;
                        state    <= S_COL_WAIT;
                    end
                    else begin
                        col_idx     <= col_idx + 1;
                        load_cx     <= 1'b1;
                        load_cx_col <= col_idx + 1;
                    end
                end

                S_COL_WAIT: begin
                    wait_cnt <= wait_cnt + 1;
                    if (wait_cnt == 3'd5) begin
                        row_idx     <= 3'd0;
                        load_rx     <= 1'b1;
                        load_rx_row <= 3'd0;
                        state       <= S_ROW_FEED;
                    end
                end

                S_ROW_FEED: begin
                    row_valid <= 1'b1;
                    if (row_idx == 3'd7) begin
                        wait_cnt <= 3'd0;
                        state    <= S_ROW_WAIT;
                    end
                    else begin
                        row_idx     <= row_idx + 1;
                        load_rx     <= 1'b1;
                        load_rx_row <= row_idx + 1;
                    end
                end

                S_ROW_WAIT: begin
                    wait_cnt <= wait_cnt + 1;
                    if (wait_cnt == 3'd5)
                        state <= S_DONE;
                end

                S_DONE: begin
                    idct_done <= 1'b1;
                    state     <= S_IDLE;
                end
            endcase
        end
    end

endmodule