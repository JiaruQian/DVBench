`timescale 1ns / 1ps
// Module:      video_filter_top.v
// Description: Top-level video filter module. Routes live pixel stream through
//              seven parallel filter modules. Multiplexer selects active filter
//              via sw[2:0]. Includes split-screen, LED blink control, and
//              text overlay instantiation.
// Author:      5529114
// Date:        April 2026

module video_filter_top #
(
    parameter DATA_WIDTH  = 24,
    parameter IMAGE_WIDTH = 1920,
    parameter IMAGE_HEIGHT = 1080,
    parameter BLINK_RATE  = 26'd62_500_000,
    parameter DEBOUNCE_LIMIT = 22'd2_500_000
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    /*
     * Switch inputs
     * sw[2]   = 0: single-pixel filters
     *           1: multi-pixel filters
     * sw[1:0] = filter select within category
     * sw[3]   = reserved for future use
     */
    input  wire [3:0]            sw,
    /*
     * Button inputs (context sensitive per filter)
     * sw[2]=0, sw[1:0]=11 (threshold):
     *   btn[0] = increase threshold
     *   btn[1] = decrease threshold
     * sw[2]=1, sw[1:0]=00 (gaussian):
     *   btn[0] = cycle blur mode
     * sw[2]=1, sw[1:0]=10 (sobel):
     *   btn[0] = cycle edge mode
     */
    input  wire [3:0]            btn,
    /*
     * LED outputs
     * One-hot encoding shows active filter within category
     * LEDs blink to indicate active filter
     */
    output reg  [3:0]            led,
    /*
     * Pixel inputs
     */
    input  wire [DATA_WIDTH-1:0] i_vid_data,
    input  wire                  i_vid_hsync,
    input  wire                  i_vid_vsync,
    input  wire                  i_vid_VDE,
    /*
     * Pixel output
     */
    output reg  [DATA_WIDTH-1:0] o_vid_data,
    output reg                   o_vid_hsync,
    output reg                   o_vid_vsync,
    output reg                   o_vid_VDE
);

    // -------------------------------------------------------------------------
    // Context sensitive button routing
    // Buttons are only active for their respective filter
    // -------------------------------------------------------------------------
    wire btn_threshold_up;
    wire btn_threshold_down;
    wire btn_gaussian_mode;
    wire btn_sobel_mode;

    assign btn_threshold_up   = (sw[2:0] == 3'b011) ? btn[0] : 1'b0;
    assign btn_threshold_down = (sw[2:0] == 3'b011) ? btn[1] : 1'b0;
    assign btn_gaussian_mode  = (sw[2:0] == 3'b100) ? btn[0] : 1'b0;
    assign btn_sobel_mode     = (sw[2:0] == 3'b110) ? btn[0] : 1'b0;
    
    // -------------------------------------------------------------------------
    // LED blink counter
    // BLINK_RATE is parameterised so testbench can use small value
    // At 125MHz: 62,500,000 cycles = 2Hz blink rate
    // -------------------------------------------------------------------------
    reg [25:0] blink_cnt;
    reg        blink_en;

    always @(posedge clk) begin
        if (!n_rst) begin
            blink_cnt <= 0;
            blink_en  <= 0;
        end
        else begin
            if (blink_cnt >= BLINK_RATE) begin
                blink_cnt <= 0;
                blink_en  <= ~blink_en;
            end
            else begin
                blink_cnt <= blink_cnt + 1;
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Pixel x and y position counters
    // Used for split screen and text overlay
    // x resets at end of each active line
    // y increments at end of each active line, resets at vsync
    // -------------------------------------------------------------------------
    reg [10:0] x_cnt;

    always @ (posedge clk) begin
        if(!n_rst) begin
            x_cnt <= 0;
        end
        else begin
            if(i_vid_VDE) begin
                if(x_cnt == IMAGE_WIDTH - 1)
                    x_cnt <= 0;
                else
                    x_cnt <= x_cnt + 1;
            end
            else begin
                x_cnt <= 0;
            end
        end
    end
    
    // -------------------------------------------------------------------------
    // Split screen logic
    // SW3 = 1: left half shows original, right half shows filtered
    // White dividing line at centre
    // -------------------------------------------------------------------------
    wire split_active;
    assign split_active = sw[3] && (x_cnt >= IMAGE_WIDTH / 2);

    wire divider_active;
    assign divider_active = sw[3] &&
                           (x_cnt >= IMAGE_WIDTH/2 - 1) &&
                           (x_cnt <= IMAGE_WIDTH/2 + 1);

    // -------------------------------------------------------------------------
    // Single pixel filter outputs
    // -------------------------------------------------------------------------
    wire [DATA_WIDTH-1:0] greyscale_data;
    wire                  greyscale_hsync, greyscale_vsync, greyscale_VDE;

    wire [DATA_WIDTH-1:0] negative_data;
    wire                  negative_hsync, negative_vsync, negative_VDE;

    wire [DATA_WIDTH-1:0] threshold_data;
    wire                  threshold_hsync, threshold_vsync, threshold_VDE;

    // -------------------------------------------------------------------------
    // Multi pixel filter outputs
    // -------------------------------------------------------------------------
    wire [DATA_WIDTH-1:0] gaussian_data;
    wire                  gaussian_hsync, gaussian_vsync, gaussian_VDE;

    wire [DATA_WIDTH-1:0] sharpen_data;
    wire                  sharpen_hsync, sharpen_vsync, sharpen_VDE;

    wire [DATA_WIDTH-1:0] sobel_data;
    wire                  sobel_hsync, sobel_vsync, sobel_VDE;

    wire [DATA_WIDTH-1:0] emboss_data;
    wire                  emboss_hsync, emboss_vsync, emboss_VDE;

    // -------------------------------------------------------------------------
    // Single pixel filter instantiations
    // All filters run in parallel - mux selects output
    // -------------------------------------------------------------------------
    greyscale #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_greyscale (
        .clk        (clk),
        .n_rst      (n_rst),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (greyscale_data),
        .o_vid_hsync(greyscale_hsync),
        .o_vid_vsync(greyscale_vsync),
        .o_vid_VDE  (greyscale_VDE)
    );

    negative #(
        .DATA_WIDTH(DATA_WIDTH)
    ) u_negative (
        .clk        (clk),
        .n_rst      (n_rst),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (negative_data),
        .o_vid_hsync(negative_hsync),
        .o_vid_vsync(negative_vsync),
        .o_vid_VDE  (negative_VDE)
    );

    threshold #(
        .DATA_WIDTH    (DATA_WIDTH),
        .DEBOUNCE_LIMIT(22'd2_500_000)
    ) u_threshold (
        .clk        (clk),
        .n_rst      (n_rst),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .btn_up     (btn_threshold_up),
        .btn_down   (btn_threshold_down),
        .o_vid_data (threshold_data),
        .o_vid_hsync(threshold_hsync),
        .o_vid_vsync(threshold_vsync),
        .o_vid_VDE  (threshold_VDE)
    );

    // -------------------------------------------------------------------------
    // Multi pixel filter instantiations
    // -------------------------------------------------------------------------
    gaussian_blur #(
        .DATA_WIDTH    (DATA_WIDTH),
        .IMAGE_WIDTH   (IMAGE_WIDTH),
        .DEBOUNCE_LIMIT(22'd2_500_000)
    ) u_gaussian (
        .clk        (clk),
        .n_rst      (n_rst),
        .btn_mode   (btn_gaussian_mode),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (gaussian_data),
        .o_vid_hsync(gaussian_hsync),
        .o_vid_vsync(gaussian_vsync),
        .o_vid_VDE  (gaussian_VDE),
        .o_blur_mode()
    );

    sharpen #(
        .DATA_WIDTH (DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH)
    ) u_sharpen (
        .clk        (clk),
        .n_rst      (n_rst),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (sharpen_data),
        .o_vid_hsync(sharpen_hsync),
        .o_vid_vsync(sharpen_vsync),
        .o_vid_VDE  (sharpen_VDE)
    );

    sobel #(
        .DATA_WIDTH    (DATA_WIDTH),
        .IMAGE_WIDTH   (IMAGE_WIDTH),
        .DEBOUNCE_LIMIT(22'd2_500_000)
    ) u_sobel (
        .clk        (clk),
        .n_rst      (n_rst),
        .btn_mode   (btn_sobel_mode),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (sobel_data),
        .o_vid_hsync(sobel_hsync),
        .o_vid_vsync(sobel_vsync),
        .o_vid_VDE  (sobel_VDE)
    );

    emboss #(
        .DATA_WIDTH (DATA_WIDTH),
        .IMAGE_WIDTH(IMAGE_WIDTH)
    ) u_emboss (
        .clk        (clk),
        .n_rst      (n_rst),
        .i_vid_data (i_vid_data),
        .i_vid_hsync(i_vid_hsync),
        .i_vid_vsync(i_vid_vsync),
        .i_vid_VDE  (i_vid_VDE),
        .o_vid_data (emboss_data),
        .o_vid_hsync(emboss_hsync),
        .o_vid_vsync(emboss_vsync),
        .o_vid_VDE  (emboss_VDE)
    );

    // -------------------------------------------------------------------------
    // Filter selection mux
    // Combinational - selects active filter output
    // -------------------------------------------------------------------------
    reg [DATA_WIDTH-1:0] selected_data;
    reg                  selected_hsync, selected_vsync, selected_VDE;

    always @ (*) begin
        case(sw[3])
            1'b0: begin
                case(sw[1:0])
                    2'b00: begin
                        selected_data  = i_vid_data;
                        selected_hsync = i_vid_hsync;
                        selected_vsync = i_vid_vsync;
                        selected_VDE   = i_vid_VDE;
                    end
                    2'b01: begin
                        selected_data  = greyscale_data;
                        selected_hsync = greyscale_hsync;
                        selected_vsync = greyscale_vsync;
                        selected_VDE   = greyscale_VDE;
                    end
                    2'b10: begin
                        selected_data  = negative_data;
                        selected_hsync = negative_hsync;
                        selected_vsync = negative_vsync;
                        selected_VDE   = negative_VDE;
                    end
                    2'b11: begin
                        selected_data  = threshold_data;
                        selected_hsync = threshold_hsync;
                        selected_vsync = threshold_vsync;
                        selected_VDE   = threshold_VDE;
                    end
                    default: begin
                        selected_data  = i_vid_data;
                        selected_hsync = i_vid_hsync;
                        selected_vsync = i_vid_vsync;
                        selected_VDE   = i_vid_VDE;
                    end
                endcase
            end
            1'b1: begin
                case(sw[1:0])
                    2'b00: begin
                        selected_data  = gaussian_data;
                        selected_hsync = gaussian_hsync;
                        selected_vsync = gaussian_vsync;
                        selected_VDE   = gaussian_VDE;
                    end
                    2'b01: begin
                        selected_data  = sharpen_data;
                        selected_hsync = sharpen_hsync;
                        selected_vsync = sharpen_vsync;
                        selected_VDE   = sharpen_VDE;
                    end
                    2'b10: begin
                        selected_data  = sobel_data;
                        selected_hsync = sobel_hsync;
                        selected_vsync = sobel_vsync;
                        selected_VDE   = sobel_VDE;
                    end
                    2'b11: begin
                        selected_data  = emboss_data;
                        selected_hsync = emboss_hsync;
                        selected_vsync = emboss_vsync;
                        selected_VDE   = emboss_VDE;
                    end
                    default: begin
                        selected_data  = i_vid_data;
                        selected_hsync = i_vid_hsync;
                        selected_vsync = i_vid_vsync;
                        selected_VDE   = i_vid_VDE;
                    end
                endcase
            end
            default: begin
                selected_data  = i_vid_data;
                selected_hsync = i_vid_hsync;
                selected_vsync = i_vid_vsync;
                selected_VDE   = i_vid_VDE;
            end
        endcase
    end
    
    // -------------------------------------------------------------------------
    // Text overlay instantiation
    // Shows active filter name in top left corner
    // -------------------------------------------------------------------------
    wire [DATA_WIDTH-1:0] text_overlay_data;

    text_overlay #(
        .DATA_WIDTH  (DATA_WIDTH),
        .IMAGE_WIDTH (IMAGE_WIDTH),
        .IMAGE_HEIGHT(IMAGE_HEIGHT)
    ) u_text_overlay (
        .clk       (clk),
        .n_rst     (n_rst),
        .filter_sel(sw[2:0]),
        .i_vid_hsync(i_vid_hsync),   // add this
        .i_vid_vsync(i_vid_vsync),   // add this
        .i_vid_VDE  (i_vid_VDE),     // add this
        .i_vid_data (selected_data),
        .o_vid_data (text_overlay_data)
    );

    // -------------------------------------------------------------------------
    // Final output with split screen, freeze frame and LED control
    // -------------------------------------------------------------------------
    always @ (posedge clk) begin
        if(!n_rst) begin
            o_vid_data  <= 0;
            o_vid_hsync <= 0;
            o_vid_vsync <= 0;
            o_vid_VDE   <= 0;
            led         <= 4'b0000;
        end
        else begin
            o_vid_hsync <= selected_hsync;
            o_vid_vsync <= selected_vsync;
            o_vid_VDE   <= selected_VDE;
            
            if(divider_active)
                o_vid_data <= 24'hFFFFFF;        // white dividing line
            else if(sw[3] && split_active) 
                o_vid_data <= text_overlay_data;     // right half - filtered
            else if(sw[3])
                o_vid_data <= i_vid_data;        // left half - original
            else 
                o_vid_data <= text_overlay_data;     // normal - filtered

            // LED blink control
            case(sw[2])
                1'b0: begin
                    case(sw[1:0])
                        2'b00: led <= blink_en ? 4'b0001 : 4'b0000;
                        2'b01: led <= blink_en ? 4'b0010 : 4'b0000;
                        2'b10: led <= blink_en ? 4'b0100 : 4'b0000;
                        2'b11: led <= blink_en ? 4'b1000 : 4'b0000;
                        default: led <= 4'b0000;
                    endcase
                end
                1'b1: begin
                    case(sw[1:0])
                        2'b00: led <= blink_en ? 4'b0001 : 4'b0000;
                        2'b01: led <= blink_en ? 4'b0010 : 4'b0000;
                        2'b10: led <= blink_en ? 4'b0100 : 4'b0000;
                        2'b11: led <= blink_en ? 4'b1000 : 4'b0000;
                        default: led <= 4'b0000;
                    endcase
                end
                default: led <= 4'b0000;
            endcase
        end
    end

endmodule
