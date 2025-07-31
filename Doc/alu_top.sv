
`include "alu_transaction.sv"
`include "alu_generator.sv"
`include "alu_driver.sv"
`include "alu_monitor.sv"
`include "alu_reference_model.sv"
`include "alu_scoreboard1.sv"
`include "alu_environment.sv"
`include "alu_test.sv"
`include "alu_interface.sv"
`include "alu_design.sv"

module top();

//import alu_pkg::*;
bit clk=0;
bit rst=0;

 initial
    begin
     forever #5 clk=~clk;
    end 

initial
    begin
      @(posedge clk);
      rst=1;
      @(posedge clk);
      rst=0;
    end 

alu_intf intf(clk,rst);  //interface instantiation

ALU_DESIGN DUT(.INP_VALID(intf.inp_valid),.OPA(intf.opa),.OPB(intf.opb),.CIN(intf.cin),.CLK(clk),.RST(rst),.CMD(intf.cmd),.CE(intf.ce),.MODE(intf.mode),.COUT(intf.cout),.OFLOW(intf.oflow),.RES(intf.res),.G(intf.g),.E(intf.e),.L(intf.l),.ERR(intf.err));  

alu_test tb;  //test class instantiation
 // test1      tb1;
  //test2      tb2;
  //test3      tb3;
 // test4      tb4;
 // test_regression tb_regression;

  // Create objects in initial block
  initial begin
    tb            = new(intf.DRV, intf.MON, intf.REF_SB);
    // tb1           = new(intf.DRV, intf.MON, intf.REF_SB);
    // tb2           = new(intf.DRV, intf.MON, intf.REF_SB);
    // tb3           = new(intf.DRV, intf.MON, intf.REF_SB);
    // tb4           = new(intf.DRV, intf.MON, intf.REF_SB);
    // tb_regression = new(intf.DRV, intf.MON, intf.REF_SB);

    // Call the regression run (can comment/uncomment others for individual test)
    //tb_regression.run();

    //# You can also try individual tests like:
    // tb.run();
    // tb1.run();
    // tb2.run();
    // tb3.run();
    // tb4.run();

    #200;
    $finish;
    end 

endmodule

