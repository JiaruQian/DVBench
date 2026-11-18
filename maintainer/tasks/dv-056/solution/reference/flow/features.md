# feature_id

## F1

- requirement_ids: R-bb8eef11f6a971-001
- module: decoder_top
- definition: rst_n is an active-low asynchronous reset that clears dec_done, trigger_dec, total_bits_consumed, and all RGB outputs to zero; reset cancels in-flight transactions. dec_start is high for only one rising edge while idle; the three bitstreams, lengths, and block_num remain stable from acceptance to completion. Lengths are 0..1024, and all read indices must be within 1024 bits; each channel contains no more than 64 run/amplitude records (EOB also counts as one record), expanding to no more than 64 coefficients. Neither completion nor numerical values are guaranteed for over-capacity records, illegal codes, overlapping starts, or unstable streams.
- interface: clk, rst_n, dec_start, bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, block_num, R_out, G_out, B_out, dec_done, trigger_dec, total_bits_consumed
- timing: Reset may be asserted between clock edges; restart after deassertion. Complete tasks are serialized.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F2

- requirement_ids: R-bb8eef11f6a971-002
- module: decoder_top
- definition: Each of the three channels reads bit by bit starting from bs_*[0], with the first bit read serving as the most significant bit of the codeword. Use the fixed code table below to match the first complete code. The high 4 bits of symbol are run, and the low 4 bits are category. 0x00 is EOB; 0xf0 is 16 zeros. For category>0, continue reading category bits to form an 8-bit shift buffer v (retain the last 8 bits if more than 8 bits are read), and mask is the low 8 bits of (2^category-1); for category1..8, take v&mask if bit category-1 of v is 1; otherwise take the low 8 bits of (v&mask)-mask and interpret them as signed. category9/10 takes the else branch because the index exceeds 8 bits.
- interface: dec_start, bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, total_bits_consumed
- timing: The code table defines the symbol facts; the input length is allowed to end at a code boundary, and unfilled coefficients are 0.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F3

- requirement_ids: R-bb8eef11f6a971-003
- module: decoder_top
- definition: run denotes the number of zeros inserted before the amplitude; decoding terminates when a decoded record has run=0 and a truncated 8-bit amplitude of 0 (including EOB, and also category9/10 that becomes exactly 0 after truncation), and the remaining coefficients are zero-filled; Huffman continues reading according to its own bitstream, and stopped RLE never resumes. 0xf0 inserts 15 zeros and then writes one zero; each channel is arranged into 8x8 row-major coefficients according to the zigzag-to-raster index table below, with the low byte corresponding to raster0.
- interface: dec_start, bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, R_out, G_out, B_out
- timing: 8-bit coefficients use signed two's complement; both record capacity and expansion capacity follow the transaction domain.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F4

- requirement_ids: R-bb8eef11f6a971-004
- module: decoder_top
- definition: When the raster diagonal 0/9/18/27/36/45/54/63 of the Y block with block_num=0 equals -127,84,94,35,30,10,13,10 in order, trigger_dec is set to 1; before that, if it is not block 0 or does not match, it retains its previous value. Once set to 1, it remains set until reset.
- interface: clk, rst_n, block_num, bs_Y, bs_len_Y, trigger_dec
- timing: The trigger takes effect after Y inverse scanning completes, affecting the current and subsequent transactions; Cb/Cr do not participate in triggering.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F5

- requirement_ids: R-bb8eef11f6a971-005
- module: decoder_top
- definition: When trigger_dec is active, add 1 to each Y coefficient, leaving an original value of 127 at 127; for other values, add 1 as an 8-bit signed value. When trigger_dec is inactive, Y is unchanged. Cb/Cr are never modified.
- interface: clk, rst_n, bs_Y, trigger_dec, R_out, G_out, B_out
- timing: The current Y block that matches the trigger is also modified; the trigger is no longer inherited after reset.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F6

- requirement_ids: R-bb8eef11f6a971-006
- module: decoder_top
- definition: Each raster entry of the three channels is multiplied by the unsigned 8-bit constant at the same index in the Q table below; coefficients are interpreted as signed 8-bit values, and the products are treated as signed 16-bit values.
- interface: bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, R_out, G_out, B_out
- timing: The Q table is the same for Y/Cb/Cr, and all 64 coefficients participate.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F7

- requirement_ids: R-bb8eef11f6a971-007
- module: decoder_top
- definition: First apply the one-dimensional T(w=16) below to each column, retaining each result as a signed 25-bit value; then apply T(w=25) to each row, also retaining each result in 25 bits. Arithmetically right-shift the second result by 6 and take a signed 9-bit value, then add 128 and clamp to 0..255.
- interface: bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, R_out, G_out, B_out
- timing: wrap_w means retaining the low w bits and interpreting them as signed; right shifts are arithmetic shifts, with no substitution of a floating-point IDCT.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F8

- requirement_ids: R-bb8eef11f6a971-008
- module: decoder_top
- definition: For each pixel, R=clip((256*Y+359*(Cr-128))>>>8), G=clip((256*Y-88*(Cb-128)-183*(Cr-128))>>>8), B=clip((256*Y+454*(Cb-128))>>>8), where clip clamps to 0..255. The low output byte corresponds to raster0.
- interface: bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, R_out, G_out, B_out, dec_done
- timing: All multiply-add operations are within the signed 20-bit range; whole-block RGB values are guaranteed only during the dec_done=1 window, and partial outputs during conversion need not be compared.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F9

- requirement_ids: R-bb8eef11f6a971-009
- module: decoder_top
- definition: dec_done is a completion pulse lasting one rising-edge update cycle. total_bits_consumed is the number of bits actually read by the Y channel, including Huffman codes and amplitudes, and including the EOB code; after being updated, it holds until the next Y decoding completes or reset.
- interface: dec_start, bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, dec_done, total_bits_consumed
- timing: Cb/Cr lengths may differ; completion must wait until all three channels have reconstructed their pixels, and must not be lost because Y finishes first.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

## F10

- requirement_ids: R-bb8eef11f6a971-010
- module: decoder_top
- definition: The acceptance edge is age0. For each channel, h is 2 times the total number of Huffman code bits read, plus category+2 for each record with category>0, plus 1 for EOB; add another 2 if the length is exhausted without EOB. r is the sum of run+1 for the records other than the zero-termination record before RLE stops, plus 2; if no record with run=0 and 8-bit amplitude=0 occurs, likewise add 2 when the records are exhausted. Let i=h+r+2; then completion occurs at age=max(iY+225,iCb+160,iCr+160)+66, the Y bit count updates at age=hY+1, and the trigger match updates at age=iY+1.
- interface: clk, rst_n, dec_start, bs_Y, bs_len_Y, bs_Cb, bs_len_Cb, bs_Cr, bs_len_Cr, block_num, R_out, G_out, B_out, dec_done, trigger_dec, total_bits_consumed
- timing: This timing is guaranteed only for legal, complete bitstreams within the transaction domain; asynchronous reset need not wait for completion.
- boundary: The legal domain and valid windows in this item govern; do not zero-fill unspecified windows.

