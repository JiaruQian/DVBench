/*---------------------------
* Fonction : Compte le nombre de blocs
* Auteur : Aurélien Goupil
* Date : 30/11/23
---------------------------*/

`timescale 1 ns/ 1 ps

module compteur_blocs import ascon_pack::*;(
	input logic clock_i, resetb_i, enable_i, init_i,
	output logic [1:0] compteur_o
	);
	
	//internal declaration
	logic [1:0] cpt_s;

always_ff @(posedge clock_i or negedge resetb_i)
begin : compteur
	if(resetb_i == 1'b0)
		cpt_s <= 0;
	else begin
		if(enable_i == 1'b1) begin
			if(init_i == 1'b1)
				cpt_s <= 0;
			else
				cpt_s <= cpt_s+1;
		end
	end	
		

end:compteur

assign compteur_o = cpt_s;

endmodule : compteur_blocs
