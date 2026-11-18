`timescale 1ns/1ps
module dvbench_model (
    input logic clk, reset_n,
    input logic [1:0] btn,
    input logic rx,
    output logic vga_hsync, vga_vsync,
    output logic [2:0] vga_rgb
);
    integer horizontal, vertical, source_phase;
    integer paddle_left, paddle_right, ball_horizontal, ball_vertical;
    integer motion_horizontal, motion_vertical;
    integer key_state[0:1], stable_count[0:1];
    integer baud_count, receive_phase, sample_count, received_bits;
    logic [7:0] received_byte, storage[0:3];
    integer read_position, write_position;
    logic fifo_empty, fifo_full, receive_done;
    logic [1:0] remote_keys, next_keys;
    logic [7:0] shape_row;
    logic [2:0] color;
    logic read_event, write_event, baud_tick, baud_pending;
    integer key_index, row_index, column_index;
    function automatic logic pressed(input integer index);
        pressed = key_state[index] >= 2;
    endfunction
    function automatic logic [7:0] shape(input integer row_number);
        case(row_number)
            0,7: shape=8'h18;
            1,6: shape=8'h3c;
            2,5: shape=8'h7e;
            default: shape=8'hff;
        endcase
    endfunction
    always @(posedge clk or negedge reset_n) begin
        if(!reset_n) begin
            horizontal=0; vertical=0; source_phase=0;
            vga_hsync<=0; vga_vsync<=0; vga_rgb<=0;
            paddle_left=220; paddle_right=220;
            ball_horizontal=280; ball_vertical=280;
            motion_horizontal=-1; motion_vertical=-1;
            remote_keys=0;
            baud_pending=0; baud_count=0; receive_phase=0; sample_count=0; received_bits=0; received_byte=0;
            read_position=0; write_position=0; fifo_empty=0; fifo_full=0;
            storage[0]=0;
            for(key_index=0;key_index<2;key_index=key_index+1) begin key_state[key_index]=0; stable_count[key_index]=0; end
        end else begin
            color=0;
            if(horizontal<640 && vertical<480) begin
                color=3'b110;
                if(horizontal>=100 && horizontal<=105 && vertical>=paddle_left && vertical<=paddle_left+80) color=1;
                else if(horizontal>=550 && horizontal<=555 && vertical>=paddle_right && vertical<=paddle_right+80) color=2;
                else if(horizontal>=ball_horizontal && horizontal<=ball_horizontal+7 && vertical>=ball_vertical && vertical<=ball_vertical+7) begin
                    row_index=vertical-ball_vertical;
                    column_index=horizontal-ball_vertical;
                    shape_row=shape(row_index);
                    if(column_index>=0 && column_index<8 && shape_row[column_index]) color=4;
                end
            end
            vga_rgb<=color;
            read_event=(horizontal==0 && vertical==500);
            next_keys=remote_keys;
            if(read_event) next_keys=0;
            else if(!fifo_empty) begin
                if(storage[read_position]==8'h73) next_keys=2;
                else if(storage[read_position]==8'h77) next_keys=1;
            end
            if(read_event) begin
                if((ball_horizontal>=100 && ball_horizontal<=105 && ball_vertical+7>=paddle_left && ball_vertical<=paddle_left+80) ||
                   (ball_horizontal>=550 && ball_horizontal<=555 && ball_vertical+7>=paddle_right && ball_vertical<=paddle_right+80) ||
                   ball_horizontal<=5 || ball_horizontal+7>=640) motion_horizontal=-motion_horizontal;
                if(ball_vertical<=5 || ball_vertical+7>=480) motion_vertical=-motion_vertical;
                ball_horizontal=(ball_horizontal+motion_horizontal)&1023;
                ball_vertical=(ball_vertical+motion_vertical)&1023;
                if(pressed(0) && paddle_left>80) paddle_left=paddle_left-10;
                else if(pressed(1) && paddle_left<400) paddle_left=paddle_left+10;
                if(remote_keys[0] && paddle_right>80) paddle_right=paddle_right-10;
                else if(remote_keys[1] && paddle_right<400) paddle_right=paddle_right+10;
            end
            remote_keys=next_keys;
            for(key_index=0;key_index<2;key_index=key_index+1) begin
                case(key_state[key_index])
                    0: if(!btn[key_index]) begin key_state[key_index]=1; stable_count[key_index]=0; end
                    1: if(btn[key_index]) key_state[key_index]=0;
                       else begin stable_count[key_index]=stable_count[key_index]+1; if(stable_count[key_index]==2097152) begin key_state[key_index]=2; stable_count[key_index]=0; end end
                    2: if(btn[key_index]) begin key_state[key_index]=3; stable_count[key_index]=0; end
                    3: if(!btn[key_index]) key_state[key_index]=2;
                       else begin stable_count[key_index]=stable_count[key_index]+1; if(stable_count[key_index]==2097152) begin key_state[key_index]=0; stable_count[key_index]=0; end end
                endcase
            end
            baud_tick=baud_pending; baud_pending=(baud_count==325);
            baud_count=(baud_count+1)%326;
            receive_done=0;
            case(receive_phase)
                0: if(!rx) begin receive_phase=1; sample_count=0; end
                1: if(baud_tick) begin sample_count=sample_count+1; if(sample_count==8) begin receive_phase=2; sample_count=0; received_bits=0; end end
                2: if(baud_tick) begin
                    sample_count=sample_count+1;
                    if(sample_count==16) begin
                        received_byte={rx,received_byte[7:1]};
                        sample_count=0; received_bits=received_bits+1;
                        if(received_bits==8) receive_phase=3;
                    end
                end
                3: receive_phase=4;
                4: if(baud_tick) begin receive_phase=0; receive_done=1; end
            endcase
            write_event=receive_done;
            if(write_event && !fifo_full) storage[write_position]=received_byte;
            if(write_event && read_event) begin write_position=(write_position+1)%4; read_position=(read_position+1)%4; end
            else if(write_event && !fifo_full) begin write_position=(write_position+1)%4; fifo_empty=0; if(write_position==read_position) fifo_full=1; end
            else if(read_event && !fifo_empty) begin read_position=(read_position+1)%4; fifo_full=0; if(read_position==write_position) fifo_empty=1; end
            source_phase=1-source_phase;
            if(source_phase==0) begin
                if(vertical==524) vertical=0;
                else if(horizontal==799) vertical=vertical+1;
                horizontal=(horizontal+1)%800;
                vga_hsync<=!(horizontal>=656 && horizontal<=751);
                vga_vsync<=!(vertical>=490 && vertical<=491);
            end
        end
    end
endmodule
