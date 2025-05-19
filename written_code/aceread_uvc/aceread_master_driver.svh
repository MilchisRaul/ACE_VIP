//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : aceread_master_driver.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Master Driver for AXI4 Read Verification IP (UVC)
//  ======================================================================================================

class aceread_master_driver extends uvm_driver#(aceread_item);

  `uvm_component_utils (aceread_master_driver)

  aceread_config m_read_config;
  
  //Mailbox to store transaction data for multiple addresses 
  mailbox #(aceread_item) rdata_mbox;
  mailbox #(aceread_item) snoop_data_mbox;

  int i = 0;
  bit en_cd_channel = 1;

  //class constructor
  function new (string name = "aceread_master_driver" , uvm_component parent = null);
    super.new (name, parent);
    rdata_mbox = new();
    snoop_data_mbox = new();
  endfunction: new

  virtual aceread_if v_if;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    init();
    @(posedge v_if.rst_n);
    fork
      get_and_drive();
      data_handshake(); //drive data with the handshakes ass soon as the data mailbox is not empty
      snoop_data_handshake(); //if needed (crresp[0] == 1), put information on snoop data channel
    join
  endtask: run_phase

  task get_and_drive();
    forever begin
      seq_item_port.get_next_item(req); //getting transaction data from TLM sequencer port
      `uvm_info ("MASTER: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_MEDIUM)
      $cast(rsp, req.clone()); // casting the transaction data into a clone transaction data item
      rsp.set_id_info(req); //setting the transaction/sequence id for future response compatibility
      fork
        snoop_resp_handshake(rsp);
        mailbox_item(rsp);   //put the item in the mailbox after address
        addr_handshake(rsp);  //put the item on the addr channel
        snoop_addr_hsk(rsp); //prut the item on the snoop addr channel
        $display("%t Master DRV :: BFR data hsk task En cd channel val = %d ", $time, rsp.en_cd_channel);
        $display("%t Master DRV :: BFR data hsk task CRRESP VALUE = %d ", $time, rsp.crresp);
        $display("MASTER DRV ITEM: %s", rsp.sprint());
      join
      //TODO: Document display feature for debug in the project documentation
      //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ADDR rdy_val_dly %d",rsp.addr_rdy_val_dly);
      //$display("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ADDR delay_type %s",rsp.addr_delay_type.name());
      seq_item_port.item_done(); //all requested transaction data was successfully drived to the virtual interface that 
                                 //communicates with the DUT
    end
  endtask: get_and_drive

  task init();
    @(posedge v_if.clk);
  //Read
    v_if.arvalid <= 'd0;
    v_if.rready  <= 'd1;
    v_if.arid    <= 'd0;
    v_if.aruser  <= 'd0;
    v_if.rack    <= 'd0;
  //Snoop
    v_if.crvalid <= 'd0;
    v_if.cdvalid <= 'd0;
    v_if.acready <= 'd1;
  endtask : init

  task send_addr(aceread_item item);
  //AXI4Read Addr channel
    v_if.araddr   <= item.araddr  ;
    v_if.arid     <= item.arid    ;
    v_if.arlen    <= item.arlen   ;
    v_if.arsize   <= item.arsize  ;
    v_if.arburst  <= item.arburst ;
    v_if.arlock   <= item.arlock  ;  
    v_if.arcache  <= item.arcache ;
    v_if.arprot   <= item.arprot  ;
    v_if.arqos    <= item.arqos   ;
    v_if.arregion <= item.arregion;
    v_if.aruser   <= item.aruser  ;
  //ACE protocol additional signals
    v_if.ardomain <= item.ardomain;
    v_if.arbar    <= item.arbar   ;
    v_if.arsnoop  <= item.arsnoop ;
  endtask: send_addr

  task addr_handshake(aceread_item item);
    @(posedge v_if.clk);
  //Choosing of addr channel hsk type
    case(item.addr_hsk_type)
      VAL_BFR_RDY: begin
        //Assert valid
        repeat(item.addr_val_rdy_dly) @(posedge v_if.clk);
        v_if.arvalid <= 1'b1;
        //Put address channel items/information on interface bus
        send_addr(item);
        //Wait for the ready signal assertion
        @(posedge v_if.clk iff v_if.arready);
        //Deassert valid if it remains asserted
        v_if.arvalid <= 1'b0;
      end
      RDY_BFR_VAL: begin
        //Wait for the ready signal assertion
        @(posedge v_if.clk iff v_if.arready);
        repeat(item.addr_rdy_val_dly) @(posedge v_if.clk);
        //Optional delay between rdy and val
        //Assert valid
        v_if.arvalid <= 1'b1;
        //Put address channel items/information on interface bus
        send_addr(item);
        @(posedge v_if.clk iff v_if.arready);
        //Deasserting valid
        v_if.arvalid <= 1'b0;
      end
      VAL_AND_RDY: begin
        //Wait for the assertion of ready signal
        @(posedge v_if.clk iff v_if.arready);
        //Assert valid
        v_if.arvalid <= 1'b1;
        //Put address channel items/information on interface bus
        send_addr(item);
        //In case ready drops bfr valid is asserted
        @(posedge v_if.clk iff v_if.arready);
        v_if.arvalid <= 1'b0;
      end
    endcase
  endtask: addr_handshake

  task data_handshake();
    aceread_item item;
    rdata_mbox.get(item);
    foreach(item.rdata[i]) begin 
      //rdata_mbox.get(item);
      fork
        case(item.data_hsk_type)
          VAL_BFR_RDY: forever begin
            //Wait for the ready signal
            @(posedge v_if.clk iff v_if.rvalid);
            @(posedge v_if.clk);
            //Delay between val and rdy
            repeat(item.data_val_rdy_dly) @(posedge v_if.clk);
            //Assert ready
            v_if.rready <= 1'b1;
            @(posedge v_if.clk);
            //Deassert ready
            v_if.rready <= 1'b0;
          end
          RDY_BFR_VAL: forever begin
            //Assert ready signal
            v_if.rready <= 1'b1;
            //Delay
            repeat(item.data_rdy_val_dly) @(posedge v_if.clk);
            //Assert valid signal
            @(posedge v_if.clk iff (v_if.rvalid));
            //Deassert ready
            v_if.rready <= 1'b0;
          end
          VAL_AND_RDY: forever begin
            //Wait for valid signal
            @(posedge v_if.clk iff v_if.rvalid);
            //Assert ready
            v_if.rready <= 1'b1;
            @(posedge v_if.clk);
            //Deassert ready
            v_if.rready <= 1'b0;
          end
        endcase
      join_none
    end
      @(posedge v_if.clk iff (v_if.rvalid & v_if.rready & v_if.rlast));
      disable fork;
  endtask : data_handshake

 //task for seding optional data for writing to MM or to other uP's caches
  task send_snoop_data(aceread_item item);
    v_if.cddata <= item.cddata;
    //v_if.cdlast <= item.cddata ? 1'b1 : 1'b0;
  endtask : send_snoop_data

  task send_snoop_resp(aceread_item item);
    v_if.crresp <= item.crresp;
  endtask : send_snoop_resp

  task snoop_addr_hsk(aceread_item item);
      case(item.snoop_addr_hsk_type)
        VAL_BFR_RDY: begin
            //Wait for the valid signal
            @(posedge v_if.clk iff v_if.acvalid);
            @(posedge v_if.clk);
            //Delay between val and rdy
            repeat(item.snoop_addr_val_rdy_dly) @(posedge v_if.clk);
            //Assert ready
            v_if.acready <= 1'b1;
            //Master can recieve address
            @(posedge v_if.clk);
            //Deassert ready
            v_if.acready <= 1'b0;
        end
        RDY_BFR_VAL: begin
            //Assert ready
            v_if.acready <= 1'b1;
            //Delay
            repeat(item.snoop_addr_rdy_val_dly) @(posedge v_if.clk);
            //Wait for Valid Signal
            @(posedge v_if.clk iff v_if.acvalid);
            //Master can recieve address
            //Deassert ready
            v_if.acready <= 1'b0;
        end
        VAL_AND_RDY: begin
            //Wait for valid signal
            @(posedge v_if.clk iff v_if.acvalid);
            //Assert ready
            v_if.acready <= 1'b1;
            @(posedge v_if.clk);
            //Master can recieve address
            //Deassert ready
            v_if.acready <= 1'b0;
        end
      endcase
  endtask : snoop_addr_hsk

  task snoop_data_handshake();
    aceread_item item;
    //if snooped data needs to be stored to a uP cache or updated/loaded in the main memory (from the sequence | for ex. it's in a Dirty state)
    //the crresp[0] bit needs to be 'b1, and the following if else condition does that from the constraint in item
    @(posedge v_if.clk);
    forever begin
    snoop_data_mbox.get(item);
      if(item.en_cd_channel == 1) begin
        //Choosing of snoop data channel hsk type
        case(item.snoop_data_hsk_type)
          VAL_BFR_RDY: begin
            //Assert valid
            repeat(item.snoop_data_val_rdy_dly) @(posedge v_if.clk);
            v_if.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            //Wait for the ready signal assertion
            @(posedge v_if.clk iff v_if.cdready);
            //Deassert valid if it remains asserted
            v_if.cdvalid <= 1'b0;
          end
          RDY_BFR_VAL: begin
            //Wait for the ready signal assertion
            @(posedge v_if.clk iff v_if.cdready);
            repeat(item.snoop_data_rdy_val_dly) @(posedge v_if.clk);
            //Optional delay between rdy and val
            //Assert valid
            v_if.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            //In case ready drops bfr valid is asserted
            @(posedge v_if.clk iff v_if.cdready);
            //Deasserting valid
            v_if.cdvalid <= 1'b0;
          end
          VAL_AND_RDY: begin
            //Wait for the assertion of ready signal
            @(posedge v_if.clk iff v_if.cdready);
            //Assert valid
            v_if.cdvalid <= 1'b1;
            //Put snoop data channel items/information on interface bus
            send_snoop_data(item);
            //In case ready drops bfr valid is asserted
            @(posedge v_if.clk iff v_if.cdready);
            v_if.cdvalid <= 1'b0;
          end
        endcase
      end
      else
      v_if.cdvalid <= 1'b0;
    end
  endtask : snoop_data_handshake

  task snoop_resp_handshake(aceread_item item);
    forever begin
      case(item.snoop_resp_hsk_type)
        VAL_BFR_RDY: begin
          //Assert valid
          v_if.crvalid <= 1'b1;
          //Wait for ready
          repeat(item.snoop_resp_val_rdy_dly) @(posedge v_if.clk);
          @(posedge v_if.clk iff v_if.crready);
          send_snoop_resp(item);
          //Deassert Valid
          v_if.crvalid <= 1'b0;
        end
        RDY_BFR_VAL: begin
          //Wait for the ready signal to be asserted
          @(posedge v_if.clk iff v_if.crready);
          //Delay between bready and bvalid
          repeat(item.snoop_resp_rdy_val_dly) @(posedge v_if.clk);
          //Assert bvalid
          v_if.crvalid <= 1'b1;
          send_snoop_resp(item);
          //Deassert valid
          v_if.crvalid <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Wait for the ready signal 
          @(posedge v_if.clk iff v_if.crready);
          //Assert valid without delay and deassert it
          v_if.crvalid <= 1'b1;
          send_snoop_resp(item);
          @(posedge v_if.clk);
          v_if.crvalid <= 1'b0;
        end
      endcase
    end
  endtask : snoop_resp_handshake

  task mailbox_item(aceread_item item);
    snoop_data_mbox.put(item);
    rdata_mbox.put(item);
  endtask : mailbox_item

endclass: aceread_master_driver

