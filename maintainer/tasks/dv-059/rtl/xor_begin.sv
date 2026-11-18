/*---------------------------
* Fonction : Porte XOR au début permutation
* Auteur : Aurélien Goupil
* Date : 10/11/23
---------------------------*/

`timescale 1 ns/ 1 ps

module xor_begin import ascon_pack::*;(
	input type_state state_i,
	input logic [63:0] data_i,
	input logic [127:0] key_i,
	input logic bypass_i, mode_on_data_i,
	output type_state state_o
	);
		
	// combinational for xor_begin process
	always_comb
		begin : xor_launch
			case ( {bypass_i, mode_on_data_i})
				{1'b0,1'b1}: //on data
					begin
					state_o = state_i;
					//register changed
					state_o [0] = state_i[0] ^ data_i;
					end
				{1'b0,1'b0} : //on key and data
					begin
					state_o = state_i;
					//register changed
					state_o [0] = state_i[0] ^ data_i;
					state_o [1] = state_i[1] ^ key_i[127:64];
				 	state_o [2] = state_i[2] ^ key_i[63:0];
				 	end
				default : state_o = state_i; //transparent
			endcase ; // case ( current_state )
		end : xor_launch

endmodule : xor_begin
