//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_slave_driver.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Slave Driver for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_slave_driver extends uvm_driver#(acewr_item);

  `uvm_component_utils (acewr_slave_driver)

  acewr_config m_wr_config;

  //Mailbox to store transaction data for multiple addresses 
  mailbox #(acewr_item) wdata_mbox;
  mailbox #(acewr_item) resp_mbox;
  mailbox #(acewr_item) snoop_data_mbox;
  mailbox #(acewr_item) snoop_resp_mbox;

  // Reactive flag to indicate if the slave is busy or not
  int i = 0;

  function new (string name = "acewr_slave_driver" , uvm_component parent = null);
    super.new (name, parent);
    wdata_mbox = new();
    resp_mbox = new();
    snoop_data_mbox = new();
    snoop_resp_mbox = new();
  endfunction: new
  
  virtual acewr_if v_if;

  virtual function void build_phase (uvm_phase phase);
    super.build_phase (phase);
  endfunction: build_phase  


  task run_phase(uvm_phase phase);
    acewr_item item;
    init();
    @(posedge v_if.rst_n);
    fork
      // Wait for data phase
      get_and_drive();
      data_handshake();
      // Wait for response phase
      resp_handshake();
      snoop_data_handshake(); //if needed (crresp[0] == 1), put information on snoop data channel
    join
  endtask : run_phase

  task init();
    @(posedge v_if.clk);
    v_if.wack <= 'd0;
  //Write
    v_if.awvalid <= 'd0;
    v_if.wvalid  <= 'd0;
    v_if.bready  <= 'd1;
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
      fork
        //Drive the response item
        addr_handshake(rsp);
        snoop_addr_hsk(rsp); //put the item on the snoop addr channel
        mailbox_item(rsp);
        snoop_resp_handshake(rsp);
      join
      //Consume the response item
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  task addr_handshake(acewr_item item);
    case(item.addr_hsk_type)
      VAL_BFR_RDY: begin
          //Wait for the valid signal
          @(posedge v_if.clk iff v_if.awvalid);
          @(posedge v_if.clk);
          //Delay between val and rdy
          repeat(item.addr_val_rdy_dly) @(posedge v_if.clk);
          //Assert ready
          v_if.awready <= 1'b1;
          @(posedge v_if.clk);
          //Deassert ready
          v_if.awready <= 1'b0;
      end
      RDY_BFR_VAL: begin
          //Assert ready
          v_if.awready <= 1'b1;
          //Delay
          repeat(item.addr_rdy_val_dly) @(posedge v_if.clk);
          //Wait for Valid Signal
          @(posedge v_if.clk iff v_if.awvalid);
          //Deassert ready
          v_if.awready <= 1'b0;
      end
      VAL_AND_RDY: begin
          //Wait for valid signal
          @(posedge v_if.clk iff v_if.awvalid);
          //Assert ready
          v_if.awready <= 1'b1;
          @(posedge v_if.clk);
          //Deassert ready
          v_if.awready <= 1'b0;
      end
    endcase
  endtask : addr_handshake

  task data_handshake();
    acewr_item item;
    forever begin
      wdata_mbox.get(item);
      fork
        case(item.data_hsk_type)
          VAL_BFR_RDY: forever begin
            //Wait for the ready signal
            @(posedge v_if.clk iff v_if.wvalid);
            @(posedge v_if.clk);
            //Delay between val and rdy
            repeat(item.data_val_rdy_dly) @(posedge v_if.clk);
            //Assert ready
            v_if.wready <= 1'b1;
            @(posedge v_if.clk);
            //Deassert ready
            v_if.wready <= 1'b0;
          end
          RDY_BFR_VAL: forever begin
            //Assert ready signal
            v_if.wready <= 1'b1;
            //Delay
            repeat(item.data_rdy_val_dly) @(posedge v_if.clk);
            //Assert valid signal
            @(posedge v_if.clk iff (v_if.wvalid));
            //Deassert ready
            v_if.wready <= 1'b0;
          end
          VAL_AND_RDY: forever begin
            //Wait for valid signal
            @(posedge v_if.clk iff v_if.wvalid);
            //Assert ready
            v_if.wready <= 1'b1;
            @(posedge v_if.clk);
            //Deassert ready
            v_if.wready <= 1'b0;
          end
        endcase
      join_none
      @(posedge v_if.clk iff (v_if.wvalid & v_if.wready & v_if.wlast));
      disable fork;
      resp_mbox.put(item);
    end
  endtask : data_handshake

  task resp_handshake();
    acewr_item item;
    forever begin
      resp_mbox.get(item);
      case(item.resp_hsk_type)
        VAL_BFR_RDY: begin
          //Assert valid
          v_if.bvalid <= 1'b1;
          //Wait for ready
          send_response(item);
          repeat(item.resp_val_rdy_dly) @(posedge v_if.clk);
          @(posedge v_if.clk iff v_if.bready);
          //Deassert Valid
          v_if.bvalid <= 1'b0;
        end
        RDY_BFR_VAL: begin
          //Wait for the ready signal to be asserted
          @(posedge v_if.clk iff v_if.bready);
          //Delay between bready and bvalid
          repeat(item.resp_rdy_val_dly) @(posedge v_if.clk);
          //Assert bvalid
          v_if.bvalid <= 1'b1;
          send_response(item);
          //Deassert valid
          v_if.bvalid <= 1'b0;
        end
        VAL_AND_RDY: begin
          //Wait for the ready signal 
          @(posedge v_if.clk iff v_if.bready);
          //Assert valid without delay and deassert it
          v_if.bvalid <= 1'b1;
          send_response(item);
          @(posedge v_if.clk);
          v_if.bvalid <= 1'b0;
        end
      endcase
    end
  endtask : resp_handshake

  task send_response(acewr_item item);
    v_if.bid   <= item.bid;
    v_if.bresp <= item.bresp;
    v_if.buser <= item.buser;
  endtask : send_response

  task snoop_addr_hsk(acewr_item item);
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
    acewr_item item;
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

  task snoop_resp_handshake(acewr_item item);
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

  task send_snoop_addr(acewr_item item);
    v_if.acaddr  <= item.acaddr;
    v_if.acsnoop <= item.acsnoop;
    v_if.acprot  <= item.acprot;
  endtask : send_snoop_addr

  task mailbox_item(acewr_item item);
    wdata_mbox.put(item);
    snoop_data_mbox.put(item);
    snoop_resp_mbox.put(item);
  endtask : mailbox_item

endclass : acewr_slave_driver