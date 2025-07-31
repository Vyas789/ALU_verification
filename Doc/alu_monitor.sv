`include "define.sv"
class alu_monitor;

//properties
alu_transaction mon_trans;
bit one_bit,found;
//mailbox for monitor to scoreboard connection 
mailbox #(alu_transaction) mbx_ms;
//virtual interface monitor modport to its instance 
virtual alu_intf vif_mon;

//coverage for the ouptut 
covergroup mon_cg;
    ERR      : coverpoint mon_trans.err   { bins err[] = {0, 1}; }
    COUT     : coverpoint mon_trans.cout  { bins cout[] = {0, 1}; }
    OFLOW    : coverpoint mon_trans.oflow { bins oflow[] = {0, 1}; }
    E        : coverpoint mon_trans.e     { bins e[] = {0, 1}; }
    G        : coverpoint mon_trans.g     { bins g[] = {0, 1}; }
    L        : coverpoint mon_trans.l     { bins l[] = {0, 1}; }
    RES      : coverpoint mon_trans.res   { bins res[] = {[0:(1<<(`n+1))-1]}; }

    OFLOW_X_RES : cross OFLOW, RES;
    ERR_X_COUT  : cross ERR, COUT;
  endgroup

function new(virtual alu_intf vif_mon,mailbox #(alu_transaction) mbx_ms);
  this.vif_mon=vif_mon;
  this.mbx_ms=mbx_ms;
  mon_cg=new();
endfunction 
//y("[%0t] [MONITOR] values from the DUT for txn #%0d: res=%0d | oflow=%0b | cout=%0b | g=%0b | l=%0b | e=%0b | err=%0b",$time, i,mon_trans.res, mon_trans.oflow, mon_trans.cout,mon_trans.g,mon_trans.l,mon_trans.e,mon_trans.err);task to co;;ect the output from the interface 
task start();
repeat(4) @(vif_mon.mon_cb);
for (int i=0;i<`num_transaction;i++)
    begin
  mon_trans=new();
  mon_cg.sample();
    one_bit=0;
    found=0;
      while(!found) begin
        @(vif_mon.mon_cb)
        begin
          if(vif_mon.mon_cb.inp_valid == 2'b11) 
    begin
            found = 1;
            $display("Monitor detected valid two-operand transaction at %0t", $time);
          end
          else if(vif_mon.mon_cb.inp_valid == 2'b00) 
     begin
            found = 1;
            $display("Monitor detected direct transaction at %0t", $time);
          end
          else if(vif_mon.mon_cb.inp_valid == 2'b01 || vif_mon.mon_cb.inp_valid == 2'b10) begin
            one_bit = 0;

            if(vif_mon.mon_cb.mode == 1) begin
              if(!(vif_mon.mon_cb.cmd inside {0,1,2,3,8,9,10})) begin
                one_bit = 1;
              end
        end
            else if(vif_mon.mon_cb.mode == 0) begin
              if(!(vif_mon.mon_cb.cmd inside {0,1,2,3,4,5,12,13})) begin
                one_bit = 1;
              end
            end

            if(one_bit) begin
              found = 1;
              $display("Monitor detected single-operand transaction at %0t", $time);
            end
          end

          if(found) begin
            mon_trans.res=vif_mon.mon_cb.res;
            mon_trans.err=vif_mon.mon_cb.err;
            mon_trans.cout=vif_mon.mon_cb.cout;
            mon_trans.g=vif_mon.mon_cb.g;
            mon_trans.l=vif_mon.mon_cb.l;
            mon_trans.e=vif_mon.mon_cb.e;
            mon_trans.oflow=vif_mon.mon_cb.oflow;

            mbx_ms.put(mon_trans);
            //$display("Monitor values from the DUT @ %0t for transaction %0d:OPA=%0d,OPB=%0d,CIN=%0d,CE=%0d,MODE=%0d,CMD=%0d,INP_VALID=%0d,RES=%0d,ERR=%0d,OFLOW=%0d,G=%0d,L=%0d,E=%0d",$time,i+1,vif_mon.mon_cb.opa,vif_mon.mon_cb.opb,vif_mon.mon_cb.cin,vif_mon.mon_cb.ce,vif_mon.mon_cb.mode,vif_mon.mon_cb.cmd,vif_mon.mon_cb.inp_valid,vif_mon.mon_cb.res,vif_mon.mon_cb.err,vif_mon.mon_cb.oflow,vif_mon.mon_cb.g,vif_mon.mon_cb.l,vif_mon.mon_cb.e);
          end
        end
      end 
        $display("OUTPUT COVERAGE :%0d",mon_cg.get_coverage());
end
endtask
endclass
