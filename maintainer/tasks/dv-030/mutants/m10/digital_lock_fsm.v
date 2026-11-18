module digital_lock_fsm (
    input wire clk,
    input wire reset_n,
    input wire [3:0] keypad_input,
    input wire key_valid,
    output reg lock,
    output reg lock_check,       
    output reg [2:0] lcd_state,     
    output reg [3:0] seg_digit
);
    // Trạng thái FSM
    localparam [3:0]
        S_IDLE        = 4'd0,
        S_1           = 4'd1,
        S_2           = 4'd2,
        S_3           = 4'd3,
        S_UNLOCK      = 4'd4,
        S_WAIT_CHANGE = 4'd5,
        S_VERIFY_0    = 4'd6,
        S_VERIFY_1    = 4'd7,
        S_VERIFY_2    = 4'd8,
        S_VERIFY_3    = 4'd9,
        S_NEW_0       = 4'd10,
        S_NEW_1       = 4'd11,
        S_NEW_2       = 4'd12,
        S_NEW_3       = 4'd13,
        S_BLOCKED     = 4'd14,
        S_WRONG       = 4'd15;
    
    // Trạng thái LCD
    localparam [2:0]
        LCD_IDLE      = 3'd0,
        LCD_UNLOCKED  = 3'd1,
        LCD_WRONG     = 3'd2,
        LCD_TIMEOUT   = 3'd3,
        LCD_CHANGE    = 3'd4,
        LCD_BLOCKED   = 3'd5;
          
    reg [3:0] current_state;
    reg [2:0] idle_counter;
    reg [8:0] unlock_counter;
    reg [1:0] input_index;
    reg [7:0] block_counter; 
    reg show_wrong;
    reg [2:0] wrong_counter;

    // Mật khẩu hiện tại
    reg [3:0] password [3:0];
    reg [3:0] input_buffer [3:0];
    reg [3:0] new_password [3:0];

    wire idle_timeout   = (idle_counter >= 3'd4);
    wire unlock_timeout = (unlock_counter >= 9'd10); 
    localparam block_timeout = 8'd100; 

    integer i;
    localparam max_fail_attempts = 3;
    reg [1:0] failed_attempts;
    
    // Logic hiển thị LCD và 7-segment
    always @(*) begin
        case (current_state)
            S_UNLOCK: lcd_state = LCD_UNLOCKED;
            S_WAIT_CHANGE, S_VERIFY_0, S_VERIFY_1, S_VERIFY_2, S_VERIFY_3, 
            S_NEW_0, S_NEW_1, S_NEW_2, S_NEW_3: lcd_state = LCD_CHANGE;
            S_BLOCKED: lcd_state = LCD_BLOCKED;
            S_WRONG: lcd_state = LCD_WRONG;
            S_IDLE: begin
                if (idle_timeout) lcd_state = LCD_TIMEOUT;
                else if (show_wrong) lcd_state = LCD_WRONG;
                else lcd_state = LCD_IDLE;
            end
            S_1, S_2, S_3: begin
                if (idle_timeout) lcd_state = LCD_TIMEOUT;
                else lcd_state = LCD_IDLE;
            end
            default: lcd_state = LCD_IDLE;
        endcase

        // Hiển thị số vừa nhập lên 7segment
        if (key_valid && current_state != S_BLOCKED) 
            seg_digit = keypad_input;
        else 
            seg_digit = 4'hF;
    end
     
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            current_state <= S_IDLE;
            lock <= 0;
            lock_check <= 0;           // **THÊM: Khởi tạo lock_check**
            idle_counter <= 0;
            unlock_counter <= 0;
            input_index <= 0;
            password[0] <= 4'd1;
            password[1] <= 4'd1;
            password[2] <= 4'd2;
            password[3] <= 4'd2;
            failed_attempts <= 0;
            block_counter <= 0; 
            show_wrong <= 0;
            wrong_counter <= 0;
            for (i = 0; i < 4; i = i + 1) begin
                input_buffer[i] <= 4'd0;
            end
        end else begin
            case (current_state)
                S_IDLE: begin
                    lock <= 0;
                    lock_check <= 0;      // **TẮT đèn khi ở IDLE**
                    input_index <= 0;
                    show_wrong <= 0;
                    wrong_counter <= 0;
                    if (failed_attempts < max_fail_attempts) begin
                        current_state <= S_BLOCKED;
                        block_counter <= 0;
                    end
                    else if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[0] <= keypad_input;
                        current_state <= S_1;
                        input_index <= 1;
                    end else begin
                        if (!idle_timeout)
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_1: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[1] <= keypad_input;
                        current_state <= S_2;
                        input_index <= 2;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_2: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[2] <= keypad_input;
                        current_state <= S_3;
                        input_index <= 3;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_3: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[3] <= keypad_input;
                        if (input_buffer[0] == password[0] &&
                            input_buffer[1] == password[1] &&
                            input_buffer[2] == password[2] &&
                            keypad_input == password[3]) begin
                            current_state <= S_UNLOCK;
                            unlock_counter <= 0;
                            failed_attempts <= 0; 
                            show_wrong <= 0;
                        end else begin
                            current_state <= S_WRONG;
                            show_wrong <= 1;
                            wrong_counter <= 0;
                            idle_counter <= 0;
                            failed_attempts <= failed_attempts + 1'b1;
                        end
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else 
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_WRONG: begin
                    lock <= 0;
                    lock_check <= 0;      // **TẮT đèn khi sai**
                    show_wrong <= 1;
                    idle_counter <= 0;
                    if (failed_attempts >= max_fail_attempts) begin
                        current_state <= S_BLOCKED;
                        block_counter <= 0;
                        show_wrong <= 0;
                        wrong_counter <= 0;
                    end else if (wrong_counter >= 3'd4) begin
                        current_state <= S_IDLE;
                        show_wrong <= 0;
                        wrong_counter <= 0;
                    end else begin
                        wrong_counter <= wrong_counter + 1'b1;
                    end
                end

                S_UNLOCK: begin
                    lock <= 1'b1;
                    lock_check <= 0;      // **TẮT đèn check trong UNLOCK**
                    show_wrong <= 0;
                    wrong_counter <= 0;
                    if (key_valid && keypad_input == 4'd10) begin 
                        current_state <= S_WAIT_CHANGE;
                        input_index <= 0;
                        unlock_counter <= 0; 
                    end else begin
                        if (unlock_counter >= unlock_timeout - 1'b1) begin
                            current_state <= S_IDLE;
                            lock <= 1'b0;
                            unlock_counter <= 0;
                        end else begin
                            unlock_counter <= unlock_counter + 1'b1;
                        end
                    end
                end

                S_WAIT_CHANGE: begin
                    lock_check <= 0;      // **TẮT đèn khi chờ nhập mật khẩu cũ**
                    show_wrong <= 0;
                    wrong_counter <= 0;
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[0] <= keypad_input;
                        current_state <= S_VERIFY_0;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_VERIFY_0: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[1] <= keypad_input;
                        current_state <= S_VERIFY_1;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_VERIFY_1: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[2] <= keypad_input;
                        current_state <= S_VERIFY_2;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_VERIFY_2: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        input_buffer[3] <= keypad_input;
                        current_state <= S_VERIFY_3;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_VERIFY_3: begin
                    if (input_buffer[0] == password[0] &&
                        input_buffer[1] == password[1] &&
                        input_buffer[2] == password[2] &&
                        input_buffer[3] == password[3]) begin
                        lock_check <= 1;   // **BẬT đèn báo nhập đúng mật khẩu cũ**
                        current_state <= S_NEW_0;
                    end else begin
                        lock_check <= 0;   // **TẮT đèn nếu sai**
                        current_state <= S_WRONG;
                        show_wrong <= 1;
                        wrong_counter <= 0;
                        idle_counter <= 0;
                        failed_attempts <= failed_attempts + 1'b1;
                    end
                end

                S_NEW_0: begin
                    // **GIỮ SÁNG đèn lock_check trong quá trình nhập mật khẩu mới**
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        new_password[0] <= keypad_input;
                        current_state <= S_NEW_1;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_NEW_1: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        new_password[1] <= keypad_input;
                        current_state <= S_NEW_2;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_NEW_2: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        new_password[2] <= keypad_input;
                        current_state <= S_NEW_3;
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end

                S_NEW_3: begin
                    if (key_valid && keypad_input < 4'd10) begin
                        idle_counter <= 0;
                        password[0] <= new_password[0];
                        password[1] <= new_password[1];
                        password[2] <= new_password[2];
                        password[3] <= keypad_input;
                        current_state <= S_IDLE;
                        lock <= 0;
                        lock_check <= 0;  // **TẮT đèn sau khi hoàn thành đổi mật khẩu**
                    end else begin
                        if (idle_timeout) begin
                            current_state <= S_IDLE;
                            lock <= 0;
                            lock_check <= 0;  // **TẮT đèn khi timeout**
                        end else
                            idle_counter <= idle_counter + 1'b1;
                    end
                end
                
                S_BLOCKED: begin
                    lock <= 0;
                    lock_check <= 0;      // **TẮT đèn khi bị khóa**
                    show_wrong <= 0;
                    wrong_counter <= 0;
                    if (block_counter >= block_timeout) begin
                        current_state <= S_IDLE;
                        failed_attempts <= 0;
                        block_counter <= 0;
                    end else begin
                        block_counter <= block_counter + 1'b1;
                    end
                end
                
                default: begin
                    current_state <= S_IDLE;
                    lock <= 0;
                    lock_check <= 0;      // **TẮT đèn ở trạng thái mặc định**
                    show_wrong <= 0;
                    wrong_counter <= 0;
                end
            endcase
        end
    end
endmodule