/*--------------------------------------------
* Fonction : Bascule D - Synchronisation ronde permutation et mémorisation registre
* Auteur : Aurélien Goupil
* Date : 18/10/23
--------------------------------------------*/

`timescale 1ns /1 ps

module reg_state import ascon_pack::*;(
	//partie déclarative vide
	input type_state register_i,
	input logic clock_i , resetb_i, enable_i,
	output type_state register_o
	);
	
// sequential process
always_ff @( posedge clock_i or negedge resetb_i)
begin : seq_0
	if ( resetb_i == 0)
	// nonblocking assignment <=
	register_o <= {64'h0,64'h0,64'h0,64'h0,64'h0};
	if (enable_i == 1) 
	register_o <= register_i ;
end : seq_0

endmodule : reg_state
