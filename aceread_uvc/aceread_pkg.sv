//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//                          25/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : AXI4WR Verification IP (UVC) Package
//  ======================================================================================================

package aceread_pkg;
  import uvm_pkg::*;
  //compiled in order
  `include "uvm_macros.svh"
  `include "aceread_type_def.svh"
  `include "aceread_item.svh"
  `include "aceread_config.svh"
  `include "aceread_master_driver.svh"
  `include "aceread_slave_driver.svh"
  `include "aceread_monitor.svh"
  `include "aceread_sequencer.svh"
  `include "aceread_agent.svh"
  `include "aceread_seq_lib.svh"
    
endpackage: aceread_pkg