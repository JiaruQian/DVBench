


`include "parameters.vh"



module instr_mem #(
    parameter WIDTH = `I_WIDTH,
    parameter DEPTH = `I_DEPTH, 
    parameter ADD_SIZE = `I_ADD_SIZE,
    parameter PROGRAM_FILE = "program3.hex"
)(
    input   [ADD_SIZE - 1 : 0]      i_add,
    output  [WIDTH - 1 :  0]        o_instr
); 

    reg [WIDTH - 1 : 0] i_mem [DEPTH - 1 : 0]; 
        
    integer word_index;
    initial begin
        for (word_index = 0; word_index < DEPTH; word_index = word_index + 1)
            i_mem[word_index] = 32'h00000013;
        $readmemh(PROGRAM_FILE, i_mem);
    end

    assign o_instr = i_mem[i_add>>2]; 

endmodule 
