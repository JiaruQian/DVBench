apply('0,3);drive[38:38]=1;drive[39:39]=1;drive[37:37]=1;apply(drive,3);
drive[57:50]=20;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[57:50]=0;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
repeat(12) begin
drive[48:41]=0;drive[40:40]=1;drive[36:5]=32'h00011b07;drive[4:1]=1;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=0;drive[40:40]=1;drive[36:5]=32'h00000b00;drive[4:1]=2;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=0;drive[40:40]=1;drive[36:5]=32'h00010000;drive[4:1]=4;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[57:50]=0;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[48:41]=4;drive[40:40]=1;drive[36:5]=$urandom;drive[4:1]=1;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=4;drive[40:40]=1;drive[36:5]=$urandom;drive[4:1]=2;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[57:50]=4;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[48:41]=20;drive[40:40]=1;drive[36:5]=1;drive[4:1]=3;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[57:50]=20;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=1;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
apply(drive,400);drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[48:41]=16;drive[40:40]=1;drive[36:5]=2;drive[4:1]=1;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
end
drive[48:41]=0;drive[40:40]=1;drive[36:5]=32'h00000302;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=20;drive[40:40]=1;drive[36:5]=0;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
apply(drive,300);drive[57:50]=8;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[48:41]=16;drive[40:40]=1;drive[36:5]=4;drive[4:1]=1;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[58:58]=1;apply(drive,2010000);drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[58:58]=0;apply(drive,10);
drive[38:38]=0;apply(drive,3);drive[38:38]=1;apply(drive,10);
drive[39:39]=0;drive[48:41]=4;drive[40:40]=1;apply(drive,1);drive[40:40]=0;apply(drive,5);drive[36:5]=32'hdeadcafe;drive[4:1]=3;drive[0:0]=1;apply(drive,1);drive[0:0]=0;apply(drive,9);drive[39:39]=1;apply(drive,3);
drive[57:50]=4;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[36:5]=32'h12345678;drive[0:0]=1;apply(drive,1);drive[0:0]=0;apply(drive,5);drive[48:41]=4;drive[40:40]=1;apply(drive,1);drive[40:40]=0;apply(drive,4);
drive[37:37]=0;drive[57:50]=4;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
apply(drive,11);drive[37:37]=1;apply(drive,3);
drive[40:40]=1;apply(drive,1);drive[40:40]=0;drive[38:38]=0;apply(drive,3);drive[38:38]=1;apply(drive,4);
drive[48:41]=20;drive[40:40]=1;drive[36:5]=0;drive[4:1]=3;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);

vif.phy_enable=1;vif.phy_identity=16'ha231;
drive[48:41]=0;drive[40:40]=1;drive[36:5]=32'h00000302;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
apply(drive,10);drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
apply(drive,300);drive[57:50]=8;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
drive[58:58]=1;apply(drive,10);drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
drive[48:41]=12;drive[40:40]=1;drive[36:5]=1;drive[4:1]=15;drive[0:0]=1;apply(drive,1);drive[40:40]=0;drive[0:0]=0;apply(drive,4);
apply(drive,2030000);
if(vif.init_done_o !== 1'b1 || vif.init_fail_o !== 1'b0) `uvm_error("INIT_SUCCESS","legal correct-ID initialization did not complete")
if({vif.peer_phycr,vif.peer_cfg4,vif.peer_rgmiictl,vif.peer_delay} !== {16'h43ff,16'hf07f,16'hf093,16'h0067})
  `uvm_error("PHY_CONFIGURATION","decoded external PHY writes violate independent register masks and delay constants")

drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_status=16'ha400;apply(drive,1450000);if(vif.phy_link_o !== 1'b1) `uvm_error("LINK_UP","successful link-up poll missing")
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_status=16'ha400;apply(drive,1450000);if(vif.phy_link_o !== 1'b1) `uvm_error("LINK_UP","successful link-up poll missing")
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_status=16'h0000;apply(drive,1450000);if(vif.phy_link_o !== 1'b0) `uvm_error("LINK_DOWN","successful link-down poll missing")
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_status=16'ha400;apply(drive,1450000);if(vif.phy_link_o !== 1'b1) `uvm_error("LINK_UP","successful link-up poll missing")
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_bad_ta=1;apply(drive,1450000);if(vif.phy_link_o !== 1'b0) `uvm_error("LINK_ERROR","failed poll must clear old link")
drive[57:50]=16;drive[49:49]=1;apply(drive,1);drive[49:49]=0;apply(drive,4);
vif.phy_bad_ta=0;drive[58:58]=0;apply(drive,10);
drive[38:38]=0;apply(drive,3);drive[38:38]=1;apply(drive,10);

mdio_concurrent_witnesses();
