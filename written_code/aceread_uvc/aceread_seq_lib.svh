//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_seq_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequences Library for AXI4 Read Verification IP (UVC)
//  ======================================================================================================

class aceread_base_sequence extends uvm_sequence;

  `uvm_object_utils (aceread_base_sequence)

  `uvm_declare_p_sequencer(aceread_sequencer)

  int trans_no = 1;
  aceread_item master_item;

  function new (string name = "aceread_base_sequence");
    super.new(name);
    master_item = aceread_item::type_id::create("master_item");
  endfunction: new
endclass: aceread_base_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                      COHERENT
//                               READ ONCE TRANSACTION
//                                 ARSNOOP = 0'b0000
//
////////////////////////////////////////////////////////////////////////////////////////////////

class aceread_rotrans_master_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_rotrans_master_sequence)

  function new (string name= "aceread_rotrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
      if(!(master_item.randomize() with {
                                  //crresp == 5'd1;
                                  //Addr channel
                                  arid     == 1'd0 ;
                                  araddr inside {[0:20]};//32'd0;
                                  arlen  inside {[1:10]};//255]} ; //inside {[1:255]}; 
                                  arsize   == 3'd5 ; // 16 bytes transfer-0b100
                                  arburst  == 2'd1 ; // INCR 0b01
                                  arlock   == 1'd0 ; 
                                  arcache  == 4'd0 ;
                                  arprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                  arqos    == 4'd0 ;
                                  arregion == 4'd0 ;
                                  aruser   == 8'd0 ;
                                  arsnoop  == 4'd0 ; // b0000 ReadOnce
                                  ardomain == 2'b01; // b01 Inner Sharable
                                  arbar    == 2'd0 ;  // NO BARRIER
                                  //Snoop
                                  //Channels handshakes between valid and ready
                                  addr_hsk_type == VAL_BFR_RDY; 
                                  data_hsk_type == RDY_BFR_VAL;
                                  snoop_addr_hsk_type == VAL_BFR_RDY;
                                  snoop_resp_hsk_type == VAL_AND_RDY;
                                  snoop_data_hsk_type == RDY_BFR_VAL;
                                  //Channels delay
                                  addr_delay_type  == B2B;
                                  data_delay_type  == B2B;
                                  snoop_addr_delay_type == B2B;
                                  snoop_data_delay_type == B2B;
                                  snoop_resp_delay_type == B2B;
                                                                 })) //giving values to axi4wr signals
        `uvm_error(get_type_name(), "Rand error!")
      master_item.crresp = 5'd1;
      master_item.en_cd_channel = 1'd1;
      $display("SEQ LIB MASTER SEQ :: %s", master_item.sprint());                                                           
      $display("%t SEQ LIB :: BFR data hsk task En cd channel val = %d", $time, master_item.en_cd_channel);
      $display("%t SEQ LIB :: BFR data hsk task CRRESP VALUE = %d", $time, master_item.crresp);
      finish_item(master_item); //all data is on transaction item
    end
  endtask: body
endclass: aceread_rotrans_master_sequence

class aceread_rotrans_slave_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_rotrans_slave_sequence)

  function new (string name= "aceread_rotrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    aceread_item slave_item;
    slave_item = aceread_item::type_id::create("slave_item");
    forever begin
      //Get address information for data generation
      p_sequencer.request_fifo.get(master_item);
      start_item(slave_item); //starting getting the data for item
      if(!(slave_item.randomize() with {
        //Addr channel
        arlen == master_item.arlen;
        rid == master_item.arid;
        crresp == master_item.crresp;
        ruser == 'd5;
        rresp == 'd0;
        //Snoop
        acaddr inside {[0:20]}; //32'd0;
        acsnoop == 'd0;
        acprot  == 'd0;
        //Channels handshakes between valid and ready
        addr_hsk_type == VAL_AND_RDY;
        data_hsk_type == VAL_BFR_RDY;
        snoop_addr_hsk_type == RDY_BFR_VAL;
        snoop_resp_hsk_type == VAL_BFR_RDY;
        snoop_data_hsk_type == VAL_BFR_RDY;
        //Channels delay
        addr_delay_type  == B2B;
        data_delay_type  == B2B;
        snoop_addr_delay_type == B2B;
        snoop_data_delay_type == B2B;
        snoop_resp_delay_type == B2B;
       })) //giving values to axi4wr signals
      `uvm_error(get_type_name(), "Rand error!")
      slave_item.crresp = 5'd1;
      slave_item.en_cd_channel = 1'd1;
      finish_item(slave_item); //all data is on transaction item  
    end
endtask: body

endclass: aceread_rotrans_slave_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                 CACHE MAINTANANCE
//                               CLEAN SHARED TRANSACTION
//                                 ARSNOOP = 0'b1000
//
////////////////////////////////////////////////////////////////////////////////////////////////

class aceread_cstrans_master_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_cstrans_master_sequence)

  function new (string name= "aceread_cstrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
      if(!(master_item.randomize() with {
                                  //crresp == 5'd1;
                                  //Addr channel
                                  arid     == 1'd0 ;
                                  araddr inside {[0:20]};//32'd0;
                                  arlen  inside {[1:10]};//255]} ; //inside {[1:255]}; 
                                  arsize   == 3'd5 ; // 16 bytes transfer-0b100
                                  arburst  == 2'd1 ; // INCR 0b01
                                  arlock   == 1'd0 ; 
                                  arcache  == 4'd0 ;
                                  arprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                  arqos    == 4'd0 ;
                                  arregion == 4'd0 ;
                                  aruser   == 8'd0 ;
                                  arsnoop  == 4'b1000 ;  // b1000 - CleanShared
                                  ardomain == 2'b10 ;    // b10 - Inner Sharable
                                  arbar    == 2'd0 ;
                                  //Snoop
                                  //Channels handshakes between valid and ready
                                  addr_hsk_type == VAL_BFR_RDY; 
                                  data_hsk_type == RDY_BFR_VAL;
                                  snoop_addr_hsk_type == VAL_BFR_RDY;
                                  snoop_resp_hsk_type == VAL_AND_RDY;
                                  snoop_data_hsk_type == RDY_BFR_VAL;
                                  //Channels delay
                                  addr_delay_type  == B2B;
                                  data_delay_type  == B2B;
                                  snoop_addr_delay_type == B2B;
                                  snoop_data_delay_type == B2B;
                                  snoop_resp_delay_type == B2B;
                                                                 })) //giving values to axi4wr signals
        `uvm_error(get_type_name(), "Rand error!")
      master_item.crresp = 5'd1;
      master_item.en_cd_channel = 1'd1;
      $display("SEQ LIB MASTER SEQ :: %s", master_item.sprint());                                                           
      $display("%t SEQ LIB :: BFR data hsk task En cd channel val = %d", $time, master_item.en_cd_channel);
      $display("%t SEQ LIB :: BFR data hsk task CRRESP VALUE = %d", $time, master_item.crresp);
      finish_item(master_item); //all data is on transaction item
    end
  endtask: body
endclass: aceread_cstrans_master_sequence

class aceread_cstrans_slave_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_cstrans_slave_sequence)

  function new (string name= "aceread_cstrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    aceread_item slave_item;
    slave_item = aceread_item::type_id::create("slave_item");
    forever begin
      //Get address information for data generation
      p_sequencer.request_fifo.get(master_item);
      start_item(slave_item); //starting getting the data for item
      if(!(slave_item.randomize() with {
        //Addr channel
        arlen == master_item.arlen;
        rid == master_item.arid;
        crresp == master_item.crresp;
        ruser == 'd5;
        rresp == 'd0;
        //Snoop
        acaddr inside {[0:20]}; //32'd0;
        acsnoop == 4'b1000; // Clean Shared transaction observed on the interconnect drived by ACE Master
        acprot  == 'd0;
        //Channels handshakes between valid and ready
        addr_hsk_type == VAL_AND_RDY;
        data_hsk_type == VAL_BFR_RDY;
        snoop_addr_hsk_type == RDY_BFR_VAL;
        snoop_resp_hsk_type == VAL_BFR_RDY;
        snoop_data_hsk_type == VAL_BFR_RDY;
        //Channels delay
        addr_delay_type  == B2B;
        data_delay_type  == B2B;
        snoop_addr_delay_type == B2B;
        snoop_data_delay_type == B2B;
        snoop_resp_delay_type == B2B;
       })) //giving values to axi4wr signals
      `uvm_error(get_type_name(), "Rand error!")
      slave_item.crresp = 5'd1;
      slave_item.en_cd_channel = 1'd1;
      finish_item(slave_item); //all data is on transaction item  
    end
endtask: body

endclass: aceread_cstrans_slave_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                      COHERENT
//                               CLEAN UNIQUE TRANSACTION
//                                 ARSNOOP = 4'b1011
//
////////////////////////////////////////////////////////////////////////////////////////////////

class aceread_cutrans_master_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_cutrans_master_sequence)

  function new (string name= "aceread_cutrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
      if(!(master_item.randomize() with {
                                  //crresp == 5'd1;
                                  //Addr channel
                                  arid     == 1'd0 ;
                                  araddr inside {[0:20]};//32'd0;
                                  arlen  inside {[1:10]};//255]} ; //inside {[1:255]}; 
                                  arsize   == 3'd5 ; // 16 bytes transfer-0b100
                                  arburst  == 2'd1 ; // INCR 0b01
                                  arlock   == 1'd0 ; 
                                  arcache  == 4'd0 ;
                                  arprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                  arqos    == 4'd0 ;
                                  arregion == 4'd0 ;
                                  aruser   == 8'd0 ;
                                  arsnoop  == 4'b1011 ;  // b1011 - CleanUnique
                                  ardomain == 2'b10 ;    // b10 - Inner Sharable
                                  arbar    == 2'd0 ;
                                  //Snoop
                                  //Channels handshakes between valid and ready
                                  addr_hsk_type == VAL_BFR_RDY; 
                                  data_hsk_type == RDY_BFR_VAL;
                                  snoop_addr_hsk_type == VAL_BFR_RDY;
                                  snoop_resp_hsk_type == VAL_AND_RDY;
                                  snoop_data_hsk_type == RDY_BFR_VAL;
                                  //Channels delay
                                  addr_delay_type  == B2B;
                                  data_delay_type  == B2B;
                                  snoop_addr_delay_type == B2B;
                                  snoop_data_delay_type == B2B;
                                  snoop_resp_delay_type == B2B;
                                                                 })) //giving values to axi4wr signals
        `uvm_error(get_type_name(), "Rand error!")
      master_item.crresp = 5'd1;
      master_item.en_cd_channel = 1'd1;
      $display("SEQ LIB MASTER SEQ :: %s", master_item.sprint());                                                           
      $display("%t SEQ LIB :: BFR data hsk task En cd channel val = %d", $time, master_item.en_cd_channel);
      $display("%t SEQ LIB :: BFR data hsk task CRRESP VALUE = %d", $time, master_item.crresp);
      finish_item(master_item); //all data is on transaction item
    end
  endtask: body
endclass: aceread_cutrans_master_sequence

class aceread_cutrans_slave_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_cutrans_slave_sequence)

  function new (string name= "aceread_cutrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    aceread_item slave_item;
    slave_item = aceread_item::type_id::create("slave_item");
    forever begin
      //Get address information for data generation
      p_sequencer.request_fifo.get(master_item);
      start_item(slave_item); //starting getting the data for item
      if(!(slave_item.randomize() with {
        //Addr channel
        arlen == master_item.arlen;
        rid == master_item.arid;
        crresp == master_item.crresp;
        ruser == 'd5;
        rresp == 'd0;
        //Snoop
        acaddr inside {[0:20]}; //32'd0;
        acsnoop == 'd0;
        acprot  == 'd0;
        //Channels handshakes between valid and ready
        addr_hsk_type == VAL_AND_RDY;
        data_hsk_type == VAL_BFR_RDY;
        snoop_addr_hsk_type == RDY_BFR_VAL;
        snoop_resp_hsk_type == VAL_BFR_RDY;
        snoop_data_hsk_type == VAL_BFR_RDY;
        //Channels delay
        addr_delay_type  == B2B;
        data_delay_type  == B2B;
        snoop_addr_delay_type == B2B;
        snoop_data_delay_type == B2B;
        snoop_resp_delay_type == B2B;
       })) //giving values to axi4wr signals
      `uvm_error(get_type_name(), "Rand error!")
      slave_item.crresp = 5'd1;
      slave_item.en_cd_channel = 1'd1;
      finish_item(slave_item); //all data is on transaction item  
    end
endtask: body

endclass: aceread_cutrans_slave_sequence

////////////////////////////////////////////////////////////////////////////////////////////////
//                                  CACHE MAINTANANCE
//                               MAKE INVALID TRANSACTION
//                                 ARSNOOP = 4'b1101
//
////////////////////////////////////////////////////////////////////////////////////////////////

class aceread_mitrans_master_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_mitrans_master_sequence)

  function new (string name= "aceread_mitrans_master_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
      if(!(master_item.randomize() with {
                                  //crresp == 5'd1;
                                  //Addr channel
                                  arid     == 1'd0 ;
                                  araddr inside {[0:20]};//32'd0;
                                  arlen  inside {[1:10]};//255]} ; //inside {[1:255]}; 
                                  arsize   == 3'd5 ; // 16 bytes transfer-0b100
                                  arburst  == 2'd1 ; // INCR 0b01
                                  arlock   == 1'd0 ; 
                                  arcache  == 4'd0 ;
                                  arprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                  arqos    == 4'd0 ;
                                  arregion == 4'd0 ;
                                  aruser   == 8'd0 ;
                                  arsnoop  == 4'b1101 ;  // b1101 - MakeInvalid
                                  ardomain == 2'b10 ;    // b10 - Inner Sharable
                                  arbar    == 2'd0 ;
                                  //Snoop
                                  //Channels handshakes between valid and ready
                                  addr_hsk_type == VAL_BFR_RDY; 
                                  data_hsk_type == RDY_BFR_VAL;
                                  snoop_addr_hsk_type == VAL_BFR_RDY;
                                  snoop_resp_hsk_type == VAL_AND_RDY;
                                  snoop_data_hsk_type == RDY_BFR_VAL;
                                  //Channels delay
                                  addr_delay_type  == B2B;
                                  data_delay_type  == B2B;
                                  snoop_addr_delay_type == B2B;
                                  snoop_data_delay_type == B2B;
                                  snoop_resp_delay_type == B2B;
                                                                 })) //giving values to axi4wr signals
        `uvm_error(get_type_name(), "Rand error!")
      master_item.crresp = 5'd1;
      master_item.en_cd_channel = 1'd1;
      $display("SEQ LIB MASTER SEQ :: %s", master_item.sprint());                                                           
      $display("%t SEQ LIB :: BFR data hsk task En cd channel val = %d", $time, master_item.en_cd_channel);
      $display("%t SEQ LIB :: BFR data hsk task CRRESP VALUE = %d", $time, master_item.crresp);
      finish_item(master_item); //all data is on transaction item
    end
  endtask: body
endclass: aceread_mitrans_master_sequence

class aceread_mitrans_slave_sequence extends aceread_base_sequence;

  `uvm_object_utils(aceread_mitrans_slave_sequence)

  function new (string name= "aceread_mitrans_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    aceread_item slave_item;
    slave_item = aceread_item::type_id::create("slave_item");
    forever begin
      //Get address information for data generation
      p_sequencer.request_fifo.get(master_item);
      start_item(slave_item); //starting getting the data for item
      if(!(slave_item.randomize() with {
        //Addr channel
        arlen == master_item.arlen;
        rid == master_item.arid;
        crresp == master_item.crresp;
        ruser == 'd5;
        rresp == 'd0;
        //Snoop
        acaddr inside {[0:20]}; //32'd0;
        acsnoop == 4'b1101;
        acprot  == 'd0;
        //Channels handshakes between valid and ready
        addr_hsk_type == VAL_AND_RDY;
        data_hsk_type == VAL_BFR_RDY;
        snoop_addr_hsk_type == RDY_BFR_VAL;
        snoop_resp_hsk_type == VAL_BFR_RDY;
        snoop_data_hsk_type == VAL_BFR_RDY;
        //Channels delay
        addr_delay_type  == B2B;
        data_delay_type  == B2B;
        snoop_addr_delay_type == B2B;
        snoop_data_delay_type == B2B;
        snoop_resp_delay_type == B2B;
       })) //giving values to axi4wr signals
      `uvm_error(get_type_name(), "Rand error!")
      slave_item.crresp = 5'd1;
      slave_item.en_cd_channel = 1'd1;
      finish_item(slave_item); //all data is on transaction item  
    end
endtask: body

endclass: aceread_mitrans_slave_sequence