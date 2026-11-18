module model_replay_tb;
    logic clock = 1'b0;
    logic rst_n = 1'b0;
    logic [3:0] wr_data = '0;
    logic wr_vld = 1'b0;
    logic wr_last = 1'b0;
    logic wr_align_last = 1'b0;
    logic rd_ready = 1'b0;
    logic dut_wr_ready;
    logic dut_rd_vld;
    logic [7:0] dut_rd_data;
    logic dut_rd_last;
    logic model_wr_ready;
    logic model_rd_vld;
    logic [7:0] model_rd_data;
    logic model_rd_last;
    integer seed_value;
    integer seed_state;
    integer cycle_index;
    integer mismatch_count = 0;
    integer input_checksum = 32'h13579bdf;
    integer driver_pair_pending = 0;
    integer random_word;

    always #5 clock = ~clock;

    width_convert #(.ISIZE(4), .OSIZE(8)) dut (
        .clock(clock), .rst_n(rst_n), .wr_data(wr_data), .wr_vld(wr_vld),
        .wr_ready(dut_wr_ready), .wr_last(wr_last), .wr_align_last(wr_align_last),
        .rd_data(dut_rd_data), .rd_vld(dut_rd_vld), .rd_ready(rd_ready), .rd_last(dut_rd_last)
    );

    dvbench_model #(.ISIZE(4), .OSIZE(8)) model (
        .clock(clock), .rst_n(rst_n), .wr_data(wr_data), .wr_vld(wr_vld),
        .wr_ready(model_wr_ready), .wr_last(wr_last), .wr_align_last(wr_align_last),
        .rd_data(model_rd_data), .rd_vld(model_rd_vld), .rd_ready(rd_ready), .rd_last(model_rd_last)
    );

    initial begin
        if (!$value$plusargs("seed=%d", seed_value)) seed_value = 1;
        seed_state = seed_value;
        repeat (3) @(posedge clock);
        @(negedge clock);
        rst_n = 1'b1;
        for (cycle_index = 0; cycle_index < 512; cycle_index = cycle_index + 1) begin
            @(negedge clock);
            random_word = $urandom(seed_state);
            wr_data = random_word[11:8];
            wr_vld = random_word[0];
            rd_ready = random_word[1];
            wr_align_last = random_word[4] && random_word[5];
            wr_last = driver_pair_pending && random_word[2] && !wr_align_last;
            input_checksum = (input_checksum * 33) ^ random_word ^ cycle_index;
            @(posedge clock);
            #1;
            if (dut_wr_ready !== model_wr_ready) mismatch_count = mismatch_count + 1;
            if (dut_rd_vld !== model_rd_vld) mismatch_count = mismatch_count + 1;
            if (dut_rd_vld && (dut_rd_data !== model_rd_data || dut_rd_last !== model_rd_last)) mismatch_count = mismatch_count + 1;
            if (wr_vld && dut_wr_ready) begin
                if (wr_align_last || wr_last) driver_pair_pending = 0;
                else driver_pair_pending = !driver_pair_pending;
            end
        end
        @(negedge clock);
        wr_vld = 1'b0;
        wr_last = 1'b0;
        wr_align_last = 1'b0;
        rd_ready = 1'b1;
        repeat (6) @(posedge clock);
        #1;
        if (dut_rd_vld !== model_rd_vld) mismatch_count = mismatch_count + 1;
        $display("MODEL_REPLAY seed=%0d checksum=%0d mismatches=%0d", seed_value, input_checksum, mismatch_count);
        if (mismatch_count != 0) $fatal(1, "MODEL_MISMATCH");
        $display("DVBench_MODEL_COMPLETED");
        $finish;
    end
endmodule
