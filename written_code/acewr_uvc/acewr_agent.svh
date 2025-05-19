//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_agent.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Agent for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_agent extends uvm_agent;
  
  `uvm_component_utils (acewr_agent)

  // interfaces declaration (items)
  acewr_sequencer                      m_sequencer;
  acewr_master_driver                  m_master_drv;
  acewr_slave_driver                   m_slave_drv;
  acewr_monitor                        m_monitor;
  acewr_config                         m_wr_config;

  function new (string name = "acewr_agent" , uvm_component parent = null); //agent constructor
    super.new (name, parent);
  endfunction: new

  //If Agent Is Active, create Driver and Sequencer, else skip
  //Always create Monitor regardless of Agent's nature

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    if(!uvm_config_db#(acewr_config)::get(this, "", "m_wr_config", m_wr_config))
      `uvm_fatal("NOCONFIG", {"Config object not set for: %s", get_full_name()})

    if(!uvm_config_db #(virtual acewr_if)::get(this, "" , "acewr_if" , m_wr_config.v_if))
    `uvm_fatal (get_type_name() , "Didn't get handle to virtual interface v_if")

    m_monitor = acewr_monitor::type_id::create("m_monitor",this); // creating the monitor
    m_monitor.v_if = m_wr_config.v_if; // connecting the monitor through virtual interface
   
    if(m_wr_config.is_active == UVM_ACTIVE) begin
      if(m_wr_config.agent_type == MASTER) begin
        m_sequencer =  acewr_sequencer::type_id::create("m_sequencer",this);
        m_master_drv = acewr_master_driver::type_id::create("m_master_drv",this);
        m_master_drv.v_if = m_wr_config.v_if;
      end
      else begin
        m_sequencer =  acewr_sequencer::type_id::create("m_sequencer",this);
        m_slave_drv = acewr_slave_driver::type_id::create("m_slave_drv",this);
        m_slave_drv.v_if = m_wr_config.v_if;
      end
    end

  endfunction: build_phase

  //Connecting components
  virtual function void connect_phase (uvm_phase phase);
    if(m_wr_config.is_active == UVM_ACTIVE)
      if(m_wr_config.agent_type == MASTER)
        m_master_drv.seq_item_port.connect(m_sequencer.seq_item_export); //Connecting sequencer export port with the master driver port
      else
        m_slave_drv.seq_item_port.connect(m_sequencer.seq_item_export); // Connecting sequencer export port with the slave driver port
        m_monitor.mon_request_port.connect(m_sequencer.request_export);
        m_sequencer.request_export.connect(m_sequencer.request_fifo.analysis_export);
  endfunction: connect_phase
  
endclass: acewr_agent