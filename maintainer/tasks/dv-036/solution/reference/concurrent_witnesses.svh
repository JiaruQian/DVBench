task mdio_probe_reset();
  drive='0;
  vif.phy_enable=1;
  vif.phy_bad_ta=0;
  apply(drive,3);
  drive[38]=1;drive[39]=1;drive[37]=1;
  apply(drive,3);
  #1;
endtask
task mdio_probe_write(input bit [7:0] address,input bit [31:0] value);
  if(vif.pred_s_axi_awready !== 1'b1 || vif.pred_s_axi_wready !== 1'b1)
    `uvm_error("PROBE_READY","Independent expected AXI write channels were not idle")
  drive[48:41]=address;drive[36:5]=value;drive[4:1]=15;
  drive[40]=1;drive[0]=1;apply(drive,1);
  drive[40]=0;drive[0]=0;apply(drive,4);
  #1;
endtask
task mdio_probe_status();
  drive[37]=0;drive[57:50]=16;drive[49]=1;apply(drive,1);
  drive[49]=0;apply(drive,3);
  #1;
  if(vif.pred_s_axi_rvalid !== 1'b1 || vif.pred_s_axi_rdata !== 32'd2)
    `uvm_error("PROBE_VACUITY","Expected completed CPU frame and held sticky status")
  drive[37]=1;apply(drive,2);
  #1;
endtask
task mdio_concurrent_witnesses();
  int status_cases;
  int divider_cases;
  status_cases=0;divider_cases=0;
  for(int delay_cycles=118;delay_cycles<=130;delay_cycles++)begin
    mdio_probe_reset();
    mdio_probe_write(20,0);
    mdio_probe_write(0,32'h00010502);
    mdio_probe_write(4,32'h00009669);
    mdio_probe_write(12,1);
    apply(drive,delay_cycles);
    #1;
    mdio_probe_write(4,32'h00006996);
    apply(drive,30);
    #1;
    mdio_probe_status();
    status_cases++;
  end
  for(int initial_divider=15;initial_divider<=63;initial_divider=initial_divider*2+1)begin
    for(int phase_delay=2;phase_delay<=8;phase_delay+=2)begin
      mdio_probe_reset();
      mdio_probe_write(20,initial_divider);
      mdio_probe_write(0,32'h00010702);
      mdio_probe_write(4,32'h0000a55a);
      mdio_probe_write(12,1);
      apply(drive,phase_delay);
      #1;
      mdio_probe_write(20,0);
      apply(drive,300);
      #1;
      mdio_probe_status();
      divider_cases++;
    end
  end
  if(status_cases!=13 || divider_cases!=12)
    `uvm_error("PROBE_VACUITY","Concurrent status/divider witness set incomplete")
  mdio_probe_reset();
endtask
