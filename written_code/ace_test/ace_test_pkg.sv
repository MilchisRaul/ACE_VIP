//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_test_pkg.sv
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test Package for ACE Verification Environment
//  ======================================================================================================

package ace_test_pkg;

  import uvm_pkg::*;

  import aceread_pkg::*;
  import acewr_pkg::*;
  import ace_tb_pkg::*;

  `include "uvm_macros.svh"
  `include "ace_vsequence_lib.svh"
  `include "ace_test_lib.svh"

endpackage : ace_test_pkg