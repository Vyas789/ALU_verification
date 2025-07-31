`include "alu_interface.sv"
`include "alu_transaction.sv"
`include "defines.sv"

class alu_reference_model;

mailbox #(alu_transaction) mbx_dr;
mailbox #(alu_transaction) mbx_rs;
alu_transaction ref_trans;
virtual alu_intf.REF_SB vif_ref;

function new(mailbox #(alu_transaction) mbx_dr,
               mailbox #(alu_transaction) mbx_rs,
               virtual alu_intf vif_ref);
    this.mbx_dr=mbx_dr;
    this.mbx_rs=mbx_rs;
    this.vif_ref=vif_ref;
endfunction

int shift_value,flag;
localparam int required_bits = $clog2(`n);

task start();   //mimic the functionality and of the design
  for(int i=0;i<`num_transaction;i++)
    begin
      flag=0;
      ref_trans=new();
      mbx_dr.get(ref_trans);
      @(vif_ref.ref_cb)
       begin
         if(vif_ref.ref_cb.reset==1)
           begin
             ref_trans.res=0;
             ref_trans.oflow=0;
             ref_trans.cout=0;
             ref_trans.g=0;
             ref_trans.l=0;
             ref_trans.e=0;
             ref_trans.err=0;
           end
         else
	     ref_trans.res=0;
             ref_trans.oflow=0;
             ref_trans.cout=0;
             ref_trans.g=0;
             ref_trans.l=0;
             ref_trans.e=0;
             ref_trans.err=0;

           begin
             if(ref_trans.ce==1)
              begin
                   if(ref_trans.inp_valid == 2'b01 || ref_trans.inp_valid == 2'b10)
                   begin // begin for input valid
		   if(((ref_trans.mode==1)&& (ref_trans.cmd inside {0,1,2,3,8,9,10})) || ((ref_trans.mode==0)&& (ref_trans.cmd inside {0,1,2,3,4,5,12,13})))
		       begin //begin for 2 operation cmd
                           repeat(16) @(vif_ref.ref_cb)
			   begin  //begin for 16 clock cycle
                              if(ref_trans.inp_valid==2'b11)
                              begin
                          	flag=1;
                          	if(ref_trans.mode==1)
                            	begin
                               	   case(ref_trans.cmd)
                                  `ADD:begin
                                           ref_trans.res=(ref_trans.opa+ref_trans.opb);
                                           ref_trans.cout=ref_trans.res[`n]?1:0;
                                        end
                                   `SUB:begin
                                           ref_trans.res=(ref_trans.opa-ref_trans.opb);
                                           ref_trans.oflow=(ref_trans.opa<ref_trans.opb)?1:0;
                                           end
                                   `ADD_CIN:begin        
                                           ref_trans.res=(ref_trans.opa+ref_trans.opb+ref_trans.cin);
                                           ref_trans.cout=ref_trans.res[`n]?1:0;
                                            end
                                   `SUB_CIN:begin
                                            ref_trans.res=(ref_trans.opa-ref_trans.opb-ref_trans.cin);
                                            ref_trans.oflow=((ref_trans.opa<ref_trans.opb)||((ref_trans.opa==ref_trans.opb)&&ref_trans.cin))?1:0;
                                          end
                                  `CMP:begin
                                            ref_trans.e=(ref_trans.opa==ref_trans.opb)? 1'b1:1'b0;
                                            ref_trans.g=(ref_trans.opa>ref_trans.opb)? 1'b1:1'b0;
                                            ref_trans.l=(ref_trans.opa<ref_trans.opb)? 1'b1:1'b0;
                                          end
                                  `INC_MUL:begin
                                            ref_trans.res=(ref_trans.opa+1)*(ref_trans.opb+1);
                                          end
                                  `SHIFT_MUL:begin
                                            ref_trans.res=(ref_trans.opa<<1)*(ref_trans.opb);
                                            end
                                  default:begin
                                               ref_trans.res=0;
                                               ref_trans.oflow=0;
                                               ref_trans.cout=0;
                                               ref_trans.g=0;
                                               ref_trans.l=0;
                                               ref_trans.e=0;
                                               ref_trans.err=0;
                                          end
                                   endcase
                            end
                        else   //for mode 0 operations
                        begin
                         case(ref_trans.cmd)
                        `AND:begin
                                ref_trans.res={1'b0,(ref_trans.opa & ref_trans.opb)};
                            end
                        `NAND:begin
                               ref_trans.res={1'b0,~(ref_trans.opa & ref_trans.opb)};
                            end
                        `OR:begin
                               ref_trans.res={1'b0,(ref_trans.opa | ref_trans.opb)};
                            end
                        `NOR:begin
                               ref_trans.res={1'b0,~(ref_trans.opa | ref_trans.opb)};
                            end
                        `XOR:begin
                               ref_trans.res={1'b0,(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `XNOR:begin
                                ref_trans.res={1'b0,~(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa<<shift_value)|(ref_trans.opa>>`n-shift_value))};
                                 if(ref_trans.opb>`n-1)
                                  ref_trans.err<=1;
                                 else
                                  ref_trans.err<=0;
                                end
                        `ROR_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa>>shift_value)|(ref_trans.opa<<`n-shift_value))};
                                if(ref_trans.opb>`n-1)
                                  ref_trans.err<=1;
                                 else
                                  ref_trans.err<=0;
                                end   
                        default:begin
                               ref_trans.res=0;
                               ref_trans.oflow=0;
                               ref_trans.cout=0;
                               ref_trans.g=0;
                               ref_trans.l=0;
                               ref_trans.e=0;
                              ref_trans.err=0;
                              end
                      endcase
                      end
		   if(flag==1 && ref_trans.err==0) begin
                       ref_trans.err=0;
		       break;
		      end
                   else
                       ref_trans.err=1;
                  end   //end if 11 case
                     else 
			ref_trans.err=1;
                   end //end of 16 clock cyle loop
                end   // end of 2 operand command
                else if((ref_trans.mode==1 && ref_trans.cmd inside {4,5,6,7}) || (ref_trans.mode==0 && ref_trans.cmd inside {6,7,8,9,10,11}))
                 begin
		     if(ref_trans.mode)
                   begin
                     case(ref_trans.cmd)
              `INC_A:begin
                     repeat(1)@(vif_ref.ref_cb);
                        ref_trans.res=ref_trans.opa+1;
                    end
              `DEC_A:begin
                     repeat(1)@(vif_ref.ref_cb);
                        ref_trans.res=ref_trans.opa-1;
                    end
              `INC_B:begin
                      repeat(1)@(vif_ref.ref_cb);
                        ref_trans.res=ref_trans.opb+1;
                    end
              `DEC_B:begin
                      repeat(1)@(vif_ref.ref_cb);
                        ref_trans.res=ref_trans.opb-1;
                    end
              default:begin
                        ref_trans.res=0;
                        ref_trans.oflow=0;
                        ref_trans.cout=0;
                        ref_trans.g=0;
                        ref_trans.l=0;
                        ref_trans.e=0;
                        ref_trans.err=0;
                      end
             endcase
                   end
                 else
                   begin
                     case(ref_trans.cmd)
              		`NOT_A:begin	
                        	ref_trans.res=~(ref_trans.opa);
                    		end
              		`NOT_B:begin
                        	ref_trans.res=~(ref_trans.opb);
                   		end
              		`SHR1_A:begin
                       		ref_trans.res=(ref_trans.opa>>1);
                    		end
			`SHL1_A:begin
                        	ref_trans.res=(ref_trans.opa<<1);
                    		end
              		`SHR1_B:begin
                      		 ref_trans.res=(ref_trans.opb>>1);
                    		end
              		`SHL1_B:begin
                       		 ref_trans.res=(ref_trans.opb<<1);
                    		end
              		default:begin
                       		 ref_trans.res=0;
                       		 ref_trans.oflow=0;
                        	 ref_trans.cout=0;
                        	 ref_trans.g=0;
                      		 ref_trans.l=0;
                        	 ref_trans.e=0;
                        	 ref_trans.err=0;
                      		end
            	     endcase
                   end
             else    //else if 11 bcz 00 is constrained
  		begin
      		if(ref_trans.mode==1)
       		 begin
            		case(ref_trans.cmd)
                             `ADD:begin
                                        ref_trans.res=(ref_trans.opa+ref_trans.opb);
                                        ref_trans.cout=ref_trans.res[`n]?1:0;
                                         end
                                 `SUB:begin
                                        ref_trans.res=(ref_trans.opa-ref_trans.opb);
                                        ref_trans.oflow=(ref_trans.opa<ref_trans.opb)?1:0;
                                         end
                                 `ADD_CIN:begin
                                                ref_trans.res=(ref_trans.opa+ref_trans.opb+ref_trans.cin);
                                                ref_trans.cout=ref_trans.res[`n]?1:0;
                                         end
                                `SUB_CIN:begin
                                                ref_trans.res=(ref_trans.opa-ref_trans.opb-ref_trans.cin);
                                                ref_trans.oflow=((ref_trans.opa<ref_trans.opb)||((ref_trans.opa==ref_trans.opb)&&ref_trans.cin))?1:0;
                                    end
                            `CMP:begin
                                        ref_trans.e=(ref_trans.opa==ref_trans.opb)? 1'b1:1'b0;
                                        ref_trans.g=(ref_trans.opa>ref_trans.opb)? 1'b1:1'b0;
                                        ref_trans.l=(ref_trans.opa<ref_trans.opb)? 1'b1:1'b0;
                                end
                           `INC_MUL:begin
                                        ref_trans.res=(ref_trans.opa+1)*(ref_trans.opb+1);
                                   end
                           `SHIFT_MUL:begin
                                        ref_trans.res=(ref_trans.opa<<1)*(ref_trans.opb);
                                     end
                           `INC_A:begin
                                   ref_trans.res=ref_trans.opa+1;
                                  end
                           `DEC_A:begin
                                  ref_trans.res=ref_trans.opa-1;
                                  end
                          `INC_B:begin
                                  ref_trans.res=ref_trans.opb+1;
                                 end
                         `DEC_B:begin
                                 ref_trans.res=ref_trans.opb-1;
                                end
                           default:begin
                                        ref_trans.res=0;
                                        ref_trans.oflow=0;
                                        ref_trans.cout=0;
                                        ref_trans.g=0;
                                        ref_trans.l=0;
                                        ref_trans.e=0;
                                        ref_trans.err=0;
                                   end
                        endcase
                    end  //end of if mode==1
                  else    //else part for mode=0
                    begin
                      case(ref_trans.cmd)
                        `AND:begin
                                ref_trans.res={1'b0,(ref_trans.opa & ref_trans.opb)};
                            end
                        `NAND:begin
                               ref_trans.res={1'b0,~(ref_trans.opa & ref_trans.opb)};
                            end
                        `OR:begin
                               ref_trans.res={1'b0,(ref_trans.opa | ref_trans.opb)};
                            end
                        `NOR:begin
                               ref_trans.res={1'b0,~(ref_trans.opa | ref_trans.opb)};
                            end
                        `XOR:begin
                               ref_trans.res={1'b0,(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `XNOR:begin
                                ref_trans.res={1'b0,~(ref_trans.opa ^ ref_trans.opb)};
                            end
                        `ROL_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa<<shift_value)|(ref_trans.opa>>`n-shift_value))};
                                 if(ref_trans.opb>`n-1)
                                  ref_trans.err<=1;
                                 else
                                  ref_trans.err<=0;
                                end
                        `ROR_A_B:begin
                                 shift_value=ref_trans.opb[required_bits-1:0];
                                 ref_trans.res={1'b0,((ref_trans.opa>>shift_value)|(ref_trans.opa<<`n-shift_value))};
                                if(ref_trans.opb>`n-1)
                                  ref_trans.err<=1;
                                 else
                                  ref_trans.err<=0;
                                end
                         `NOT_A:begin;
                                 ref_trans.res=~(ref_trans.opa);
                                end
                         `NOT_B:begin
                                ref_trans.res=~(ref_trans.opb);
                                end
                         `SHR1_A:begin
                                 ref_trans.res=(ref_trans.opa>>1);
                                 end
                        `SHL1_A:begin
                                ref_trans.res=(ref_trans.opa<<1);
                                end
                        `SHR1_B:begin
                                 ref_trans.res=(ref_trans.opb>>1);
                                end
                        `SHL1_B:begin
                                 ref_trans.res=(ref_trans.opb<<1);
                                end

                        default:begin
                                 ref_trans.res=0;
                                 ref_trans.oflow=0;
                                 ref_trans.cout=0;
                                 ref_trans.g=0;
                                 ref_trans.l=0;
                                 ref_trans.e=0;
                                 ref_trans.err=0;
                              end
                      endcase
                  end       //end of else mode==0
            end        //end of inp_valid=11 directly case
        end    //end of ce=1
     else   //if ce=0
    begin
       ref_trans.res=0;
       ref_trans.oflow=0;
       ref_trans.cout=0;
       ref_trans.g=0;
       ref_trans.l=0;
       ref_trans.e=0;
       ref_trans.err=0;
     end
  end   //end of else loop for reset!=1
repeat(1)@(vif_ref.ref_cb);
mbx_rs.put(ref_trans);   //put to the mailbox
end   //end of for loop

endtask
endclass
