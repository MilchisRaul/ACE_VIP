// Define the ACE driver class
class acewrite_master_driver extends uvm_driver #(acewrite_item);

  `uvm_component_utils (acewrite_master_driver)

  // Virtual interface handle
  virtual acewrite_if vif;

  // Mailboxes for inter-task communication
  mailbox #(acewrite_item) aw_mb;
  mailbox #(acewrite_item) w_mb;
  mailbox #(acewrite_item) b_mb;
  mailbox #(acewrite_item) ac_mb;
  mailbox #(acewrite_item) cd_mb;
  mailbox #(acewrite_item) cr_mb;

  // Constructor
  function new(string name = "acewrite_master_driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual acewrite_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", "Virtual interface not found")
    end
    aw_mb = new();
    w_mb = new();
    b_mb = new();
    ac_mb = new();
    cd_mb = new();
    cr_mb = new();
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    forever begin
      acewrite_item req;
      seq_item_port.get_next_item(req);

      // Drive transactions for each ACE channel
      fork
        drive_aw_channel(req);
        drive_w_channel(req);
        drive_b_channel(req);
        drive_ac_channel(req);
        drive_cd_channel(req);
        drive_cr_channel(req);
    join

      seq_item_port.item_done();
    end
  endtask

  // Driving Address Write Channel
  task drive_aw_channel(acewrite_item req);
    vif.awaddr <= req.awaddr;
    vif.awid   <= req.awid;
    vif.awburst <= req.awburst;
    vif.awcache <= req.awcache;
    vif.awlen <= req.awlen;
    vif.awprot <= req.awprot;
    vif.awsize <= req.awsize;
    vif.awqos <= req.awqos;
    vif.awregion <= req.awregion;
    vif.awuser <= req.awuser;
    vif.awlock <= req.awlock;
    vif.awsnoop <= req.awsnoop;
    vif.awdomain <= req.awdomain;
    vif.awbar <= req.awbar;
    vif.awunique <= req.awunique;
        vif.awvalid <= 1'b1;
    wait(vif.awready);
        vif.awvalid <= 1'b0;
  endtask

  // Driving Data Write Channel
  task drive_w_channel(acewrite_item req);
    vif.wdata <= req.wdata;
    vif.wstrb <= req.wstrb;
    vif.wuser <= req.wuser;
        vif.wvalid <= 1'b1;
    wait(vif.wready);
        vif.wvalid <= 1'b0;
  endtask

  // Driving Response Channel
  task drive_b_channel(acewrite_item req);
    wait(vif.bvalid);
    req.bid <= vif.bid;
    req.bresp <= vif.bresp;
    req.buser <= vif.buser;
    vif.bready <= 1'b1;
    vif.bready <= 1'b0;
  endtask

  // Driving Snoop Address Channel
  task drive_ac_channel(acewrite_item req);
    vif.acaddr <= req.acaddr;
    vif.acsnoop <= req.acsnoop;
    vif.acprot <= req.acprot;
    vif.acvalid <= 1'b1;
    wait(vif.acready);
    vif.acvalid <= 1'b0;
  endtask

  // Driving Snoop Data Channel
  task drive_cd_channel(acewrite_item req);
    vif.cddata <= req.cdata;
    vif.cdvalid <= 1'b1;
    wait(vif.cdready);
    vif.cdvalid <= 1'b0;
  endtask

  // Driving Snoop Response Channel
  task drive_cr_channel(acewrite_item req);
    wait(vif.crvalid);
    req.crresp <= vif.crresp;
    vif.crready <= 1'b1;
    vif.crready <= 1'b0;
  endtask

endclass : acewrite_master_driver
