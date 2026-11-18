module Digital_lock_top(
    input CLOCK_50Mhz,            
    input KEY_0,                  
    input [3:0] keypad_input,     
    input key_valid,
    output lock,                  
    output lock_c,                
    output [6:0] HEX0,            
    output LCD_ON,               
    output LCD_BLON,             
    output LCD_RS,                
    output LCD_RW,                
    output LCD_EN,	             
    output [7:0] LCD_DATA         
);
    // Tín hiệu kết nối giữa các module
    wire [2:0] lcd_state;
    wire [3:0] seg_digit;
    wire lock_status;
    wire lock_check;              // Tín hiệu từ FSM
    wire clk_fsm;
     
    // Bật LCD và đèn nền
    assign LCD_ON = 1'b1;
    assign LCD_BLON = 1'b1;
    
    // Reset tích cực mức thấp
    wire reset_n = KEY_0;
    
    // Kết nối tín hiệu ra ngoài
    assign lock = lock_status;
    assign lock_c = lock_check;   
    // Quản lý các xung clock
    clock_manager clk_manager(
        .CLOCK_50Mhz(CLOCK_50Mhz),
        .clk_fsm(clk_fsm)
    );
    // Module FSM chính
    digital_lock_fsm fsm(
        .clk(clk_fsm),
        .reset_n(reset_n),
        .keypad_input(keypad_input),
        .key_valid(key_valid),
        .lock(lock_status),
        .lock_check(lock_check),  // Kết nối đúng tên port
        .lcd_state(lcd_state),
        .seg_digit(seg_digit)
    );
    // Điều khiển 7-segment
    seg7_display seg7_ctrl(
        .reset_n(reset_n),
        .digit(seg_digit),
        .segment(HEX0)
    );
    // Điều khiển LCD
    lcd_controller lcd(
        .CLOCK_50(CLOCK_50Mhz),   
        .reset_n(reset_n),
        .lcd_state(lcd_state),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_EN(LCD_EN),
        .LCD_DATA(LCD_DATA)
    );
endmodule