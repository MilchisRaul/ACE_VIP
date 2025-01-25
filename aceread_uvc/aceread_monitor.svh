//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : aceread_monitor.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          25/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Monitor for AXI4 Read Verification IP (UVC)
//  ======================================================================================================

class aceread_monitor extends uvm_monitor;

  `uvm_component_utils (aceread_monitor)

  //monitor constructor
  function new (string name = "aceread_monitor" , uvm_component parent = null);
    super.new (name, parent);
  endfunction: new

  aceread_item m_item;
  mailbox #(aceread_item) m_req_addr_mb;
  mailbox #(aceread_item) m_req_snoop_addr_mb;

  virtual aceread_if v_if; //declaration of virtual interface

  uvm_analysis_port #(aceread_item) mon_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(aceread_item) mon_request_port; // partial data request analysis port for monitor

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Creation of declared analysis port
    mon_analysis_port = new ("mon_analysis_port", this);
    mon_request_port = new ("mon_request_port", this);
    m_req_addr_mb = new("m_req_addr_mb");
    m_req_snoop_addr_mb = new("m_req_snoop_addr_mb");
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    m_item = aceread_item::type_id::create("m_item",this);
    m_item.rdata = new [1];
    fork      
        forever collect_req_addr();
        forever collect_req_snoop_addr();
        forever collect_items();
    join
  endtask : run_phase

  task collect_items();
    fork
      retrieve_addr_from_mb(m_item);
      retrieve_snoop_addr_from_mb(m_item);
      collect_data(m_item);
      collect_snoop_resp(m_item);
      collect_snoop_data(m_item);
    join 
    mon_analysis_port.write(m_item);
  endtask : collect_items

  task collect_req_addr();
    aceread_item addr_item;
    addr_item = aceread_item::type_id::create("addr_item",this);
    @(posedge v_if.clk iff v_if.arvalid & v_if.arready);
    addr_item.araddr   = v_if.araddr;
    addr_item.arid     = v_if.arid;
    addr_item.arlen    = v_if.arlen;
    addr_item.aruser   = v_if.aruser;
    addr_item.arregion = v_if.arregion;
    addr_item.arsize   = v_if.arsize;
    addr_item.arburst  = v_if.arburst;
    addr_item.arlock   = v_if.arlock;
    addr_item.arcache  = v_if.arcache;
    addr_item.arprot   = v_if.arprot;
    addr_item.arqos    = v_if.arqos;
    addr_item.arsnoop  = v_if.arsnoop;
    addr_item.ardomain = v_if.ardomain;
    addr_item.arbar    = v_if.arbar;
    mon_request_port.write(addr_item);
    $display("%t MON: Addr arlen: %d", $time, addr_item.arlen);
    m_req_addr_mb.put(addr_item);
  endtask : collect_req_addr

  //For back to back functionality, this is needed
  task retrieve_addr_from_mb(ref aceread_item item);
    aceread_item addr_item;
    $cast(addr_item, item.clone());
    m_req_addr_mb.get(addr_item);
    item.araddr   = addr_item.araddr;
    item.arid     = addr_item.arid;
    item.arlen    = addr_item.arlen;
    item.aruser   = addr_item.aruser;
    item.arregion = addr_item.arregion;
    item.arsize   = addr_item.arsize;
    item.arburst  = addr_item.arburst;
    item.arlock   = addr_item.arlock;
    item.arcache  = addr_item.arcache;
    item.arprot   = addr_item.arprot;
    item.arqos    = addr_item.arqos;
    item.arsnoop  = addr_item.arsnoop;
    item.ardomain = addr_item.ardomain;
    item.arbar    = addr_item.arbar;
  endtask : retrieve_addr_from_mb

  task collect_data(ref aceread_item item);
    int i = 0;
    @(posedge v_if.clk iff (v_if.rvalid & v_if.rready));
    item.ruser = v_if.ruser;
    item.rid   = v_if.rid;
    repeat(v_if.arlen + 1) 
    item.rdata = new[item.rdata.size() + 1](item.rdata);
    @(posedge v_if.clk iff ~v_if.rlast)
    item.rdata = new [item.rdata.size() - 1](item.rdata);
    item.rdata[i] = v_if.rdata;
  endtask : collect_data

  task collect_req_snoop_addr();
    aceread_item read_snoop_addr_item;
    read_snoop_addr_item = aceread_item::type_id::create("read_snoop_addr_item",this);
    $display("%t MON: Snoop acaddr: %d", $time, read_snoop_addr_item.acaddr);
    @(posedge v_if.clk iff (v_if.acvalid & v_if.acready));
    read_snoop_addr_item.acaddr  = v_if.acaddr;
    read_snoop_addr_item.acsnoop = v_if.acsnoop;
    read_snoop_addr_item.acprot  = v_if.acprot;
    //$cast(snoop_addr_item, item.clone());
    mon_request_port.write(read_snoop_addr_item);
    m_req_snoop_addr_mb.put(read_snoop_addr_item);
  endtask : collect_req_snoop_addr

  task retrieve_snoop_addr_from_mb(ref aceread_item item);
    aceread_item read_snoop_addr_item;
    $cast(read_snoop_addr_item, item.clone());
    m_req_snoop_addr_mb.get(read_snoop_addr_item);
    item.acaddr  = read_snoop_addr_item.acaddr;
    item.acsnoop = read_snoop_addr_item.acsnoop;
    item.acprot  = read_snoop_addr_item.acprot;
  endtask : retrieve_snoop_addr_from_mb
    
  task collect_snoop_data(ref aceread_item item);
    @(posedge v_if.clk iff (v_if.cdvalid & v_if.cdready));
    item.cddata = v_if.cddata;
  endtask : collect_snoop_data

  task collect_snoop_resp(ref aceread_item item);
    item.crresp = v_if.crresp;
  endtask : collect_snoop_resp


endclass : aceread_monitor