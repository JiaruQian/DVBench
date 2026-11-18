/*--------------------------------------------
* Fonction : calcul 1 substitution
* Auteur : Aurélien Goupil
* Date : 20/10/23
--------------------------------------------*/

`timescale 1 ns/1 ps

module sbox import ascon_pack::*; (
	input logic[0:4] sbox_i,
	output logic[0:4] sbox_o
	);	
	
//substitution 5bits selon sbox_constant de ascon_pack
	assign sbox_o = sbox_constant[sbox_i];

endmodule : sbox
