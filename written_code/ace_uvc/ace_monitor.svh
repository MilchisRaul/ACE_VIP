//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_monitor.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Monitor for ACE Verification IP (UVC)
//  ======================================================================================================

class ace_monitor extends uvm_monitor;

  `uvm_component_utils (ace_monitor)

  //monitor constructor
  function new (string name = "ace_monitor" , uvm_component parent = null);
    super.new (name, parent);
  endfunction : new

  ace_item m_item;
  mailbox #(ace_item) m_req_read_addr_mb;
  mailbox #(ace_item) m_req_snoop_addr_mb;

  virtual ace_if v_if; //declaration of virtual interface

  uvm_analysis_port #(ace_item) mon_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(ace_item) mon_request_port; // partial data request analysis port for monitor
  
  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Creation of declared analysis port
    mon_analysis_port = new ("mon_analysis_port", this);
    mon_request_port = new ("mon_request_port", this);
    m_req_read_addr_mb = new("m_req_read_addr_mb");
    m_req_snoop_addr_mb = new("m_req_snoop_addr_mb");
  endfunction: build_phase

  virtual task run_phase(uvm_phase phase);
    m_item = ace_item::type_id::create("m_item",this);
    m_item.wdata  = new [1];
    m_item.wstrb  = new [1];
    m_item.rdata  = new [1];
    m_item.cddata = new [1];
      fork
        forever collect_req_raddr();
        forever collect_req_snoop_addr();
        forever collect_items();
      join
  endtask : run_phase

  task collect_items();
    fork
      sample_wr_if();
      sample_read_if();
    join 
    mon_analysis_port.write(m_item);
    //$display("================================================================");
    //$display("%s", m_item.sprint());
    //$display("================================================================");
  endtask : collect_items

  task sample_wr_if();
    fork
      $display("%t Monitor write", $time);
      collect_wr_addr(m_item);
      collect_wr_data(m_item);
      collect_response(m_item);
      retrieve_snoop_addr_from_mb(m_item);
      collect_snoop_resp(m_item);
      collect_snoop_data(m_item);
    join
  endtask : sample_wr_if

  task sample_read_if();
    fork
      $display("%t Monitor read", $time);
      retrieve_raddr_from_mb(m_item);
      collect_rdata(m_item);
      retrieve_snoop_addr_from_mb(m_item);
      collect_snoop_data(m_item);
      collect_snoop_resp(m_item);
    join
  endtask : sample_read_if

  task collect_wr_addr(ref ace_item item);
    ace_item wr_addr_item;
    mon_request_port.write(item);
    @(posedge v_if.clk iff (v_if.awvalid & v_if.awready));
    item.awaddr   = v_if.awaddr;
    item.awid     = v_if.awid;
    item.awlen    = v_if.awlen;
    item.awuser   = v_if.awuser;
    item.awregion = v_if.awregion;
    item.awsize   = v_if.awsize;
    item.awburst  = v_if.awburst;
    item.awlock   = v_if.awlock;
    item.awcache  = v_if.awcache;
    item.awprot   = v_if.awprot;
    item.awqos    = v_if.awqos;
    $cast(wr_addr_item, item.clone());
    mon_request_port.write(wr_addr_item);
    @(posedge v_if.clk iff (v_if.awready & v_if.awvalid));
  endtask : collect_wr_addr

  task collect_wr_data(ref ace_item item);
    int i = 0;
    @(posedge v_if.clk iff (v_if.wvalid & v_if.wready));
      item.wuser = v_if.wuser;
      repeat(v_if.awlen + 1)
      item.wdata = new[item.wdata.size() + 1](item.wdata);
      item.wstrb = new[item.wstrb.size() + 1](item.wstrb);
      @(posedge v_if.clk iff ~v_if.wlast)
      //if(~v_if.wlast) begin
      item.wdata = new [item.wdata.size() - 1](item.wdata);
      item.wdata[i] = v_if.wdata;
      item.wstrb = new [item.wstrb.size() - 1](item.wstrb);
      item.wstrb[i] = v_if.wstrb;
      //end
  endtask : collect_wr_data

  task collect_response(ref ace_item item);
    @(posedge v_if.clk iff (v_if.bvalid & v_if.bready));
    item.bid   = v_if.bid;
    item.buser = v_if.buser;
    item.bresp = v_if.bresp;
  endtask : collect_response

  task collect_req_raddr();
    ace_item raddr_item;
    raddr_item = ace_item::type_id::create("raddr_item",this);
    @(posedge v_if.clk iff (v_if.arvalid & v_if.arready));
    raddr_item.araddr   = v_if.araddr;
    raddr_item.arid     = v_if.arid;
    raddr_item.arlen    = v_if.arlen;
    raddr_item.aruser   = v_if.aruser;
    raddr_item.arregion = v_if.arregion;
    raddr_item.arsize   = v_if.arsize;
    raddr_item.arburst  = v_if.arburst;
    raddr_item.arlock   = v_if.arlock;
    raddr_item.arcache  = v_if.arcache;
    raddr_item.arprot   = v_if.arprot;
    raddr_item.arqos    = v_if.arqos;
    raddr_item.arsnoop  = v_if.arsnoop;
    raddr_item.ardomain = v_if.ardomain;
    raddr_item.arbar    = v_if.arbar;
    mon_request_port.write(raddr_item);
    $display("%t MON: Addr arlen: %d", $time, raddr_item.arlen);
    m_req_read_addr_mb.put(raddr_item);
  endtask : collect_req_raddr

  //For back to back functionality, this is needed
  task retrieve_raddr_from_mb(ref ace_item item);
    ace_item raddr_item;
    $cast(raddr_item, item.clone());
    m_req_read_addr_mb.get(raddr_item);
    item.araddr   = raddr_item.araddr;
    item.arid     = raddr_item.arid;
    item.arlen    = raddr_item.arlen;
    item.aruser   = raddr_item.aruser;
    item.arregion = raddr_item.arregion;
    item.arsize   = raddr_item.arsize;
    item.arburst  = raddr_item.arburst;
    item.arlock   = raddr_item.arlock;
    item.arcache  = raddr_item.arcache;
    item.arprot   = raddr_item.arprot;
    item.arqos    = raddr_item.arqos;
    item.arsnoop  = raddr_item.arsnoop;
    item.ardomain = raddr_item.ardomain;
    item.arbar    = raddr_item.arbar;
  endtask : retrieve_raddr_from_mb

  task collect_rdata(ref ace_item item);
    int i = 0;
    @(posedge v_if.clk iff (v_if.rvalid & v_if.rready));
      item.ruser = v_if.ruser;
      item.rid   = v_if.rid;
      repeat(v_if.arlen + 1) 
      item.rdata = new[item.rdata.size() + 1](item.rdata);
      @(posedge v_if.clk iff ~v_if.rlast)
      item.rdata = new [item.rdata.size() - 1](item.rdata);
      item.rdata[i] = v_if.rdata;
  endtask : collect_rdata

  task collect_req_snoop_addr();
    ace_item read_snoop_addr_item;
    read_snoop_addr_item = ace_item::type_id::create("read_snoop_addr_item",this);
    $display("%t MON: Snoop acaddr: %d", $time, read_snoop_addr_item.acaddr);
    @(posedge v_if.clk iff (v_if.acvalid & v_if.acready));
    read_snoop_addr_item.acaddr  = v_if.acaddr;
    read_snoop_addr_item.acsnoop = v_if.acsnoop;
    read_snoop_addr_item.acprot  = v_if.acprot;
    //$cast(snoop_addr_item, item.clone());
    mon_request_port.write(read_snoop_addr_item);
    m_req_snoop_addr_mb.put(read_snoop_addr_item);
  endtask : collect_req_snoop_addr

  task retrieve_snoop_addr_from_mb(ref ace_item item);
    ace_item read_snoop_addr_item;
    $cast(read_snoop_addr_item, item.clone());
    m_req_snoop_addr_mb.get(read_snoop_addr_item);
    item.acaddr  = read_snoop_addr_item.acaddr;
    item.acsnoop = read_snoop_addr_item.acsnoop;
    item.acprot  = read_snoop_addr_item.acprot;
  endtask : retrieve_snoop_addr_from_mb
    
  task collect_snoop_data(ref ace_item item);
    int i = 0;
    @(posedge v_if.clk iff (v_if.cdvalid & v_if.cdready));
    $display("%t MON: item R/W val =", $time, item.read_write);
    if(item.read_write)
      repeat (v_if.awlen + 1);
    else 
      repeat (v_if.arlen + 1);
    item.cddata = new[item.cddata.size() + 1](item.cddata);
    @(posedge v_if.clk iff ~v_if.cdlast)
    item.cddata = new [item.cddata.size() - 1](item.cddata);
    item.cddata[i] = v_if.cddata;
  endtask : collect_snoop_data

  task collect_snoop_resp(ref ace_item item);
    item.crresp = v_if.crresp;
  endtask : collect_snoop_resp

endclass : ace_monitor