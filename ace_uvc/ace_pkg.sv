//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : ACE Verification IP (UVC) Package
//  ======================================================================================================

package ace_pkg;
  import uvm_pkg::*;
  //compiled in order
  `include "uvm_macros.svh"
  `include "ace_type_def.svh"
  `include "ace_item.svh"
  `include "ace_config.svh"
  `include "ace_master_driver.svh"
  `include "ace_slave_driver.svh"
  `include "ace_monitor.svh"
  `include "ace_sequencer.svh"
  `include "ace_agent.svh"
  `include "ace_seq_lib.svh"
    
endpackage : ace_pkg