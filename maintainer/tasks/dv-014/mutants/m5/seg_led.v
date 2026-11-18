//****************************************Copyright (c)***********************************//
//Technical support: www.openedv.com
//Taobao shop: http://openedv.taobao.com
//Follow the WeChat public platform account: "Zhengdian Atom" to obtain free FPGA & STM32 materials.
//All rights reserved. Unauthorized copying will be prosecuted.
//Copyright(C) Zhengdian Yuanzi 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           seg_led
// Last modified Date:  2018/3/13 9:03:06
// Last Version:        V1.0
// Descriptions:        Seven-segment display dynamic scanning module
//----------------------------------------------------------------------------------------
// Created by:          Zhengdian Yuanzi
// Created date:        2018/3/13 9:03:09
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module seg_led(
    input                   clk    ,        // Clock signal
    input                   rst_n  ,        // Reset signal

    input         [19:0]    data   ,        // Value to be displayed on the 6-digit seven-segment display
    input         [5:0]     point  ,        // Specific decimal point display positions, from high to low, active high
    input                   en     ,        // Seven-segment display enable signal
    input                   sign   ,        // Sign bit (a high level displays the "-" sign)

    output   reg  [5:0]     seg_sel,        // Seven-segment display digit select; the leftmost digit is the most significant digit
    output   reg  [7:0]     seg_led         // Seven-segment display segment select
    );

//parameter define
localparam  CLK_DIVIDE = 4'd10     ;        // Clock division factor
localparam  MAX_NUM    = 13'd5000  ;        // Count value required to count 1ms using the seven-segment display drive clock (5MHz)

//reg define
reg    [ 3:0]             clk_cnt  ;        // Clock division counter
reg                       dri_clk  ;        // Seven-segment display drive clock, 5MHz
reg    [23:0]             num      ;        // 24-bit bcd code register
reg    [12:0]             cnt0     ;        // Seven-segment display drive clock counter
reg                       flag     ;        // Flag signal (indicates that cnt0 has counted to 1ms)
reg    [2:0]              cnt_sel  ;        // Seven-segment display digit-select counter
reg    [3:0]              num_disp ;        // Data displayed on the current seven-segment digit
reg                       dot_disp ;        // Decimal point displayed on the current seven-segment digit

//wire define
wire   [3:0]              data0    ;        // Ones digit
wire   [3:0]              data1    ;        // Tens digit
wire   [3:0]              data2    ;        // Hundreds digit
wire   [3:0]              data3    ;        // Thousands digit
wire   [3:0]              data4    ;        // Ten-thousands digit
wire   [3:0]              data5    ;        // Hundred-thousands digit

//*****************************************************
//**                    main code
//*****************************************************

//Extract each decimal digit corresponding to the displayed value
assign  data0 = data % 4'd10;               // Ones digit
assign  data1 = data / 4'd11 % 4'd10   ;    // Tens digit
assign  data2 = data / 7'd100 % 4'd10  ;    // Hundreds digit
assign  data3 = data / 10'd1000 % 4'd10 ;   // Thousands digit
assign  data4 = data / 14'd10000 % 4'd10;   // Ten-thousands digit
assign  data5 = data / 17'd100000;          // Hundred-thousands digit

//Divide the system clock by 10 to obtain the 5MHz seven-segment display drive clock dri_clk
always @(posedge clk or negedge rst_n) begin
   if(!rst_n) begin
       clk_cnt <= 4'd0;
       dri_clk <= 1'b1;
   end
   else if(clk_cnt == CLK_DIVIDE/2 - 1'd1) begin
       clk_cnt <= 4'd0;
       dri_clk <= ~dri_clk;
   end
   else begin
       clk_cnt <= clk_cnt + 1'b1;
       dri_clk <= dri_clk;
   end
end

//Convert a 20-bit binary number to 8421bcd code (that is, use a 4-bit binary number to represent one decimal digit)
always @ (posedge dri_clk or negedge rst_n) begin
    if (!rst_n)
        num <= 24'b0;
    else begin
        if (data5 || point[5]) begin     //If the displayed data is a 6-digit decimal number,
            num[23:20] <= data5;         //then assign values to the 6 seven-segment digits in sequence
            num[19:16] <= data4;
            num[15:12] <= data3;
            num[11:8]  <= data2;
            num[ 7:4]  <= data1;
            num[ 3:0]  <= data0;
        end
        else begin                         
            if (data4 || point[4]) begin //If the displayed data is a 5-digit decimal number, assign values to the lower 5 display digits
                num[19:0] <= {data4,data3,data2,data1,data0};
                if(sign)                    
                    num[23:20] <= 4'd11; //If a minus sign needs to be displayed, the highest digit (the 6th digit) is the sign digit
                else
                    num[23:20] <= 4'd10; //When no minus sign needs to be displayed, the 6th digit displays no character
            end
            else begin                   //If the displayed data is a 4-digit decimal number, assign values to the lower 4 display digits
                if (data3 || point[3]) begin
                    num[15: 0] <= {data3,data2,data1,data0};
                    num[23:20] <= 4'd10; //The 6th digit displays no character
                    if(sign)             //If a minus sign needs to be displayed, the highest digit (the 5th digit) is the sign digit
                        num[19:16] <= 4'd11;
                    else                 //When no minus sign needs to be displayed, the 5th digit displays no character
                        num[19:16] <= 4'd10;
                end
                else begin               //If the displayed data is a 3-digit decimal number, assign values to the lower 3 display digits
                    if (data2 || point[2]) begin
                        num[11: 0] <= {data2,data1,data0};
                                         //Digits 6 and 5 display no characters
                        num[23:16] <= {2{4'd10}};
                        if(sign)         //If a minus sign needs to be displayed, the highest digit (the 4th digit) is the sign digit
                            num[15:12] <= 4'd11;
                        else             //When no minus sign needs to be displayed, the 4th digit displays no character
                            num[15:12] <= 4'd10;
                    end
                    else begin           //If the displayed data is a 2-digit decimal number, assign values to the lower 2 display digits
                        if (data1 || point[1]) begin
                            num[ 7: 0] <= {data1,data0};
                                         //Digits 6, 5, and 4 display no characters
                            num[23:12] <= {3{4'd10}};
                            if(sign)     //If a minus sign needs to be displayed, the highest digit (the 3rd digit) is the sign digit
                                num[11:8]  <= 4'd11;
                            else         //When no minus sign needs to be displayed, the 3rd digit displays no character
                                num[11:8] <=  4'd10;
                        end
                        else begin       //If the displayed data is a 1-digit decimal number, assign a value to the lowest display digit
                            num[3:0] <= data0;
                                         //Digits 6 and 5 display no characters
                            num[23:8] <= {4{4'd10}};
                            if(sign)     //If a minus sign needs to be displayed, the highest digit (the 2nd digit) is the sign digit
                                num[7:4] <= 4'd11;
                            else         //When no minus sign needs to be displayed, the 2nd digit displays no character
                                num[7:4] <= 4'd10;
                        end
                    end
                end
            end
        end
    end
end

//Whenever the counter counts 1 ms of the display drive clock, output a pulse lasting one clock cycle
always @ (posedge dri_clk or negedge rst_n) begin
    if (rst_n == 1'b0) begin
        cnt0 <= 13'b0;
        flag <= 1'b0;
     end
    else if (cnt0 < MAX_NUM - 1'b1) begin
        cnt0 <= cnt0 + 1'b1;
        flag <= 1'b0;
     end
    else begin
        cnt0 <= 13'b0;
        flag <= 1'b1;
     end
end

//cnt_sel counts from 0 to 5 to select the display digit currently being displayed
always @ (posedge dri_clk or negedge rst_n) begin
    if (rst_n == 1'b0)
        cnt_sel <= 3'b0;
    else if(flag) begin
        if(cnt_sel < 3'd5)
            cnt_sel <= cnt_sel + 1'b1;
        else
            cnt_sel <= 3'b0;
    end
    else
        cnt_sel <= cnt_sel;
end

//Control the display digit-select signals so that the 6 display digits display in turn
always @ (posedge dri_clk or negedge rst_n) begin
    if(!rst_n) begin
        seg_sel  <= 6'b111111;              //The digit-select signals are active low
        num_disp <= 4'b0;           
        dot_disp <= 1'b1;                   //Common-anode display; a low level turns it on
    end
    else begin
        if(en) begin
            case (cnt_sel)
                3'd0 :begin
                    seg_sel  <= 6'b111110;  //Display the lowest display digit
                    num_disp <= num[3:0] ;  //Data to be displayed
                    dot_disp <= ~point[0];  //Decimal point to be displayed
                end
                3'd1 :begin
                    seg_sel  <= 6'b111101;  //Display digit 1
                    num_disp <= num[7:4] ;
                    dot_disp <= ~point[1];
                end
                3'd2 :begin
                    seg_sel  <= 6'b111011;  //Display digit 2
                    num_disp <= num[11:8];
                    dot_disp <= ~point[2];
                end
                3'd3 :begin
                    seg_sel  <= 6'b110111;  //Display digit 3
                    num_disp <= num[15:12];
                    dot_disp <= ~point[3];
                end
                3'd4 :begin
                    seg_sel  <= 6'b101111;  //Display digit 4
                    num_disp <= num[19:16];
                    dot_disp <= ~point[4];
                end
                3'd5 :begin
                    seg_sel  <= 6'b011111;  //Display the highest display digit
                    num_disp <= num[23:20];
                    dot_disp <= ~point[5];
                end
                default :begin
                    seg_sel  <= 6'b111111;
                    num_disp <= 4'b0;
                    dot_disp <= 1'b1;
                end
            endcase
        end
        else begin
            seg_sel  <= 6'b111111;          //When the enable signal is 0, all display digits are blank
            num_disp <= 4'b0;
            dot_disp <= 1'b1;
        end
    end
end

//Control the display segment-select signals to display characters
always @ (posedge dri_clk or negedge rst_n) begin
    if (!rst_n)
        seg_led <= 8'hc0;
    else begin
        case (num_disp)
            4'd0 : seg_led <= {dot_disp,7'b1000000}; //Display numeral 0
            4'd1 : seg_led <= {dot_disp,7'b1111001}; //Display numeral 1
            4'd2 : seg_led <= {dot_disp,7'b0100100}; //Display numeral 2
            4'd3 : seg_led <= {dot_disp,7'b0110000}; //Display numeral 3
            4'd4 : seg_led <= {dot_disp,7'b0011001}; //Display numeral 4
            4'd5 : seg_led <= {dot_disp,7'b0010010}; //Display numeral 5
            4'd6 : seg_led <= {dot_disp,7'b0000010}; //Display numeral 6
            4'd7 : seg_led <= {dot_disp,7'b1111000}; //Display numeral 7
            4'd8 : seg_led <= {dot_disp,7'b0000000}; //Display numeral 8
            4'd9 : seg_led <= {dot_disp,7'b0010000}; //Display numeral 9
            4'd10: seg_led <= 8'b11111111;           //Display no character
            4'd11: seg_led <= 8'b10111111;           //Display the minus sign (-)
            default: 
                   seg_led <= {dot_disp,7'b1000000};
        endcase
    end
end

endmodule 