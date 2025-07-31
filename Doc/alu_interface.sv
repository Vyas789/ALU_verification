`include "define.sv"

interface alu_intf(clk,rst);

input bit clk,rst;
//input signals 
logic [`n-1:0] opa,opb;
logic ce;
logic mode;
logic [`m-1:0] cmd;
logic [1:0] inp_valid;
logic cin;

//output signals
logic [`n:0] res;
logic oflow;
logic cout;
logic g,l,e;
logic err;

//assertion coverage

property input_validity;
  @(posedge clk) disable iff (rst)
    !$isunknown({opa, opb, cmd, mode, ce, inp_valid, cin, clk, rst});
endproperty

assert property (input_validity)
  $info("All passed: Inputs are not X/Z");
else
  $error("failed: Inputs contain X or Z");

property output_validity;
  @(posedge clk) disable iff (rst)
    !$isunknown({res, cout, oflow, e, g, l, err});
endproperty

assert property (output_validity)
  $info("All passed: Outputs are not X/Z");
else
  $error("failed: Outputs contain X or Z");

property output_validity;
  @(posedge clk) disable iff (rst)
    !$isunknown({res, cout, oflow, e, g, l, err});
endproperty

assert property (output_validity)
  $info("All passed: Outputs are not X/Z");
else
  $error("failed: Outputs contain X or Z");

property input_timing;
  @(posedge clk) disable iff (rst)
    (inp_valid == 2'b11) |-> ##1 !$isunknown(res);
endproperty

assert property (input_timing)
  $info("passed: RES valid 1 cycle after inp_valid == 2'b11");
else
  $error("failed: RES not valid 1 cycle after inp_valid == 2'b11");

property wait_window;
  @(posedge clk) disable iff (rst)
    (inp_valid inside {2'b01, 2'b10}) |->
      (
        (##[1:16] ((inp_valid == 2'b11) && !$isunknown(res))) or
        (##16 !$isunknown(res) ##1 err)
      );
endproperty

assert property (wait_window)
  $info("passed: RES appeared within 16 cycles or ERR raised on 17th cycle");
else
  $error("failed: RES not ready within 16 cycles and no ERR on 17th cycle");

property mul_latency;
  @(posedge clk) disable iff (rst)
    ((cmd == `INC_MUL || cmd == `SHIFT_MUL) && inp_valid == 2'b11) |-> ##3 !$isunknown(res);
endproperty

assert property (mul_latency)
  $info("passed: RES valid 3 cycles after multiplication command");
else
  $error("failed: RES not valid 3 cycles after multiplication");

property rotate_error;
  @(posedge clk) disable iff (rst)
    ((cmd == `ROL_A_B || cmd == `ROR_A_B) && opb[7:4] != 0) |-> ##1 (err && !$isunknown(res));
endproperty

assert property (rotate_error)
  $info("passed: ERR raised correctly for rotate with non-zero shift amount");
else
  $error("failed: ERR not raised for rotate with invalid OPB[7:4]");

property ce_stable;
  @(posedge clk) disable iff (rst)
    (ce == 0) |=> $stable({res, cout, oflow, g, e, l, err});
endproperty

property ce_stable;
  @(posedge clk) disable iff (rst)
    (ce == 0) |=> $stable({res, cout, oflow, g, e, l, err});
endproperty

assert property (ce_stable)
  $info("passed: Outputs stable when CE = 0");
else
  $error("failed: Outputs changed despite CE = 0");

//tclocking block for the driver
clocking drv_cb @(posedge clk);
    default input #0 output #0;
    output opa,opb,cin,ce,mode,inp_valid,cmd;
endclocking

//clocking block for the monitor
clocking mon_cb @(posedge clk);
    default input #0 output #0;
    input opa,opb,ce,mode,cmd,inp_valid,cin;
    input res,oflow,cout,g,l,e,err;
endclocking

//clocking block for the reference model
clocking ref_cb @(posedge clk);
    default input #0 output #0;
    input opa,opb,cin,ce,mode,inp_valid,cmd,rst;
    output res,oflow,err,g,l,cout;
endclocking

//modport for the driver monitor and the reference model 
modport DRV(clocking drv_cb);
modport MON(clocking mon_cb);
modport REF_SB(clocking ref_cb);

endinterface
