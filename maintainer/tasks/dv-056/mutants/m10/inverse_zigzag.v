`timescale 1ns / 1ps

// INPUT:  zigzag_in  [511:0] — 64 × 8-bit zigzag ordered
//         inv_zz_start       — pulse to trigger output
// OUTPUT: raster_out [511:0] — 64 × 8-bit raster ordered
//         inv_zz_done        — pulse one cycle after input

module inv_zigzag (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        inv_zz_start,
    input  wire [511:0] zigzag_in,

    output reg         inv_zz_done,
    output reg  [511:0] raster_out
);



 wire [511:0] inv_wire;

// Inverse zigzag: raster[zigzag_map[i]] = zigzag[i]
// Written explicitly as: raster[known_position] = zigzag[i]
assign inv_wire[0*8  +: 8] = zigzag_in[0*8  +: 8]; // map[0]=0
assign inv_wire[1*8  +: 8] = zigzag_in[1*8  +: 8]; // map[1]=1
assign inv_wire[8*8  +: 8] = zigzag_in[2*8  +: 8]; // map[2]=8
assign inv_wire[16*8 +: 8] = zigzag_in[3*8  +: 8]; // map[3]=16
assign inv_wire[9*8  +: 8] = zigzag_in[4*8  +: 8]; // map[4]=9
assign inv_wire[2*8  +: 8] = zigzag_in[5*8  +: 8]; // map[5]=2
assign inv_wire[3*8  +: 8] = zigzag_in[6*8  +: 8]; // map[6]=3
assign inv_wire[10*8 +: 8] = zigzag_in[7*8  +: 8]; // map[7]=10
assign inv_wire[17*8 +: 8] = zigzag_in[8*8  +: 8]; // map[8]=17
assign inv_wire[24*8 +: 8] = zigzag_in[9*8  +: 8]; // map[9]=24
assign inv_wire[32*8 +: 8] = zigzag_in[10*8 +: 8]; // map[10]=32
assign inv_wire[25*8 +: 8] = zigzag_in[11*8 +: 8]; // map[11]=25
assign inv_wire[18*8 +: 8] = zigzag_in[12*8 +: 8]; // map[12]=18
assign inv_wire[11*8 +: 8] = zigzag_in[13*8 +: 8]; // map[13]=11
assign inv_wire[4*8  +: 8] = zigzag_in[14*8 +: 8]; // map[14]=4
assign inv_wire[5*8  +: 8] = zigzag_in[15*8 +: 8]; // map[15]=5
assign inv_wire[12*8 +: 8] = zigzag_in[16*8 +: 8]; // map[16]=12
assign inv_wire[19*8 +: 8] = zigzag_in[17*8 +: 8]; // map[17]=19
assign inv_wire[26*8 +: 8] = zigzag_in[18*8 +: 8]; // map[18]=26
assign inv_wire[33*8 +: 8] = zigzag_in[19*8 +: 8]; // map[19]=33
assign inv_wire[40*8 +: 8] = zigzag_in[20*8 +: 8]; // map[20]=40
assign inv_wire[48*8 +: 8] = zigzag_in[21*8 +: 8]; // map[21]=48
assign inv_wire[41*8 +: 8] = zigzag_in[22*8 +: 8]; // map[22]=41
assign inv_wire[34*8 +: 8] = zigzag_in[23*8 +: 8]; // map[23]=34
assign inv_wire[27*8 +: 8] = zigzag_in[24*8 +: 8]; // map[24]=27
assign inv_wire[20*8 +: 8] = zigzag_in[25*8 +: 8]; // map[25]=20
assign inv_wire[13*8 +: 8] = zigzag_in[26*8 +: 8]; // map[26]=13
assign inv_wire[6*8  +: 8] = zigzag_in[27*8 +: 8]; // map[27]=6
assign inv_wire[7*8  +: 8] = zigzag_in[28*8 +: 8]; // map[28]=7
assign inv_wire[14*8 +: 8] = zigzag_in[29*8 +: 8]; // map[29]=14
assign inv_wire[21*8 +: 8] = zigzag_in[30*8 +: 8]; // map[30]=21
assign inv_wire[28*8 +: 8] = zigzag_in[31*8 +: 8]; // map[31]=28
assign inv_wire[35*8 +: 8] = zigzag_in[32*8 +: 8]; // map[32]=35
assign inv_wire[42*8 +: 8] = zigzag_in[33*8 +: 8]; // map[33]=42
assign inv_wire[49*8 +: 8] = zigzag_in[34*8 +: 8]; // map[34]=49
assign inv_wire[56*8 +: 8] = zigzag_in[35*8 +: 8]; // map[35]=56
assign inv_wire[57*8 +: 8] = zigzag_in[36*8 +: 8]; // map[36]=57
assign inv_wire[50*8 +: 8] = zigzag_in[37*8 +: 8]; // map[37]=50
assign inv_wire[43*8 +: 8] = zigzag_in[38*8 +: 8]; // map[38]=43
assign inv_wire[36*8 +: 8] = zigzag_in[39*8 +: 8]; // map[39]=36
assign inv_wire[29*8 +: 8] = zigzag_in[40*8 +: 8]; // map[40]=29
assign inv_wire[22*8 +: 8] = zigzag_in[41*8 +: 8]; // map[41]=22
assign inv_wire[15*8 +: 8] = zigzag_in[42*8 +: 8]; // map[42]=15
assign inv_wire[23*8 +: 8] = zigzag_in[43*8 +: 8]; // map[43]=23
assign inv_wire[30*8 +: 8] = zigzag_in[44*8 +: 8]; // map[44]=30
assign inv_wire[37*8 +: 8] = zigzag_in[45*8 +: 8]; // map[45]=37
assign inv_wire[44*8 +: 8] = zigzag_in[46*8 +: 8]; // map[46]=44
assign inv_wire[51*8 +: 8] = zigzag_in[47*8 +: 8]; // map[47]=51
assign inv_wire[58*8 +: 8] = zigzag_in[48*8 +: 8]; // map[48]=58
assign inv_wire[59*8 +: 8] = zigzag_in[49*8 +: 8]; // map[49]=59
assign inv_wire[52*8 +: 8] = zigzag_in[50*8 +: 8]; // map[50]=52
assign inv_wire[45*8 +: 8] = zigzag_in[51*8 +: 8]; // map[51]=45
assign inv_wire[38*8 +: 8] = zigzag_in[52*8 +: 8]; // map[52]=38
assign inv_wire[31*8 +: 8] = zigzag_in[53*8 +: 8]; // map[53]=31
assign inv_wire[39*8 +: 8] = zigzag_in[54*8 +: 8]; // map[54]=39
assign inv_wire[46*8 +: 8] = zigzag_in[55*8 +: 8]; // map[55]=46
assign inv_wire[53*8 +: 8] = zigzag_in[56*8 +: 8]; // map[56]=53
assign inv_wire[60*8 +: 8] = zigzag_in[57*8 +: 8]; // map[57]=60
assign inv_wire[61*8 +: 8] = zigzag_in[58*8 +: 8]; // map[58]=61
assign inv_wire[54*8 +: 8] = zigzag_in[59*8 +: 8]; // map[59]=54
assign inv_wire[47*8 +: 8] = zigzag_in[60*8 +: 8]; // map[60]=47
assign inv_wire[55*8 +: 8] = zigzag_in[61*8 +: 8]; // map[61]=55
assign inv_wire[62*8 +: 8] = zigzag_in[62*8 +: 8]; // map[62]=62
assign inv_wire[63*8 +: 8] = zigzag_in[63*8 +: 8]; // map[63]=63

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            raster_out   <= 512'd0;
            inv_zz_done  <= 1'b0;
        end
        else begin
            inv_zz_done <= 1'b0;

            if (inv_zz_start) begin
                raster_out  <= inv_wire;
                inv_zz_done <= 1'b1;
            end
        end
    end

endmodule