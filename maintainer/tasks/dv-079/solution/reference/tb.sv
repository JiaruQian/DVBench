
`timescale 1ns/1ps
interface dvbench_if(input logic clk);
    logic [63:0] inputs;
    wire [5-1:0] actual, expected;
endinterface
package dvbench_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dvbench_item extends uvm_sequence_item;
        `uvm_object_utils(dvbench_item)
        logic [63:0] value;
        integer cycles;
        logic [5-1:0] actual, expected;
        longint unsigned edge_number;
        function new(string name="dvbench_item"); super.new(name); endfunction
    endclass
    class dvbench_sequence extends uvm_sequence #(dvbench_item);
        `uvm_object_utils(dvbench_sequence)
        function new(string name="dvbench_sequence"); super.new(name); endfunction
        task send(logic [63:0] value, integer cycles);
            dvbench_item item=dvbench_item::type_id::create("item");
            start_item(item); item.value=value; item.cycles=cycles; finish_item(item);
        endtask
        task body();
            logic [63:0] value;
            string profile;
            void'($value$plusargs("witness=%s",profile));
            if(profile=="uart_overlap") begin
                send(14,8);send(15,8345601-137*326+99-104320);
                value=8'h77;
                send(7,5216);
                for(int bit_number=0;bit_number<8;bit_number++) send(7|(((value>>bit_number)&1)<<3),5216);
                send(15,5216+52160);
                value=8'h73;
                send(7,5216);
                for(int bit_number=0;bit_number<8;bit_number++) send(7|(((value>>bit_number)&1)<<3),5216);
                send(15,5216+52160);
                value=8'h73;
                send(7,5216);
                for(int bit_number=0;bit_number<8;bit_number++) send(7|(((value>>bit_number)&1)<<3),5216);
                send(15,5216+52160);
                send(15,838400*4);
                return;
            end
            
        send(14,8); send(15,80+$urandom_range(0,325));
        send(13,31); send(15,17); send(13,43); send(15,29);
        send(13,2097152); send(13,32);
        send(15,100); send(13,100);
        for(integer byte_number=0;byte_number<6;byte_number++) begin
            value=byte_number%3==0 ? 8'h77 : byte_number%3==1 ? 8'h73 : 8'h41;
            send(5,5216);
            for(integer bit_number=0;bit_number<8;bit_number++) send(5|(((value>>bit_number)&1)<<3),5216);
            send(13,5216+byte_number*37);
        end
        send(13,838400*146);
        send(15,2097200); send(11,838400*24);
        send(9,838400*3); send(15,2097200);
        send(14,8); send(15,838400*146);
        
        endtask
    endclass
    class dvbench_driver extends uvm_driver #(dvbench_item);
        `uvm_component_utils(dvbench_driver)
        virtual dvbench_if vif;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
        endfunction
        task run_phase(uvm_phase phase);
            forever begin
                seq_item_port.get_next_item(req);
                #1; vif.inputs=req.value;
                repeat(req.cycles) @(negedge vif.clk);
                seq_item_port.item_done();
            end
        endtask
    endclass
    class dvbench_monitor extends uvm_component;
        `uvm_component_utils(dvbench_monitor)
        virtual dvbench_if vif;
        uvm_analysis_port#(dvbench_item) observations;
        longint unsigned edge_number;
        logic [5-1:0] last_actual,last_expected;
        function new(string name,uvm_component parent); super.new(name,parent); observations=new("observations",this); endfunction
        function void build_phase(uvm_phase phase);
            if(!uvm_config_db#(virtual dvbench_if)::get(this,"","vif",vif)) `uvm_fatal("VIF","missing interface")
        endfunction
        task run_phase(uvm_phase phase);
            dvbench_item item;
            forever begin
                @(posedge vif.clk or vif.inputs[0]); #1;
                edge_number++;
                if(vif.actual!==last_actual || vif.expected!==last_expected || edge_number%997==0 || edge_number<100) begin
                    item=dvbench_item::type_id::create("observation");
                    item.actual=vif.actual; item.expected=vif.expected;
                    item.value=vif.inputs; item.edge_number=edge_number;
                    observations.write(item);
                end
                last_actual=vif.actual; last_expected=vif.expected;
            end
        endtask
    endclass
    class dvbench_predictor extends uvm_subscriber#(dvbench_item);
        `uvm_component_utils(dvbench_predictor)
        uvm_analysis_port#(dvbench_item) predictions;
        function new(string name,uvm_component parent); super.new(name,parent); predictions=new("predictions",this); endfunction
        function void write(dvbench_item item); predictions.write(item); endfunction
    endclass
    class dvbench_scoreboard extends uvm_subscriber#(dvbench_item);
        `uvm_component_utils(dvbench_scoreboard)
        longint unsigned comparisons,mismatches;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void write(dvbench_item item);
            comparisons++;
            if(item.actual!==item.expected) begin
                mismatches++;
                if(mismatches<=12) `uvm_error("MISMATCH",$sformatf("edge=%0d actual=%h expected=%h inputs=%h",item.edge_number,item.actual,item.expected,item.value))
            end
        endfunction
        function void check_phase(uvm_phase phase);
            if(comparisons<10) `uvm_error("VACUOUS","too few comparison points")
            if(mismatches>12) `uvm_error("MISMATCH_TOTAL",$sformatf("mismatches=%0d",mismatches))
        endfunction
        function void report_phase(uvm_phase phase);
            `uvm_info("COMPARISONS",$sformatf("comparisons=%0d mismatches=%0d",comparisons,mismatches),UVM_NONE)
        endfunction
    endclass
    class dvbench_checker extends uvm_subscriber#(dvbench_item);
        `uvm_component_utils(dvbench_checker)
        integer failures;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void write(dvbench_item item);
            if($isunknown(item.actual)) begin
                failures++;
                if(failures<=3) `uvm_error("UNKNOWN","unknown public output after initialization")
            end
            if(!item.value[0] && item.actual!==0 && failures<3) begin failures++; `uvm_error("RESET","VGA outputs must clear during reset") end
        endfunction
    endclass
    class dvbench_coverage extends uvm_subscriber#(dvbench_item);
        `uvm_component_utils(dvbench_coverage)
        covergroup observations with function sample(logic [5-1:0] outputs,logic [63:0] inputs);
            option.per_instance=1;
            output_bits: coverpoint outputs {option.auto_bin_max=32;}
            reset_pin: coverpoint inputs[0];
            stimulus: coverpoint inputs[4:1];
            activity: cross reset_pin,stimulus;
        endgroup
        function new(string name,uvm_component parent); super.new(name,parent); observations=new; endfunction
        function void write(dvbench_item item); observations.sample(item.actual,item.value); endfunction
        function void report_phase(uvm_phase phase);
            `uvm_info("FUNCTIONAL_COVERAGE",$sformatf("coverage=%0.4f",observations.get_inst_coverage()),UVM_NONE)
        endfunction
    endclass
    class dvbench_agent extends uvm_agent;
        `uvm_component_utils(dvbench_agent)
        dvbench_driver driver;
        uvm_sequencer#(dvbench_item) sequencer;
        dvbench_monitor monitor;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            driver=dvbench_driver::type_id::create("driver",this);
            sequencer=new("sequencer",this); monitor=dvbench_monitor::type_id::create("monitor",this);
        endfunction
        function void connect_phase(uvm_phase phase); driver.seq_item_port.connect(sequencer.seq_item_export); endfunction
    endclass
    class dvbench_env extends uvm_env;
        `uvm_component_utils(dvbench_env)
        dvbench_agent agent;
        dvbench_predictor predictor;
        dvbench_scoreboard scoreboard;
        dvbench_checker checker;
        dvbench_coverage coverage;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase);
            agent=dvbench_agent::type_id::create("agent",this);
            predictor=dvbench_predictor::type_id::create("predictor",this);
            scoreboard=dvbench_scoreboard::type_id::create("scoreboard",this);
            checker=dvbench_checker::type_id::create("checker",this);
            coverage=dvbench_coverage::type_id::create("coverage",this);
        endfunction
        function void connect_phase(uvm_phase phase);
            agent.monitor.observations.connect(predictor.analysis_export);
            predictor.predictions.connect(scoreboard.analysis_export);
            agent.monitor.observations.connect(checker.analysis_export);
            agent.monitor.observations.connect(coverage.analysis_export);
        endfunction
    endclass
    class dvbench_test extends uvm_test;
        `uvm_component_utils(dvbench_test)
        dvbench_env env;
        function new(string name,uvm_component parent); super.new(name,parent); endfunction
        function void build_phase(uvm_phase phase); env=dvbench_env::type_id::create("env",this); endfunction
        task run_phase(uvm_phase phase);
            dvbench_sequence sequence_instance=dvbench_sequence::type_id::create("sequence_instance");
            phase.raise_objection(this);
            fork
                sequence_instance.start(env.agent.sequencer);
                begin
                    wait(env.scoreboard.mismatches>0); #20;
                    `uvm_info("COUNTEREXAMPLE_STOP","Stopping after a real scoreboard mismatch; no completion marker on error",UVM_NONE)
                end
            join_any
            disable fork;
            #3; phase.drop_objection(this);
        endtask
        function void report_phase(uvm_phase phase);
            uvm_report_server server=uvm_report_server::get_server();
            if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)
                `uvm_info("DVBench_COMPLETED","DVBench_COMPLETED",UVM_NONE)
        endfunction
    endclass
endpackage
module dvbench_top;
    import uvm_pkg::*;
    import dvbench_pkg::*;
    logic clk=0;
    always #5 clk=~clk;
    dvbench_if bus(clk);
    pong_top  dut(.clk(clk),.reset_n(bus.inputs[0]),.btn(bus.inputs[2:1]),.rx(bus.inputs[3]),.vga_hsync(bus.actual[4]),.vga_vsync(bus.actual[3]),.vga_rgb(bus.actual[2:0]));
    dvbench_model  predictor(.clk(clk),.reset_n(bus.inputs[0]),.btn(bus.inputs[2:1]),.rx(bus.inputs[3]),.vga_hsync(bus.expected[4]),.vga_vsync(bus.expected[3]),.vga_rgb(bus.expected[2:0]));
    initial begin
        uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
        run_test("dvbench_test");
    end
endmodule
