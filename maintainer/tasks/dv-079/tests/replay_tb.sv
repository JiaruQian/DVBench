
`timescale 1ns/1ps
module replay_tb;
    logic clk=0;
    logic [63:0] inputs;
    wire [5-1:0] outputs;
    logic [5-1:0] previous;
    longint unsigned edge_number=0;
    logic [63:0] value;
    always #5 clk=~clk;
    REPLAY_TARGET  dut(.clk(clk),.reset_n(inputs[0]),.btn(inputs[2:1]),.rx(inputs[3]),.vga_hsync(outputs[4]),.vga_vsync(outputs[3]),.vga_rgb(outputs[2:0]));
    task send(logic [63:0] value, integer cycles);
        #1; inputs=value;
        repeat(cycles) @(negedge clk);
    endtask
    always @(posedge clk or inputs[0]) begin
        #1; edge_number++;
        if(outputs!==previous || edge_number%997==0 || edge_number<100)
            $display("TRACE %0d %h %h",edge_number,inputs,outputs);
        previous=outputs;
    end
    initial begin
        
        send(14,8); send(15,80+$urandom_range(0,325));
        send(13,31); send(15,17); send(13,43); send(15,29);
        send(13,2097152); send(13,32);
        send(15,100); send(13,100);
        for(integer byte_number=0;byte_number<6;byte_number++) begin
            value=byte_number%3==0 ? 8'h77 : byte_number%3==1 ? 8'h73 : 8'h41;
            send(5,5216);
            for(integer bit_number=0;bit_number<8;bit_number++) send(5|(((value>>bit_number)&1)<<3),5216);
            send(13,5216+byte_number*37);
        end
        send(13,838400*146);
        send(15,2097200); send(11,838400*24);
        send(9,838400*3); send(15,2097200);
        send(14,8); send(15,838400*146);
        
        #3; $display("REPLAY_COMPLETED"); $finish;
    end
endmodule
