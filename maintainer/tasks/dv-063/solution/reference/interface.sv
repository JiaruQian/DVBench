interface dvbench_if;
logic clk;
logic rst;
logic load;
logic start;
logic [127:0] key;
logic [127:0] iv;
logic [127:0] iBlock;
logic [127:0] oBlock;
logic idle;
logic [127:0] exp_oBlock;
logic exp_idle;
logic [386:0] pins;logic [128:0] actual,expected;
assign {rst,load,start,key,iv,iBlock}=pins;
assign actual={oBlock,idle};
assign expected={exp_oBlock,exp_idle};
initial begin clk=0;forever #5 clk=~clk;end
endinterface
