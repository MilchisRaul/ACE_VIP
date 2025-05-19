class acewrite_slave_driver extends uvm_driver #(acewrite_item);

  `uvm_component_utils (acewrite_slave_driver)

  // Virtual interface for the ACE Write Interface
  virtual acewrite_if vif;
  acewrite_config    m_wr_config;

    // Mailboxes for internal communication
  mailbox #(acewrite_item) aw_mb;
  mailbox #(acewrite_item) w_mb;
  mailbox #(acewrite_item) b_mb;
  mailbox #(acewrite_item) ac_mb;
  mailbox #(acewrite_item) cd_mb;
  mailbox #(acewrite_item) cr_mb;

  // Constructor
  function new(string name = "acewrite_slave_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase to get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Initialize mailboxes
    aw_mb = new();
    w_mb = new();
    b_mb = new();
    ac_mb = new();
    cd_mb = new();
    cr_mb = new();
  endfunction

    // Run phase
  task run_phase(uvm_phase phase);
    phase.raise_objection(this);

    fork
      process_aw_channel();
      process_w_channel();
      process_b_channel();
      process_ac_channel();
      process_cd_channel();
      process_cr_channel();
    join

    phase.drop_objection(this);
  endtask

  // Task to process the Address Write Channel
  task process_aw_channel();
    acewrite_item item;
    forever begin
      aw_mb.get(item);
      vif.awaddr <= item.awaddr;
      vif.awburst <= item.awburst;
      vif.awcache <= item.awcache;
      vif.awid <= item.awid;
      vif.awlen <= item.awlen;
      vif.awprot <= item.awprot;
      vif.awsize <= item.awsize;
      vif.awqos <= item.awqos;
      vif.awregion <= item.awregion;
      vif.awuser <= item.awuser;
      vif.awlock <= item.awlock;
      vif.awvalid <= 1;
      @(posedge vif.clk);
      while (!vif.awready)
        @(posedge vif.clk);
      vif.awvalid <= 0;
    end
  endtask

  // Task to process the Data Write Channel
  task process_w_channel();
    acewrite_item item;
    forever begin
      w_mb.get(item);
      vif.wdata <= item.wdata;
      vif.wstrb <= item.wstrb;
      vif.wuser <= item.wuser;
      vif.wvalid <= 1;
      @(posedge vif.clk);
      while (!vif.wready)
        @(posedge vif.clk);
      vif.wvalid <= 0;
    end
  endtask

  // Task to process the Response Channel
  task process_b_channel();
    acewrite_item item;
    forever begin
      b_mb.get(item);
      vif.bid <= item.bid;
      vif.bresp <= item.bresp;
      vif.buser <= item.buser;
      vif.bvalid <= 1;
      @(posedge vif.clk);
      while (!vif.bready)
        @(posedge vif.clk);
      vif.bvalid <= 0;
    end
  endtask

  // Task to process the Snoop Address Channel
  task process_ac_channel();
    acewrite_item item;
    forever begin
      ac_mb.get(item);
      vif.acaddr <= item.acaddr;
      vif.acsnoop <= item.acsnoop;
      vif.acprot <= item.acprot;
      vif.acvalid <= 1;
      @(posedge vif.clk);
      while (!vif.acready)
        @(posedge vif.clk);
      vif.acvalid <= 0;
    end
  endtask

  // Task to process the Snoop Data Channel
  task process_cd_channel();
    acewrite_item item;
    forever begin
      cd_mb.get(item);
      vif.cddata <= item.cdata;
      vif.cdvalid <= 1;
      @(posedge vif.clk);
      while (!vif.cdready)
        @(posedge vif.clk);
      vif.cdvalid <= 0;
    end
  endtask

  // Task to process the Snoop Response Channel
  task process_cr_channel();
    acewrite_item item;
    forever begin
      cr_mb.get(item);
      vif.crresp <= item.crresp;
      vif.crvalid <= 1;
      @(posedge vif.clk);
      while (!vif.crready)
        @(posedge vif.clk);
      vif.crvalid <= 0;
    end
  endtask

endclass : acewrite_slave_driver