//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_tb_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test Bench Package for ACE Verification Environment
//  ======================================================================================================

package ace_tb_pkg;

  import uvm_pkg::*;

  import aceread_pkg::*;   
  import acewr_pkg::*;   

  `include "uvm_macros.svh"

  `include "ace_proj_config.svh"
  `include "ace_virtual_sequencer.svh"
  //`include "ace_scoreboard.svh"
  `include "ace_tb.svh"

endpackage : ace_tb_pkg