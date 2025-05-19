//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_sequencer.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequencer for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_sequencer extends uvm_sequencer#(acewr_item);

  `uvm_component_utils(acewr_sequencer)

  acewr_config m_wr_config;
  uvm_analysis_export #(acewr_item) request_export;
  uvm_tlm_analysis_fifo #(acewr_item) request_fifo;

  function new(string name, uvm_component parent);
    super.new(name, parent);
    request_export = new("request_export" , this);
    request_fifo = new("request_fifo" , this);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if(!uvm_config_db#(acewr_config)::get(this, "", "m_wr_config", m_wr_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})
  endfunction : build_phase



endclass : acewr_sequencer