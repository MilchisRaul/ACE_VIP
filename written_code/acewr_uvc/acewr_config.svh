//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023 
//  File name             : acewr_config.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          26/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Config file for ACEWR Verification IP (UVC)
//  ======================================================================================================

class acewr_config extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual acewr_if v_if;

  `uvm_object_utils_begin(acewr_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "acewr_config");
    super.new(name);
    //Create the virtual interface
  endfunction : new

endclass : acewr_config