module dvbench_model(
input logic [1:0] screen,
input logic [2:0] opcode,
input logic [3:0] A,
input logic [3:0] B,
input logic carry_in,
output logic carry_out,
output logic overflow,
output logic [11:0] bcd,
output logic error
);
integer arithmetic_result;
integer display_value;
always @* begin
    arithmetic_result = 0;
    display_value = 0;
    carry_out = 0;
    overflow = 0;
    error = opcode >= 6;
    case (screen)
        0: display_value = opcode;
        1: display_value = A;
        2: display_value = B;
        3: begin
            case (opcode)
                0: begin
                    arithmetic_result = int'(A) + int'(B) + int'(carry_in);
                    display_value = arithmetic_result % 16;
                    carry_out = arithmetic_result >= 16;
                    overflow = carry_out;
                end
                1: begin
                    arithmetic_result = int'(A) - int'(B) - int'(carry_in);
                    display_value = (arithmetic_result + 32) % 16;
                    carry_out = arithmetic_result < 0;
                end
                2: display_value = int'(A) * int'(B);
                3: display_value = A & B;
                4: display_value = A | B;
                5: display_value = A ^ B;
                default: display_value = 0;
            endcase
        end
    endcase
    bcd[11:8] = 4'(display_value / 100);
    bcd[7:4] = 4'((display_value / 10) % 10);
    bcd[3:0] = 4'(display_value % 10);
end
endmodule
