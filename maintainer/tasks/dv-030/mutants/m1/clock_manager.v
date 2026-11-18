module clock_manager(
    input wire CLOCK_50Mhz,      
    output wire clk_fsm          
);
    // Clock 1Hz cho FSM
    reg [25:0] counter_1Hz = 0;
    reg clk_1Hz = 0;
    
    always @(posedge CLOCK_50Mhz) begin
        if (counter_1Hz >= 24_999_999) begin
            counter_1Hz <= 0;
            clk_1Hz <= ~clk_1Hz;
        end else begin
            counter_1Hz <= counter_1Hz + 1;
        end
    end
    assign clk_fsm = clk_1Hz;        
endmodule