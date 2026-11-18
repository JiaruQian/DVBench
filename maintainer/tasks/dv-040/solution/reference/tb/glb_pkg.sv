`timescale 1ns/1ps
package glb_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class glb_item extends uvm_sequence_item;
        `uvm_object_utils(glb_item)
        int reset_domain;
        bit valid,write_enable,nonposted;
        bit [21:0] address;
        bit [31:0] data;
        bit [11:0] events;
        bit [6:0] ignored;
        function new(string name="glb_item"); super.new(name); endfunction
    endclass
    class glb_sequence extends uvm_sequence #(glb_item);
        `uvm_object_utils(glb_sequence)
        virtual glb_if vif;
        function new(string name="glb_sequence"); super.new(name); endfunction
        task request(bit valid,bit write_enable,bit nonposted,bit [21:0] address,bit [31:0] data,bit [11:0] events);
            glb_item item=glb_item::type_id::create("request");
            if(vif.stop_requested) return;
            start_item(item);
            item.valid=valid;
            item.write_enable=write_enable;
            item.nonposted=nonposted;
            item.address=address;
            item.data=data;
            item.events=events;
            item.ignored=$urandom;
            finish_item(item);
        endtask
        task reset_domain(int domain);
            glb_item item=glb_item::type_id::create("reset");
            if(vif.stop_requested) return;
            start_item(item);
            item.reset_domain=domain;
            finish_item(item);
        endtask
        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual glb_if)::get(null,"","vif",vif)) `uvm_fatal("CONFIG","Missing sequence interface")
            reset_domain(3);
            for(int source_index=0;source_index<12;source_index++) begin
                request(1,1,1,1,0,0);
                request(1,1,1,3,32'hffffffff,0);
                request(0,0,0,0,0,12'b1<<source_index);
                repeat(5) request(0,0,0,0,0,0);
                request(1,0,0,3,0,0);
                repeat(5) request(0,0,0,0,0,0);
                request(1,1,1,1,32'b1<<(source_index<6?source_index:source_index+10),0);
                repeat(8) request(0,0,0,0,0,0);
                request(1,1,0,1,0,0);
                repeat(8) request(0,0,0,0,0,0);
                request(1,1,1,1,32'hffffffff,0);
                repeat(8) request(0,0,0,0,0,0);
                request(1,1,0,1,0,0);
                repeat(8) request(0,0,0,0,0,0);
                request(1,1,1,3,32'hffffffff,12'b1<<source_index);
                repeat(4) request(0,0,0,0,0,12'b1<<source_index);
                request(1,0,0,3,0,0);
                request(1,1,1,3,32'hffffffff,0);
                repeat(8) request(0,0,0,0,0,0);
            end
            for(int iteration=0;iteration<5000;iteration++) begin
                random_value=$urandom;
                request(random_value[0],random_value[1],random_value[2],random_value[6:3]<12?random_value[4:3]:22'habcde,$urandom,$urandom);
                if(iteration==1211) reset_domain(1);
                if(iteration==2771) reset_domain(2);
            end
            for(int address=0;address<4;address++) begin
                request(1,0,0,22'h1ffc00|address,0,0);
                request(1,1,1,22'h1ffc00|address,32'hffffffff,0);
                request(1,0,0,address,0,0);
            end
            for(int source_index=0;source_index<12;source_index++) begin
                reset_domain(3);
                request(0,0,0,0,0,12'b1<<source_index);
                reset_domain(4);
                repeat(5) request(0,0,0,0,0,0);
                request(1,0,0,3,0,0);
                repeat(8) request(0,0,0,0,0,0);
            end
            reset_domain(3);
            repeat(20) request(0,0,0,0,0,0);
        endtask
    endclass
    class glb_driver extends uvm_driver #(glb_item);
        `uvm_component_utils(glb_driver)
        virtual glb_if vif;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual glb_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            glb_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.nvdla_core_clk);
                if(item.reset_domain==4) begin
                    vif.checking=1;
                    #1;
                    vif.nvdla_core_rstn=0;
                    vif.csb2glb_req_pvld=0;
                    {vif.cacc2glb_done_intr_pd,vif.cdma_wt2glb_done_intr_pd,vif.cdma_dat2glb_done_intr_pd,vif.pdp2glb_done_intr_pd,vif.cdp2glb_done_intr_pd,vif.sdp2glb_done_intr_pd}=0;
                    #1;
                    vif.nvdla_core_rstn=1;
                end else if(item.reset_domain!=0) begin
                    vif.checking=1;
                    #2;
                    if(item.reset_domain&1) vif.nvdla_core_rstn=0;
                    if(item.reset_domain&2) vif.nvdla_falcon_rstn=0;
                    vif.csb2glb_req_pvld=1;
                    vif.csb2glb_req_pd={7'b0,1'b1,1'b1,32'hffffffff,22'd2};
                    repeat(4) @(posedge vif.nvdla_core_clk);
                    @(negedge vif.nvdla_core_clk);
                    if(item.reset_domain&1) vif.nvdla_core_rstn=1;
                    if(item.reset_domain&2) vif.nvdla_falcon_rstn=1;
                    vif.csb2glb_req_pvld=0;
                end else begin
                    vif.csb2glb_req_pvld=item.valid;
                    vif.csb2glb_req_pd={item.ignored,item.nonposted,item.write_enable,item.data,item.address};
                    {vif.cacc2glb_done_intr_pd,vif.cdma_wt2glb_done_intr_pd,vif.cdma_dat2glb_done_intr_pd,vif.pdp2glb_done_intr_pd,vif.cdp2glb_done_intr_pd,vif.sdp2glb_done_intr_pd}=item.events;
                    vif.direct_reset_=~vif.direct_reset_;
                    vif.test_mode=~vif.test_mode;
                    @(posedge vif.nvdla_core_clk);
                    #2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class glb_sample extends uvm_sequence_item;
        `uvm_object_utils(glb_sample)
        logic actual_intr,actual_ready,actual_valid,expected_intr,expected_ready,expected_valid;
        logic [33:0] actual_data,expected_data;
        bit asynchronous_reset;
        function new(string name="glb_sample"); super.new(name); endfunction
    endclass
    class glb_monitor extends uvm_monitor;
        `uvm_component_utils(glb_monitor)
        virtual glb_if vif;
        uvm_analysis_port #(glb_sample) samples;
        function new(string name,uvm_component parent); super.new(name,parent); samples=new("samples",this); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual glb_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            glb_sample sample=glb_sample::type_id::create("sample");
            #1;
            if(vif.checking) begin
                sample.actual_intr=vif.core_intr;
                sample.actual_ready=vif.csb2glb_req_prdy;
                sample.actual_valid=vif.glb2csb_resp_valid;
                sample.actual_data=vif.glb2csb_resp_pd;
                sample.expected_intr=vif.expected_core_intr;
                sample.expected_ready=vif.expected_csb2glb_req_prdy;
                sample.expected_valid=vif.expected_glb2csb_resp_valid;
                sample.expected_data=vif.expected_glb2csb_resp_pd;
                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.nvdla_core_clk or posedge vif.nvdla_falcon_clk); sample_ports(0); end
                forever begin @(negedge vif.nvdla_core_rstn or negedge vif.nvdla_falcon_rstn); sample_ports(1); end
            join
        endtask
    endclass
    class glb_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(glb_scoreboard)
        virtual glb_if vif;
        uvm_analysis_imp #(glb_sample,glb_scoreboard) samples;
        int unsigned checks,failures,reset_checks,valid_checks;
        function new(string name,uvm_component parent); super.new(name,parent); samples=new("samples",this); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual glb_if)::get(this,"","vif",vif)) `uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(glb_sample sample);
            checks+=4;
            reset_checks+=sample.asynchronous_reset;
            valid_checks+=sample.expected_valid===1'b1;
            if(sample.actual_intr!==sample.expected_intr || sample.actual_ready!==sample.expected_ready || sample.actual_valid!==sample.expected_valid || sample.actual_data!==sample.expected_data) begin
                failures++;
                vif.stop_requested=1;
                if(failures<=20) `uvm_error("NATIVE_MISMATCH",$sformatf("intr=%b/%b ready=%b/%b valid=%b/%b response=%h/%h async_reset=%b",sample.actual_intr,sample.expected_intr,sample.actual_ready,sample.expected_ready,sample.actual_valid,sample.expected_valid,sample.actual_data,sample.expected_data,sample.asynchronous_reset))
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<30000 || reset_checks<3 || valid_checks<1000)) `uvm_error("VACUOUS","Required native comparison windows did not execute")
            if(failures>20) `uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class glb_env extends uvm_env;
        `uvm_component_utils(glb_env)
        uvm_sequencer #(glb_item) sequencer;
        glb_driver driver;
        glb_monitor monitor;
        glb_scoreboard scoreboard;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(glb_item)::type_id::create("sequencer",this);
            driver=glb_driver::type_id::create("driver",this);
            monitor=glb_monitor::type_id::create("monitor",this);
            scoreboard=glb_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        glb_env env;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase); super.build_phase(phase); env=glb_env::type_id::create("env",this); endfunction
        task run_phase(uvm_phase phase);
            glb_sequence sequence_instance=glb_sequence::type_id::create("sequence_instance");
            phase.raise_objection(this);
            sequence_instance.start(env.sequencer);
            #20;
            phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server server=uvm_report_server::get_server();
            super.report_phase(phase);
            `uvm_info("CHECK_COUNTS",$sformatf("checks=%0d failures=%0d reset_checks=%0d valid_checks=%0d",env.scoreboard.checks,env.scoreboard.failures,env.scoreboard.reset_checks,env.scoreboard.valid_checks),UVM_NONE)
            if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0) $display("DVBench_COMPLETED");
        endfunction
    endclass
endpackage
