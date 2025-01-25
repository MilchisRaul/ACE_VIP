//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_sequencer.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequencer for ACE Verification IP (UVC)
//  ======================================================================================================

class ace_sequencer extends uvm_sequencer#(ace_item);

  `uvm_component_utils(ace_sequencer)

  ace_config m_config;
  uvm_analysis_export #(ace_item) request_export;
  uvm_tlm_analysis_fifo #(ace_item) request_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    request_export = new("request_export" , this);
    request_fifo = new("request_fifo" , this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(ace_config)::get(this, "", "m_config", m_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase



endclass : ace_sequencer