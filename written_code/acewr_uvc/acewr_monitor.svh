//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_monitor.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Monitor for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_monitor extends uvm_monitor;

  `uvm_component_utils (acewr_monitor)

  
  //monitor constructor
  function new (string name = "acewr_monitor" , uvm_component parent = null);
    super.new (name, parent);
  endfunction: new

  acewr_item m_item;
  mailbox #(acewr_item) m_req_snoop_addr_mb;

  virtual acewr_if v_if; //declaration of virtual interface

  uvm_analysis_port #(acewr_item) mon_analysis_port; //data analysis port input for monitor
  uvm_analysis_port #(acewr_item) mon_request_port; // partial data request analysis port for monitor

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
    //Creation of declared analysis port
    mon_analysis_port = new ("mon_analysis_port", this);
    mon_request_port = new ("mon_request_port", this);
    m_req_snoop_addr_mb = new(); //m = monitor
  endfunction: build_phase


  virtual task run_phase(uvm_phase phase);
    m_item = acewr_item::type_id::create("m_item",this);
    m_item.wdata  = new [1];
    m_item.wstrb  = new [1];
    fork      
      forever collect_req_snoop_addr();
      forever collect_items();
  join
  endtask : run_phase

  task collect_items();
    fork
      retrieve_snoop_addr_from_mb(m_item);
      collect_addr(m_item);
      collect_data(m_item);
      collect_response(m_item);
    join
    //collect_req_snoop_addr();
    //retrieve_snoop_addr_from_mb(m_item);
    //collect_snoop_resp(m_item);
    //collect_snoop_data(m_item);
    //$display("================================================================");
    //$display("%s", m_item.sprint());
    //$display("================================================================");
    mon_analysis_port.write(m_item);
  endtask : collect_items

  task collect_addr(ref acewr_item item);
    acewr_item addr_item;
    mon_request_port.write(item);
    @(posedge v_if.clk iff (v_if.awvalid));
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
    item.awsnoop  = v_if.awsnoop;
    item.awdomain = v_if.awdomain;
    item.awbar    = v_if.awbar;
    item.awunique = v_if.awunique;
    $cast(addr_item, item.clone());
    mon_request_port.write(addr_item);
    @(posedge v_if.clk iff (v_if.awready & v_if.awvalid));
  endtask : collect_addr

  task collect_data(ref acewr_item item);
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
  endtask : collect_data

  task collect_response(ref acewr_item item);
    @(posedge v_if.clk iff (v_if.bvalid & v_if.bready));
    item.bid   = v_if.bid;
    item.buser = v_if.buser;
    item.bresp = v_if.bresp;
  endtask : collect_response

  task collect_req_snoop_addr();
    acewr_item wr_snoop_addr_item;
    wr_snoop_addr_item = acewr_item::type_id::create("wr_snoop_addr_item",this);
    @(posedge v_if.clk iff (v_if.acvalid & v_if.acready));
    wr_snoop_addr_item.acaddr  = v_if.acaddr;
    wr_snoop_addr_item.acsnoop = v_if.acsnoop;
    wr_snoop_addr_item.acprot  = v_if.acprot;
    //$cast(snoop_addr_item, item.clone());
    mon_request_port.write(wr_snoop_addr_item);
    m_req_snoop_addr_mb.put(wr_snoop_addr_item);
  endtask : collect_req_snoop_addr

  task retrieve_snoop_addr_from_mb(ref acewr_item item);
    acewr_item snoop_addr_item;
    $cast(snoop_addr_item, item.clone());
    m_req_snoop_addr_mb.get(snoop_addr_item);
    item.acaddr  = snoop_addr_item.acaddr;
    item.acsnoop = snoop_addr_item.acsnoop;
    item.acprot  = snoop_addr_item.acprot;
  endtask : retrieve_snoop_addr_from_mb
    
  task collect_snoop_data(ref acewr_item item);
    @(posedge v_if.clk iff (v_if.cdvalid & v_if.cdready));
    item.cddata = v_if.cddata;
  endtask : collect_snoop_data

  task collect_snoop_resp(ref acewr_item item);
    item.crresp = v_if.crresp;
  endtask : collect_snoop_resp

endclass : acewr_monitor