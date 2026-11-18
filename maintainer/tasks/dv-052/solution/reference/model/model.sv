module dvbench_model(
    input wire [127:0] ciphertext,
    input wire [127:0] key10,
    input wire rst,
    input wire clk,
    output wire [127:0] plaintext
);
logic [127:0] history [0:58];
logic [127:0] key_history [0:2];
logic [2:0] key_valid;

function automatic logic [7:0] multiply(input logic [7:0] left, right);
    logic [7:0] accumulator, multiplicand;
    accumulator=0;
    multiplicand=left;
    for(int bit_index=0;bit_index<8;bit_index++) begin
        if(right[bit_index]) accumulator^=multiplicand;
        multiplicand=(multiplicand<<1) ^ (multiplicand[7] ? 8'h1b : 8'h00);
    end
    return accumulator;
endfunction

function automatic logic [7:0] inverse(input logic [7:0] value);
    logic [7:0] result_value, power_value;
    result_value=1;
    power_value=value;
    for(int bit_index=0;bit_index<8;bit_index++) begin
        if(bit_index!=0) result_value=multiply(result_value,power_value);
        power_value=multiply(power_value,power_value);
    end
    return result_value;
endfunction

function automatic logic [7:0] rotate(input logic [7:0] value,input int distance);
    return (value<<distance)|(value>>(8-distance));
endfunction

function automatic logic [7:0] substitute(input logic [7:0] value,input bit backwards);
    logic [7:0] intermediate;
    if(backwards) return inverse(rotate(value,1)^rotate(value,3)^rotate(value,6)^8'h05);
    intermediate=inverse(value);
    return intermediate^rotate(intermediate,1)^rotate(intermediate,2)^rotate(intermediate,3)^rotate(intermediate,4)^8'h63;
endfunction

function automatic logic [127:0] inverse_round_bytes(input logic [127:0] value);
    logic [127:0] result_value;
    for(int column=0;column<4;column++) begin
        for(int row=0;row<4;row++) begin
            result_value[127-8*(4*column+row)-:8]=substitute(value[127-8*(4*((column+4-row)%4)+row)-:8],1);
        end
    end
    return result_value;
endfunction

function automatic logic [127:0] mix(input logic [127:0] value);
    logic [127:0] result_value;
    logic [7:0] coefficient;
    for(int column=0;column<4;column++) begin
        for(int row=0;row<4;row++) begin
            result_value[127-8*(4*column+row)-:8]=0;
            for(int term=0;term<4;term++) begin
                case((term+4-row)%4)
                    0: coefficient=14;
                    1: coefficient=11;
                    2: coefficient=13;
                    3: coefficient=9;
                endcase
                result_value[127-8*(4*column+row)-:8]^=multiply(value[127-8*(4*column+term)-:8],coefficient);
            end
        end
    end
    return result_value;
endfunction

function automatic logic [127:0] reverse_key(input logic [127:0] last_key,input int rounds);
    logic [127:0] current_key;
    logic [31:0] previous_last, transformed;
    logic [7:0] constant_value;
    current_key=last_key;
    for(int round_index=0;round_index<rounds;round_index++) begin
        case(round_index)
            0: constant_value=8'h36;
            1: constant_value=8'h1b;
            2: constant_value=8'h80;
            3: constant_value=8'h40;
            4: constant_value=8'h20;
            5: constant_value=8'h10;
            6: constant_value=8'h08;
            7: constant_value=8'h04;
            8: constant_value=8'h02;
            9: constant_value=8'h01;
        endcase
        previous_last=current_key[31:0]^current_key[63:32];
        transformed={substitute(previous_last[23:16],0),substitute(previous_last[15:8],0),
                     substitute(previous_last[7:0],0),substitute(previous_last[31:24],0)};
        current_key={current_key[127:96]^transformed^{constant_value,24'b0},
                     current_key[127:96]^current_key[95:64],
                     current_key[95:64]^current_key[63:32],previous_last};
    end
    return current_key;
endfunction

always @(posedge clk or negedge rst) begin
    if(!rst) begin
        for(int position=0;position<59;position++) history[position]<=0;
        for(int position=0;position<3;position++) key_history[position]<=0;
        key_valid<=0;
    end else begin
        key_valid<={key_valid[1:0],1'b1};
        key_history[0]<=key10;
        key_history[1]<=key_history[0];
        key_history[2]<=key_history[1];
        history[0]<=ciphertext^key10;
        for(int position=1;position<59;position++) begin
            case(position%6)
                1: history[position]<=inverse_round_bytes(history[position-1]);
                4: history[position]<=history[position-1]^(key_valid[2] ? reverse_key(key_history[2],position/6+1) : 128'b0);
                5: history[position]<=mix(history[position-1]);
                default: history[position]<=history[position-1];
            endcase
        end
    end
end
assign plaintext=history[58];
endmodule
