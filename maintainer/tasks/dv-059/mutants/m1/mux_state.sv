/*---------------------------
* Fonction : Multiplexeur permutation
* Auteur : Aurélien Goupil
* Date : 08/11/23
---------------------------*/

`timescale 1 ns/ 1 ps

module mux_state import ascon_pack::*;(
	input type_state state_0_i, state_1_i,
	input logic input_mode_i,
	output type_state state_o
	);

	//module description
	assign state_o = (input_mode_i) ? state_1_i : state_0_i;

endmodule : mux_state
