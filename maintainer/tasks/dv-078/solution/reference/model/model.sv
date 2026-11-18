`timescale 1ns/1ps
module dvbench_model #(parameter integer CPU_HALF_PERIOD=4, parameter MEMFILE="temp_warning_test.mem") (
    input logic clk, rst,
    input logic [15:0] sw,
    output logic [6:0] seg,
    output logic [3:0] an,
    output logic [15:0] leds
);
    logic [31:0] program_words [0:63];
    logic [31:0] registers [0:31];
    logic [31:0] address, instruction, immediate, operand_left, operand_right, result_value, next_address;
    logic [15:0] display_value;
    logic less_mark, greater_mark, fail_mark;
    integer divider, slow_phase, digit_phase=0, digit_counter=0;
    integer register_index, source_left, source_right, destination, opcode, function_code;
    logic write_enable, is_upper, is_branch, is_jump, is_indirect;
    logic [3:0] current_digit;
    initial begin
        program_words[0]=32'h12345a37;
        program_words[1]=32'h00000513;
        program_words[2]=32'h00000593;
        program_words[3]=32'h00000613;
        program_words[4]=32'h01900293;
        program_words[5]=32'h01e00313;
        program_words[6]=32'h0062c463;
        program_words[7]=32'h06000263;
        program_words[8]=32'h008000ef;
        program_words[9]=32'h00000663;
        program_words[10]=32'h00100513;
        program_words[11]=32'h00008067;
        program_words[12]=32'h02800293;
        program_words[13]=32'h01400313;
        program_words[14]=32'h0062c663;
        program_words[15]=32'h00000513;
        program_words[16]=32'h00000463;
        program_words[17]=32'h02000e63;
        program_words[18]=32'h02300293;
        program_words[19]=32'h01e00313;
        program_words[20]=32'h0062d463;
        program_words[21]=32'h02000663;
        program_words[22]=32'h008000ef;
        program_words[23]=32'h00000663;
        program_words[24]=32'h00100593;
        program_words[25]=32'h00008067;
        program_words[26]=32'h00a00293;
        program_words[27]=32'h01400313;
        program_words[28]=32'h0062d663;
        program_words[29]=32'h00000593;
        program_words[30]=32'h00000863;
        program_words[31]=32'h00000263;
        program_words[32]=32'h00100613;
        program_words[33]=32'h00000263;
        program_words[34]=32'h00000063;
        program_words[35]=32'h00000000;
        program_words[36]=32'h00000000;
        program_words[37]=32'h00000000;
        program_words[38]=32'h00000000;
        program_words[39]=32'h00000000;
        program_words[40]=32'h00000000;
        program_words[41]=32'h00000000;
        program_words[42]=32'h00000000;
        program_words[43]=32'h00000000;
        program_words[44]=32'h00000000;
        program_words[45]=32'h00000000;
        program_words[46]=32'h00000000;
        program_words[47]=32'h00000000;
        program_words[48]=32'h00000000;
        program_words[49]=32'h00000000;
        program_words[50]=32'h00000000;
        program_words[51]=32'h00000000;
        program_words[52]=32'h00000000;
        program_words[53]=32'h00000000;
        program_words[54]=32'h00000000;
        program_words[55]=32'h00000000;
        program_words[56]=32'h00000000;
        program_words[57]=32'h00000000;
        program_words[58]=32'h00000000;
        program_words[59]=32'h00000000;
        program_words[60]=32'h00000000;
        program_words[61]=32'h00000000;
        program_words[62]=32'h00000000;
        program_words[63]=32'h00000000;
    end
    task automatic execute_instruction;
        instruction = program_words[address >> 2];
        opcode = instruction[6:0];
        destination = instruction[11:7];
        source_left = instruction[19:15];
        source_right = instruction[24:20];
        function_code = instruction[14:12];
        operand_left = registers[source_left];
        operand_right = registers[source_right];
        immediate = {{20{instruction[31]}}, instruction[31:20]};
        next_address = address + 4;
        result_value = 0;
        write_enable = 0;
        is_upper = opcode == 7'h37;
        is_branch = opcode == 7'h63;
        is_jump = opcode == 7'h6f;
        is_indirect = opcode == 7'h67;
        case(opcode)
            7'h37: begin result_value = {instruction[31:12],12'b0}; write_enable = 1; end
            7'h13: begin
                write_enable = 1;
                case(function_code)
                    7: result_value = operand_left & immediate;
                    6: result_value = operand_left | immediate;
                    4: result_value = operand_left ^ immediate;
                    1: result_value = operand_left << immediate[4:0];
                    5: result_value = operand_left >> immediate[4:0];
                    default: result_value = operand_left + immediate;
                endcase
            end
            7'h63: begin
                immediate = {{19{instruction[31]}},instruction[31],instruction[7],instruction[30:25],instruction[11:8],1'b0};
                if ((function_code == 0 && operand_left == operand_right) ||
                    (function_code == 4 && $signed(operand_left) < $signed(operand_right)) ||
                    (function_code == 5 && $signed(operand_left) >= $signed(operand_right))) next_address = address + immediate;
            end
            7'h6f: begin
                immediate = {{11{instruction[31]}},instruction[31],instruction[19:12],instruction[20],instruction[30:21],1'b0};
                next_address = address + immediate;
                result_value = address + 4;
                write_enable = 1;
            end
            7'h67: begin
                next_address = (operand_left + immediate) & 32'hfffffffe;
                result_value = address + 4;
                write_enable = 1;
            end
            default: begin end
        endcase
        if(is_upper) leds = result_value[31:16];
        else leds = {10'd0,fail_mark,greater_mark,less_mark,is_indirect,is_jump,is_branch};
        if(write_enable && destination != 0) begin
            if(is_upper) display_value = result_value[15:0];
            else display_value = ((destination / 10) << 12) | ((destination % 10) << 8) | result_value[7:0];
            if(destination == 10) less_mark = result_value[0];
            if(destination == 11) greater_mark = result_value[0];
            if(destination == 12) fail_mark = result_value[0];
            registers[destination] = result_value;
        end
        registers[0] = 0;
        address = next_address;
    endtask
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            divider = 0;
            slow_phase = 0;
            address = 0;
            display_value = 0;
            leds = 0;
            less_mark = 0;
            greater_mark = 0;
            fail_mark = 0;
            for(register_index=0; register_index<32; register_index=register_index+1) registers[register_index]=0;
        end else begin
            divider = divider + 1;
            if(divider == CPU_HALF_PERIOD) begin
                divider = 0;
                slow_phase = 1 - slow_phase;
                if(slow_phase == 1) execute_instruction();
            end
        end
    end
    always @(posedge clk) begin
        if(digit_counter == 0) digit_phase = (digit_phase+1)%4;
        digit_counter = (digit_counter+1)%65536;
    end
    always @* begin
        an = ~(4'b1 << digit_phase);
        current_digit = (display_value >> (digit_phase*4)) & 15;
        case(current_digit)
            0: seg=7'b1000000; 1: seg=7'b1111001; 2: seg=7'b0100100; 3: seg=7'b0110000;
            4: seg=7'b0011001; 5: seg=7'b0010010; 6: seg=7'b0000010; 7: seg=7'b1111000;
            8: seg=7'b0000000; 9: seg=7'b0010000; 10: seg=7'b0001000; 11: seg=7'b0000011;
            12: seg=7'b1000110; 13: seg=7'b0100001; 14: seg=7'b0000110; 15: seg=7'b0001110;
        endcase
    end
endmodule
