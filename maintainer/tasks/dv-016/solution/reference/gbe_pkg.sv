`timescale 1ns/1ps
package gbe_pkg;
 import uvm_pkg::*;`include "uvm_macros.svh"
 class raw_item extends uvm_sequence_item;
 `uvm_object_utils(raw_item)
 bit rst;byte unsigned bytes[$];int idle_cycles;int repeat_frames;int table_profile;
 bit configure_filter;bit[7:0] filter_match_mask;
 int unsigned gap_stride,gap_cycles,abort_prefix;bit separate_last;
 function new(string name="raw_item");super.new(name);endfunction
 endclass
 class gbe_driver extends uvm_driver#(raw_item);
 `uvm_component_utils(gbe_driver)
 virtual gbe_if v;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual gbe_if)::get(this,"","vif",v))`uvm_fatal("VIF","missing") endfunction
 task reset_bus();
 @(negedge v.clk);v.mac_i_valid=0;v.mac_i_last=0;v.rst=1;
 repeat(3)@(negedge v.clk);v.rst=0;
 endtask
 task drive_bytes(raw_item t,int count,bit finish_frame);
 for(int i=0;i<count;i++)begin
 if(t.gap_stride>0 && i>0 && i%t.gap_stride==0)
 repeat(t.gap_cycles)begin @(negedge v.clk);v.mac_i_valid=0;v.mac_i_last=0;end
 @(negedge v.clk);v.mac_i_valid=1;v.mac_i_data=t.bytes[i];
 v.mac_i_last=finish_frame && !t.separate_last && i==count-1;
 end
 if(finish_frame && t.separate_last)begin @(negedge v.clk);v.mac_i_valid=0;v.mac_i_last=1;end
 @(negedge v.clk);v.mac_i_valid=0;v.mac_i_last=0;
 endtask
 task run_phase(uvm_phase phase);
 raw_item t;v.rst=1;v.mac_i_valid=0;v.mac_i_last=0;v.mac_i_data=0;
 v.local_ip=32'h0a000001;v.local_ip2=32'h0a000002;
 v.filter_ip_addr1=32'h0a000003;v.filter_ip_addr2=4;v.filter_ip_addr3=5;v.filter_ip_addr4=6;
 v.filter_ip_addr5=7;v.filter_ip_addr6=8;v.filter_ip_addr7=9;v.filter_ip_addr8=10;
 repeat(4)@(negedge v.clk);v.rst=0;
 forever begin
 seq_item_port.get_next_item(t);
 if(t.rst)reset_bus();
 v.table_profile=t.table_profile;
 if(t.configure_filter)begin
 v.filter_ip_addr1=t.filter_match_mask[0]?32'h0a000003:32'h0b000000;
 v.filter_ip_addr2=t.filter_match_mask[1]?32'h0a000003:32'h0b000001;
 v.filter_ip_addr3=t.filter_match_mask[2]?32'h0a000003:32'h0b000002;
 v.filter_ip_addr4=t.filter_match_mask[3]?32'h0a000003:32'h0b000003;
 v.filter_ip_addr5=t.filter_match_mask[4]?32'h0a000003:32'h0b000004;
 v.filter_ip_addr6=t.filter_match_mask[5]?32'h0a000003:32'h0b000005;
 v.filter_ip_addr7=t.filter_match_mask[6]?32'h0a000003:32'h0b000006;
 v.filter_ip_addr8=t.filter_match_mask[7]?32'h0a000003:32'h0b000007;
 end
 if(t.abort_prefix>0)begin drive_bytes(t,t.abort_prefix,0);reset_bus();end
 repeat(t.repeat_frames>0?t.repeat_frames:1)drive_bytes(t,t.bytes.size(),1);
 if(t.configure_filter && v.e_pkt_type !== (t.filter_match_mask!=0?2'd2:2'd0))
 `uvm_error("PROBE_VACUITY","Independent predictor did not reach required filter union outcome")
 repeat(t.idle_cycles)@(negedge v.clk);
 seq_item_port.item_done();
 end
 endtask
 endclass
 class gbe_observation extends uvm_sequence_item;
 `uvm_object_utils(gbe_observation)
 logic[91:0] actual,expected;time sample_time;
 function new(string n="gbe_observation");super.new(n);endfunction
 endclass
 class gbe_scoreboard extends uvm_component;
 `uvm_component_utils(gbe_scoreboard)
 uvm_analysis_imp#(gbe_observation,gbe_scoreboard) sink;int checks,errors;
 function new(string n,uvm_component p);super.new(n,p);sink=new("sink",this);endfunction
 function void write(gbe_observation t);
 checks++;if(t.actual!==t.expected)begin errors++;if(errors<=24)`uvm_error("MODEL",$sformatf("point=%0d time=%0t actual=%023h expected=%023h",checks,t.sample_time,t.actual,t.expected))end
 endfunction
 function void check_phase(uvm_phase phase);if(checks<1000)`uvm_error("VACUOUS","insufficient native comparison samples")endfunction
 function void report_phase(uvm_phase phase);`uvm_info("CHECKS",$sformatf("compared_points=%0d errors=%0d",checks,errors),UVM_NONE)endfunction
 endclass
 class gbe_monitor extends uvm_component;
 `uvm_component_utils(gbe_monitor)
 virtual gbe_if v;uvm_analysis_port#(gbe_observation) ap;
 covergroup cg;option.per_instance=1;packet:coverpoint v.pkt_type;search:coverpoint v.is_searching;addr:coverpoint v.table_rd_addr {bins edge_addr[]={0,255,511};}endgroup
 function new(string n,uvm_component p);super.new(n,p);ap=new("ap",this);cg=new();endfunction
 function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual gbe_if)::get(this,"","vif",v))`uvm_fatal("VIF","missing") endfunction
 task run_phase(uvm_phase phase);gbe_observation t;forever begin
 @(posedge v.clk);#2;t=gbe_observation::type_id::create("observation");t.sample_time=$time;
 t.actual={v.is_searching,v.table_rd_addr,v.pkt_type,v.udp_filter_index,v.gbe_rx_pkt_cnt,v.gbe_rx_byte_cnt};
 t.expected={v.e_is_searching,v.e_table_rd_addr,v.e_pkt_type,v.e_udp_filter_index,v.e_gbe_rx_pkt_cnt,v.e_gbe_rx_byte_cnt};
 cg.sample();ap.write(t);end endtask
 endclass
 class gbe_protocol_checker extends uvm_component;
 `uvm_component_utils(gbe_protocol_checker)
 virtual gbe_if v;int async_checks;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);if(!uvm_config_db#(virtual gbe_if)::get(this,"","vif",v))`uvm_fatal("VIF","missing") endfunction
 task run_phase(uvm_phase phase);logic sampled_rst,sampled_last;fork begin forever begin
 @(posedge v.clk);sampled_rst=v.rst;sampled_last=v.mac_i_last;#2;
 if(sampled_rst===1'b0 && sampled_last===1'b0)
 if(v.pkt_type!==2'b00 || v.udp_filter_index!==16'h0000)`uvm_error("OUTPUT_PULSE","native type/index nonzero outside last window")
 end end
 begin forever begin
 @(posedge v.rst);#2;async_checks++;
 if({v.is_searching,v.table_rd_addr,v.pkt_type,v.udp_filter_index,v.gbe_rx_pkt_cnt,v.gbe_rx_byte_cnt}!==92'b0)
 `uvm_error("ASYNC_RESET","native outputs not cleared before next clock edge")
 end end join endtask
 function void check_phase(uvm_phase phase);if(async_checks==0)`uvm_error("ASYNC_VACUITY","no independent reset-edge checks")endfunction
 function void report_phase(uvm_phase phase);`uvm_info("ASYNC_CHECKS",$sformatf("reset_edge_checks=%0d",async_checks),UVM_NONE)endfunction
 endclass
 class gbe_sequence extends uvm_sequence#(raw_item);
 `uvm_object_utils(gbe_sequence)
 function new(string n="gbe_sequence");super.new(n);endfunction

 task overlapping_filters();
 raw_item item;
 for(int match_mask=0;match_mask<256;match_mask++)begin
 item=raw_item::type_id::create("overlapping_filters");
 start_item(item);item.rst=1;item.idle_cycles=3;
 item.configure_filter=1;item.filter_match_mask=match_mask;
 repeat(64)item.bytes.push_back(0);
 item.bytes[12]=8'h08;item.bytes[13]=0;item.bytes[14]=8'h45;
 item.bytes[16]=0;item.bytes[17]=50;item.bytes[23]=6;
 item.bytes[30]=10;item.bytes[31]=0;item.bytes[32]=0;item.bytes[33]=3;
 item.gap_stride=(match_mask%2)?7:0;item.gap_cycles=1;
 item.separate_last=match_mask[1];
 finish_item(item);
 end
 endtask

 task hardening_witnesses();
 raw_item t;int target;
 t=raw_item::type_id::create("arp_alias");start_item(t);t.rst=1;t.idle_cycles=8;
 repeat(64)t.bytes.push_back(0);
 t.bytes[12]=8'h08;t.bytes[13]=8'h06;
 t.bytes[38]=8'h0b;t.bytes[39]=0;t.bytes[40]=0;t.bytes[41]=1;
 finish_item(t);
 for(int scenario=0;scenario<2;scenario++)begin
 target=scenario==0?400:100;
 t=raw_item::type_id::create("signed_search");start_item(t);t.rst=1;t.idle_cycles=8;t.table_profile=1;
 repeat(240)t.bytes.push_back(0);
 t.bytes[12]=8'h08;t.bytes[13]=0;t.bytes[14]=8'h45;
 t.bytes[16]=0;t.bytes[17]=226;t.bytes[23]=17;
 t.bytes[26]=10;t.bytes[29]=4;
 t.bytes[30]=10;t.bytes[31]=0;t.bytes[32]=target>>8;t.bytes[33]=target;
 t.bytes[36]=(16'h7f00+target)>>8;t.bytes[37]=16'h7f00+target;
 t.bytes[38]=0;t.bytes[39]=196;
 finish_item(t);
 end
 t=raw_item::type_id::create("packet_carry");start_item(t);t.rst=1;t.idle_cycles=8;t.repeat_frames=65537;
 repeat(16)t.bytes.push_back(0);t.bytes[12]=8'h88;t.bytes[13]=8'hb5;
 finish_item(t);
 endtask
 task body();raw_item t;int typ;int n;int mode;
 for(int f=0;f<160;f++)begin
 t=raw_item::type_id::create("frame");start_item(t);typ=f%10;n=(typ>=4)?240:64;
 for(int i=0;i<n;i++)t.bytes.push_back($urandom);
 t.bytes[12]=8'h08;t.bytes[13]=(typ==0)?8'h06:(typ==1)?8'h01:0;
 t.bytes[14]=8'h45;t.bytes[16]=0;t.bytes[17]=226;t.bytes[23]=(typ==2)?6:17;
 t.bytes[24]=0;t.bytes[25]=0;
 t.bytes[26]=10;t.bytes[27]=0;t.bytes[28]=0;t.bytes[29]=4;
 t.bytes[30]=10;t.bytes[31]=0;t.bytes[32]=0;t.bytes[33]=(typ==2)?3:1;
 t.bytes[36]=0;t.bytes[37]=0;t.bytes[38]=0;t.bytes[39]=(typ==3)?195:196;
 t.bytes[40]=0;t.bytes[41]=0;
 if(typ>=4 && typ<=6)begin int k;k=(typ==4)?0:(typ==5)?255:511;t.bytes[30]=10;t.bytes[31]=0;t.bytes[32]=k>>8;t.bytes[33]=k;t.bytes[36]=(k*123)>>8;t.bytes[37]=k*123;end
 if(typ==7)begin t.bytes[24]=8'h7a;t.bytes[25]=8'h33;end
 if(typ==0)begin t.bytes[38]=10;t.bytes[39]=0;t.bytes[40]=0;t.bytes[41]=(f[3])?1:2;end
 if(typ==8 || typ==9)begin
 bit [31:0] sum,pseudo,fold;bit[15:0] csum;
 sum=0;for(int k=34;k+1<n;k+=2)sum+={t.bytes[k],t.bytes[k+1]};
 pseudo={t.bytes[26],t.bytes[27]}+{t.bytes[28],t.bytes[29]}+{t.bytes[30],t.bytes[31]}+{t.bytes[32],t.bytes[33]}+t.bytes[23]+{t.bytes[16],t.bytes[17]}-20;
 sum+=pseudo;fold=(sum>>16)+(sum&32'hffff);csum=~fold[15:0];if(csum==0)csum=16'hffff;
 if(typ==9)csum^=16'h0800;t.bytes[40]=csum>>8;t.bytes[41]=csum;
 end
 t.rst=(f%17==0);t.idle_cycles=8;
 mode=(f/10)%4;t.gap_stride=(mode==1 || mode==3)?7:0;t.gap_cycles=1+(f/10)%3;t.separate_last=(mode>=2);t.abort_prefix=(mode==3)?t.bytes.size()/2:0;
 finish_item(t);
 end
 hardening_witnesses();
 overlapping_filters();
 endtask
 endclass
 class gbe_agent extends uvm_agent;
 `uvm_component_utils(gbe_agent)
 gbe_driver d;uvm_sequencer#(raw_item) s;gbe_monitor m;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);d=gbe_driver::type_id::create("driver",this);s=new("sequencer",this);m=gbe_monitor::type_id::create("monitor",this);endfunction
 function void connect_phase(uvm_phase phase);d.seq_item_port.connect(s.seq_item_export);endfunction
 endclass
 class gbe_env extends uvm_env;
 `uvm_component_utils(gbe_env)
 gbe_agent a;gbe_scoreboard sb;gbe_protocol_checker protocol_checker;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);a=gbe_agent::type_id::create("agent",this);sb=gbe_scoreboard::type_id::create("scoreboard",this);protocol_checker=gbe_protocol_checker::type_id::create("protocol_checker",this);endfunction
 function void connect_phase(uvm_phase phase);a.m.ap.connect(sb.sink);endfunction
 endclass
 class dvbench_test extends uvm_test;
 `uvm_component_utils(dvbench_test)
 gbe_env e;
 function new(string n,uvm_component p);super.new(n,p);endfunction
 function void build_phase(uvm_phase phase);e=gbe_env::type_id::create("env",this);endfunction
 task run_phase(uvm_phase phase);gbe_sequence s;phase.raise_objection(this);s=gbe_sequence::type_id::create("seq");s.start(e.a.s);repeat(8)@(negedge e.a.d.v.clk);phase.drop_objection(this);endtask
 function void report_phase(uvm_phase phase);uvm_report_server server;server=uvm_report_server::get_server();if(server.get_severity_count(UVM_ERROR)==0 && server.get_severity_count(UVM_FATAL)==0)`uvm_info("DVBench_COMPLETED","DVBench_COMPLETED",UVM_NONE)endfunction
 endclass
endpackage
