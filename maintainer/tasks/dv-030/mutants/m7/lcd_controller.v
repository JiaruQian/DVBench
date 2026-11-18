
module lcd_controller(
    input wire CLOCK_50,           
    input wire reset_n,            
    input wire [2:0] lcd_state,    
    output reg LCD_RS,             
    output wire LCD_RW,         
    output reg LCD_EN,             
    output reg [7:0] LCD_DATA      
);
    localparam [2:0]
        LCD_IDLE      = 3'd0,
        LCD_UNLOCKED  = 3'd1,
        LCD_WRONG     = 3'd2,
        LCD_TIMEOUT   = 3'd3,
        LCD_CHANGE    = 3'd4,
		  LCD_BLOCKED     = 3'd5;    
    localparam [3:0]
        INIT             = 4'd0,  // 8 cycles 
        INIT_MAINTAIN    = 4'd1,
        HOME             = 4'd2,  
        HOME_MAINTAIN    = 4'd3,
        WRDATA1          = 4'd4,  // line 1
        WRDATA1_MAINTAIN = 4'd5,
        LINE2            = 4'd6,  
        LINE2_MAINTAIN   = 4'd7,
        WRDATA2          = 4'd8,  // line 2
        WRDATA2_MAINTAIN = 4'd9,
        DONE             = 4'd10;
    reg [3:0] state;           
    integer count;             
    integer clockticks;        
    reg clock;                 
    integer i;

    localparam integer max = 50000;
    localparam integer half = max / 2;
   
    always @(posedge CLOCK_50) begin
        if (clockticks < max)
            clockticks <= clockticks + 1;
        else
            clockticks <= 0;

        if (clockticks < half)
            clock <= 0;
        else
            clock <= 1;
    end
    
    // Định nghĩa WriteInstruction và WriteData macro
    `define WriteInstruction(ctr_en, ctr_rs, data, source) \
        data <= source; \
        ctr_en <= 1'b1; \
        ctr_rs <= 1'b0;

    `define WriteData(ctr_en, ctr_rs, data, source) \
        data <= source; \
        ctr_en <= 1'b1; \
        ctr_rs <= 1'b1;
    
    // Các mảng lưu trữ dữ liệu khởi tạo LCD
    reg [7:0] initcode [0:7];
    reg [7:0] line1 [0:15];
    reg [7:0] line2 [0:15];
    always @(*) begin
        initcode[0] = 8'h38; // step 1,2,3,4: 8bit data,2 lines, 5x8 character size(4 times)
        initcode[1] = 8'h38;    
        initcode[2] = 8'h38;   
        initcode[3] = 8'h38;   
        initcode[4] = 8'h08; // step 5: display off    
        initcode[5] = 8'h01; // step 6: clear display 
        initcode[6] = 8'h06; // entry mode: tăng địa chỉ, không dịch màn hình
        initcode[7] = 8'h0C; // display ON, cursor OFF, blink OFF
        for (i = 0; i < 16; i = i + 1) begin
         line1[i] = 8'h20;  
         line2[i] = 8'h20;
        end
        case (lcd_state)
            LCD_IDLE: begin
                line1[0] = 8'h45; // E
                line1[1] = 8'h4E; // N
                line1[2] = 8'h54; // T
                line1[3] = 8'h45; // E
                line1[4] = 8'h52; // R
                line1[5] = 8'h20;
                line1[6] = 8'h50; // P
                line1[7] = 8'h41; // A
                line1[8] = 8'h53; // S
                line1[9] = 8'h53; // S
                line1[10] = 8'h57; // W
                line1[11] = 8'h4F; // O
                line1[12] = 8'h52; // R
                line1[13] = 8'h44; // D
                line1[14] = 8'h20; 
                line1[15] = 8'h20; 
            end
            LCD_UNLOCKED: begin
                line1[0] = 8'h44; // D
                line1[1] = 8'h4F; // O
                line1[2] = 8'h4F; // O
                line1[3] = 8'h52; // R
                line1[4] = 8'h20; 
                line1[5] = 8'h55; // U
                line1[6] = 8'h4E; // N
                line1[7] = 8'h4C; // L
                line1[8] = 8'h4F; // O
                line1[9] = 8'h43; // C
                line1[10] = 8'h4B; // K
                line1[11] = 8'h45; // E
                line1[12] = 8'h44; // D
                line1[13] = 8'h20; 
                line1[14] = 8'h20; 
                line1[15] = 8'h20; 
                
                
                line2[0] = 8'h41; // A
                line2[1] = 8'h55; // U
                line2[2] = 8'h54; // T
                line2[3] = 8'h4F; // O
                line2[4] = 8'h20; 
                line2[5] = 8'h4C; // L
                line2[6] = 8'h6F; // o
                line2[7] = 8'h63; // c
                line2[8] = 8'h6B; // k
                line2[9] = 8'h20; 
                line2[10] = 8'h53; // S
                line2[11] = 8'h6F; // o
                line2[12] = 8'h6F; // o
                line2[13] = 8'h6E; // n
                line2[14] = 8'h2E; // .
                line2[15] = 8'h2E; // .
            end
            LCD_WRONG: begin
                line1[0] = 8'h57; // W
                line1[1] = 8'h52; // R
                line1[2] = 8'h4F; // O
                line1[3] = 8'h4E; // N
                line1[4] = 8'h47; // G
                line1[5] = 8'h20; 
                line1[6] = 8'h50; // P
                line1[7] = 8'h41; // A
                line1[8] = 8'h53; // S
                line1[9] = 8'h53; // S
                line1[10] = 8'h57; // W
                line1[11] = 8'h4F; // O
                line1[12] = 8'h52; // R
                line1[13] = 8'h44; // D
                line1[14] = 8'h21; // !
                line1[15] = 8'h20; 
                
                line2[0] = 8'h54; // T
                line2[1] = 8'h72; // r
                line2[2] = 8'h79; // y
                line2[3] = 8'h20; 
                line2[4] = 8'h41; // A
                line2[5] = 8'h67; // g
                line2[6] = 8'h61; // a
                line2[7] = 8'h69; // i
                line2[8] = 8'h6E; // n
                line2[9] = 8'h20; 
                line2[10] = 8'h20; 
                line2[11] = 8'h20;
                line2[12] = 8'h20; 
                line2[13] = 8'h20; 
                line2[14] = 8'h20; 
                line2[15] = 8'h20; 
            end
            
            LCD_TIMEOUT: begin
                line1[0] = 8'h54; // T
                line1[1] = 8'h49; // I
                line1[2] = 8'h4D; // M
                line1[3] = 8'h45; // E
                line1[4] = 8'h4F; // O
                line1[5] = 8'h55; // U
                line1[6] = 8'h54; // T
                line1[7] = 8'h20; 
                line1[8] = 8'h45; // E
                line1[9] = 8'h52; // R
                line1[10] = 8'h52; // R
                line1[11] = 8'h4F; // O
                line1[12] = 8'h52; // R
                line1[13] = 8'h20; 
                line1[14] = 8'h20;
                line1[15] = 8'h20; 
                
               
                line2[0] = 8'h53; // S
                line2[1] = 8'h74; // t
                line2[2] = 8'h61; // a
                line2[3] = 8'h72; // r
                line2[4] = 8'h74; // t
                line2[5] = 8'h20; 
                line2[6] = 8'h41; // A
                line2[7] = 8'h67; // g
                line2[8] = 8'h61; // a
                line2[9] = 8'h69; // i
                line2[10] = 8'h6E; // n
                line2[11] = 8'h20; 
                line2[12] = 8'h20; 
                line2[13] = 8'h20; 
                line2[14] = 8'h20; 
                line2[15] = 8'h20; 
            end
            
            LCD_CHANGE: begin
                
                line1[0] = 8'h43; // C
                line1[1] = 8'h48; // H
                line1[2] = 8'h41; // A
                line1[3] = 8'h4E; // N
                line1[4] = 8'h47; // G
                line1[5] = 8'h45; // E
                line1[6] = 8'h20; 
                line1[7] = 8'h50; // P
                line1[8] = 8'h41; // A
                line1[9] = 8'h53; // S
                line1[10] = 8'h53; // S
                line1[11] = 8'h57; // W
                line1[12] = 8'h4F; // O
                line1[13] = 8'h52; // R
                line1[14] = 8'h44; // D
                line1[15] = 8'h20; 
                
                line2[0] = 8'h45; // E
                line2[1] = 8'h6E; // n
                line2[2] = 8'h74; // t
                line2[3] = 8'h65; // e
                line2[4] = 8'h72; // r
                line2[5] = 8'h20; 
                line2[6] = 8'h4E; // N
                line2[7] = 8'h65; // e
                line2[8] = 8'h77; // w
                line2[9] = 8'h20; 
                line2[10] = 8'h43; // C
                line2[11] = 8'h6F; // o
                line2[12] = 8'h64; // d
                line2[13] = 8'h65; // e
                line2[14] = 8'h20;  
                line2[15] = 8'h20; 
            end
            LCD_BLOCKED: begin
                line1[0] = 8'h20;  
                line1[1] = 8'h20;  
                line1[2] = 8'h20;  
                line1[3] = 8'h20; 
                line1[4] = 8'h42; // B
                line1[5] = 8'h4C; // L
                line1[6] = 8'h4F; // O
                line1[7] = 8'h43; // C
                line1[8] = 8'h4B; // K
                line1[9] = 8'h45; // E
                line1[10] = 8'h44; //D
                line1[11] = 8'h20; 
                line1[12] = 8'h20; 
                line1[13] = 8'h20; 
                line1[14] = 8'h20; 
                line1[15] = 8'h20; 
					 
					 line2[0] = 8'h20; 
                line2[1] = 8'h20; 
                line2[2] = 8'h20; 
                line2[3] = 8'h20; 
                line2[4] = 8'h20; 
                line2[5] = 8'h20; 
                line2[6] = 8'h20; 
                line2[7] = 8'h20; 
                line2[8] = 8'h20; 
                line2[9] = 8'h20; 
                line2[10] = 8'h20; 
                line2[11] = 8'h20; 
                line2[12] = 8'h20; 
                line2[13] = 8'h20; 
                line2[14] = 8'h20; 
                line2[15] = 8'h20; 

				end
            default: begin
                
                line1[0] = 8'h45; // E
                line1[1] = 8'h4E; // N
                line1[2] = 8'h54; // T
                line1[3] = 8'h45; // E
                line1[4] = 8'h52; // R
                line1[5] = 8'h20; 
                line1[6] = 8'h50; // P
                line1[7] = 8'h41; // A
                line1[8] = 8'h53; // S
                line1[9] = 8'h53; // S
                line1[10] = 8'h57; // W
                line1[11] = 8'h4F; // O
                line1[12] = 8'h52; // R
                line1[13] = 8'h44; // D
                line1[14] = 8'h20; 
                line1[15] = 8'h20; 
					 
					 line2[0] = 8'h20; 
                line2[1] = 8'h20; 
                line2[2] = 8'h20; 
                line2[3] = 8'h20; 
                line2[4] = 8'h20; 
                line2[5] = 8'h20; 
                line2[6] = 8'h20; 
                line2[7] = 8'h20; 
                line2[8] = 8'h20; 
                line2[9] = 8'h20; 
                line2[10] = 8'h20; 
                line2[11] = 8'h20; 
                line2[12] = 8'h20; 
                line2[13] = 8'h20; 
                line2[14] = 8'h20; 
                line2[15] = 8'h20; 
            end
        endcase
    end
    // chi ghi 
    assign LCD_RW = 1'b0;
    // Controller state machine
    always @(posedge clock or negedge reset_n) begin
        if (!reset_n) begin
            count <= 0;
            state <= INIT;
            LCD_EN <= 0;LCD_RS <= 0;LCD_DATA <= 8'h38;
        end else begin
            case (state)
                INIT: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, initcode[count]);
                    state <= INIT_MAINTAIN;
                end
                INIT_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count <= count + 1;
                    state <= (count < 7) ? INIT : HOME;
                end
                HOME: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'h80); // Address 0x00 - start of line 1
                    state <= HOME_MAINTAIN;
                end
                HOME_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count <= 0;
                    state <= WRDATA1;
                end
                WRDATA1: begin
                    `WriteData(LCD_EN, LCD_RS, LCD_DATA, line1[count]);
                    state <= WRDATA1_MAINTAIN;
                end
                WRDATA1_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count <= count + 1;
                    state <= (count < 15) ? WRDATA1 : LINE2;
                end
                LINE2: begin
                    `WriteInstruction(LCD_EN, LCD_RS, LCD_DATA, 8'hC0); // Address 0x40 - start of line 2 bit thu 8 luon =1
                    state <= LINE2_MAINTAIN;
                end
                LINE2_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count <= 0;
                    state <= WRDATA2;
                end
                WRDATA2: begin
                    `WriteData(LCD_EN, LCD_RS, LCD_DATA, line2[count]);
                    state <= WRDATA2_MAINTAIN;
                end
                WRDATA2_MAINTAIN: begin
                    LCD_EN <= 1'b0;
                    count <= count + 1;
                    state <= (count < 15) ? WRDATA2 : HOME; // quay lai home 
                end
                default: begin
                    state <= INIT;
                    count <= 0;
                end
            endcase
        end
    end

endmodule