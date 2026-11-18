
`timescale 1ns/1ps
module replay_tb;
    logic clk=0;
    logic [63:0] inputs;
    wire [33-1:0] outputs;
    logic [33-1:0] previous;
    longint unsigned edge_number=0;
    logic [63:0] value;
    always #5 clk=~clk;
    REPLAY_TARGET #(.PROGRAM_FILE("code.txt")) dut(.Clk(clk),.Reset(inputs[0]),.input_data(inputs[32:1]),.result_valid(outputs[32]),.result_data(outputs[31:0]));
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
        
        for(integer trial=0;trial<24;trial++) begin
            value = trial<8 ? (64'h1 << (trial*4)) : {$urandom,$urandom};
            send((value<<1)|1,8);
            send(value<<1,19);
            value = trial==0 ? 32'h7fffffff : trial==1 ? 32'hffffffff : $urandom;
            send(value<<1,1);
            case(trial)
                0:value=0; 1:value=1; 2:value=32'hfffffffc; 3:value=32'hffffffff;
                4:value=32'h7fffffff; 5:value=32'h80000000; 6:value=32'h12345678; 7:value=32'hffff0001;
                8:value=32'h00007fff; 9:value=32'h00008000; 10:value=32'h0000fffc; 11:value=32'h0000ffff; 12:value=32'h01020304;
                default:value=$urandom;
            endcase
            send(value<<1,1);
            send(($urandom<<1),1);
            send(($urandom<<1),80);
        end
        send(1,8); send(64'h12345678<<1,65); send(1,8);
        send(64'h80000000<<1,300);
        
        #3; $display("REPLAY_COMPLETED"); $finish;
    end
endmodule
