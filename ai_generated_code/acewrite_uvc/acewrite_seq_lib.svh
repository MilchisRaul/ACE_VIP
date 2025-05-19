class acewrite_base_sequence extends uvm_sequence;

  `uvm_declare_p_sequencer(acewrite_sequencer)

  acewrite_item item_write;

  // Constructor
  function new(string name = "acewrite_base_sequence");
    super.new(name);
    item_write = acewrite_item::type_id::create("item_write");
  endfunction

endclass : acewrite_base_sequence

class ace_write_master_sequence extends acewrite_base_sequence;

  `uvm_object_utils (ace_write_master_sequence)

  // Constructor
  function new(string name = "ace_write_master_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    `uvm_info(get_type_name(), "Starting write sequence", UVM_LOW)

    start_item(item_write);
      if (!item_write.randomize() with {
        awid     inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
        awlen    inside {[0:255]};
        awsize   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        awburst  inside {2'b00, 2'b01, 2'b10, 2'b11};
        awcache  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
        awqos    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awregion inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        awsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
        awdomain inside {2'b00, 2'b01, 2'b10, 2'b11};
        awbar    inside {2'b00, 2'b01, 2'b10, 2'b11};
        wdata    inside {[32'h0000_0000:32'hFFFF_FFFF]};
        wstrb    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
        // wid      inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      }) begin
        `uvm_error(get_type_name(), "Randomization failed")
      end
    finish_item(item_write);
    `uvm_info(get_type_name(), "Completed write sequence", UVM_LOW)
  endtask : body

endclass : ace_write_master_sequence

class ace_write_slave_sequence extends acewrite_base_sequence;

  `uvm_object_utils (ace_write_slave_sequence)

  // Constructor
  function new(string name = "ace_write_slave_sequence");
    super.new(name);
  endfunction

  // Body task
  virtual task body();
    `uvm_info(get_type_name(), "Starting ACE Write Slave Sequence", UVM_LOW)

    start_item(item_write);
    if (!item_write.randomize() with {
      awaddr   inside {[32'h0000_0000:32'hFFFF_FFFF]};
      awlen    inside {[0:255]};
      awsize   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      awburst  inside {2'b00, 2'b01, 2'b10, 2'b11};
      awcache  inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      awprot   inside {3'b000, 3'b001, 3'b010, 3'b011, 3'b100, 3'b101, 3'b110, 3'b111};
      awqos    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      awregion inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      awsnoop  inside {2'b00, 2'b01, 2'b10, 2'b11};
      awdomain inside {2'b00, 2'b01, 2'b10, 2'b11};
      awbar    inside {2'b00, 2'b01, 2'b10, 2'b11};
      wdata    inside {[32'h0000_0000:32'hFFFF_FFFF]};
      wstrb    inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
      bresp    inside {2'b00, 2'b01, 2'b10, 2'b11};
      bid      inside {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001, 4'b1010, 4'b1011, 4'b1100, 4'b1101, 4'b1110, 4'b1111};
    }) begin
      `uvm_error(get_type_name(), "Randomization failed")
    end
    finish_item(item_write);

    `uvm_info(get_type_name(), "Completed ACE Write Slave Sequence", UVM_LOW)
  endtask : body

endclass : ace_write_slave_sequence