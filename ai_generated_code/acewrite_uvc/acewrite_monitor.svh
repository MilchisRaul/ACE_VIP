class acewrite_monitor extends uvm_monitor;

  `uvm_component_utils (acewrite_monitor)

  acewrite_item item;
  // Analysis port to send transactions to other components
  uvm_analysis_port #(acewrite_item) analysis_port;

  // Virtual interface for the ACE Write Interface
  virtual acewrite_if vif;
  acewrite_config     m_wr_config;

  // Constructor
  function new(string name = "acewrite_monitor", uvm_component parent = null);
    super.new(name, parent);
    analysis_port = new("analysis_port", this);
  endfunction

  // Build phase to get the virtual interface
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item = acewrite_item::type_id::create("item");
  endfunction

  // Run phase to monitor the signals and capture transactions
  task run_phase(uvm_phase phase);
    forever begin
      @(posedge vif.clk);
      capture_address_channel();
      capture_data_channel();
      capture_response_channel();
      capture_snoop_address_channel();
      capture_snoop_response_channel();
      capture_snoop_data_channel();
      analysis_port.write(item);
    end
  endtask

  // Task to capture the address channel
  task capture_address_channel();

    if (vif.awvalid && vif.awready) begin
      item.awaddr   = vif.awaddr;
      item.awlen    = vif.awlen;
      item.awsize   = vif.awsize;
      item.awburst  = vif.awburst;
      item.awcache  = vif.awcache;
      item.awprot   = vif.awprot;
      item.awqos    = vif.awqos;
      item.awregion = vif.awregion;
      item.awid     = vif.awid;
      item.awsnoop  = vif.acsnoop;
      item.awdomain = vif.awuser[1:0]; // Assuming awdomain is part of awuser
      item.awbar    = vif.awuser[3:2];    // Assuming awbar is part of awuser
    end
  endtask

  // Task to capture the data channel
  task capture_data_channel();

    if (vif.wvalid && vif.wready) begin
      item.wdata = vif.wdata;
      item.wstrb = vif.wstrb;
    end
  endtask

  // Task to capture the response channel
  task capture_response_channel();

    if (vif.bvalid && vif.bready) begin
      item.bresp = vif.bresp;
      item.bid   = vif.bid;
      analysis_port.write(item);
    end
  endtask

  // Task to capture the snoop address channel (AC)
  task capture_snoop_address_channel();

    if (vif.acvalid && vif.acready) begin
      item.awaddr  = vif.acaddr;
      item.awsnoop = vif.acsnoop;
      item.awprot  = vif.acprot;
    end
  endtask

  // Task to capture the snoop response channel (CR)
  task capture_snoop_response_channel();

    if (vif.crvalid && vif.crready) begin
      item.bresp = vif.crresp[1:0]; // Assuming bresp is part of crresp
    end
  endtask

  // Task to capture the snoop data channel (CD)
  task capture_snoop_data_channel();
    // if (vif.cdvalid && vif.cdready) begin
    //   item.wdata = vif.cddata[31:0]; // Assuming wdata is part of cddata
    //   item.wlast = vif.cdlast;
    // end
  endtask

endclass : acewrite_monitor