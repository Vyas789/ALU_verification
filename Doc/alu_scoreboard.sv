`include "define.sv"

class alu_scoreboard;

  // Match/Mismatch counters
  int match = 0;
  int mismatch = 0;

  // Transaction handles
  alu_transaction ref2sb_trans, mon2sb_trans;

  // Mailboxes
  mailbox #(alu_transaction) mbx_rs;
  mailbox #(alu_transaction) mbx_ms;

  // Constructor
  function new(mailbox #(alu_transaction) mbx_rs,
               mailbox #(alu_transaction) mbx_ms);
    this.mbx_rs = mbx_rs;
    this.mbx_ms = mbx_ms;
  endfunction

  // Compare function
  function void compare();
    if ((ref2sb_trans.res    === mon2sb_trans.res)  &&  
        (ref2sb_trans.cout   === mon2sb_trans.cout) &&
        (ref2sb_trans.oflow  === mon2sb_trans.oflow)&&
        (ref2sb_trans.e      === mon2sb_trans.e)    &&  
        (ref2sb_trans.g      === mon2sb_trans.g)    &&  
        (ref2sb_trans.l      === mon2sb_trans.l)    &&  
        (ref2sb_trans.err    === mon2sb_trans.err)) begin
      match++;
    end else begin
      mismatch++;
      $display("scb mismatch  @%0t", $time);
      $display("  REF: res=%0d, cout=%b, oflow=%b, e=%b, g=%b, l=%b, err=%b",
               ref2sb_trans.res, ref2sb_trans.cout, ref2sb_trans.oflow,
               ref2sb_trans.e,   ref2sb_trans.g,    ref2sb_trans.l, 
               ref2sb_trans.err);
      $display("  MON: res=%0d, cout=%b, oflow=%b, e=%b, g=%b, l=%b, err=%b", 
               mon2sb_trans.res, mon2sb_trans.cout, mon2sb_trans.oflow, 
               mon2sb_trans.e,   mon2sb_trans.g,    mon2sb_trans.l,  
               mon2sb_trans.err);
    end 
  endfunction

  // Scoreboard main task
  task start();
    for (int i = 0; i < `num_transaction; i++) begin
      ref2sb_trans = new();
      mon2sb_trans = new();
    
      // Receive transactions in parallel
      fork
        begin
          mbx_rs.get(ref2sb_trans);
          $display("scb-ref mailbox @%0t value from the reference modeltX=%0d: res=%0d, cout=%b, oflow=%b, e=%b, g=%b, l=%b, err=%b",
                   $time, i,
                   ref2sb_trans.res, ref2sb_trans.cout, ref2sb_trans.oflow,
                   ref2sb_trans.e,   ref2sb_trans.g,    ref2sb_trans.l,
                   ref2sb_trans.err);
        end
        begin
          mbx_ms.get(mon2sb_trans);
          $display("scb-mon mailbox @%0t value from the monitor TX=%0d: res=%0d, cout=%b, oflow=%b, e=%b, g=%b, l=%b, err=%b",
                   $time, i,
                   mon2sb_trans.res, mon2sb_trans.cout, mon2sb_trans.oflow,
                   mon2sb_trans.e,   mon2sb_trans.g,    mon2sb_trans.l,
                   mon2sb_trans.err);
        end
      join

      // Compare and log counts
      compare();
      $display("scb  Matches=%0d, Mismatches=%0d", match, mismatch);
    end 
  $display("----------------------------------------------------------");
  endtask

endclass

