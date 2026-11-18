`timescale 1ns/1ps
package timer_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class timer_item extends uvm_sequence_item;
        `uvm_object_utils(timer_item)
        bit reset_request;
        bit [11:0] PADDR;
        bit [31:0] PWDATA;
        bit PWRITE;
        bit PSEL;
        bit PENABLE;
        bit dft_cg_enable_i;
        bit ref_clk_i;
        bit event_lo_i;
        bit event_hi_i;

        function new(string name="timer_item");super.new(name);endfunction
    endclass
    class timer_sequence extends uvm_sequence #(timer_item);
        `uvm_object_utils(timer_sequence)
        virtual timer_if vif;
        function new(string name="timer_sequence");super.new(name);endfunction
        task send_reset();
            timer_item item=timer_item::type_id::create("reset");
            if(vif.stop_requested)return;
            start_item(item);item.reset_request=1;finish_item(item);
        endtask
        task cycle(bit selected,bit enabled,bit write_enable,bit [11:0] address,bit [31:0] data,bit reference_value,bit low_event,bit high_event,bit force_clock);
            timer_item item=timer_item::type_id::create("cycle");
            if(vif.stop_requested)return;
            start_item(item);
            item.PSEL=selected;item.PENABLE=enabled;item.PWRITE=write_enable;item.PADDR=address;item.PWDATA=data;
            item.ref_clk_i=reference_value;item.event_lo_i=low_event;item.event_hi_i=high_event;item.dft_cg_enable_i=force_clock;
            finish_item(item);
        endtask
        task write_register(bit [5:0] address,bit [31:0] data);
            cycle(1,0,1,12'h400|address,data,0,0,0,0);
            cycle(1,1,1,12'h400|address,data,0,0,0,0);
            cycle(0,0,0,0,0,0,0,0,0);
        endtask

        task carry_write_overlap();
            for(int pattern=0;pattern<32;pattern++) begin
                send_reset();
                write_register(16,32'h13579bdf);
                write_register(20,32'h2468ace0);
                write_register(12,32'hffffffff-(32'b1<<pattern));
                cycle(1,1,1,12'h408,32'hffffffff,0,0,0,0);
                cycle(1,1,1,12'h400,32'h80000001,0,0,0,0);
                cycle(1,1,1,12'h408,32'b1<<pattern,0,0,0,0);
                repeat(4)cycle(1,1,0,12'h40c,0,0,0,0,0);
                cycle(1,1,1,12'h400,0,0,0,0,0);
                repeat(4)cycle(1,1,0,12'h40c,0,0,0,0,0);
            end
        endtask
        task body();
            int unsigned random_value;
            if(!uvm_config_db#(virtual timer_if)::get(null,"","vif",vif))`uvm_fatal("CONFIG","Missing sequence interface")
            send_reset();
            for(int mode=0;mode<16;mode++)begin
                send_reset();write_register(16,4);write_register(20,3);
                write_register(0,32'h5|(mode[0]?32'h10:0)|(mode[1]?32'h20:0)|(mode[2]?32'h240:0)|(mode[3]?32'h80:0));
                write_register(4,32'h5|(mode[0]?32'h10:0)|(mode[2]?32'h140:0)|(mode[3]?32'h80:0));
                for(int iteration=0;iteration<80;iteration++)cycle(1,1,0,12'h400+4*(iteration%6),0,iteration[1],0,0,0);
                write_register(32,0);write_register(36,0);write_register(0,32'h8);write_register(4,32'h8);
                repeat(2)cycle(0,0,0,0,0,0,1,1,0);
                repeat(8)cycle(0,0,0,0,0,0,0,0,0);
            end
            for(int mode=0;mode<4;mode++)begin
                send_reset();write_register(8,32'hfffffffc);write_register(12,32'hfffffffe);
                write_register(16,0);write_register(20,32'hffffffff);
                write_register(0,32'h80000005|(mode[0]?32'h140:0)|(mode[1]?32'h80:0));
                for(int iteration=0;iteration<100;iteration++)cycle(1,1,0,12'h408+(iteration[0]?4:0),0,iteration[1],0,0,0);
            end
            for(int iteration=0;iteration<5000;iteration++)begin
                random_value=$urandom;
                cycle(random_value[0],random_value[1],random_value[2],random_value[7]?12'h400+4*random_value[6:3]:random_value[19:8],$urandom,random_value[20],random_value[21],random_value[22],random_value[23]);
                if(iteration==711 || iteration==2111)send_reset();
            end
            send_reset();repeat(10)cycle(0,0,0,0,0,0,0,0,0);
            carry_write_overlap();

        endtask
    endclass
    class timer_driver extends uvm_driver #(timer_item);
        `uvm_component_utils(timer_driver)
        virtual timer_if vif;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual timer_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing driver interface")
        endfunction
        task run_phase(uvm_phase phase);
            timer_item item;
            forever begin
                seq_item_port.get_next_item(item);
                @(negedge vif.HCLK);
                if(item.reset_request)begin
                    vif.checking=1;
                    #2 vif.HRESETn=0;
                    repeat(3)@(posedge vif.HCLK);
                    @(negedge vif.HCLK);vif.HRESETn=1;
                end else begin
                    vif.PADDR=item.PADDR;
                    vif.PWDATA=item.PWDATA;
                    vif.PWRITE=item.PWRITE;
                    vif.PSEL=item.PSEL;
                    vif.PENABLE=item.PENABLE;
                    vif.dft_cg_enable_i=item.dft_cg_enable_i;
                    vif.ref_clk_i=item.ref_clk_i;
                    vif.event_lo_i=item.event_lo_i;
                    vif.event_hi_i=item.event_hi_i;

                    @(posedge vif.HCLK);#2;
                end
                seq_item_port.item_done();
            end
        endtask
    endclass
    class timer_sample extends uvm_sequence_item;
        `uvm_object_utils(timer_sample)
        logic [31:0] actual_PRDATA;
        logic [31:0] expected_PRDATA;
        logic actual_PREADY;
        logic expected_PREADY;
        logic actual_PSLVERR;
        logic expected_PSLVERR;
        logic [31:0] actual_timer_val_lo_o;
        logic [31:0] expected_timer_val_lo_o;
        logic actual_irq_lo_o;
        logic expected_irq_lo_o;
        logic actual_irq_hi_o;
        logic expected_irq_hi_o;
        logic actual_busy_o;
        logic expected_busy_o;

        bit asynchronous_reset;
        function new(string name="timer_sample");super.new(name);endfunction
    endclass
    class timer_monitor extends uvm_monitor;
        `uvm_component_utils(timer_monitor)
        virtual timer_if vif;
        uvm_analysis_port #(timer_sample) samples;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual timer_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing monitor interface")
        endfunction
        task sample_ports(bit asynchronous_reset);
            timer_sample sample=timer_sample::type_id::create("sample");
            #1;
            if(vif.checking)begin
                sample.actual_PRDATA=vif.PRDATA;sample.expected_PRDATA=vif.expected_PRDATA;
                sample.actual_PREADY=vif.PREADY;sample.expected_PREADY=vif.expected_PREADY;
                sample.actual_PSLVERR=vif.PSLVERR;sample.expected_PSLVERR=vif.expected_PSLVERR;
                sample.actual_timer_val_lo_o=vif.timer_val_lo_o;sample.expected_timer_val_lo_o=vif.expected_timer_val_lo_o;
                sample.actual_irq_lo_o=vif.irq_lo_o;sample.expected_irq_lo_o=vif.expected_irq_lo_o;
                sample.actual_irq_hi_o=vif.irq_hi_o;sample.expected_irq_hi_o=vif.expected_irq_hi_o;
                sample.actual_busy_o=vif.busy_o;sample.expected_busy_o=vif.expected_busy_o;

                sample.asynchronous_reset=asynchronous_reset;
                samples.write(sample);
            end
        endtask
        task run_phase(uvm_phase phase);
            fork
                forever begin @(posedge vif.HCLK);sample_ports(0);end
                forever begin @(negedge vif.HRESETn);sample_ports(1);end
            join
        endtask
    endclass
    class timer_scoreboard extends uvm_scoreboard;
        `uvm_component_utils(timer_scoreboard)
        virtual timer_if vif;
        uvm_analysis_imp #(timer_sample,timer_scoreboard) samples;
        int unsigned checks,failures,reset_checks;
        function new(string name,uvm_component parent);super.new(name,parent);samples=new("samples",this);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if(!uvm_config_db#(virtual timer_if)::get(this,"","vif",vif))`uvm_fatal("CONFIG","Missing scoreboard interface")
        endfunction
        function void write(timer_sample sample);
            bit mismatch=0;
            reset_checks+=sample.asynchronous_reset;
            checks++;if(sample.actual_PRDATA!==sample.expected_PRDATA)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("PRDATA=%h/%h async_reset=%b",sample.actual_PRDATA,sample.expected_PRDATA,sample.asynchronous_reset))end
            checks++;if(sample.actual_PREADY!==sample.expected_PREADY)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("PREADY=%h/%h async_reset=%b",sample.actual_PREADY,sample.expected_PREADY,sample.asynchronous_reset))end
            checks++;if(sample.actual_PSLVERR!==sample.expected_PSLVERR)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("PSLVERR=%h/%h async_reset=%b",sample.actual_PSLVERR,sample.expected_PSLVERR,sample.asynchronous_reset))end
            checks++;if(sample.actual_timer_val_lo_o!==sample.expected_timer_val_lo_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("timer_val_lo_o=%h/%h async_reset=%b",sample.actual_timer_val_lo_o,sample.expected_timer_val_lo_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_irq_lo_o!==sample.expected_irq_lo_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("irq_lo_o=%h/%h async_reset=%b",sample.actual_irq_lo_o,sample.expected_irq_lo_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_irq_hi_o!==sample.expected_irq_hi_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("irq_hi_o=%h/%h async_reset=%b",sample.actual_irq_hi_o,sample.expected_irq_hi_o,sample.asynchronous_reset))end
            checks++;if(sample.actual_busy_o!==sample.expected_busy_o)begin mismatch=1;if(failures<20)`uvm_error("NATIVE_MISMATCH",$sformatf("busy_o=%h/%h async_reset=%b",sample.actual_busy_o,sample.expected_busy_o,sample.asynchronous_reset))end

            if(mismatch)begin
                failures++;
                vif.stop_requested=1;
            end
        endfunction
        function void check_phase(uvm_phase phase);
            super.check_phase(phase);
            if(failures==0 && (checks<50000 || reset_checks<20))`uvm_error("VACUOUS","Required comparison windows did not execute")
            if(failures>20)`uvm_error("MISMATCH_TOTAL",$sformatf("Total failed samples=%0d",failures))
        endfunction
    endclass
    class timer_env extends uvm_env;
        `uvm_component_utils(timer_env)
        uvm_sequencer #(timer_item) sequencer;
        timer_driver driver;
        timer_monitor monitor;
        timer_scoreboard scoreboard;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer=uvm_sequencer#(timer_item)::type_id::create("sequencer",this);
            driver=timer_driver::type_id::create("driver",this);
            monitor=timer_monitor::type_id::create("monitor",this);
            scoreboard=timer_scoreboard::type_id::create("scoreboard",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
            monitor.samples.connect(scoreboard.samples);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        timer_env env;
        function new(string name,uvm_component parent);super.new(name,parent);endfunction
        function void build_phase(uvm_phase phase);super.build_phase(phase);env=timer_env::type_id::create("env",this);endfunction
        task run_phase(uvm_phase phase);
            timer_sequence sequence_instance=timer_sequence::type_id::create("sequence_instance");
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
