//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : ace_seq_lib.svh
//  Last modified+updates : 16/02/2023 (RM)
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Sequences Library for ACE Verification IP (UVC)
//  ======================================================================================================

class ace_base_sequence extends uvm_sequence;

  `uvm_object_utils (ace_base_sequence)

  `uvm_declare_p_sequencer(ace_sequencer)

  int trans_no = 5;
  ace_item master_item;

  function new (string name = "ace_base_sequence");
    super.new(name);
  endfunction : new

endclass : ace_base_sequence

class aceread_master_sequence extends ace_base_sequence; //read from memory
//Write sequence
  `uvm_object_utils(aceread_master_sequence)

  function new (string name= "aceread_master_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    ace_item t_item;
    t_item = ace_item::type_id::create("t_item"); //creating AXI4WR item for signals
    $cast(master_item, t_item.clone());
    $display("%t SEQ LIB :: Transactions no: %d" , $time, trans_no);
    repeat(trans_no) begin
      start_item(master_item); //starting getting the data for item
      if(!(master_item.randomize() with {
                                  //Addr channel
                                  arid     == 1'd0 ;
                                  araddr inside {[0:20]};//32'd0;
                                  arlen  inside {[1:10]}; //inside {[1:255]}; 
                                  arsize   == 3'd3 ; // 16 bytes transfer-0b100
                                  arburst  == 2'd1 ; // INCR 0b01
                                  arlock   == 1'd0 ; 
                                  arcache  == 4'd0 ;
                                  arprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                  arqos    == 4'd0 ;
                                  arregion == 4'd0 ;
                                  aruser   == 8'd0 ;
                                  arsnoop  == 4'd0 ;
                                  ardomain == 2'd0 ;
                                  arbar    == 2'd0 ;
                                  //Channels handshakes between valid and ready
                                  addr_hsk_type == VAL_BFR_RDY;
                                  data_hsk_type == RDY_BFR_VAL;
                                  //Signal for showing data direction for the uP(store to MM or load from MM)
                                  read_write == 1'b0;
                                  //Channels delay
                                  addr_delay_type  == B2B;
                                  //dist between rlast
                                  data_delay_type  == B2B;
                                 })) //giving values to axi4wr signals
        `uvm_error(get_type_name(), "Rand error!")
      $display("%t SEQ LIB ::  Snoop data channel enable = %d",$time, master_item.en_cd_channel);
      
      finish_item(master_item); //all data is on transaction item
    end
  endtask : body
endclass : aceread_master_sequence

class ace_write_master_sequence extends ace_base_sequence; //write to memory
  //Write sequence
    `uvm_object_utils(ace_write_master_sequence)
  
    function new (string name= "ace_write_master_sequence");
      super.new(name);
    endfunction : new
  
    virtual task body();
      ace_item t_item;
      t_item = ace_item::type_id::create("t_item"); //creating AXI4WR item for signals
      repeat(trans_no) begin
        start_item(t_item); //starting getting the data for item
         if(!(t_item.randomize() with {
                                     //Addr channel
                                     awid     == 1'd0 ;
                                     awaddr inside {[0:20]};//32'd0;
                                     awlen  inside {[0:255]}; 
                                     awsize   == 3'd3 ; // 16 bytes transfer-0b100 for 128 data width bus
                                     awburst  == 2'd1 ; // INCR 0b01
                                     awlock   == 1'd0 ; 
                                     awcache  == 4'd0 ;
                                     awprot   == 3'd2 ; // b010(Data access,non-secure access,unprivileged)
                                     awqos    == 4'd0 ;
                                     awregion == 4'd0 ;
                                     awuser   == 8'd0 ;
                                     awsnoop  == 3'd0 ;
                                     awdomain == 2'd0 ;
                                     awbar    == 2'd0 ;
                                     awunique == 1'd0 ;
                                     //Data channel
                                     wuser == 8'd0;
                                     //Signal for showing data direction for the uP(store to MM or load from MM)
                                     read_write == 1'b1;
                                     //Channels handshakes between valid and ready
                                     addr_hsk_type == VAL_BFR_RDY;
                                     data_hsk_type == VAL_BFR_RDY;
                                     resp_hsk_type == RDY_BFR_VAL;
                                     //Channels delay
                                     addr_delay_type  == B2B;
                                     data_delay_type  == B2B;
                                     resp_delay_type  == B2B;
                                    })) //giving values to axi4wr signals
           `uvm_error(get_type_name(), "Rand error!")
         finish_item(t_item); //all data is on transaction item
      end
    endtask : body
  
endclass : ace_write_master_sequence

class ace_write_slave_sequence extends ace_base_sequence; //read from memory

  `uvm_object_utils(ace_write_slave_sequence)

  function new (string name= "ace_write_slave_sequence");
    super.new(name);
  endfunction : new

  virtual task body();
    ace_item t_item;
    ace_item item;
    t_item = ace_item::type_id::create("t_item"); //creating AXI4WR item for signals
    forever begin
      //wait for a transaction request (get is blocking)
      $cast(item, t_item.clone());
      //generate response based on observed request
      start_item(item); //starting getting the data for item
      //Snoop Addr Channel
      item.acaddr  = 'd0;//inside {[0:20]};//32'd0;
      item.acsnoop = 'd0;
      item.acprot  = 'd0;
      //TODO: Preserving address channel item values don't randomize item!
      //Response channel
      item.bid   = 'd0;
      item.buser = 'd0;
      item.bresp = 'd0;
      //Channels handshakes between valid and ready
      item.addr_hsk_type = VAL_AND_RDY;
      item.data_hsk_type = VAL_BFR_RDY;
      item.resp_hsk_type = VAL_AND_RDY;
      //Channels delay
      item.addr_delay_type  = B2B;
      item.data_delay_type  = B2B;
      item.resp_delay_type  = B2B;
      //giving values to axi4wr signals
      //Resp channel
      finish_item(item); //all data is on transaction item  
      p_sequencer.request_fifo.get(item);
    end
endtask : body

endclass : ace_write_slave_sequence

class aceread_slave_sequence extends ace_base_sequence; //write to memory

  `uvm_object_utils(aceread_slave_sequence)

  function new (string name= "aceread_slave_sequence");
    super.new(name);
  endfunction: new

  virtual task body();
    ace_item item;
    item = ace_item::type_id::create("item"); //creating AXI4WR item for signals
    forever begin
      //Get address information for data generation
      p_sequencer.request_fifo.get(master_item);
      start_item(item); //starting getting the data for item\
      if(!(item.randomize() with {
        //Addr channel
        arlen == master_item.arlen;
        rid == master_item.arid;
        ruser == 'd5;
        rresp == 'd0;
        //Snoop Addr Channel
        acaddr inside {[0:20]}; //32'd0;
        acsnoop == 'd0;
        acprot  == 'd0;
        //Channels handshakes between valid and ready
        addr_hsk_type == VAL_AND_RDY;
        //dist between rlast
        data_hsk_type == VAL_BFR_RDY;
        //Channels delay
        addr_delay_type  == B2B;
        data_delay_type  == B2B;
       })) //giving values to axi4wr signals
      `uvm_error(get_type_name(), "Rand error!")
      finish_item(item); //all data is on transaction item  
    end
endtask : body

endclass : aceread_slave_sequence

