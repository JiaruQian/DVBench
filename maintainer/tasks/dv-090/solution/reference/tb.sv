
`timescale 1ns/1ps
interface dvbench_if(input logic clk);
    logic [63:0] inputs;
    wire [33-1:0] actual, expected;
endinterface
package dvbench_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    class dvbench_item extends uvm_sequence_item;
        `uvm_object_utils(dvbench_item)
        logic [63:0] value;
        integer cycles;
        logic [33-1:0] actual, expected;
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
            
        for(integer trial=0;trial<24;trial++) begin
            value = trial<8 ? (64'h1 << (trial*4)) : {$urandom,$urandom};
            send((value<<1)|1,8);
            send(value<<1,19);
            value = trial==0 ? 32'h7fffffff : trial==1 ? 32'hffffffff : $urandom;
            send(value<<1,1);
            case(trial)
                0:value=0; 1:value=1; 2:value=32'hfffffffc; 3:value=32'hffffffff;
                4:value=32'h7fffffff; 5:value=32'h80000000; 6:value=32'h12345678; 7:value=32'hffff0001;
                8:value=32'h00007fff; 9:value=32'h00008000; 10:value=32'h0000fffc; 11:value=32'h0000ffff; 12:value=32'h01020304;
                default:value=$urandom;
            endcase
            send(value<<1,1);
            send(($urandom<<1),1);
            send(($urandom<<1),80);
        end
        send(1,8); send(64'h12345678<<1,65); send(1,8);
        send(64'h80000000<<1,300);
        
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
        logic [33-1:0] last_actual,last_expected;
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
            if(item.value[0] && item.actual!==0 && failures<3) begin failures++; `uvm_error("RESET","MMIO outputs must clear during reset") end
        endfunction
    endclass
    class dvbench_coverage extends uvm_subscriber#(dvbench_item);
        `uvm_component_utils(dvbench_coverage)
        covergroup observations with function sample(logic [33-1:0] outputs,logic [63:0] inputs);
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
    Controller #(.PROGRAM_FILE("code.txt")) dut(.Clk(clk),.Reset(bus.inputs[0]),.input_data(bus.inputs[32:1]),.result_valid(bus.actual[32]),.result_data(bus.actual[31:0]));
    dvbench_model #(.PROGRAM_FILE("code.txt")) predictor(.Clk(clk),.Reset(bus.inputs[0]),.input_data(bus.inputs[32:1]),.result_valid(bus.expected[32]),.result_data(bus.expected[31:0]));
    initial begin
        uvm_config_db#(virtual dvbench_if)::set(null,"*","vif",bus);
        run_test("dvbench_test");
    end
endmodule
