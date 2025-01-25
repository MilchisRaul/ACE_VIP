//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_test_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test Library for ACE Verification Environment
//  ======================================================================================================

class ace_base_test extends uvm_test;

  `uvm_component_utils(ace_base_test)

  ace_tb m_tb;

  //uvm_factory factory = uvm_factory::get();

  function new(string name = "ace_base_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    m_tb = ace_tb::type_id::create("m_tb", this);
  endfunction : build_phase
  
  function void final_phase(uvm_phase phase);
    `uvm_info("@@@@@@@@~~~~~~~~~~~~| TEST PASSED |~~~~~~~~~~~~@@@@@@@@", "No errors detected", UVM_NONE)
  endfunction : final_phase

  virtual function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

endclass : ace_base_test

class aceread_fs_test extends ace_base_test;
  
  `uvm_component_utils(aceread_fs_test)

  function new(string name = "aceread_fs_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    begin
      aceread_master_seq m_aceread_vseq;
      aceread_slave_seq s_aceread_vseq;
      m_aceread_vseq = aceread_master_seq::type_id::create("m_aceread_vseq");
      s_aceread_vseq = aceread_slave_seq::type_id::create("s_aceread_vseq");
        phase.raise_objection(this);
        fork
          m_aceread_vseq.start(m_tb.m_aceread_vseqr);
          s_aceread_vseq.start(m_tb.m_aceread_vseqr);
        join
        phase.phase_done.set_drain_time(this, 1000000);
        phase.drop_objection(this);
    end
  endtask : run_phase

endclass : aceread_fs_test


class acewr_fs_test extends ace_base_test;
  
  `uvm_component_utils(acewr_fs_test)

  function new(string name = "acewr_fs_test", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    begin
      acewr_master_seq m_acewr_vseq;
      acewr_slave_seq s_acewr_vseq;
      m_acewr_vseq = acewr_master_seq::type_id::create("m_acewr_vseq");
      s_acewr_vseq = acewr_slave_seq::type_id::create("s_acewr_vseq");
        phase.raise_objection(this);
        fork
          m_acewr_vseq.start(m_tb.m_acewr_vseqr);
          s_acewr_vseq.start(m_tb.m_acewr_vseqr);
        join
        phase.phase_done.set_drain_time(this, 1000000);
        phase.drop_objection(this);
    end
  endtask : run_phase

endclass : acewr_fs_test