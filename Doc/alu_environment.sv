`include "defines.sv"
`include "alu_interface.sv"
`include "alu_generator.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_reference_model.sv"
`include "alu_scoreboard.sv"

class alu_environment;

virtual alu_intf.DRV vif_drv;
virtual alu_intf.MON vif_mon;
virtual alu_intf.REF_SB vif_ref;

mailbox #(alu_transaction) mbx_gd;
mailbox #(alu_transaction) mbx_dr;
mailbox #(alu_transaction) mbx_ms;
mailbox #(alu_transaction) mbx_rs;

alu_generator gen;
alu_monitor mon;
alu_driver drv;
alu_reference_model ref;
alu_scoreboard scb;


function new(virtual alu_intf.DRV vif_drv,virtual alu_intf.MON vif_mon,virtual alu_intf.REF_SB vif_ref);
 this.vif_drv=vif_drv;
 this.vif_mon=vif_mon;
 this.vif_ref=vif_ref;
endfunction

task build();
 begin
  mbx_gd=new();
  mbx_dr=new();
  mbx_ms=new();
  mbx_rs=new();

  gen=new(mbx_gd);
  drv=new(mbx_gd,mbx_dr,vif_drv);
  mon=new(mbx_ms,vif_mon);
  ref=new(mbx_dr,mbx_rs,vif_ref);
  scb=new(mbx_ms,mbx_rs);
 end
endtask

task start();
    fork
    gen.start();
    drv.start();
    mon.start();
    scb.start();
    ref.start();
    join
 endtask

endclass
