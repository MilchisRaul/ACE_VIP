//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_tb.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Test Bench for ACE Verification Environment
//  ======================================================================================================

class ace_tb extends uvm_env;

  `uvm_component_utils(ace_tb)

  aceread_agent              m_aceread_mst_agent;
  aceread_agent              m_aceread_slv_agent;
  acewr_agent                m_acewr_mst_agent;
  acewr_agent                m_acewr_slv_agent;

  //axi4wr_scoreboard        m_axi4wr_sb       ;
  ace_virtual_sequencer  m_aceread_vseqr;
  ace_virtual_sequencer  m_acewr_vseqr;

  aceread_config             m_read_config;
  acewr_config               m_wr_config;

  ace_proj_config        m_ace_cfg;

  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction : new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_ace_cfg = new("m_ace_cfg");
    m_ace_cfg.is_active = UVM_ACTIVE;
    m_ace_cfg.build();

    uvm_config_db#(aceread_config)::set(this, "m_aceread_mst_agent*", "m_read_config", m_ace_cfg.m_aceread_mst_cfg);
    m_aceread_mst_agent = aceread_agent::type_id::create("m_aceread_mst_agent", this);

    uvm_config_db#(aceread_config)::set(this, "m_aceread_slv_agent*", "m_read_config", m_ace_cfg.m_aceread_slv_cfg);
    m_aceread_slv_agent = aceread_agent::type_id::create("m_aceread_slv_agent", this);

    uvm_config_db#(acewr_config)::set(this, "m_acewr_mst_agent*", "m_wr_config", m_ace_cfg.m_acewr_mst_cfg);
    m_acewr_mst_agent = acewr_agent::type_id::create("m_acewr_mst_agent", this);

    uvm_config_db#(acewr_config)::set(this, "m_acewr_slv_agent*", "m_wr_config", m_ace_cfg.m_acewr_slv_cfg);
    m_acewr_slv_agent = acewr_agent::type_id::create("m_acewr_slv_agent", this);

    m_aceread_vseqr = ace_virtual_sequencer::type_id::create("m_aceread_vseqr", this);
    m_acewr_vseqr = ace_virtual_sequencer::type_id::create("m_acewr_vseqr", this);
      
    //m_axi4wr_sb    = axi4wr_scoreboard::type_id::create("m_axi4wr_sb", this);
    //m_axi4wr_sb.m_config = m_ace_cfg;

  endfunction : build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    //ACE Read
    m_aceread_vseqr.m_aceread_master_seqr = m_aceread_mst_agent.m_sequencer;
    m_aceread_vseqr.m_aceread_slave_seqr = m_aceread_slv_agent.m_sequencer;
    //ACE Write
    m_acewr_vseqr.m_acewr_master_seqr = m_acewr_mst_agent.m_sequencer;
    m_acewr_vseqr.m_acewr_slave_seqr = m_acewr_slv_agent.m_sequencer;
  endfunction : connect_phase

endclass : ace_tb