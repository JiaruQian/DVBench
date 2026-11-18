/*--------------------------------------------
* Fonction : Permutation avec le module xor_begin
* Auteur : Aurélien Goupil
* Date : 17/11/23
--------------------------------------------*/

`timescale 1 ns/1 ps

module permutation_with_xor import ascon_pack::*; (
	input type_state state_in, 
	input logic select_i, reset_i, enable_reg_i, clock_i, bypass_xor_begin_i, bypass_xor_end_i, mode_on_data_i,mode_on_key_i,
	input logic [3:0] round_i,
	input logic [63:0] data_i,
	input logic [127:0] key_i,
	output logic [63:0] cipher_o,
	output type_state state_out
	);
	
//internal declaration
	type_state register_input_xorB,register_input_c, register_input_s, register_input_l, register_input_xorE,register_input_reg_state, register_loop;
	
//multiplexeur choisi entre début et boucles
	mux_state mux_state_inst(
		.state_1_i(state_in),
		.state_0_i(register_loop),
		.input_mode_i(select_i),
		.state_o(register_input_xorB)
		);
		
//passage dans le bloc xor_begin
	xor_begin xor_begin_inst(
		.state_i(register_input_xorB),
		.data_i(data_i),
		.key_i(key_i),
		.bypass_i(bypass_xor_begin_i),
		.mode_on_data_i(mode_on_data_i),
		.state_o(register_input_c)
		);
	assign cipher_o = register_input_c[0];

		
//passage dans le bloc Pc - Constant addition
	constant_addition constant_addition_inst(
		.state_i(register_input_c),
		.round_i(round_i),
		.state_o(register_input_s)
		);

//passage dans le bloc Ps - Substitution
	substitution substitution_inst(
		.state_i(register_input_s),
		.state_o(register_input_l)
		);
		
//passage dans le bloc Pl - Couche de diffusion
	diffusion diffusion_inst(
		.state_i(register_input_l),
		.state_o(register_input_xorE)
		);

//passage dans le bloc xor_end
	xor_end xor_end_inst(
		.state_i(register_input_xorE),
		.key_i(key_i),
		.bypass_i(bypass_xor_end_i),
		.mode_on_key_i(mode_on_key_i),
		.state_o(register_input_reg_state)
		);

//passage dans le bascule D - reg_state
	reg_state reg_state_inst(
		.register_i(register_input_reg_state),
		.clock_i(clock_i),
		.resetb_i(reset_i),
		.enable_i(enable_reg_i),
		.register_o(register_loop)
		);
		
assign state_out = register_loop;
endmodule : permutation_with_xor
