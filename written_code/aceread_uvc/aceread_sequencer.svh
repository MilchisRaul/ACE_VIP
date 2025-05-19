//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : aceread_sequencer.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          25/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequencer for AXI4Read Verification IP (UVC)
//  ======================================================================================================

class aceread_sequencer extends uvm_sequencer#(aceread_item);

  `uvm_component_utils(aceread_sequencer)

  aceread_config m_read_config;
  uvm_analysis_export #(aceread_item) request_export;
  uvm_tlm_analysis_fifo #(aceread_item) request_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    request_export = new("request_export" , this);
    request_fifo = new("request_fifo" , this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(aceread_config)::get(this, "", "m_read_config", m_read_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase



endclass : aceread_sequencer