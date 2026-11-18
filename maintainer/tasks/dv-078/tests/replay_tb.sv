
`timescale 1ns/1ps
module replay_tb;
    logic clk=0;
    logic [63:0] inputs;
    wire [27-1:0] outputs;
    logic [27-1:0] previous;
    longint unsigned edge_number=0;
    logic [63:0] value;
    always #5 clk=~clk;
    REPLAY_TARGET #(.CPU_HALF_PERIOD(4),.MEMFILE("temp_warning_test.mem")) dut(.clk(clk),.rst(inputs[0]),.sw(inputs[16:1]),.seg(outputs[6:0]),.an(outputs[10:7]),.leds(outputs[26:11]));
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
        
        send(1,8); send(0,700);
        for(integer trial=0;trial<32;trial++) send(($urandom & 16'hffff)<<1,17+trial);
        send(64'h1fffe,262160);
        for(integer scan_trial=0;scan_trial<4;scan_trial++) begin
            send(1,8); send((scan_trial*16'h5555)<<1,65537);
        end
        
        #3; $display("REPLAY_COMPLETED"); $finish;
    end
endmodule
