/*--------------------------------------------
* Fonction : pc - 1e transformation d'une permutation ASCON128
* Auteur : Aurélien Goupil
* Date : 20/10/23
--------------------------------------------*/

`timescale 1 ns/1 ps

module constant_addition import ascon_pack::*;  (
	input type_state state_i,
	input logic [3:0] round_i,
	output type_state state_o
	);
	
//State bits not changed
	assign state_o[0]= state_i[0];
	assign state_o[1] = state_i[1];
	assign state_o[2][63:8] = state_i[2][63:8];
	assign state_o[3] = state_i[3];
	assign state_o[4] = state_i[4];
	
//State bits changed
	assign state_o[2][7:0] = state_i[2][7:0] ^ round_constant[round_i];

endmodule : constant_addition
