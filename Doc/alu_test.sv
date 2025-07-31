`include "define.sv"

class alu_test;

virtual alu_intf.DRV vif_drv;
virtual alu_intf.MON vif_mon;
virtual alu_intf.REF_SB vif_ref;
alu_environment env;

function new(virtual alu_intf.DRV vif_drv,virtual alu_intf.MON vif_mon,virtual alu_intf.REF_SB vif_ref);
 this.vif_drv=vif_drv;
 this.vif_mon=vif_mon;
 this.vif_ref=vif_ref;
endfunction

task run();
env=new(vif_drv,vif_mon,vif_ref);
env.build();
env.start();
endtask

endclass

/*class test_regression extends alu_test;

  alu_transaction_1 trans1;
  alu_transaction_2 trans2;
  alu_transaction_3 trans3;
  alu_transaction_4 trans4;

  function new(virtual alu_if drv_vif,
               virtual alu_if mon_vif,
               virtual alu_if ref_vif);
    super.new(drv_vif, mon_vif, ref_vif);
  endfunction

  task run();
    env = new(drv_vif, mon_vif, ref_vif);
    env.build();

    // logical operations with CMD[6:11]
    trans1 = new();
    if (!trans1.randomize()) $fatal("randomization failed for trans1");
    env.gen.blueprint = trans1;
    env.start();

    // arithmetic operations with single operand CMD[4:7]
    trans2 = new();
    if (!trans2.randomize()) $fatal("randomization failed for trans2");
    env.gen.blueprint = trans2;
    env.start();

    // logical operations with two operands CMD[0:6],12,13
    trans3 = new();
    if (!trans3.randomize()) $fatal("randomization failed for trans3");
    env.gen.blueprint = trans3;
    env.start();

    // arithmetic operations with two operands CMD[0:3],8,9,10
    trans4 = new();
    if (!trans4.randomize()) $fatal("randomization failed for trans4");
    env.gen.blueprint = trans4;
    env.start();
  endtask

endclass
*/
