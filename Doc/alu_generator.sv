`include "define.sv"

class alu_generator;
//properties 
alu_transaction blueprint;
//mailbox for generator to driver  connection
mailbox #(alu_transaction) mbx_gd;

//methods 
//explicitly overriding the constructor to make the mailbox connection from generator to driver 
function new(mailbox #(alu_transaction) mbx_gd);
  this.mbx_gd=mbx_gd;
  blueprint=new(); 
endfunction

//generate task to give random stimuli
task start();

for(int i=0;i<`num_transaction;i++) begin
  //blueprint=new();
  if (blueprint.randomize())
    $display("randomization successfull");
  else
    $display("randomization failed");
  mbx_gd.put(blueprint.copy);
   $display(" %0t GENERATOR: Transaction %0d => opa = %0d, opb = %0d, cin = %0b, ce = %0b, mode = %0b, inp_valid = %0b, cmd = %0d",
               $time, i, blueprint.opa, blueprint.opb, blueprint.cin,
               blueprint.ce, blueprint.mode, blueprint.inp_valid,
               blueprint.cmd);
end
$display("-----------------------------------------------------------------------");
endtask
endclass
