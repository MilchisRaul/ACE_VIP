//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_vsequencer_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Virtual Sequencers Library for ACE Verification Environment
//  ======================================================================================================

class ace_base_vsequence extends uvm_sequence#(uvm_sequence_item);

  `uvm_object_utils(ace_base_vsequence)

  `uvm_declare_p_sequencer(ace_virtual_sequencer)

  function new(string name = "ace_base_vsequence");
    super.new(name);
  endfunction : new

endclass : ace_base_vsequence

class aceread_master_seq extends ace_base_vsequence;

  `uvm_object_utils(aceread_master_seq)

  typedef aceread_rotrans_master_sequence aceread_master_sequence_t;
  
  function new(string name = "aceread_master_seq");
    super.new(name);
  endfunction : new

  task body();
    aceread_master_sequence_t aceread_master_sequence;
    aceread_master_sequence = aceread_master_sequence_t::type_id::create("aceread_master_sequence");
    aceread_master_sequence.start(p_sequencer.m_aceread_master_seqr);
  endtask : body

endclass : aceread_master_seq

class aceread_slave_seq extends ace_base_vsequence;

  `uvm_object_utils(aceread_slave_seq)

  typedef aceread_rotrans_slave_sequence aceread_slave_sequence_t;
  
  function new(string name = "aceread_slave_seq");
    super.new(name);
  endfunction : new

  task body();
    aceread_slave_sequence_t aceread_slave_sequence;
    aceread_slave_sequence = aceread_slave_sequence_t::type_id::create("aceread_slave_sequence");
    aceread_slave_sequence.start(p_sequencer.m_aceread_slave_seqr);
  endtask : body

endclass : aceread_slave_seq

class acewr_master_seq extends ace_base_vsequence;

  `uvm_object_utils(acewr_master_seq)

  typedef acewr_evtrans_master_sequence acewr_master_sequence_t;
  
  function new(string name = "acewr_master_seq");
    super.new(name);
  endfunction : new

  task body();
    acewr_master_sequence_t acewr_master_sequence;
    acewr_master_sequence = acewr_master_sequence_t::type_id::create("acewr_master_sequence");
    acewr_master_sequence.start(p_sequencer.m_acewr_master_seqr);
  endtask : body

endclass : acewr_master_seq

class acewr_slave_seq extends ace_base_vsequence;

  `uvm_object_utils(acewr_slave_seq)

  typedef acewr_evtrans_slave_sequence acewr_slave_sequence_t;
  
  function new(string name = "acewr_slave_seq");
    super.new(name);
  endfunction : new

  task body();
    acewr_slave_sequence_t acewr_slave_sequence;
    acewr_slave_sequence = acewr_slave_sequence_t::type_id::create("acewr_slave_sequence");
    acewr_slave_sequence.start(p_sequencer.m_acewr_slave_seqr);
  endtask : body

endclass : acewr_slave_seq