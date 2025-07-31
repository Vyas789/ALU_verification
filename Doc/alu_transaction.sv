`include "define.sv"
class alu_transaction;

//properties
//input declared as rand variables
rand logic [`n-1:0] opa,opb;
rand logic cin;
rand logic ce; 
rand logic mode;
rand logic [1:0] inp_valid;
rand logic [`m-1:0] cmd;

//output signals not randomized 
logic [`n:0] res;
logic oflow,cout,g,l,e,err;

//constraints for the inp_valid ce and mode signals
//constraints for cmd varies from 0 to 13 for logical operations an 0 to 10 for arithmetic operationsconstraint inp_valid_constraint {inp_valid inside {2'b01,2'b10,2'b11;;}
constraint ce_constraint {ce dist {1'b0:=50,1'b1:=50};}
constraint mode_constraint {mode dist {1'b0:=50,1'b1:=50};}
constraint cmd_constraint {if (mode) 
        cmd inside {[0:10]};
          else
        cmd inside {[0:13]};
          }
//methods for copying objects 
virtual function alu_transaction copy();
  copy=new();
  copy.opa=this.opa;
  copy.opb=this.opb;
  copy.cin=this.cin;
  copy.ce=this.ce;
  copy.mode=this.mode;
  copy.inp_valid=this.inp_valid;
  copy.cmd=this.cmd;
endfunction
endclass

/*class alu_transaction_1 extends alu_transaction;
  constraint mode { mode == 0; }
  constraint cmd  { cmd inside {[6:11]}; }

  virtual function alu_transaction_1 copy();
    copy = new();
    copy.ce         = this.ce;
    copy.mode       = this.mode;
    copy.cmd        = this.cmd;
    copy.inp_valid  = this.inp_valid;
    copy.opa        = this.opa;
    copy.opb        = this.opb;
    copy.cin        = this.cin;
    return copy;
  endfunction
// arithmetic ops with single input, mode = 1, cmd = 4 to 7
class alu_transaction_2 extends alu_transaction;
  constraint mode { mode == 1; }
  constraint cmd  { cmd inside {[4:7]}; }
  constraint inp_valid { inp_valid == 2'b11; }

  virtual function alu_transaction_2 copy();
    copy = new();
    copy.ce         = this.ce;
    copy.mode       = this.mode;
    copy.cmd        = this.cmd;
    copy.inp_valid  = this.inp_valid;
    copy.opa        = this.opa;
    copy.opb        = this.opb;
    copy.cin        = this.cin;
    return copy;
  endfunction
endclass

/ arithmetic ops with two operands, mode = 1, cmd = 0 to 3, 8 to 10
class alu_transaction_4 extends alu_transaction;
  constraint mode { mode == 1; }
  constraint cmd  { cmd inside {[0:3], [8:10]}; }
  constraint inp_valid { inp_valid == 2'b11; }

  virtual function alu_transaction_4 copy();
    copy = new();
    copy.ce         = this.ce;
    copy.mode       = this.mode;
    copy.cmd        = this.cmd;
    copy.inp_valid  = this.inp_valid;
    copy.opa        = this.opa;
    copy.opb        = this.opb;
    copy.cin        = this.cin;
    return copy;
  endfunction
endclass


