class alu_driver;

//properties
  mailbox #(alu_transaction)mbx_gd;
  mailbox #(alu_transaction)mbx_dr;
  alu_transaction drv_trans;
  virtual alu_intf vif_drv;

  //coverage for the inputs
  covergroup drv_cg;

  INP_VALID:coverpoint drv_trans.inp_valid{bins inp_valid[]={0,1,2,3};}
  CMD:coverpoint drv_trans.cmd{bins cmd[]={ [0:13] }; }
  CE:coverpoint drv_trans.ce{bins ce[]={0,1};}
  CIN:coverpoint drv_trans.cin{bins cin[]={0,1};}
  MODE:coverpoint drv_trans.mode{bins mode[]={0,1};}
  OPA:coverpoint drv_trans.opa{bins opa[]={ [0:`n-1] }; }
  OPB:coverpoint drv_trans.opb{bins opb[]={ [0:`n-1] }; }
  MODE_X_INP_VALID:cross MODE,INP_VALID;
  MODE_X_CMD:cross MODE,CMD;
  OPA_X_OPB:cross OPA,OPB;
  endgroup

  function new(mailbox #(alu_transaction)mbx_gd,mailbox #(alu_transaction)mbx_dr,virtual alu_intf vif_drv);
    this.mbx_gd=mbx_gd;
    this.mbx_dr=mbx_dr;
    this.vif_drv=vif_drv;
    drv_cg=new();
  endfunction

  task start();
   repeat(3)@(vif_drv.drv_cb);
  $display("-----------------Inside driver ---------",$time);
    for(int i=0;i<`num_transaction;i++)
        begin
        drv_trans=new();
        mbx_gd.get(drv_trans);
        drv_cg.sample();
        $display("[%0t] value got from the generator: Got txn #%0d -> opa=%0d, opb=%0d, cin=%b, ce=%0d, mode=%0b, valid=%0b, cmd=%d",$time, i, drv_trans.opa, drv_trans.opb, drv_trans.cin,drv_trans.ce, drv_trans.mode, drv_trans.inp_valid, drv_trans.cmd);
      // repeat(1)@(vif_drv.drv_cb);
          if(((drv_trans.mode==1) && (drv_trans.cmd inside {0,1,2,3,8,9,10})) || ((drv_trans.mode==0) && (drv_trans.cmd inside {0,1,2,3,4,5,12,13})))
           begin
            if(drv_trans.inp_valid==2'b01 || drv_trans.inp_valid==2'b10)
              begin
              for(int j=0;j<16;j++)
                begin
                  if(drv_trans.inp_valid!=2'b11)
                    begin
                    repeat(1)@(vif_drv.drv_cb);
                    drv_trans.mode.rand_mode(0);
                    drv_trans.cmd.rand_mode(0);
                    drv_trans.ce.rand_mode(0);   // optional
                    void'( drv_trans.randomize());       // randomize again
                    vif_drv.drv_cb.opa <= drv_trans.opa;
                    vif_drv.drv_cb.opb <= drv_trans.opb;
                    vif_drv.drv_cb.cin <= drv_trans.cin;
                    vif_drv.drv_cb.ce <= drv_trans.ce;
                    vif_drv.drv_cb.cmd <= drv_trans.cmd;
                    vif_drv.drv_cb.mode <= drv_trans.mode;
                    vif_drv.drv_cb.inp_valid <= drv_trans.inp_valid;
                    //repeat(1)@(vif_drv.drv_cb);
                    //mbx_dr.put(drv_trans);
                    $display("[%0t] value till we get inp 11: put txn #%0d -> opa=%0d, opb=%0d, cin=%b, ce=%0d, mode=%0b, valid=%0b, cmd=%d",$time, i, drv_trans.opa, drv_trans.opb, drv_trans.cin,drv_trans.ce, drv_trans.mode, drv_trans.inp_valid, drv_trans.cmd);
                    end
                    else begin
                      $display("input valid got 11");
                      repeat(1)@(vif_drv.drv_cb);
                      mbx_dr.put(drv_trans);
                      break;
                    end
                 /*else begin
                    vif_drv.drv_cb.opa <= drv_trans.opa;
                    vif_drv.drv_cb.opb <= drv_trans.opb;
                    vif_drv.drv_cb.cin <= drv_trans.cin;
                    vif_drv.drv_cb.ce <= drv_trans.ce;
                    vif_drv.drv_cb.cmd <= drv_trans.cmd;
                    vif_drv.drv_cb.mode <= drv_trans.mode;
                    vif_drv.drv_cb.inp_valid <= drv_trans.inp_valid;
                    //repeat(1)@(vif_drv.drv_cb);
                    mbx_dr.put(drv_trans);
                    break;
                  end */
                end //end part for the for loop
            end    //end of if inp_valid is 01 or 10
	  else    //else part for inp_valid is 11 or 00 in the 2 operand case
          begin
        //repeat(1)@(vif_drv.drv_cb);
          vif_drv.drv_cb.opa <= drv_trans.opa;
          vif_drv.drv_cb.opb <= drv_trans.opb;
          vif_drv.drv_cb.cin <= drv_trans.cin;
          vif_drv.drv_cb.ce <= drv_trans.ce;
          vif_drv.drv_cb.cmd <= drv_trans.cmd;
          vif_drv.drv_cb.mode <= drv_trans.mode;
          vif_drv.drv_cb.inp_valid <= drv_trans.inp_valid;
          repeat(1)@(vif_drv.drv_cb);
          mbx_dr.put(drv_trans);
          $display("[%0t] value put when in comes 11 or 00 first case: put txn #%0d -> opa=%0d, opb=%0d, cin=%b, ce=%0d, mode=%0b, valid=%0b, cmd=%d",$time, i, drv_trans.opa, drv_trans.opb, drv_trans.cin,drv_trans.ce, drv_trans.mode, drv_trans.inp_valid, drv_trans.cmd);
          end
        end  //end of mode and cmd check if loop
     else  //else to check for one operand operations
       begin
        //repeat(1)@(vif_drv.drv_cb);
        vif_drv.drv_cb.opa <= drv_trans.opa;
        vif_drv.drv_cb.opb <= drv_trans.opb;
        vif_drv.drv_cb.cin <= drv_trans.cin;
        vif_drv.drv_cb.ce <= drv_trans.ce;
        vif_drv.drv_cb.cmd <= drv_trans.cmd;
        vif_drv.drv_cb.mode <= drv_trans.mode;
        vif_drv.drv_cb.inp_valid <= drv_trans.inp_valid;
        repeat(1)@(vif_drv.drv_cb);
        mbx_dr.put(drv_trans);
        $display("[%0t] value put for single operand case:put txn #%0d -> opa=%0d, opb=%0d, cin=%b, ce=%0d, mode=%0b, valid=%0b, cmd=%d",$time, i, drv_trans.opa, drv_trans.opb, drv_trans.cin,drv_trans.ce, drv_trans.mode, drv_trans.inp_valid, drv_trans.cmd);
       end
    // end
      $display("INPUT COVERAGE :%0d",drv_cg.get_coverage());
   end
  $display("-----------------Outside driver ---------",$time);
endtask
endclass

