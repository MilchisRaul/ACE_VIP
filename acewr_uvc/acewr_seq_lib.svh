//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : axi4wr_seq_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequences Library for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_base_sequence extends uvm_sequence;

  `uvm_object_utils (acewr_base_sequence)

  `uvm_declare_p_sequencer(acewr_sequencer)

  int trans_no = 1;

  //typedef acewr_item axi4wr_item_t; //for parametrizable item

  function new (string name = "acewr_base_sequence");
    super.new(name);
  endfunction: new
endclass: acewr_base_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                       COHERENT
//                               WRITE UNIQUE TRANSACTION
//                                 AWSNOOP = 3'b000
//
////////////////////////////////////////////////////////////////////////////////////////////////

class acewr_wutrans_master_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_wutrans_master_sequence)

  function new (string name= "acewr_wutrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item master_item;
    master_item = acewr_item::type_id::create("master_item"); //creating AXI4WR item for signals
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
        if(!(master_item.randomize() with {
                                    //Addr channel
                                    awid     == 1'd0 ;
                                    awaddr inside {[0:20]};//32'd0;
                                    awlen  inside {[0:10]}; //Max VAL 255
                                    awsize   == 3'd3 ; // 16 bytes transfer-0b100
                                    awburst  == 2'd1 ; // INCR 0b01
                                    awlock   == 1'd0 ; 
                                    awcache  == 4'd0 ;
                                    awprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                    awqos    == 4'd0 ;
                                    awregion == 4'd0 ;
                                    awuser   == 8'd0 ;
                                    awsnoop  == 3'b000; // b000 - Write Unique
                                    awbar    == 2'b00;  // awbar[0] = 0 - No Barrier
                                    awdomain == 2'b10;  // b10 - Inner Shareable
                                    //Data channel
                                    wuser == 8'd5;
                                    //Channels handshakes between valid and ready
                                    addr_hsk_type == VAL_BFR_RDY;
                                    data_hsk_type == VAL_BFR_RDY;
                                    resp_hsk_type == RDY_BFR_VAL;
                                    snoop_addr_hsk_type == VAL_BFR_RDY;
                                    snoop_resp_hsk_type == VAL_AND_RDY;
                                    snoop_data_hsk_type == RDY_BFR_VAL;
                                    //Channels delay
                                    addr_delay_type  == B2B;
                                    data_delay_type  == B2B;
                                    resp_delay_type  == B2B;
                                    snoop_addr_delay_type == B2B;
                                    snoop_data_delay_type == B2B;
                                    snoop_resp_delay_type == B2B;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       master_item.crresp = 5'd1;
       master_item.en_cd_channel = 1'd1;
      
       finish_item(master_item); //all data is on transaction item
    end
  endtask: body

endclass: acewr_wutrans_master_sequence

class acewr_wutrans_slave_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_wutrans_slave_sequence)

  function new (string name= "acewr_wutrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item slave_item;
    acewr_item item;
    slave_item = acewr_item::type_id::create("slave_item"); //creating AXI4WR item for signals
    forever begin
      //wait for a transaction request (get is blocking)
      $cast(item, slave_item.clone());
      //generate response based on observed request
      start_item(item); //starting getting the data for item
      //TODO: Preserving address channel item values don't randomize item!
      //Response channel
      item.bid   = 'd0;
      item.buser = 'd0;
      item.bresp = 'd0;
      //Channels handshakes between valid and ready
      item.addr_hsk_type = VAL_AND_RDY;
      item.data_hsk_type = VAL_AND_RDY;
      item.resp_hsk_type = VAL_AND_RDY;
      item.snoop_addr_hsk_type = VAL_BFR_RDY;
      item.snoop_resp_hsk_type = VAL_BFR_RDY;
      item.snoop_data_hsk_type = RDY_BFR_VAL;
      //Channels delay
      item.addr_delay_type  = B2B;
      item.data_delay_type  = B2B;
      item.resp_delay_type  = B2B;
      item.snoop_addr_delay_type = B2B;
      item.snoop_data_delay_type = B2B;
      item.snoop_resp_delay_type = B2B;
      //Enable/Disable Data Channel CRRESP[0] = 1 Enable Snoop Ch / CRRESP[0] = 0 Disable Snoop Ch
      item.en_cd_channel = 1'd1;
      item.crresp        = 5'd1;
      //giving values to axi4wr signals
      //Resp channel
      finish_item(item); //all data is on transaction item  
      p_sequencer.request_fifo.get(item);
    end
endtask: body

endclass: acewr_wutrans_slave_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                   MEMORY UPDATE
//                               WRITE CLEAN TRANSACTION
//                                 AWSNOOP = 3'b010
//
////////////////////////////////////////////////////////////////////////////////////////////////

class acewr_wrctrans_master_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_wrctrans_master_sequence)

  function new (string name= "acewr_wrctrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item master_item;
    master_item = acewr_item::type_id::create("master_item"); //creating AXI4WR item for signals
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
        if(!(master_item.randomize() with {
                                    //Addr channel
                                    awid     == 1'd0 ;
                                    awaddr inside {[0:20]};//32'd0;
                                    awlen  inside {[0:10]}; //Max VAL 255
                                    awsize   == 3'd3 ; // 16 bytes transfer-0b100
                                    awburst  == 2'd1 ; // INCR 0b01
                                    awlock   == 1'd0 ; 
                                    awcache  == 4'd0 ;
                                    awprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                    awqos    == 4'd0 ;
                                    awregion == 4'd0 ;
                                    awuser   == 8'd0 ;
                                    awsnoop  == 3'b010; // b010 - Write Clean
                                    awbar    == 2'b00;  // awbar[0] = 0 - No Barrier
                                    awdomain == 2'b10;  // b10 - Inner Shareable
                                    //Data channel
                                    wuser == 8'd5;
                                    //Channels handshakes between valid and ready
                                    addr_hsk_type == VAL_BFR_RDY;
                                    data_hsk_type == VAL_BFR_RDY;
                                    resp_hsk_type == RDY_BFR_VAL;
                                    snoop_addr_hsk_type == VAL_BFR_RDY;
                                    snoop_resp_hsk_type == VAL_AND_RDY;
                                    snoop_data_hsk_type == RDY_BFR_VAL;
                                    //Channels delay
                                    addr_delay_type  == B2B;
                                    data_delay_type  == B2B;
                                    resp_delay_type  == B2B;
                                    snoop_addr_delay_type == B2B;
                                    snoop_data_delay_type == B2B;
                                    snoop_resp_delay_type == B2B;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       master_item.crresp = 5'd1;
       master_item.en_cd_channel = 1'd1;
      
       finish_item(master_item); //all data is on transaction item
    end
  endtask: body

endclass: acewr_wrctrans_master_sequence

class acewr_wrctrans_slave_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_wrctrans_slave_sequence)

  function new (string name= "acewr_wrctrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item slave_item;
    acewr_item item;
    slave_item = acewr_item::type_id::create("slave_item"); //creating AXI4WR item for signals
    forever begin
      //wait for a transaction request (get is blocking)
      $cast(item, slave_item.clone());
      //generate response based on observed request
      start_item(item); //starting getting the data for item
      //TODO: Preserving address channel item values don't randomize item!
      //Response channel
      item.bid   = 'd0;
      item.buser = 'd0;
      item.bresp = 'd0;
      //Channels handshakes between valid and ready
      item.addr_hsk_type = VAL_AND_RDY;
      item.data_hsk_type = VAL_AND_RDY;
      item.resp_hsk_type = VAL_AND_RDY;
      item.snoop_addr_hsk_type = VAL_BFR_RDY;
      item.snoop_resp_hsk_type = VAL_BFR_RDY;
      item.snoop_data_hsk_type = RDY_BFR_VAL;
      //Channels delay
      item.addr_delay_type  = B2B;
      item.data_delay_type  = B2B;
      item.resp_delay_type  = B2B;
      item.snoop_addr_delay_type = B2B;
      item.snoop_data_delay_type = B2B;
      item.snoop_resp_delay_type = B2B;
      //Enable/Disable Data Channel CRRESP[0] = 1 Enable Snoop Ch / CRRESP[0] = 0 Disable Snoop Ch
      item.en_cd_channel = 1'd1;
      item.crresp        = 5'd1;
      //giving values to axi4wr signals
      //Resp channel
      finish_item(item); //all data is on transaction item  
      p_sequencer.request_fifo.get(item);
    end
endtask: body

endclass: acewr_wrctrans_slave_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                   MEMORY UPDATE
//                                 EVICT TRANSACTION
//                                 AWSNOOP = 3'b100
//
////////////////////////////////////////////////////////////////////////////////////////////////

class acewr_evtrans_master_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_evtrans_master_sequence)

  function new (string name= "acewr_evtrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item master_item;
    master_item = acewr_item::type_id::create("master_item"); //creating AXI4WR item for signals
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
        if(!(master_item.randomize() with {
                                    //Addr channel
                                    awid     == 1'd0 ;
                                    awaddr inside {[0:20]};//32'd0;
                                    awlen  inside {[0:10]}; //Max VAL 255
                                    awsize   == 3'd3 ; // 16 bytes transfer-0b100
                                    awburst  == 2'd1 ; // INCR 0b01
                                    awlock   == 1'd0 ; 
                                    awcache  == 4'd0 ;
                                    awprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                    awqos    == 4'd0 ;
                                    awregion == 4'd0 ;
                                    awuser   == 8'd0 ;
                                    awsnoop  == 3'b100; // b100 - Evict
                                    awbar    == 2'b00;  // awbar[0] = 0 - No Barrier
                                    awdomain == 2'b10;  // b10 - Inner Shareable
                                    //Data channel
                                    wuser == 8'd5;
                                    //Channels handshakes between valid and ready
                                    addr_hsk_type == VAL_BFR_RDY;
                                    data_hsk_type == VAL_BFR_RDY;
                                    resp_hsk_type == RDY_BFR_VAL;
                                    snoop_addr_hsk_type == VAL_BFR_RDY;
                                    snoop_resp_hsk_type == VAL_AND_RDY;
                                    snoop_data_hsk_type == RDY_BFR_VAL;
                                    //Channels delay
                                    addr_delay_type  == B2B;
                                    data_delay_type  == B2B;
                                    resp_delay_type  == B2B;
                                    snoop_addr_delay_type == B2B;
                                    snoop_data_delay_type == B2B;
                                    snoop_resp_delay_type == B2B;
                                   })) //giving values to axi4wr signals
          `uvm_error(get_type_name(), "Rand error!")
       master_item.crresp = 5'd1;
       master_item.en_cd_channel = 1'd1;
      
       finish_item(master_item); //all data is on transaction item
    end
  endtask: body

endclass: acewr_evtrans_master_sequence

class acewr_evtrans_slave_sequence extends acewr_base_sequence;

  `uvm_object_utils(acewr_evtrans_slave_sequence)

  function new (string name= "acewr_evtrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    acewr_item slave_item;
    acewr_item item;
    slave_item = acewr_item::type_id::create("slave_item"); //creating AXI4WR item for signals
    forever begin
      //wait for a transaction request (get is blocking)
      $cast(item, slave_item.clone());
      //generate response based on observed request
      start_item(item); //starting getting the data for item
      //TODO: Preserving address channel item values don't randomize item!
      //Response channel
      item.bid   = 'd0;
      item.buser = 'd0;
      item.bresp = 'd0;
      //Channels handshakes between valid and ready
      item.addr_hsk_type = VAL_AND_RDY;
      item.data_hsk_type = VAL_AND_RDY;
      item.resp_hsk_type = VAL_AND_RDY;
      item.snoop_addr_hsk_type = VAL_BFR_RDY;
      item.snoop_resp_hsk_type = VAL_BFR_RDY;
      item.snoop_data_hsk_type = RDY_BFR_VAL;
      //Channels delay
      item.addr_delay_type  = B2B;
      item.data_delay_type  = B2B;
      item.resp_delay_type  = B2B;
      item.snoop_addr_delay_type = B2B;
      item.snoop_data_delay_type = B2B;
      item.snoop_resp_delay_type = B2B;
      //Enable/Disable Data Channel CRRESP[0] = 1 Enable Snoop Ch / CRRESP[0] = 0 Disable Snoop Ch
      item.en_cd_channel = 1'd1;
      item.crresp        = 5'd1;
      //giving values to axi4wr signals
      //Resp channel
      finish_item(item); //all data is on transaction item  
      p_sequencer.request_fifo.get(item);
    end
endtask: body

endclass: acewr_evtrans_slave_sequence