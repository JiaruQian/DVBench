# decoder_top Behavioral Specification

The fixed native complete top level is decoder_top; there are no top-level parameters. All inputs/outputs interact only through ports. Sample stable values after the rising edge.

### R-bb8eef11f6a971-001 — Reset and transaction domain

rst_n is an active-low asynchronous reset that clears dec_done, trigger_dec, total_bits_consumed, and all RGB outputs to zero; reset cancels in-flight transactions. dec_start is high for only one rising edge while idle; the three bitstreams, lengths, and block_num remain stable from acceptance through completion. Lengths are 0..1024, and all read indices must be within 1024 bits; each stream contains no more than 64 run/amplitude records (EOB also counts as one record), expanding to no more than 64 coefficients. No completion or numerical guarantees are made for records exceeding capacity, illegal codes, overlapping starts, or unstable streams.

Reset may be asserted between clock edges, with a fresh start after deassertion; complete tasks are serialized.

### R-bb8eef11f6a971-002 — Huffman and amplitude

The three streams are each read bit by bit starting at bs_*[0], with the first bit read serving as the most significant bit of the codeword. Match the first complete code using the fixed code table below. The upper 4 bits of symbol are run, and the lower 4 bits are category. 0x00 is EOB; 0xf0 represents 16 zeros. For category>0, continue reading category bits to form an 8-bit shift buffer v (retaining the last 8 bits when more than 8 bits are read), with mask being the low 8 bits of (2^category-1); for category1..8, take v&mask if bit category-1 of v is 1; otherwise take the low 8 bits of (v&mask)-mask and interpret them as signed. category9/10 follows the else branch because the index is outside 8 bits.

The code table defines the symbol facts; input lengths may end at code boundaries, and unfilled coefficients are 0.

### R-bb8eef11f6a971-003 — RLE and inverse scan

run indicates the number of zeros inserted before the amplitude; decoding ends when a decoded record has run=0 and its truncated 8-bit amplitude is 0 (including EOB, and also category9/10 that becomes exactly 0 after truncation), with the remaining coefficients zero-filled; Huffman continues reading according to its own bitstream, and stopped RLE never resumes. 0xf0 inserts 15 zeros and then writes one zero; each stream is arranged into 8x8 row-major coefficients according to the zigzag-to-raster index table below, with the low byte being raster0.

8-bit coefficients use signed two's complement; record and expansion capacities both follow the transaction domain.

### R-bb8eef11f6a971-004 — Steganographic trigger

When the Y block with block_num=0 has raster diagonal entries 0/9/18/27/36/45/54/63 equal in order to -127,84,94,35,30,10,13,10, trigger_dec is set to 1; before that, if the block is not block 0 or does not match, it retains its previous value. Once set to 1, it remains set until reset.

The trigger takes effect after the Y inverse scan ends, affecting the current and subsequent transactions; Cb/Cr do not participate in triggering.

### R-bb8eef11f6a971-005 — Y payload modification

When trigger_dec is active, add 1 to every Y coefficient, except that an original value of 127 remains 127; for other values, add 1 as an 8-bit signed value. When trigger_dec is inactive, Y is unchanged. Cb/Cr are never modified.

The current Y block that matches the trigger is also modified; the trigger is no longer carried over after reset.

### R-bb8eef11f6a971-006 — Dequantization

Each raster entry in the three streams is multiplied by the unsigned 8-bit constant at the same index in the Q table below; coefficients are interpreted as signed 8-bit values, and the product is a signed 16-bit value.

The Q table is the same for Y/Cb/Cr, and all 64 coefficients participate.

### R-bb8eef11f6a971-007 — Fixed integer two-dimensional transform

First apply the one-dimensional T(w=16) below to each column, retaining each result as a signed 25-bit value; then apply T(w=25) to each row, also retaining each result as 25 bits. Arithmetically right-shift the second-pass results by 6, take a signed 9-bit value, then add 128 and clamp to 0..255.

wrap_w means retaining the low w bits and interpreting them as signed; right shifts are arithmetic shifts, and no floating-point IDCT substitution is allowed.

### R-bb8eef11f6a971-008 — RGB conversion

For each pixel, R=clip((256*Y+359*(Cr-128))>>>8), G=clip((256*Y-88*(Cb-128)-183*(Cr-128))>>>8), B=clip((256*Y+454*(Cb-128))>>>8), where clip clamps to 0..255. The low output byte corresponds to raster0.

All multiplications and additions are within the signed 20-bit range; whole-block numerical guarantees for RGB apply only during the dec_done=1 window, and partial outputs during conversion need not be compared.

### R-bb8eef11f6a971-009 — Completion and consumed bit count

dec_done is a completion pulse lasting one rising-edge update cycle. total_bits_consumed is the number of bits actually read by the Y channel, including Huffman codes and amplitudes, and including the EOB code; after being updated, it holds until the next Y decoding completes or reset.

Cb/Cr lengths may differ; completion must wait until all three channels have reconstructed their pixels, and must not be lost because Y finishes first.

### R-bb8eef11f6a971-010 — Native Timing

The acceptance edge is age0. For each channel, h is 2 times the total number of Huffman code bits read, plus category+2 for each record with category>0, plus 1 for EOB; add another 2 if the length is exhausted without EOB. r is the sum of run+1 for each nonzero-termination record before RLE stops, plus 2; if no record with run=0 and 8-bit amplitude=0 occurs, likewise add 2 when the records are exhausted. Let i=h+r+2; completion is then at age=max(iY+225,iCb+160,iCr+160)+66, the Y bit count is updated at age=hY+1, and the trigger match is updated at age=iY+1.

This timing is guaranteed only for legal, complete bitstreams within the transaction domain; asynchronous reset need not wait for completion.

## One-Dimensional Transform T

Let the inputs be x0..x7; all variables are signed. a0/a1=wrap_(w+1)(x0±x4), a2=wrap_(w+9)((90*x2)>>>7), and a3 uses the same expression with x6; a4/a7=wrap_(w+1)(x1±x7), a5/a6=wrap_(w+1)(x3±x5). b0=a0+a2, b1=a1+a3, b2=a1-a3, b3=a0-a2; b4=(49*a4+118*a7)>>>7, b5=(118*a5+49*a6)>>>7, b6=(118*a6-49*a5)>>>7, b7=(49*a7-118*a4)>>>7; apply wrap_(w+10) to each b. For j=0..3, zj=wrap_25(wrap_(w+11)(bj+b(j+4))), z(7-j)=wrap_25(wrap_(w+11)(bj-b(j+4))).

## Fixed Code Table

Symbols are represented in hexadecimal; codewords retain leading zeros according to their actual lengths.

|symbol|code|
|---|---|
|00|1010|
|01|00|
|02|01|
|03|100|
|04|1011|
|05|11010|
|06|1111000|
|07|11111000|
|08|1111110110|
|09|1111111110000010|
|0a|1111111110000011|
|11|1100|
|12|11011|
|13|1111001|
|14|111110110|
|15|11111110110|
|16|1111111110000100|
|17|1111111110000101|
|18|1111111110000110|
|19|1111111110000111|
|1a|1111111110001000|
|21|11100|
|22|11111001|
|23|1111110111|
|24|111111110100|
|25|1111111110001001|
|26|1111111110001010|
|27|1111111110001011|
|28|1111111110001100|
|29|1111111110001101|
|2a|1111111110001110|
|31|111010|
|32|111110111|
|33|111111110101|
|34|1111111110001111|
|35|1111111110010000|
|36|1111111110010001|
|37|1111111110010010|
|38|1111111110010011|
|39|1111111110010100|
|3a|1111111110010101|
|41|111011|
|42|1111111000|
|43|1111111110010110|
|44|1111111110010111|
|45|1111111110011000|
|46|1111111110011001|
|47|1111111110011010|
|48|1111111110011011|
|49|1111111110011100|
|4a|1111111110011101|
|51|1111010|
|52|11111110111|
|53|1111111110011110|
|54|1111111110011111|
|55|1111111110100000|
|56|1111111110100001|
|57|1111111110100010|
|58|1111111110100011|
|59|1111111110100100|
|5a|1111111110100101|
|61|1111011|
|62|111111110110|
|63|1111111110100110|
|64|1111111110100111|
|65|1111111110101000|
|66|1111111110101001|
|67|1111111110101010|
|68|1111111110101011|
|69|1111111110101100|
|6a|1111111110101101|
|71|11111010|
|72|111111110111|
|73|1111111110101110|
|74|1111111110101111|
|75|1111111110110000|
|76|1111111110110001|
|77|1111111110110010|
|78|1111111110110011|
|79|1111111110110100|
|7a|1111111110110101|
|81|111111000|
|82|111111111000000|
|83|1111111110110110|
|84|1111111110110111|
|85|1111111110111000|
|86|1111111110111001|
|87|1111111110111010|
|88|1111111110111011|
|89|1111111110111100|
|8a|1111111110111101|
|91|111111001|
|92|1111111110111110|
|93|1111111110111111|
|94|1111111111000000|
|95|1111111111000001|
|96|1111111111000010|
|97|1111111111000011|
|98|1111111111000100|
|99|1111111111000101|
|9a|1111111111000110|
|a1|111111010|
|a2|1111111111000111|
|a3|1111111111001000|
|a4|1111111111001001|
|a5|1111111111001010|
|a6|1111111111001011|
|a7|1111111111001100|
|a8|1111111111001101|
|a9|1111111111001110|
|aa|1111111111001111|
|b1|1111111001|
|b2|1111111111010000|
|b3|1111111111010001|
|b4|1111111111010010|
|b5|1111111111010011|
|b6|1111111111010100|
|b7|1111111111010101|
|b8|1111111111010110|
|b9|1111111111010111|
|ba|1111111111011000|
|c1|1111111010|
|c2|1111111111011001|
|c3|1111111111011010|
|c4|1111111111011011|
|c5|1111111111011100|
|c6|1111111111011101|
|c7|1111111111011110|
|c8|1111111111011111|
|c9|1111111111100000|
|ca|1111111111100001|
|d1|11111111000|
|d2|1111111111100010|
|d3|1111111111100011|
|d4|1111111111100100|
|d5|1111111111100101|
|d6|1111111111100110|
|d7|1111111111100111|
|d8|1111111111101000|
|d9|1111111111101001|
|da|1111111111101010|
|e1|1111111111101011|
|e2|1111111111101100|
|e3|1111111111101101|
|e4|1111111111101110|
|e5|1111111111101111|
|e6|1111111111110000|
|e7|1111111111110001|
|e8|1111111111110010|
|e9|1111111111110011|
|ea|1111111111110100|
|f0|11111111001|
|f1|1111111111110101|
|f2|1111111111110110|
|f3|1111111111110111|
|f4|1111111111111000|
|f5|1111111111111001|
|f6|1111111111111010|
|f7|1111111111111011|
|f8|1111111111111100|
|f9|1111111111111101|
|fa|1111111111111110|

## Fixed Q Table and Scan Order

Q in raster0..63 order is: 16, 11, 10, 16, 24, 40, 51, 61, 12, 12, 14, 19, 26, 58, 60, 55, 14, 13, 16, 24, 40, 57, 69, 56, 14, 17, 22, 29, 51, 87, 80, 62, 18, 22, 37, 56, 68, 109, 103, 77, 24, 35, 55, 64, 81, 104, 113, 92, 49, 64, 78, 87, 103, 121, 120, 101, 72, 92, 95, 98, 112, 100, 103, 99.

The raster indices corresponding to zigzag indices 0..63 are: 0, 1, 8, 16, 9, 2, 3, 10, 17, 24, 32, 25, 18, 11, 4, 5, 12, 19, 26, 33, 40, 48, 41, 34, 27, 20, 13, 6, 7, 14, 21, 28, 35, 42, 49, 56, 57, 50, 43, 36, 29, 22, 15, 23, 30, 37, 44, 51, 58, 59, 52, 45, 38, 31, 39, 46, 53, 60, 61, 54, 47, 55, 62, 63.
