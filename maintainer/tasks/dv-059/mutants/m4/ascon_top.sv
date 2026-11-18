
/*--------------------------------------------
* Fonction : ASCON128
* Auteur : Aurélien Goupil
* Date : 30/11/23
--------------------------------------------*/

`timescale 1ns /1 ps

module ascon_top import ascon_pack::*; (
	input type_state state_i,
	input logic [127:0] key_i,
	input logic [63:0] data_i,
	input logic resetb_i,start_i, clock_i, data_valid_i,
	output logic end_o,cipher_valid_o,
	output logic [63:0] cipher_o,
	output logic [127:0] tag_o
	);
	
//internal declaration
	logic [3:0] rnd_s;
	logic [1:0] nb_blocs_s;
	logic bypass_xor_end_s, bypass_xor_begin_s, enable_reg_state_s, enable_cpt_perm_s, enable_cpt_blocs_s, input_mode_s, input_p6_s, input_p12_s, init_blocs_s, xor_end_key_mode_s,xor_begin_data_mode_s;
	type_state state_s;
	
	ascon_fsm fsm_inst(
		.resetb_i(resetb_i),
		.start_i( start_i),
		.clock_i( clock_i ),
		.rnd_i(rnd_s),
		.nb_blocs_i(nb_blocs_s),
		.data_valid_i(data_valid_i),
		.bypass_xor_begin_o( bypass_xor_begin_s),
		.bypass_xor_end_o( bypass_xor_end_s),
		.enable_reg_state_o(enable_reg_state_s),
		.enable_cpt_perm_o(enable_cpt_perm_s),
		.enable_cpt_blocs_o(enable_cpt_blocs_s),
		.input_mode_o(input_mode_s),
		.input_p6_o(input_p6_s),
		.input_p12_o(input_p12_s),
		.init_blocs_o(init_blocs_s),
		.xor_end_key_mode_o( xor_end_key_mode_s),
		.xor_begin_data_mode_o(xor_begin_data_mode_s),
		.end_o(end_o),
		.cipher_valid_o(cipher_valid_o)
		);
		
	compteur_permutations cpt_perm_inst(
		.clock_i( clock_i),
		.resetb_i(resetb_i), 
		.enable_i(enable_cpt_perm_s), 
		.init_p6_i(input_p6_s), 
		.init_p12_i(input_p12_s),
		.compteur_o(rnd_s)
		);
		
	compteur_blocs cpt_bloc_inst(
		.clock_i( clock_i),
		.resetb_i(resetb_i), 
		.enable_i(enable_cpt_blocs_s), 
		.init_i(init_blocs_s),
		.compteur_o(nb_blocs_s)
		);
		
		
	permutation_with_xor perm_inst(
		.state_in(state_i),
		.select_i(input_mode_s),
		.reset_i(resetb_i),
		.enable_reg_i( enable_reg_state_s),
		.clock_i( clock_i ),
		.bypass_xor_begin_i( bypass_xor_begin_s),
		.bypass_xor_end_i( bypass_xor_end_s),
		.mode_on_data_i(xor_begin_data_mode_s),
		.mode_on_key_i( xor_end_key_mode_s),
		.round_i( rnd_s ),
		.data_i(data_i),
		.key_i( key_i),
		.cipher_o(cipher_o),
		.state_out( state_s )
		);	

always_comb
	begin : tag
		case(end_o)
			1'b1 : begin
				tag_o [127:64] = state_s[3];
				tag_o [63:0] = state_s[3];
			end
		endcase
	end : tag

endmodule : ascon_top
