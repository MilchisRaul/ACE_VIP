class acewrite_item extends uvm_sequence_item;

    // Address Write Channel
    rand logic [31:0] awaddr;    // Write address
    rand logic [1:0]  awburst;   // Burst type
    rand logic [3:0]  awcache;   // Cache type
    rand logic [3:0]  awid;      // Transaction ID
    rand logic [7:0]  awlen;     // Burst length
    rand logic [2:0]  awprot;    // Protection type
    rand logic [2:0]  awsize;    // Burst size
    rand logic [3:0]  awqos;     // Quality of Service
    rand logic [3:0]  awregion;  // Region identifier
    rand logic [3:0]  awuser;    // User signal
    rand bit          awlock;    // Lock type

    //Ace  signals
    rand logic [2:0]  awsnoop;   // Snoop type
    rand logic [1:0]  awdomain;  // Domain
    rand logic [1:0]  awbar;     // Barrier
    rand bit          awunique;  // Unique transaction

    // Data Write Channel
    rand logic [31:0] wdata;     // Write data
    rand logic [3:0]  wstrb;     // Write strobes
    rand logic [3:0]  wuser;     // User signal

    // Response Channel
    rand logic [3:0]  bid;       // Response ID
    rand logic [1:0]  bresp;     // Write response
    rand logic [3:0]  buser;     // User signal

    // Snoop Address Channel
    rand logic [31:0] acaddr;    // Snoop address
    rand logic [1:0]  acsnoop;   // Snoop type
    rand logic [2:0]  acprot;    // Protection type

    // Snoop Data Channel
    rand logic [31:0] cdata;     // Snoop data

    // Snoop Response Channel

    rand logic [4:0]  crresp;    // Snoop response

  // Constraints
  constraint data_size_c {
    awsize inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  constraint address_size_c {
    awaddr inside {[32'h0000_0000:32'hFFFF_FFFF]};
  }

  constraint snoop_data_c {
    awsnoop inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  constraint address_channel_delay_c {
    awlen inside {[0:255]};
  }

  constraint response_channel_delay_c {
    bresp inside {2'b00, 2'b01, 2'b10, 2'b11};
  }

  // Constructor
  function new(string name = "acewrite_item");
    super.new(name);
  endfunction

  // Add UVM macros to register the class with the UVM factory
  `uvm_object_utils_begin(acewrite_item)
    `uvm_field_int(awaddr ,     UVM_ALL_ON)
    `uvm_field_int(awburst,     UVM_ALL_ON)
    `uvm_field_int(awcache,     UVM_ALL_ON)
    `uvm_field_int(awid   ,     UVM_ALL_ON)
    `uvm_field_int(awlen  ,     UVM_ALL_ON)
    `uvm_field_int(awprot ,     UVM_ALL_ON)
    `uvm_field_int(awsize ,     UVM_ALL_ON)
    `uvm_field_int(awqos  ,     UVM_ALL_ON)
    `uvm_field_int(awregion,    UVM_ALL_ON)
    `uvm_field_int(awuser  ,    UVM_ALL_ON)
    `uvm_field_int(awlock  ,    UVM_ALL_ON)

    `uvm_field_int(awsnoop ,    UVM_ALL_ON)
    `uvm_field_int(awdomain,    UVM_ALL_ON)
    `uvm_field_int(awbar   ,    UVM_ALL_ON)
    `uvm_field_int(awunique,    UVM_ALL_ON)

    `uvm_field_int(wdata,       UVM_ALL_ON)
    `uvm_field_int(wstrb,       UVM_ALL_ON)
    `uvm_field_int(wuser,       UVM_ALL_ON)

    `uvm_field_int(bid ,        UVM_ALL_ON)
    `uvm_field_int(bresp,       UVM_ALL_ON)
    `uvm_field_int(buser,       UVM_ALL_ON)

    `uvm_field_int(acaddr ,     UVM_ALL_ON)
    `uvm_field_int(acsnoop,     UVM_ALL_ON)
    `uvm_field_int(acprot ,     UVM_ALL_ON)
    `uvm_field_int(cdata  ,     UVM_ALL_ON)
    `uvm_field_int(crresp ,     UVM_ALL_ON)
  `uvm_object_utils_end

endclass : acewrite_item