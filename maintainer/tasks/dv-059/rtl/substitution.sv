/*--------------------------------------------
* Fonction : ps - 2e transformation d'une permutation ASCON128
* Auteur : Aurélien Goupil
* Date : 20/10/23
--------------------------------------------*/

`timescale 1 ns/1 ps

module substitution import ascon_pack::*; (
	input type_state state_i,
	output type_state state_o
	);
//intern declaration
	genvar i;

	generate
		for (i = 0; i < 64; i++)
			begin : subs				
				//substitution vecteur
				sbox sbox_inst(
					.sbox_i({state_i[0][i], state_i[1][i], state_i[2][i], state_i[3][i], state_i[4][i]}),
					.sbox_o({state_o[0][i], state_o[1][i], state_o[2][i], state_o[3][i], state_o[4][i]})
					);
			end
	endgenerate

endmodule : substitution
