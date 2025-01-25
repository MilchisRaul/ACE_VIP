//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023 
//  File name             : ace_virtual_sequencer.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Virtual Sequencer for ACE Verification Environment
//  ======================================================================================================

class ace_virtual_sequencer extends uvm_sequencer;

  `uvm_component_utils(ace_virtual_sequencer)

  aceread_config m_config;

  aceread_sequencer   m_aceread_master_seqr;
  aceread_sequencer   m_aceread_slave_seqr;
  
  acewr_sequencer   m_acewr_master_seqr;
  acewr_sequencer   m_acewr_slave_seqr;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction : build_phase

endclass : ace_virtual_sequencer