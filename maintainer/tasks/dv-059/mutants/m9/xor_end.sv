
/*---------------------------
* Fonction : Porte XOR à la fin permutation
* Auteur : Aurélien Goupil
* Date : 10/11/23
---------------------------*/

`timescale 1 ns/ 1 ps

module xor_end import ascon_pack::*;(
	input type_state state_i,
	input logic [127:0] key_i,
	input logic bypass_i, mode_on_key_i,
	output type_state state_o
	);
		
	// combinational for xor_end process
	always_comb
		begin : xor_launch
			case ({bypass_i, mode_on_key_i})
				{1'b0,1'b1}: //on key
					begin
					state_o = state_i;
					//register changed
					state_o [3] = state_i[3] ^ key_i[127:64];
				 	state_o [4] = state_i[4] ^ key_i[63:0];
					end
				{1'b0,1'b0}: //on {...,1}
					begin
					state_o = state_i;
					//register changed
					state_o [4][0] = state_i[4][0]  ^ 1;
				 	end
				default : state_o = state_i; //transparent
			endcase ; // case ( current_state )
		end : xor_launch

endmodule : xor_end
