module seg7_display (
    input wire reset_n,
    input wire [3:0] digit,
    output reg [6:0] segment
);
    always @(*) begin
        if (!reset_n)
            segment = 7'b1111111; 	
        else begin
            case (digit)
                4'h0: segment = 7'b1000000; // 0
                4'h1: segment = 7'b1111001; // 1
                4'h2: segment = 7'b0100100; // 2
                4'h3: segment = 7'b0110000; // 3
                4'h4: segment = 7'b0011001; // 4
                4'h5: segment = 7'b0010010; // 5
                4'h6: segment = 7'b0000010; // 6
                4'h7: segment = 7'b1111000; // 7
                4'h8: segment = 7'b0000000; // 8
                4'h9: segment = 7'b0010000; // 9
					 4'd10: segment = 7'b1000110; // "C"
                default: segment = 7'b1111111; // Tắt
            endcase
        end
    end
endmodule

