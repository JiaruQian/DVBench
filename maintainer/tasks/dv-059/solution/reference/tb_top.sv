`timescale 1ns/1ps
module dvbench_top;import uvm_pkg::*;import pins_pkg::*;logic clock_i=0;always #5 clock_i=~clock_i;pins_if v(clock_i);
logic resetb_i;
logic start_i;
logic data_valid_i;
logic[0:4][63:0] state_i;
logic[127:0] key_i;
logic[63:0] data_i;
wire end_o;
wire cipher_valid_o;
wire[63:0] cipher_o;
wire[127:0] tag_o;
assign {resetb_i,start_i,data_valid_i,state_i,key_i,data_i}=v.drive_inputs;
ascon_top dut(.resetb_i(resetb_i),.start_i(start_i),.data_valid_i(data_valid_i),.state_i(state_i),.key_i(key_i),.data_i(data_i),.end_o(end_o),.cipher_valid_o(cipher_valid_o),.cipher_o(cipher_o),.tag_o(tag_o),.clock_i(clock_i));
assign v.actual={end_o,cipher_valid_o,cipher_o,tag_o};
logic m_resetb_i;
logic m_start_i;
logic m_data_valid_i;
logic[0:4][63:0] m_state_i;
logic[127:0] m_key_i;
logic[63:0] m_data_i;
wire m_end_o;
wire m_cipher_valid_o;
wire[63:0] m_cipher_o;
wire[127:0] m_tag_o;
assign {m_resetb_i,m_start_i,m_data_valid_i,m_state_i,m_key_i,m_data_i}=v.drive_inputs;
dvbench_model model(.resetb_i(m_resetb_i),.start_i(m_start_i),.data_valid_i(m_data_valid_i),.state_i(m_state_i),.key_i(m_key_i),.data_i(m_data_i),.end_o(m_end_o),.cipher_valid_o(m_cipher_valid_o),.cipher_o(m_cipher_o),.tag_o(m_tag_o),.clock_i(clock_i));
assign v.expected={m_end_o,m_cipher_valid_o,m_cipher_o,m_tag_o};

always_comb begin v.mask={(v.expected[193]!==1'bx),(v.expected[192]!==1'bx),{64{v.expected[192]===1'b1}},{128{v.expected[193]===1'b1}}};for(int j=0;j<128;j++)if(v.expected[j]===1'bx)v.mask[j]=0;end
initial begin uvm_config_db#(virtual pins_if)::set(null,"*","vif",v);run_test("dvbench_test");end
endmodule
