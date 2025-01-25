//  -----------------------------------------------------------------------------------------------------
//  Project Information:
//  
//  Designer              : Raul Milchis (RM)
//  Date                  : 16/02/2023 
//  File name             : ace_config.svh
//  Last modified+updates : 16/02/2023 (RM)
//                          25/04/2023 (RM) - Modified ACE Structure into
//                                            Read and Write separate ACE UVC's
//  Project               : ACE Protocol VIP
//
//  ------------------------------------------------------------------------------------------------------
//  Description           : Config file for ACE Read Verification IP (UVC)
//  ======================================================================================================

class aceread_config extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;
  
  agent_type_t agent_type = MASTER;

  virtual aceread_if v_if;

  `uvm_object_utils_begin(aceread_config)
    `uvm_field_enum(uvm_active_passive_enum, is_active,    UVM_DEFAULT)
    `uvm_field_enum(agent_type_t,           agent_type,   UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "aceread_config");
    super.new(name);
    //Create the virtual interface
  endfunction : new

endclass : aceread_config