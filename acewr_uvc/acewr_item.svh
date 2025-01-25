//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023
//  File name             : acewr_item.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Item for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_item extends uvm_sequence_item;

  //Control Information (address)
  rand bit [32 -1:0] awaddr  ; 
  rand bit [1:0]     awid    ;
  rand bit [8 -1:0]  awlen   ;
  rand bit [8 -1:0]  awuser  ;
  rand bit [3 : 0]   awregion;  
  rand bit [2 : 0]   awsize  ;
  rand bit [1 : 0]   awburst ;
  rand bit           awlock  ;
  rand bit [3 : 0]   awcache ;
  rand bit [2 : 0]   awprot  ;
  rand bit [3 : 0]   awqos   ;
  //ACE additional signals
  rand bit [2: 0] awsnoop;
  rand bit [1: 0] awdomain;
  rand bit [1: 0] awbar;
  rand bit        awunique;
  //Transaction data 
  rand bit [128 -1:0]   wdata[];
  rand bit [128/8 -1:0] wstrb[];
  rand bit [8 -1 :0]    wuser;
  //Write resp data 
  rand bit [1:0]           bid  ;
  rand bit [8 -1:0]        buser;
  rand bit [1 : 0]         bresp;
  //Snoop address channel (AC) signals
  rand bit [32-1 :0] acaddr; // must match AXI4 WR/R address bus width
  rand bit [3 : 0]   acsnoop;
  rand bit [2 : 0]   acprot;
  //Snoop response channel (CR) signals
  rand bit [4: 0] crresp;   
  //Snoop data channel (CD) signals
  rand bit [128-1 :0] cddata;

  //Flag bit to activate/deactivate snoop data channel if necesarry to write to the main memory
  rand bit  en_cd_channel;

  rand bit [9:0] addr_val_rdy_dly;
  rand bit [9:0] addr_rdy_val_dly;

  rand bit [9:0] data_val_rdy_dly;
  rand bit [9:0] data_rdy_val_dly;

  rand bit [9:0] resp_rdy_val_dly;
  rand bit [9:0] resp_val_rdy_dly;

  rand bit [9:0] snoop_addr_rdy_val_dly;
  rand bit [9:0] snoop_addr_val_rdy_dly;

  rand bit [9:0] snoop_data_rdy_val_dly;
  rand bit [9:0] snoop_data_val_rdy_dly;

  rand bit [9:0] snoop_resp_rdy_val_dly;
  rand bit [9:0] snoop_resp_val_rdy_dly;
  //delay types declaration
  rand delay_type addr_delay_type ;
  rand delay_type data_delay_type ;
  rand delay_type resp_delay_type ;

  rand delay_type snoop_addr_delay_type;
  rand delay_type snoop_data_delay_type;
  rand delay_type snoop_resp_delay_type;

  rand hsk_type addr_hsk_type;
  rand hsk_type data_hsk_type;
  rand hsk_type resp_hsk_type;

  rand hsk_type snoop_addr_hsk_type;
  rand hsk_type snoop_data_hsk_type;
  rand hsk_type snoop_resp_hsk_type;


//Data size constraint, according to AXI4 protocol
  constraint c_data_size{
    wdata.size() == (awlen + 1);
    wstrb.size() == (awlen + 1);
  };

  constraint c_addr_size{
    awaddr%16 == 0;
    soft acaddr%16 == 0;
  };

  //Constraint to use the snoop data channel by the protocol if needed
  //Constraint to use the snoop data channel by the protocol if needed
  constraint c_snooped_data{
    solve crresp before en_cd_channel;
    (crresp[0] == 1'b1) -> en_cd_channel == 1'b1;
  };
  
//Constraint for address channel transactions delay
  constraint c_addr_trans_delay {
    solve addr_delay_type before addr_val_rdy_dly,addr_rdy_val_dly;
    (addr_delay_type == B2B)    -> addr_val_rdy_dly == 0 &&
                              addr_rdy_val_dly == 0;
    (addr_delay_type == SHORT)  -> addr_val_rdy_dly inside {[1: 10]} &&
                              addr_rdy_val_dly inside {[1: 10]};
    (addr_delay_type == MEDIUM) -> addr_val_rdy_dly inside {[10: 100]} && 
                              addr_rdy_val_dly inside {[10: 100]};
    (addr_delay_type == LONG)   -> addr_val_rdy_dly inside {[100: 1000]} &&
                              addr_rdy_val_dly inside {[100: 1000]};
  };
//Constraint for data channel transactions delay
  constraint c_data_trans_delay {
    solve data_delay_type before data_val_rdy_dly,data_rdy_val_dly;
    (data_delay_type == B2B)    -> data_val_rdy_dly == 0 &&
                              data_rdy_val_dly == 0;
    (data_delay_type == SHORT)  -> data_val_rdy_dly inside {[1: 10]} &&
                              data_rdy_val_dly inside {[1: 10]};
    (data_delay_type == MEDIUM) -> data_val_rdy_dly inside {[10: 100]} &&   
                              data_rdy_val_dly inside {[10: 100]};
    (data_delay_type == LONG)   -> data_val_rdy_dly inside {[100: 1000]} &&
                              data_rdy_val_dly inside {[100: 1000]};
  };
//Constraint for response channel transactions delay
  constraint c_resp_trans_delay {
    solve resp_delay_type before resp_val_rdy_dly,resp_rdy_val_dly;
    (resp_delay_type == B2B)    -> resp_val_rdy_dly == 0 &&
                              resp_rdy_val_dly == 0;
    (resp_delay_type == SHORT)  -> resp_val_rdy_dly inside {[1: 10]} &&
                              resp_rdy_val_dly inside {[1: 10]};
    (resp_delay_type == MEDIUM) -> resp_val_rdy_dly inside {[10: 100]} &&   
                              resp_rdy_val_dly inside {[10: 100]};
    (resp_delay_type == LONG)   -> resp_val_rdy_dly inside {[100: 1000]} &&
                              resp_rdy_val_dly inside {[100: 1000]};
  };

  constraint c_snoop_addr_trans_delay{
    solve snoop_addr_delay_type before snoop_addr_val_rdy_dly,snoop_addr_rdy_val_dly;
    (snoop_addr_delay_type == B2B)    -> snoop_addr_val_rdy_dly == 0 &&
                                    snoop_addr_rdy_val_dly == 0;
    (snoop_addr_delay_type == SHORT)  -> snoop_addr_val_rdy_dly inside {[1: 10]} &&
                                    snoop_addr_rdy_val_dly inside {[1: 10]};
    (snoop_addr_delay_type == MEDIUM) -> snoop_addr_val_rdy_dly inside {[10: 100]} &&   
                                    snoop_addr_rdy_val_dly inside {[10: 100]};
    (snoop_addr_delay_type == LONG)   -> snoop_addr_val_rdy_dly inside {[100: 1000]} &&
                                    snoop_addr_rdy_val_dly inside {[100: 1000]};
  };

  constraint c_snoop_data_trans_delay{
    solve snoop_data_delay_type before snoop_data_val_rdy_dly,snoop_data_rdy_val_dly;
    (snoop_data_delay_type == B2B)    -> snoop_data_val_rdy_dly == 0 &&
                                    snoop_data_rdy_val_dly == 0;
    (snoop_data_delay_type == SHORT)  -> snoop_data_val_rdy_dly inside {[1: 10]} &&
                                    snoop_data_rdy_val_dly inside {[1: 10]};
    (snoop_data_delay_type == MEDIUM) -> snoop_data_val_rdy_dly inside {[10: 100]} &&   
                                    snoop_data_rdy_val_dly inside {[10: 100]};
    (snoop_data_delay_type == LONG)   -> snoop_data_val_rdy_dly inside {[100: 1000]} &&
                                    snoop_data_rdy_val_dly inside {[100: 1000]};
  };

  constraint c_snoop_resp_trans_delay{
    solve snoop_resp_delay_type before snoop_resp_val_rdy_dly,snoop_resp_rdy_val_dly;
    (snoop_resp_delay_type == B2B)    -> snoop_resp_val_rdy_dly == 0 &&
                                    snoop_resp_rdy_val_dly == 0;
    (snoop_resp_delay_type == SHORT)  -> snoop_resp_val_rdy_dly inside {[1: 10]} &&
                                    snoop_resp_rdy_val_dly inside {[1: 10]};
    (snoop_resp_delay_type == MEDIUM) -> snoop_resp_val_rdy_dly inside {[10: 100]} &&   
                                    snoop_resp_rdy_val_dly inside {[10: 100]};
    (snoop_resp_delay_type == LONG)   -> snoop_resp_val_rdy_dly inside {[100: 1000]} &&
                                    snoop_resp_rdy_val_dly inside {[100: 1000]};
  };  

  //Utility and Field macros including paramteres
  //TODO: To be documented registry uvm_field_int and do_copy,do_compare,do_pack,do_unpack,do_print overwriting fn
  //`uvm_field_int(ARVALID,UVM_ALL_ON|UVM_NOPRINT|UVM_NOCOMPARE) example how to ignore these fn and to not overwrite them
  `uvm_object_utils_begin(acewr_item)
  //Address channel
    `uvm_field_int (awaddr,   UVM_DEFAULT)
    `uvm_field_int (awid,     UVM_DEFAULT)
    `uvm_field_int (awlen,    UVM_DEFAULT)
    `uvm_field_int (awuser,   UVM_DEFAULT)
    `uvm_field_int (awregion, UVM_DEFAULT)
    `uvm_field_int (awsize,   UVM_DEFAULT)
    `uvm_field_int (awburst,  UVM_DEFAULT)
    `uvm_field_int (awlock,   UVM_DEFAULT)
    `uvm_field_int (awcache,  UVM_DEFAULT)
    `uvm_field_int (awprot ,  UVM_DEFAULT)
    `uvm_field_int (awqos,    UVM_DEFAULT)
  //ACE extension
    `uvm_field_int (awsnoop,  UVM_DEFAULT)
    `uvm_field_int (awdomain, UVM_DEFAULT)
    `uvm_field_int (awbar,    UVM_DEFAULT)
    `uvm_field_int (awunique, UVM_DEFAULT)
  //Data channel
    `uvm_field_array_int (wdata, UVM_DEFAULT)
    `uvm_field_array_int (wstrb, UVM_DEFAULT)
    `uvm_field_int (wuser, UVM_DEFAULT)
  //Response channel
    `uvm_field_int (bid,    UVM_DEFAULT)
    `uvm_field_int (bresp,  UVM_DEFAULT)
    `uvm_field_int (buser,  UVM_DEFAULT)
  //Snoop address channel (AC) signals
    `uvm_field_int (acaddr,    UVM_DEFAULT)
    `uvm_field_int (acsnoop,  UVM_DEFAULT)
    `uvm_field_int (acprot,  UVM_DEFAULT)
  //Snoop response channel (CR) signals
    `uvm_field_int (crresp,  UVM_DEFAULT)
  //Snoop data channel (CD) signals
    `uvm_field_int (cddata, UVM_DEFAULT)
  //
    `uvm_field_int (en_cd_channel,  UVM_DEFAULT)
  //Delay 
    `uvm_field_enum (delay_type, addr_delay_type, UVM_DEFAULT)
    `uvm_field_int  (addr_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (addr_val_rdy_dly, UVM_DEFAULT)
    `uvm_field_enum (delay_type, data_delay_type, UVM_DEFAULT)
    `uvm_field_int  (data_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (data_val_rdy_dly, UVM_DEFAULT)
    `uvm_field_enum (delay_type, resp_delay_type, UVM_DEFAULT)
    `uvm_field_int  (resp_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (resp_val_rdy_dly, UVM_DEFAULT)
    `uvm_field_enum (delay_type, snoop_addr_delay_type, UVM_DEFAULT)
    `uvm_field_int  (snoop_addr_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (snoop_addr_val_rdy_dly, UVM_DEFAULT)
    `uvm_field_enum (delay_type, snoop_data_delay_type, UVM_DEFAULT)
    `uvm_field_int  (snoop_data_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (snoop_data_val_rdy_dly, UVM_DEFAULT)
    `uvm_field_enum (delay_type, snoop_resp_delay_type, UVM_DEFAULT)
    `uvm_field_int  (snoop_resp_rdy_val_dly, UVM_DEFAULT)
    `uvm_field_int  (snoop_resp_val_rdy_dly, UVM_DEFAULT)
  //Handshake type
    `uvm_field_enum (hsk_type, addr_hsk_type, UVM_DEFAULT)
    `uvm_field_enum (hsk_type, data_hsk_type, UVM_DEFAULT)
    `uvm_field_enum (hsk_type, resp_hsk_type, UVM_DEFAULT)
    `uvm_field_enum (hsk_type, snoop_addr_hsk_type, UVM_DEFAULT)
    `uvm_field_enum (hsk_type, snoop_data_hsk_type, UVM_DEFAULT)
    `uvm_field_enum (hsk_type, snoop_resp_hsk_type, UVM_DEFAULT)
    //Configuration signals
  `uvm_object_utils_end
  
  //Constructor
  function new(string name = "acewr_item");
    super.new(name);
  endfunction: new

endclass: acewr_item
