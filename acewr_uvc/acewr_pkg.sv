//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : ACEWR Verification IP (UVC) Package
//  ======================================================================================================

package acewr_pkg;
  import uvm_pkg::*;
  //compiled in order
  `include "uvm_macros.svh"
  `include "acewr_type_def.svh"
  `include "acewr_item.svh"
  `include "acewr_config.svh"
  `include "acewr_master_driver.svh"
  `include "acewr_slave_driver.svh"
  `include "acewr_monitor.svh"
  `include "acewr_sequencer.svh"
  `include "acewr_agent.svh"
  `include "acewr_seq_lib.svh"
    
endpackage: acewr_pkg