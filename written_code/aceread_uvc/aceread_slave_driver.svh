//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : aceread_slave_driver.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Slave Driver for AXI4 Read Verification IP (UVC)
//  ======================================================================================================

class aceread_slave_driver extends uvm_driver#(aceread_item);

  `uvm_component_utils (aceread_slave_driver)

  aceread_config m_read_config;

  //Mailbox to store transaction data for multiple addresses 
  mailbox #(aceread_item) rdata_mbox;
  mailbox #(aceread_item) snoop_data_mbox;
  mailbox #(aceread_item) snoop_resp_mbox;

  // Reactive flag to indicate if the slave is busy or not
  int i = 0;
  bit en_cd_channel = 1;

  function new (string name = "aceread_slave_driver" , uvm_component parent = null);
    super.new (name, parent);
    rdata_mbox = new();
    snoop_data_mbox = new();
    snoop_resp_mbox = new();
  endfunction: new

  virtual aceread_if v_if;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
  endfunction: build_phase  


  task run_phase(uvm_phase phase);
    aceread_item item;
    init();
    @(posedge v_if.rst_n);
    fork
      // Wait for data phase
      get_and_drive();
      data_handshake();
      snoop_data_handshake(); //if needed (crresp[0] == 1), put information on snoop data channel
    join
  endtask : run_phase

  task init();
    @(posedge v_if.clk);
//Read
    v_if.arready <= 'd1;
    v_if.rvalid  <= 'd0;
    v_if.rid     <= 'd0;
    v_if.ruser   <= 'd0;
    v_if.rdata   <= 'd0;
    v_if.rack    <= 'd0;
  //Snoop
    v_if.crready <= 'd1;
    v_if.cdready <= 'd1;
    v_if.acvalid <= 'd0;
  endtask : init

  task get_and_drive();
    forever begin
      //Get next response item from the sequencer
      seq_item_port.get_next_item(req);
      `uvm_info ("SLAVE: Getting next item...",$sformatf("get_next_item fn calling rsp"), UVM_MEDIUM)
      $cast(rsp, req.clone());
      rsp.set_id_info(req);
      mailbox_item(rsp);
      //Drive the response item
      $display("SLV DRV ITEM:%s", rsp.sprint());
      fork
        addr_handshake(rsp);
        snoop_addr_hsk(rsp); //put the item on the snoop addr channel
        snoop_resp_handshake(rsp);
      join
      //Consume the response item
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  task addr_handshake(aceread_item item);
    case(item.addr_hsk_type)
      VAL_BFR_RDY: begin
          //Wait for the valid signal
          @(posedge v_if.clk iff v_if.arvalid);
          @(posedge v_if.clk);
          //Delay between val and rdy
          repeat(item.addr_val_rdy_dly) @(posedge v_if.clk);
          //Assert ready
          v_if.arready <= 1'b1;
          @(posedge v_if.clk);
          //Deassert ready
          v_if.arready <= 1'b0;
      end
      RDY_BFR_VAL: begin
          //Assert ready
          v_if.arready <= 1'b1;
          //Delay
          repeat(item.addr_rdy_val_dly) @(posedge v_if.clk);
          //Wait for Valid Signal
          @(posedge v_if.clk iff v_if.arvalid);
          //Deassert ready
          v_if.arready <= 1'b0;
      end
      VAL_AND_RDY: begin
          //Wait for valid signal
          @(posedge v_if.clk iff v_if.arvalid);
          //Assert ready
          v_if.arready <= 1'b1;
          @(posedge v_if.clk);
          //Deassert ready
          v_if.arready <= 1'b0;
      end
    endcase
  endtask : addr_handshake


  task data_handshake();
    //Choosing of data channel hsk type
    aceread_item item;
    @(posedge v_if.clk);
    forever begin
      rdata_mbox.get(item); 
      $display("%t SLV DRV: Before foreach data size: %d", $time, item.rdata.size());
      //Taking all the rdata and putting value on it with send_data() task
      foreach(item.rdata[i]) begin
       // fork
          case(item.data_hsk_type)
            VAL_BFR_RDY: begin
              //Assert valid
              repeat(item.data_val_rdy_dly) @(posedge v_if.clk);
              v_if.rvalid <= 1'b1;
              //Put data channel items/information on interface bus
              send_data(item, i);
              //Wait for the ready signal assertion
              @(posedge v_if.clk iff v_if.rready);
              //Deassert valid if it remains asserted
              v_if.rvalid <= 1'b0;
            end
            RDY_BFR_VAL: begin
              //Wait for the ready signal assertion
              @(posedge v_if.clk iff v_if.rready);
              repeat(item.data_rdy_val_dly) @(posedge v_if.clk);
              //Optional delay between rdy and val
              //Assert valid
              v_if.rvalid <= 1'b1;
              //Put data channel items/information on interface bus
              send_data(item, i);
              //In case ready drops bfr valid is asserted
              @(posedge v_if.clk iff v_if.rready);
              //Deasserting valid
              v_if.rvalid <= 1'b0;
            end
            VAL_AND_RDY: begin
              //Wait for the assertion of ready signal
              @(posedge v_if.clk iff v_if.rready);
              //Assert valid
              v_if.rvalid <= 1'b1;
              //Put data channel items/information on interface bus
              send_data(item, i);
              //In case ready drops bfr valid is asserted
              @(posedge v_if.clk iff v_if.rready);
              v_if.rvalid <= 1'b0;
            end
          endcase
        //join
      end
    end
   // @(posedge v_if.clk iff (v_if.rvalid & v_if.rready & v_if.rlast));
   // disable fork;
  endtask : data_handshake

  //Drive item information to the virtual interface
  task send_data(aceread_item item, int i);
    //AXI4WR Data channel
      v_if.rdata  <= item.rdata[i];
      v_if.ruser  <= item.ruser;
      v_if.rresp  <= item.rresp;
      v_if.rid    <= item.rid;
      v_if.rlast  <= (i == (item.rdata.size() - 1)) ? 1'b1 : 1'b0;
    endtask: send_data

  task mailbox_item(aceread_item item);
    rdata_mbox.put(item);
    snoop_data_mbox.put(item);
    snoop_resp_mbox.put(item);
  endtask : mailbox_item

  task snoop_addr_hsk(aceread_item item);
    @(posedge v_if.clk);
  //Choosing of addr channel hsk type
    case(item.snoop_addr_hsk_type)
      VAL_BFR_RDY: begin
        //Assert valid
        repeat(item.snoop_addr_val_rdy_dly) @(posedge v_if.clk);
        v_if.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        //Wait for the ready signal assertion
        @(posedge v_if.clk iff v_if.acready);
        //Deassert valid if it remains asserted
        v_if.acvalid <= 1'b0;
      end
      RDY_BFR_VAL: begin
        //Wait for the ready signal assertion
        @(posedge v_if.clk iff v_if.acready);
        repeat(item.snoop_addr_rdy_val_dly) @(posedge v_if.clk);
        //Optional delay between rdy and val
        //Assert valid
        v_if.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        @(posedge v_if.clk iff v_if.acready);
        //Deasserting valid
        v_if.acvalid <= 1'b0;
      end
      VAL_AND_RDY: begin
        //Wait for the assertion of ready signal
        @(posedge v_if.clk iff v_if.acready);
        //Assert valid
        v_if.acvalid <= 1'b1;
        //Send addr and other snoop addr ch information
        send_snoop_addr(item);
        //In case ready drops bfr valid is asserted
        @(posedge v_if.clk iff v_if.acready);
        v_if.acvalid <= 1'b0;
      end
    endcase
  endtask: snoop_addr_hsk

  task snoop_data_handshake();
    aceread_item item;
    snoop_data_mbox.get(item);
    if(item.en_cd_channel == 1) begin 
        fork
          case(item.snoop_data_hsk_type)
            VAL_BFR_RDY: forever begin
              //Wait for the ready signal
              @(posedge v_if.clk iff v_if.cdvalid);
              @(posedge v_if.clk);
              //Delay between val and rdy
              repeat(item.snoop_data_val_rdy_dly) @(posedge v_if.clk);
              //Assert ready
              v_if.cdready <= 1'b1;
              @(posedge v_if.clk);
              //Deassert ready
              v_if.cdready <= 1'b0;
            end
            RDY_BFR_VAL: forever begin
              //Assert ready signal
              v_if.cdready <= 1'b1;
              //Delay
              repeat(item.snoop_data_rdy_val_dly) @(posedge v_if.clk);
              //Assert valid signal
              @(posedge v_if.clk iff (v_if.cdvalid));
              //Deassert ready
              v_if.cdready <= 1'b0;
            end
            VAL_AND_RDY: forever begin
              //Wait for valid signal
              @(posedge v_if.clk iff v_if.cdvalid);
              //Assert ready
              v_if.cdready <= 1'b1;
              @(posedge v_if.clk);
              //Deassert ready
              v_if.cdready <= 1'b0;
            end
          endcase
        join_none
        @(posedge v_if.clk iff (v_if.cdvalid & v_if.cdready));//& v_if.cdlast));
        disable fork;
      end
    else
      v_if.cdready <= 1'b0;
  endtask : snoop_data_handshake

  task snoop_resp_handshake(aceread_item item);
    forever begin
      snoop_resp_mbox.get(item);
      case(item.snoop_resp_hsk_type)
        VAL_BFR_RDY: begin
          //Wait for valid signal
          @(posedge v_if.clk iff v_if.crvalid);
          v_if.crready <= 1'b1;
          repeat(item.snoop_resp_val_rdy_dly) @(posedge v_if.clk);
          //Deassert ready after receiving the response
          v_if.crready <= 1'b0;
        end
        RDY_BFR_VAL: begin
          @(posedge v_if.clk iff v_if.cdlast);
          //Assert ready signal
          v_if.crready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge v_if.clk iff v_if.crvalid);
          repeat(item.snoop_resp_rdy_val_dly) @(posedge v_if.clk);
          //Deassert ready after receiving the response
          v_if.crready <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Assert ready signal
          v_if.crready <= 1'b1;
          //Wait for valid signal assertion
          @(posedge v_if.clk iff v_if.crvalid);
          //Deassert ready after receiving the response
          v_if.crready <= 1'b0;
        end
      endcase
    end
  endtask : snoop_resp_handshake

  task send_snoop_addr(aceread_item item);
    v_if.acaddr  <= item.acaddr;
    v_if.acsnoop <= item.acsnoop;
    v_if.acprot  <= item.acprot;
  endtask : send_snoop_addr

endclass : aceread_slave_driver