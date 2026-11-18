`timescale 1ns/1ps
package cvt_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class cvt_item extends uvm_sequence_item;
        `uvm_object_utils(cvt_item)
        bit reset_request;
        bit short_reset_request;
        bit dc2cvt_dat_wr_en;
        bit [16:0] dc2cvt_dat_wr_addr;
        bit [63:0] dc2cvt_dat_wr_data;
        bit [11:0] dc2cvt_dat_wr_info_pd;
        bit img2cvt_dat_wr_en;
        bit [16:0] img2cvt_dat_wr_addr;
        bit [63:0] img2cvt_dat_wr_data;
        bit [127:0] img2cvt_mn_wr_data;
        bit [7:0] img2cvt_dat_wr_pad_mask;
        bit [11:0] img2cvt_dat_wr_info_pd;
        bit reg2dp_op_en;
        bit [1:0] reg2dp_in_precision;
        bit [1:0] reg2dp_proc_precision;
        bit reg2dp_cvt_en;
        bit [5:0] reg2dp_cvt_truncate;
        bit [15:0] reg2dp_cvt_offset;
        bit [15:0] reg2dp_cvt_scale;
        bit reg2dp_nan_to_zero;
        bit [15:0] reg2dp_pad_value;
        bit dp2reg_done;

        function new(string name="cvt_item");super.new(name);endfunction
    endclass
    class cvt_sequence extends uvm_sequence #(cvt_item);
        `uvm_object_utils(cvt_sequence)
        virtual cvt_if vif;
        function new(string name="cvt_sequence");super.new(name);endfunction
        task send_reset();
            cvt_item item=cvt_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task send(bit configure,bit op_enable,bit done,bit conversion,bit [1:0] traffic);
            cvt_item item=cvt_item::type_id::create("conversion_operation");
            if(vif.stop_requested)return;
            start_item(item);
            item.dc2cvt_dat_wr_en=$urandom;
            item.dc2cvt_dat_wr_addr[0+:17]=$urandom;
            item.dc2cvt_dat_wr_data[0+:32]=$urandom;
            item.dc2cvt_dat_wr_data[32+:32]=$urandom;
            item.dc2cvt_dat_wr_info_pd[0+:12]=$urandom;
            item.img2cvt_dat_wr_en=$urandom;
            item.img2cvt_dat_wr_addr[0+:17]=$urandom;
            item.img2cvt_dat_wr_data[0+:32]=$urandom;
            item.img2cvt_dat_wr_data[32+:32]=$urandom;
            item.img2cvt_mn_wr_data[0+:32]=$urandom;
            item.img2cvt_mn_wr_data[32+:32]=$urandom;
            item.img2cvt_mn_wr_data[64+:32]=$urandom;
            item.img2cvt_mn_wr_data[96+:32]=$urandom;
            item.img2cvt_dat_wr_pad_mask[0+:8]=$urandom;
            item.img2cvt_dat_wr_info_pd[0+:12]=$urandom;
            item.reg2dp_op_en=$urandom;
            item.reg2dp_in_precision[0+:2]=$urandom;
            item.reg2dp_proc_precision[0+:2]=$urandom;
            item.reg2dp_cvt_en=$urandom;
            item.reg2dp_cvt_truncate[0+:6]=$urandom;
            item.reg2dp_cvt_offset[0+:16]=$urandom;
            item.reg2dp_cvt_scale[0+:16]=$urandom;
            item.reg2dp_nan_to_zero=$urandom;
            item.reg2dp_pad_value[0+:16]=$urandom;
            item.dp2reg_done=$urandom;
            item.reg2dp_op_en=op_enable;item.dp2reg_done=done;item.reg2dp_cvt_en=conversion;
            if(!configure)begin
                item.reg2dp_cvt_offset=held_offset;item.reg2dp_cvt_scale=held_scale;item.reg2dp_cvt_truncate=held_shift;item.reg2dp_proc_precision=held_precision;item.reg2dp_pad_value=held_pad;
            end else begin held_offset=item.reg2dp_cvt_offset;held_scale=item.reg2dp_cvt_scale;held_shift=item.reg2dp_cvt_truncate;held_precision=item.reg2dp_proc_precision;held_pad=item.reg2dp_pad_value;end
            item.dc2cvt_dat_wr_en=(traffic==1);item.img2cvt_dat_wr_en=(traffic==2);
            item.dc2cvt_dat_wr_info_pd[3:0]=1;item.img2cvt_dat_wr_info_pd[3:0]=1;
            finish_item(item);
        endtask
        bit [15:0] held_offset,held_scale,held_pad;
        bit [5:0] held_shift;
        bit [1:0] held_precision;

        task rounding_step(bit operation_enable,bit done,int source,bit use_mean,int mean_value,int selected_lane,int address);
            cvt_item item=cvt_item::type_id::create("rounding_boundary");
            if(vif.stop_requested)return;
            start_item(item);
            item.reg2dp_op_en=operation_enable;
            item.dp2reg_done=done;
            item.reg2dp_cvt_en=1;
            item.reg2dp_cvt_offset=held_offset;
            item.reg2dp_cvt_scale=held_scale;
            item.reg2dp_cvt_truncate=held_shift;
            item.reg2dp_proc_precision=held_precision;
            item.reg2dp_pad_value=held_pad;
            item.dc2cvt_dat_wr_en=(source==1);
            item.img2cvt_dat_wr_en=(source==2);
            item.dc2cvt_dat_wr_addr=address;
            item.img2cvt_dat_wr_addr=address;
            item.dc2cvt_dat_wr_info_pd=use_mean?12'h081:12'h001;
            item.img2cvt_dat_wr_info_pd=use_mean?12'h081:12'h001;
            item.img2cvt_mn_wr_data[selected_lane*16+:16]=mean_value;
            finish_item(item);
        endtask
        task rounding_carry_boundaries();
            int direction,scale_value,mean_value,address;
            address=0;
            repeat(8200)send(0,0,1,0,0);
            for(int shift_value=2;shift_value<=6;shift_value++)begin
                for(int sign_case=0;sign_case<2;sign_case++)begin
                    direction=sign_case?-1:1;
                    scale_value=direction*(513<<(shift_value-2));
                    for(int precision_value=0;precision_value<4;precision_value++)begin
                        for(int mean_mode=0;mean_mode<2;mean_mode++)begin
                            repeat(12)rounding_step(0,1,0,0,0,0,address);
                            held_offset=mean_mode?0:-direction*511;
                            held_scale=scale_value;
                            held_shift=shift_value;
                            held_precision=precision_value;
                            held_pad=16'h005a;
                            rounding_step(1,0,0,0,0,0,address);
                            repeat(8)rounding_step(1,0,0,0,0,0,address);
                            for(int lane_index=0;lane_index<8;lane_index++)begin
                                for(int source_index=1;source_index<=2;source_index++)begin
                                    for(int neighbor=-1;neighbor<=1;neighbor++)begin
                                        mean_value=-direction*(511+neighbor);
                                        rounding_step(1,0,source_index,mean_mode,mean_value,lane_index,address);
                                        address++;
                                        repeat(8)rounding_step(1,0,0,0,0,0,address);
                                    end
                                end
                            end
                            repeat(12)rounding_step(1,0,0,0,0,0,address);
                        end
                    end
                end
            end
        endtask

        task restart_step(bit operation_enable,bit done,int source,int precision_value);
            cvt_item item=cvt_item::type_id::create("restart_operation");
            if(vif.stop_requested)return;
            start_item(item);
            item.reg2dp_op_en=operation_enable;
            item.dp2reg_done=done;
            item.reg2dp_cvt_en=1;
            item.reg2dp_cvt_offset=1;
            item.reg2dp_cvt_scale=1;
            item.reg2dp_proc_precision=precision_value;
            item.dc2cvt_dat_wr_en=(source==1);
            item.img2cvt_dat_wr_en=(source==2);
            item.dc2cvt_dat_wr_data=64'h0101010101010101;
            item.img2cvt_dat_wr_data=64'h0101010101010101;
            item.dc2cvt_dat_wr_info_pd=1;
            item.img2cvt_dat_wr_info_pd=1;
            item.dc2cvt_dat_wr_addr=17'h12345;
            item.img2cvt_dat_wr_addr=17'h12345;
            finish_item(item);
        endtask
        task short_reset_restart();
            cvt_item item;
            int completed_cases;
            completed_cases=0;
            for(int precision_value=0;precision_value<4;precision_value++)begin
                for(int source=1;source<=2;source++)begin
                    repeat(12)restart_step(0,1,0,precision_value);
                    repeat(12)restart_step(1,0,0,precision_value);
                    if(vif.stop_requested)return;
                    item=cvt_item::type_id::create("short_reset");
                    start_item(item);item.reset_request=1;item.short_reset_request=1;finish_item(item);
                    repeat(3)restart_step(1,0,0,precision_value);
                    restart_step(1,0,source,precision_value);
                    repeat(10)restart_step(1,0,0,precision_value);
                    if(!vif.stop_requested && vif.expected_cdma2buf_dat_wr_data !== 64'b0)
                        `uvm_error("PROBE_VACUITY","Restarted conversion must independently predict eight zero bytes")
                    completed_cases++;
                end
            end
            if(!vif.stop_requested && completed_cases!=8)
                `uvm_error("PROBE_VACUITY","Restart precision/source matrix incomplete")
        endtask

        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual cvt_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            repeat(8200)send(0,0,0,0,0);
            for(int operation=0;operation<64;operation++)begin
                repeat(12)send(0,0,1,0,0);
                send(1,1,0,operation%2,0);
                repeat(8)send(0,1,0,operation%2,0);
                for(int iteration=0;iteration<120;iteration++)send(0,1,0,operation%2,iteration%3);
                repeat(12)send(0,1,0,operation%2,0);
                repeat(2)send(0,1,1,operation%2,0);
                send(1,1,0,(operation+1)%2,0);
                repeat(8)send(0,1,0,(operation+1)%2,0);
                repeat(6)send(0,1,0,(operation+1)%2,2);
                repeat(12)send(0,1,0,(operation+1)%2,0);
                if(operation==17||operation==43)begin send_reset();repeat(8200)send(0,0,0,0,0);end
            end
            send_reset();repeat(10)send(0,0,0,0,0);
            rounding_carry_boundaries();
            short_reset_restart();

        endtask
    endclass
    class cvt_driver extends uvm_driver #(cvt_item);
        `uvm_component_utils(cvt_driver)
        virtual cvt_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cvt_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            cvt_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.nvdla_core_clk);
                if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.nvdla_core_rstn=0;
                    if(item.short_reset_request)begin
                        #2 vif.nvdla_core_rstn=1;
                    end else begin
                    repeat(3)@(posedge vif.nvdla_core_clk);
                    @(negedge vif.nvdla_core_clk);vif.nvdla_core_rstn=1;
                    end
                end else begin
                    vif.dc2cvt_dat_wr_en=item.dc2cvt_dat_wr_en;
                    vif.dc2cvt_dat_wr_addr=item.dc2cvt_dat_wr_addr;
                    vif.dc2cvt_dat_wr_data=item.dc2cvt_dat_wr_data;
                    vif.dc2cvt_dat_wr_info_pd=item.dc2cvt_dat_wr_info_pd;
                    vif.img2cvt_dat_wr_en=item.img2cvt_dat_wr_en;
                    vif.img2cvt_dat_wr_addr=item.img2cvt_dat_wr_addr;
                    vif.img2cvt_dat_wr_data=item.img2cvt_dat_wr_data;
                    vif.img2cvt_mn_wr_data=item.img2cvt_mn_wr_data;
                    vif.img2cvt_dat_wr_pad_mask=item.img2cvt_dat_wr_pad_mask;
                    vif.img2cvt_dat_wr_info_pd=item.img2cvt_dat_wr_info_pd;
                    vif.reg2dp_op_en=item.reg2dp_op_en;
                    vif.reg2dp_in_precision=item.reg2dp_in_precision;
                    vif.reg2dp_proc_precision=item.reg2dp_proc_precision;
                    vif.reg2dp_cvt_en=item.reg2dp_cvt_en;
                    vif.reg2dp_cvt_truncate=item.reg2dp_cvt_truncate;
                    vif.reg2dp_cvt_offset=item.reg2dp_cvt_offset;
                    vif.reg2dp_cvt_scale=item.reg2dp_cvt_scale;
                    vif.reg2dp_nan_to_zero=item.reg2dp_nan_to_zero;
                    vif.reg2dp_pad_value=item.reg2dp_pad_value;
                    vif.dp2reg_done=item.dp2reg_done;

                    @(posedge vif.nvdla_core_clk);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class cvt_sample extends uvm_sequence_item;
        `uvm_object_utils(cvt_sample)
        logic actual_cdma2buf_dat_wr_en;
        logic expected_cdma2buf_dat_wr_en;
        logic [16:0] actual_cdma2buf_dat_wr_addr;
        logic [16:0] expected_cdma2buf_dat_wr_addr;
        logic [63:0] actual_cdma2buf_dat_wr_data;
        logic [63:0] expected_cdma2buf_dat_wr_data;
        logic actual_slcg_hls_en;
        logic expected_slcg_hls_en;
        logic [31:0] actual_dp2reg_nan_data_num;
        logic [31:0] expected_dp2reg_nan_data_num;
        logic [31:0] actual_dp2reg_inf_data_num;
        logic [31:0] expected_dp2reg_inf_data_num;
        logic actual_dp2reg_dat_flush_done;
        logic expected_dp2reg_dat_flush_done;

        bit asynchronous_reset;
        function new(string name="cvt_sample");super.new(name);endfunction
    endclass
    class cvt_monitor extends uvm_monitor;
        `uvm_component_utils(cvt_monitor)
        virtual cvt_if vif;
        uvm_analysis_port #(cvt_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cvt_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            cvt_sample sample=cvt_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_cdma2buf_dat_wr_en=vif.cdma2buf_dat_wr_en;sample.expected_cdma2buf_dat_wr_en=vif.expected_cdma2buf_dat_wr_en;
                sample.actual_cdma2buf_dat_wr_addr=vif.cdma2buf_dat_wr_addr;sample.expected_cdma2buf_dat_wr_addr=vif.expected_cdma2buf_dat_wr_addr;
                sample.actual_cdma2buf_dat_wr_data=vif.cdma2buf_dat_wr_data;sample.expected_cdma2buf_dat_wr_data=vif.expected_cdma2buf_dat_wr_data;
                sample.actual_slcg_hls_en=vif.slcg_hls_en;sample.expected_slcg_hls_en=vif.expected_slcg_hls_en;
                sample.actual_dp2reg_nan_data_num=vif.dp2reg_nan_data_num;sample.expected_dp2reg_nan_data_num=vif.expected_dp2reg_nan_data_num;
                sample.actual_dp2reg_inf_data_num=vif.dp2reg_inf_data_num;sample.expected_dp2reg_inf_data_num=vif.expected_dp2reg_inf_data_num;
                sample.actual_dp2reg_dat_flush_done=vif.dp2reg_dat_flush_done;sample.expected_dp2reg_dat_flush_done=vif.expected_dp2reg_dat_flush_done;

                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.nvdla_core_clk);sample_ports(0);end
                forever begin @(negedge vif.nvdla_core_rstn);sample_ports(1);end
            join
        endtask
    endclass
    class cvt_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(cvt_scoreboard)
        virtual cvt_if vif;
        uvm_analysis_imp #(cvt_sample,cvt_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual cvt_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(cvt_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_cdma2buf_dat_wr_en!==sample.expected_cdma2buf_dat_wr_en)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("cdma2buf_dat_wr_en=%h/%h async_reset=%b",sample.actual_cdma2buf_dat_wr_en,sample.expected_cdma2buf_dat_wr_en,sample.asynchronous_reset))end
            checks++;if(sample.actual_cdma2buf_dat_wr_addr!==sample.expected_cdma2buf_dat_wr_addr)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("cdma2buf_dat_wr_addr=%h/%h async_reset=%b",sample.actual_cdma2buf_dat_wr_addr,sample.expected_cdma2buf_dat_wr_addr,sample.asynchronous_reset))end
            checks++;if(sample.actual_cdma2buf_dat_wr_data!==sample.expected_cdma2buf_dat_wr_data)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("cdma2buf_dat_wr_data=%h/%h async_reset=%b",sample.actual_cdma2buf_dat_wr_data,sample.expected_cdma2buf_dat_wr_data,sample.asynchronous_reset))end
            checks++;if(sample.actual_slcg_hls_en!==sample.expected_slcg_hls_en)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("slcg_hls_en=%h/%h async_reset=%b",sample.actual_slcg_hls_en,sample.expected_slcg_hls_en,sample.asynchronous_reset))end
            checks++;if(sample.actual_dp2reg_nan_data_num!==sample.expected_dp2reg_nan_data_num)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("dp2reg_nan_data_num=%h/%h async_reset=%b",sample.actual_dp2reg_nan_data_num,sample.expected_dp2reg_nan_data_num,sample.asynchronous_reset))end
            checks++;if(sample.actual_dp2reg_inf_data_num!==sample.expected_dp2reg_inf_data_num)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("dp2reg_inf_data_num=%h/%h async_reset=%b",sample.actual_dp2reg_inf_data_num,sample.expected_dp2reg_inf_data_num,sample.asynchronous_reset))end
            checks++;if(sample.actual_dp2reg_dat_flush_done!==sample.expected_dp2reg_dat_flush_done)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("dp2reg_dat_flush_done=%h/%h async_reset=%b",sample.actual_dp2reg_dat_flush_done,sample.expected_dp2reg_dat_flush_done,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<200000 || reset_checks<3))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class cvt_env extends uvm_env;
        `uvm_component_utils(cvt_env)
        uvm_sequencer #(cvt_item) sequencer;
        cvt_driver driver;
        cvt_monitor monitor;
        cvt_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(cvt_item)::type_id::create("sequencer",this);
            driver=cvt_driver::type_id::create("driver",this);
            monitor=cvt_monitor::type_id::create("monitor",this);
            scoreboard=cvt_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        cvt_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=cvt_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            cvt_sequence sequence_instance=cvt_sequence::type_id::create("sequence_instance");
            phase.raise_objection(this);sequence_instance.start(env.sequencer);#20;phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server server=uvm_report_server::get_server();
            super.report_phase(phase);
            `uvm_info("CHECK_COUNTS",$sformatf("checks=%0d failures=%0d reset_checks=%0d",env.scoreboard.checks,env.scoreboard.failures,env.scoreboard.reset_checks),UVM_NONE)
            if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)$display("DVBench_COMPLETED");
        endfunction
    endclass
endpackage
