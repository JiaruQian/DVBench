//****************************************Copyright (c)***********************************//
//Technical support: www.openedv.com
//Taobao shop: http://openedv.taobao.com
//Follow the WeChat public platform account: "Zhengdian Atom" to obtain free FPGA & STM32 materials.
//All rights reserved. Unauthorized copying will be prosecuted.
//Copyright(C) Zhengdian Yuanzi 2018-2028
//All rights reserved
//----------------------------------------------------------------------------------------
// File name:           led_disp
// Last modified Date:  2018/05/10 16:48:59
// Last Version:        V1.0
// Descriptions:        The data magnitude determines the number of illuminated leds
//----------------------------------------------------------------------------------------
// Created by:          Zhengdian Yuanzi
// Created date:        2018/05/10 16:49:07
// Version:             V1.0
// Descriptions:        The original version
//
//----------------------------------------------------------------------------------------
//****************************************************************************************//

module led_disp(
    //system clock
    input                          clk  ,     // Clock signal
    input                          rst_n,     // Reset signal

    //led interface
    output   reg   [3:0]           led  ,     // led interface

    //user interface
    input          [9:0]           data       // Data
);

//*****************************************************
//**                    main code
//*****************************************************

//The number of leds on and off indicates the data magnitude
always @(posedge clk or negedge rst_n) begin
    if(rst_n == 1'b0) begin
        led <=  4'd0;
    end
    else if(data < 10'd15)
        led <= 4'b0001;
    else if(data < 10'd128)
        led <= 4'b0011;
    else if(data < 10'd512)
        led <= 4'b0111;
    else
        led <= 4'b1111;
end

endmodule